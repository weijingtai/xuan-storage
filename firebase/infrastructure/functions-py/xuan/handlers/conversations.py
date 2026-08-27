"""私聊与拉黑。基准实现：functions/src/conversations.ts"""

from datetime import datetime, timezone

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import (
    XuanHttpsError, already_exists, failed_precondition, invalid_argument, not_found,
)
from xuan.handlers._guard import guard_rate_limit
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _permission_denied(message: str) -> XuanHttpsError:
    return XuanHttpsError("permission-denied", message)


def _make_participant_pair_key(a: str, b: str) -> str:
    """两个 app_user_id 排序后拼接作为确定性配对键，保证 a->b 与 b->a 得到同一个键。"""
    return ":".join(sorted([a, b]))


def _send_dm_request_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "send_dm_request", data.get("idempotency_key"))

    target = data.get("targetAppUserId")
    initial = data.get("initialMessage")

    if not target or not isinstance(target, str):
        raise invalid_argument("targetAppUserId 不能为空")
    if not initial or not isinstance(initial, str) or not initial.strip():
        raise invalid_argument("initialMessage 不能为空")
    if target == app_user_id:
        raise invalid_argument("不能给自己发私聊申请")

    pair_key = _make_participant_pair_key(app_user_id, target)

    def _run() -> dict:
        client = db()

        # 1. 优先使用确定性配对键 participant_pair_key 点查（limit=1）
        matched = client.collection(COLLECTIONS["conversations"]) \
            .where("participant_pair_key", "==", pair_key).limit(1).get()
        if list(matched):
            raise already_exists("对话已存在")

        # 2. 存量旧数据兜底：若旧会话尚未写入 participant_pair_key，回落到 array_contains 扫描
        mine = client.collection(COLLECTIONS["conversations"]) \
            .where("participants", "array_contains", app_user_id).get()
        for doc in mine:
            if target in (doc.to_dict() or {}).get("participants", []):
                # 惰性回填 participant_pair_key
                try:
                    doc.reference.update({"participant_pair_key": pair_key})
                except Exception:
                    pass
                raise already_exists("对话已存在")

        conv_ref = client.collection(COLLECTIONS["conversations"]).document()
        now = gcf.SERVER_TIMESTAMP
        conv_ref.set({
            "id": conv_ref.id,
            "participant_pair_key": pair_key,
            "participants": [app_user_id, target],
            "participant_a_provider_uid": uid,
            "participant_a_app_user_id": app_user_id,
            "participant_b_app_user_id": target,
            "status": "pending",
            "initiated_by": app_user_id,
            "created_at": now,
            "updated_at": now,
        })

        msg_ref = client.collection(COLLECTIONS["messages"]).document()
        msg_ref.set({
            "id": msg_ref.id,
            "conversation_id": conv_ref.id,
            "sender_provider_uid": uid,
            "sender_app_user_id": app_user_id,
            "recipient_app_user_id": target,
            "text": initial.strip(),
            "type": "dm_request",
            "created_at": now,
            "sent_at": now,
        })

        return {
            "conversation_id": conv_ref.id,
            "status": "pending",
            "participants": [app_user_id, target],
            "initiated_by": app_user_id,
            "created_at": _now_iso(),
        }

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


def _respond_dm_request_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    conv_id = data.get("conversationId")
    accept = data.get("accept")

    if not conv_id or not isinstance(conv_id, str):
        raise invalid_argument("conversationId 不能为空")
    # 严格布尔：Python 里 1/0 也是 int，但 TS 要求 typeof === 'boolean'
    if not isinstance(accept, bool):
        raise invalid_argument("accept 必须是布尔值")

    def _run() -> dict:
        client = db()
        ref = client.collection(COLLECTIONS["conversations"]).document(conv_id)
        snap = ref.get()
        if not snap.exists:
            raise not_found("对话不存在")

        conv = snap.to_dict() or {}
        if app_user_id not in conv.get("participants", []):
            raise _permission_denied("不是对话参与者")
        if conv.get("initiated_by") == app_user_id:
            raise _permission_denied("不能响应自己发起的请求")

        now = gcf.SERVER_TIMESTAMP
        if accept:
            ref.update({"status": "active", "updated_at": now})
            outbox_ref = client.collection(COLLECTIONS["outbox"]).document()
            outbox_ref.set({
                "id": outbox_ref.id,
                "event_type": "dm_accepted",
                "conversation_id": conv_id,
                "user_app_user_id": app_user_id,
                "created_at": now,
            })
        else:
            # 拒绝**不发**通知事件
            ref.update({"status": "declined", "updated_at": now})

        return {
            "success": True,
            "conversation_id": conv_id,
            "status": "active" if accept else "declined",
            "participants": conv.get("participants", []),
            "initiated_by": conv.get("initiated_by"),
            "created_at": _now_iso(),
        }

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def send_dm_request_py(req: https_fn.CallableRequest) -> dict:
    """发起私聊申请。"""
    return _send_dm_request_impl(req.auth.uid if req.auth else None, req.data or {})


@https_fn.on_call(region=REGION)
def respond_dm_request_py(req: https_fn.CallableRequest) -> dict:
    """接受或拒绝私聊申请。"""
    return _respond_dm_request_impl(req.auth.uid if req.auth else None, req.data or {})


def _send_message_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "send_message", data.get("idempotency_key"))

    conv_id = data.get("conversationId")
    text = data.get("text")

    if not conv_id or not isinstance(conv_id, str):
        raise invalid_argument("conversationId 不能为空")
    if not text or not isinstance(text, str) or not text.strip():
        raise invalid_argument("text 不能为空")

    def _run() -> dict:
        client = db()
        ref = client.collection(COLLECTIONS["conversations"]).document(conv_id)
        snap = ref.get()
        if not snap.exists:
            raise not_found("对话不存在")

        conv = snap.to_dict() or {}
        # 顺序与 TS 一致：先判状态，再判参与者
        if conv.get("status") != "active":
            raise failed_precondition("对话未激活")
        participants = conv.get("participants", [])
        if app_user_id not in participants:
            raise _permission_denied("不是对话参与者")

        other = next((p for p in participants if p != app_user_id), None)

        # 拦截方向：**对方拉黑了我**。反方向（我拉黑对方）不拦。
        blocks = client.collection(COLLECTIONS["blocks"]) \
            .where("blocker_app_user_id", "==", other) \
            .where("blocked_app_user_id", "==", app_user_id).get()
        if list(blocks):
            raise _permission_denied("对方已将你拉黑")

        now = gcf.SERVER_TIMESTAMP
        msg_ref = client.collection(COLLECTIONS["messages"]).document()
        msg_ref.set({
            "id": msg_ref.id,
            "conversation_id": conv_id,
            "sender_provider_uid": uid,
            "sender_app_user_id": app_user_id,
            "recipient_app_user_id": other,
            "text": text.strip(),
            "type": "message",
            "created_at": now,
            "sent_at": now,
        })
        ref.update({"updated_at": now})

        outbox_ref = client.collection(COLLECTIONS["outbox"]).document()
        outbox_ref.set({
            "id": outbox_ref.id,
            "event_type": "dm_message",
            "conversation_id": conv_id,
            "sender_app_user_id": app_user_id,
            "recipient_app_user_id": other,
            "message_id": msg_ref.id,
            "created_at": now,
        })

        return {
            "message_id": msg_ref.id,
            "conversation_id": conv_id,
            "sender_app_user_id": app_user_id,
            "text": text.strip(),
            "created_at": _now_iso(),
        }

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def send_message_py(req: https_fn.CallableRequest) -> dict:
    """在已激活的会话里发消息。"""
    return _send_message_impl(req.auth.uid if req.auth else None, req.data or {})


def _block_user_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    target = data.get("targetAppUserId") or data.get("target_app_user_id")
    if not target or not isinstance(target, str) or not target.strip():
        raise invalid_argument("targetAppUserId 不能为空")
    target = target.strip()
    if target == app_user_id:
        raise invalid_argument("不能拉黑自己")

    def _run() -> dict:
        client = db()
        doc_id = f"block_{app_user_id}_{target}"
        doc_ref = client.collection(COLLECTIONS["blocks"]).document(doc_id)

        @gcf.transactional
        def _tx_block(tx):
            snap = doc_ref.get(transaction=tx)
            if snap.exists:
                # ★ 坑 6：已拉黑直接返回，**不落第二条记录**，返回体多一个字段
                return {"blocked": True, "already_blocked": True}

            # 存量旧 ID 记录兜底检查
            existing = client.collection(COLLECTIONS["blocks"]) \
                .where("blocker_app_user_id", "==", app_user_id) \
                .where("blocked_app_user_id", "==", target).get()
            if list(existing):
                return {"blocked": True, "already_blocked": True}

            tx.set(doc_ref, {
                "id": doc_id,
                "blocker_provider_uid": uid,
                "blocker_app_user_id": app_user_id,
                "blocked_app_user_id": target,
                "created_at": gcf.SERVER_TIMESTAMP,
            })
            return {"blocked": True}

        return _tx_block(client.transaction())

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


def _unblock_user_impl(uid: str, data: dict) -> dict:
    """取消拉黑。校验 targetAppUserId 必填且不可为自己。"""
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    target = data.get("targetAppUserId") or data.get("target_app_user_id")
    if not target or not isinstance(target, str) or not target.strip():
        raise invalid_argument("targetAppUserId 不能为空")
    target = target.strip()
    if target == app_user_id:
        raise invalid_argument("不能对自身执行解除拉黑")

    def _run() -> dict:
        client = db()
        doc_id = f"block_{app_user_id}_{target}"
        doc_ref = client.collection(COLLECTIONS["blocks"]).document(doc_id)

        removed = 0

        @gcf.transactional
        def _tx_unblock(tx):
            snap = doc_ref.get(transaction=tx)
            if snap.exists:
                tx.delete(doc_ref)
                return 1
            return 0

        removed += _tx_unblock(client.transaction())

        # 存量历史未对齐固定 ID 的旧记录一并清理
        rows = list(client.collection(COLLECTIONS["blocks"])
                    .where("blocker_app_user_id", "==", app_user_id)
                    .where("blocked_app_user_id", "==", target).get())
        for doc in rows:
            if doc.id != doc_id:
                doc.reference.delete()
                removed += 1
        return {"unblocked": True, "removed": removed}

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def block_user_py(req: https_fn.CallableRequest) -> dict:
    """拉黑某人。"""
    return _block_user_impl(req.auth.uid if req.auth else None, req.data or {})


@https_fn.on_call(region=REGION)
def unblock_user_py(req: https_fn.CallableRequest) -> dict:
    """取消拉黑。"""
    return _unblock_user_impl(req.auth.uid if req.auth else None, req.data or {})


