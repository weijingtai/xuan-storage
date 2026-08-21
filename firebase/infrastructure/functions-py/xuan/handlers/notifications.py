"""通知分发。基准实现：functions/src/notifications.ts

结构上与 TS 的最大差异：业务逻辑抽成纯函数 `handle_outbox_event`，
trigger 装饰器只是薄壳（见 Task 4）。这样测试可以直接调它，
不必模拟 Firebase 的事件投递。行为本身完全一致。
"""

from typing import Optional

from firebase_functions import firestore_fn
from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, REGION, db
from xuan.push import send_push_notification


def _already_notified(event_id: str) -> bool:
    """★ 坑 2：trigger 是 at-least-once，同一 outbox 文档可能被投递多次。"""
    existing = db().collection(COLLECTIONS["notifications"]) \
        .where("notification_event_id", "==", event_id).get()
    return bool(list(existing))


def _write_notification(event_id: str, recipient: str, payload: dict) -> str:
    ref = db().collection(COLLECTIONS["notifications"]).document()
    ref.set({
        "id": ref.id,
        "notification_event_id": event_id,
        "recipient_app_user_id": recipient,
        "is_read": False,
        "created_at": gcf.SERVER_TIMESTAMP,
        **payload,
    })
    return ref.id


def _author_of(collection_key: str, doc_id: str) -> Optional[str]:
    if not doc_id:
        return None
    snap = db().collection(COLLECTIONS[collection_key]).document(doc_id).get()
    if not snap.exists:
        return None
    return (snap.to_dict() or {}).get("author_app_user_id")


def handle_outbox_event(event_id: str, data: dict) -> Optional[str]:
    """处理一条 outbox 事件。返回新建通知的 id；未产生通知则返回 None。

    ★ 五个分支中只有 verification_revoked 不发推送（坑 1）。
    """
    data = data or {}
    event_type = data.get("event_type")

    if event_type == "reply_verified":
        recipient = _author_of("replies", data.get("reply_id"))
        if not recipient or _already_notified(event_id):
            return None
        nid = _write_notification(event_id, recipient, {
            "type": "reply_verified",
            "post_id": data.get("post_id"),
            "reply_id": data.get("reply_id"),
            "actor_app_user_id": data.get("verifier_app_user_id"),
        })
        send_push_notification(recipient, "你的回复被应验了", "有人应验了你的占卜回复", {
            "type": "reply_verified",
            "post_id": data.get("post_id") or "",
            "reply_id": data.get("reply_id") or "",
        })
        return nid

    if event_type == "verification_revoked":
        recipient = _author_of("replies", data.get("reply_id"))
        if not recipient or _already_notified(event_id):
            return None
        # ★ 坑 1：只写记录，**不推送** —— 撤销应验不该再打扰对方
        return _write_notification(event_id, recipient, {
            "type": "verification_revoked",
            "post_id": data.get("post_id"),
            "reply_id": data.get("reply_id"),
            "actor_app_user_id": data.get("verifier_app_user_id"),
        })

    if event_type == "like_added":
        post_id = data.get("post_id")
        reply_id = data.get("reply_id")
        liker = data.get("user_app_user_id")

        recipient = _author_of("posts", post_id) if post_id else (
            _author_of("replies", reply_id) if reply_id else None)

        # ★ 坑 3：自赞不通知
        if not recipient or recipient == liker or _already_notified(event_id):
            return None

        nid = _write_notification(event_id, recipient, {
            "type": "like_added",
            "post_id": post_id if post_id else None,
            "reply_id": reply_id if reply_id else None,
            "actor_app_user_id": liker,
        })
        send_push_notification(
            recipient, "有人赞了你",
            "有人赞了你的帖子" if post_id else "有人赞了你的回复",
            {"type": "like_added", "post_id": post_id or "", "reply_id": reply_id or ""},
        )
        return nid

    if event_type == "dm_message":
        recipient = data.get("recipient_app_user_id")
        if not recipient or _already_notified(event_id):
            return None
        conversation_id = data.get("conversation_id")
        nid = _write_notification(event_id, recipient, {
            "type": "dm_message",
            "conversation_id": conversation_id,
            "message_id": data.get("message_id"),
            "actor_app_user_id": data.get("sender_app_user_id"),
        })
        send_push_notification(recipient, "新消息", "你收到了一条私信", {
            "type": "dm_message", "conversation_id": conversation_id or "",
        })
        return nid

    if event_type == "dm_accepted":
        conversation_id = data.get("conversation_id")
        acceptor = data.get("user_app_user_id")
        snap = db().collection(COLLECTIONS["conversations"]).document(conversation_id).get() \
            if conversation_id else None
        if snap is None or not snap.exists:
            return None
        recipient = (snap.to_dict() or {}).get("initiated_by")

        # ★ 坑 3 的第二处：自己接受自己不通知
        if not recipient or recipient == acceptor or _already_notified(event_id):
            return None

        nid = _write_notification(event_id, recipient, {
            "type": "dm_accepted",
            "conversation_id": conversation_id,
            "actor_app_user_id": acceptor,
        })
        send_push_notification(recipient, "私信请求被接受", "对方接受了你的私信请求", {
            "type": "dm_accepted", "conversation_id": conversation_id or "",
        })
        return nid

    # 未知事件类型：静默忽略，与 TS 的 switch 无 default 一致
    return None


@firestore_fn.on_document_created(
    document=COLLECTIONS["outbox"] + "/{docId}",
    region=REGION,
)
def on_outbox_created_py(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    """outbox 文档创建时分发通知。**薄壳：只解事件，逻辑在 handle_outbox_event。**"""
    snapshot = event.data
    if snapshot is None:
        return
    handle_outbox_event(event.params["docId"], snapshot.to_dict() or {})
