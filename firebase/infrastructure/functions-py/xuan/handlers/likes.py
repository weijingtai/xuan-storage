"""点赞。基准实现：functions/src/likes.ts

与 bookmarks 的两处不同：
  1. 目标二选一（postId 或 replyId），id 前缀随之不同
  2. 成功后要写 outbox 事件，供通知链路消费
"""

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.cache import (
    invalidate_guest_replies_cache,
    invalidate_playground_post_cache,
)
from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import invalid_argument, not_found
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id


def _set_like_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    identity = resolve_app_user_id(uid)
    app_user_id = identity["appUserId"]

    post_id = data.get("postId")
    reply_id = data.get("replyId")
    action = data.get("action")

    if not post_id and not reply_id:
        raise invalid_argument("postId 或 replyId 必须提供一个")
    if action not in ("like", "unlike"):
        raise invalid_argument("action 必须是 like 或 unlike")
    if post_id is not None and not isinstance(post_id, str):
        raise invalid_argument("postId 格式无效")
    if reply_id is not None and not isinstance(reply_id, str):
        raise invalid_argument("replyId 格式无效")

    client = db()
    # 注意：TS 版把存在性检查放在 withIdempotency **外面**（与 bookmarks 相反）
    if post_id:
        if not client.collection(COLLECTIONS["posts"]).document(post_id).get().exists:
            raise not_found("帖子不存在")
    if reply_id:
        if not client.collection(COLLECTIONS["replies"]).document(reply_id).get().exists:
            raise not_found("回复不存在")

    like_id = f"like_post_{uid}_{post_id}" if post_id else f"like_reply_{uid}_{reply_id}"
    target_type = "post" if post_id else "reply"

    def _write_outbox(event_type: str) -> None:
        ref = client.collection(COLLECTIONS["outbox"]).document()
        ref.set({
            "id": ref.id,
            "event_type": event_type,
            "post_id": post_id or None,
            "reply_id": reply_id or None,
            "user_app_user_id": app_user_id,
            "created_at": gcf.SERVER_TIMESTAMP,
        })

    def _run() -> dict:
        like_ref = client.collection(COLLECTIONS["likes"]).document(like_id)

        if action == "like":
            like_data = {
                "id": like_id,
                "user_provider_uid": uid,
                "user_app_user_id": app_user_id,
                "created_at": gcf.SERVER_TIMESTAMP,
            }
            if post_id:
                like_data["post_id"] = post_id
            if reply_id:
                like_data["reply_id"] = reply_id
            like_ref.set(like_data)
            _write_outbox("like_added")
            if post_id:
                invalidate_guest_replies_cache(post_id)
                invalidate_playground_post_cache(post_id)
            elif reply_id:
                r_snap = client.collection(COLLECTIONS["replies"]).document(reply_id).get()
                if r_snap.exists:
                    pid = (r_snap.to_dict() or {}).get("post_id")
                    invalidate_guest_replies_cache(pid)
                    invalidate_playground_post_cache(pid)
            return {"liked": True, "id": like_id, "target_type": target_type}

        # unlike：只有确实存在时才删除并发事件
        if like_ref.get().exists:
            like_ref.delete()
            _write_outbox("like_removed")
            if post_id:
                invalidate_guest_replies_cache(post_id)
                invalidate_playground_post_cache(post_id)
            elif reply_id:
                r_snap = client.collection(COLLECTIONS["replies"]).document(reply_id).get()
                if r_snap.exists:
                    pid = (r_snap.to_dict() or {}).get("post_id")
                    invalidate_guest_replies_cache(pid)
                    invalidate_playground_post_cache(pid)
        return {"liked": False, "id": like_id, "target_type": target_type}

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def set_like_py(req: https_fn.CallableRequest) -> dict:
    """点赞 / 取消点赞一个帖子或回复。"""
    uid = req.auth.uid if req.auth else None
    return _set_like_impl(uid, req.data or {})
