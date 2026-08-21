"""幂等执行包装器。对应 TS 侧 src/idempotency.ts 的 withIdempotency。

流程与 TS 版严格一致：
  1. key 为空          → 直接执行，不留记录
  2. 记录已过期        → 删除，当作不存在
  3. hash 相同且有结果 → 重放，返回缓存
  4. hash 相同但无结果 → 另一调用正在执行，抛 unavailable
  5. hash 不同         → 抛 aborted（冲突）
  6. 记录不存在        → 写 running 占位 → 执行 → 回填 completed
  7. 执行抛异常        → 删除记录（保证可重试）后原样抛出

第 4 与第 7 条最容易漏：漏 4 会并发重复执行，漏 7 会让该 key 永久卡死。
"""

from datetime import datetime, timedelta, timezone
from typing import Any, Callable, Optional

from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, db
from xuan.errors import conflict, unavailable


def _to_datetime(value: Any) -> Optional[datetime]:
    """Firestore 时间戳与原生 datetime 的兼容读取。"""
    if value is None:
        return None
    if isinstance(value, datetime):
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value
    to_dt = getattr(value, "to_datetime", None)
    if callable(to_dt):
        dt = to_dt()
        if dt is not None and dt.tzinfo is None:
            return dt.replace(tzinfo=timezone.utc)
        return dt
    return None


def with_idempotency(
    idempotency_key: Optional[str],
    payload_hash: str,
    fn: Callable[[], Any],
    ttl_minutes: int = 60,
) -> Any:
    """幂等执行。语义见模块 docstring。"""
    if not idempotency_key:
        return fn()

    client = db()
    doc_ref = client.collection(COLLECTIONS["idempotency"]).document(idempotency_key)
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=ttl_minutes)

    @gcf.transactional
    def _claim(tx) -> dict:
        snap = doc_ref.get(transaction=tx)
        if snap.exists:
            data = snap.to_dict() or {}
            exp = _to_datetime(data.get("expires_at"))

            if exp is not None and exp < datetime.now(timezone.utc):
                # 分支 2：过期，删掉后走下面的重新 claim
                tx.delete(doc_ref)
            elif data.get("payload_hash") == payload_hash:
                if data.get("result") is not None:
                    # 分支 3：重放
                    return {"kind": "replay", "result": data["result"]}
                # 分支 4：另一个调用已 claim 但未回填结果
                raise unavailable("idempotency command is in progress")
            else:
                # 分支 5：同 key 异载荷
                raise conflict(f"idempotency key conflict: {idempotency_key}")

        # 分支 6：写 running 占位
        tx.set(doc_ref, {
            "idempotency_key": idempotency_key,
            "payload_hash": payload_hash,
            "state": "running",
            "created_at": gcf.SERVER_TIMESTAMP,
            "expires_at": expires_at,
        })
        return {"kind": "execute", "expires_at": expires_at}

    decision = _claim(client.transaction())
    if decision["kind"] == "replay":
        return decision["result"]

    # 刻意放在事务外：Firestore 可能重跑事务回调，而业务逻辑含普通写入与 outbox，
    # 不可重复执行。上面已提交的 claim 会挡住并发调用。
    try:
        result = fn()
    except Exception:
        # 分支 7：失败必须清理，否则该 key 永远停在 running
        doc_ref.delete()
        raise

    doc_ref.set({
        "result": result,
        "state": "completed",
        "completed_at": gcf.SERVER_TIMESTAMP,
        "expires_at": decision.get("expires_at", expires_at),
    }, merge=True)
    return result
