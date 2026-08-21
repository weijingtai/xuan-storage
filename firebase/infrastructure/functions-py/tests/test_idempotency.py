"""幂等中间件。对应 TS 侧 withIdempotency。

这是整个 P1 语义最密的一处：五条分支 + 失败清理，
漏任何一条都会在生产上表现为「偶发重复执行」或「某个 key 永久卡死」。
"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.idempotency import with_idempotency


def test_无_key_直接执行不留记录(clean_collections):
    calls = []
    got = with_idempotency(None, "h1", lambda: (calls.append(1), {"ok": True})[1])
    assert got == {"ok": True}
    assert calls == [1]
    docs = list(clean_collections.collection(COLLECTIONS["idempotency"]).stream())
    assert docs == [], "无 key 时不应写幂等记录"


def test_首次执行并落记录(clean_collections):
    got = with_idempotency("k1", "h1", lambda: {"v": 1})
    assert got == {"v": 1}
    snap = clean_collections.collection(COLLECTIONS["idempotency"]).document("k1").get()
    assert snap.exists
    data = snap.to_dict()
    assert data["state"] == "completed"
    assert data["payload_hash"] == "h1"
    assert data["result"] == {"v": 1}


def test_同key同载荷重放不再执行(clean_collections):
    calls = []

    def fn():
        calls.append(1)
        return {"v": 1}

    first = with_idempotency("k2", "h1", fn)
    second = with_idempotency("k2", "h1", fn)
    assert first == second == {"v": 1}
    assert calls == [1], "重放必须命中缓存，不得二次执行"


def test_同key异载荷抛冲突(clean_collections):
    with_idempotency("k3", "h1", lambda: {"v": 1})
    with pytest.raises(XuanHttpsError) as e:
        with_idempotency("k3", "不同的hash", lambda: {"v": 2})
    assert e.value.code == "aborted"
    assert "conflict" in str(e.value).lower()


def test_running_态并发抛_unavailable(clean_collections):
    """已有 claim 但还没回填 result —— 另一个调用正在跑，绝不能重复执行。"""
    clean_collections.collection(COLLECTIONS["idempotency"]).document("k4").set({
        "idempotency_key": "k4",
        "payload_hash": "h1",
        "state": "running",
    })
    calls = []
    with pytest.raises(XuanHttpsError) as e:
        with_idempotency("k4", "h1", lambda: calls.append(1))
    assert e.value.code == "unavailable"
    assert calls == [], "running 态下业务逻辑一次都不能被调用"


def test_过期记录视为不存在(clean_collections):
    from datetime import datetime, timedelta, timezone

    clean_collections.collection(COLLECTIONS["idempotency"]).document("k5").set({
        "idempotency_key": "k5",
        "payload_hash": "老的hash",
        "state": "completed",
        "result": {"old": True},
        "expires_at": datetime.now(timezone.utc) - timedelta(minutes=1),
    })
    got = with_idempotency("k5", "新的hash", lambda: {"new": True})
    assert got == {"new": True}, "过期记录应被丢弃并重新执行"


def test_执行失败必须删除记录以便重试(clean_collections):
    def boom():
        raise RuntimeError("业务炸了")

    with pytest.raises(RuntimeError):
        with_idempotency("k6", "h1", boom)

    snap = clean_collections.collection(COLLECTIONS["idempotency"]).document("k6").get()
    assert not snap.exists, "失败后必须删除记录，否则该 key 永久卡死"

    # 删干净了才能重试成功
    assert with_idempotency("k6", "h1", lambda: {"retried": True}) == {"retried": True}
