"""收藏。基准实现：functions/src/bookmarks.ts"""

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import invalid_argument, not_found
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id


def _set_bookmark_impl(uid: str, data: dict) -> dict:
    """纯逻辑部分，与 Firebase 运行时解耦，便于直接单测。"""
    uid = require_auth_uid(uid)
    identity = resolve_app_user_id(uid)
    app_user_id = identity["appUserId"]

    post_id = data.get("postId")
    action = data.get("action")

    if not post_id or not isinstance(post_id, str):
        raise invalid_argument("postId 不能为空")
    if action not in ("bookmark", "unbookmark"):
        raise invalid_argument("action 必须是 bookmark 或 unbookmark")

    def _run() -> dict:
        client = db()
        post_snap = client.collection(COLLECTIONS["posts"]).document(post_id).get()
        if not post_snap.exists:
            raise not_found("帖子不存在")

        bookmark_id = f"bookmark_{uid}_{post_id}"
        ref = client.collection(COLLECTIONS["bookmarks"]).document(bookmark_id)

        if action == "bookmark":
            ref.set({
                "id": bookmark_id,
                "post_id": post_id,
                "user_provider_uid": uid,
                "user_app_user_id": app_user_id,
                "created_at": gcf.SERVER_TIMESTAMP,
            })
            return {"bookmarked": True, "id": bookmark_id}

        ref.delete()
        return {"bookmarked": False, "id": bookmark_id}

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def set_bookmark_py(req: https_fn.CallableRequest) -> dict:
    """收藏 / 取消收藏一个帖子。"""
    uid = req.auth.uid if req.auth else None
    return _set_bookmark_impl(uid, req.data or {})
