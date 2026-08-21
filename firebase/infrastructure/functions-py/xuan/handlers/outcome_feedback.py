"""最终反馈。基准实现：functions/src/outcome_feedback.ts

一条帖子同时只能有一条有效反馈（deleted_at 为 null）。
设置与撤销都要回写 posts.has_outcome_feedback。
"""

from datetime import datetime, timezone

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.cache import invalidate_guest_replies_cache
from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import XuanHttpsError, already_exists, invalid_argument, not_found
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _permission_denied(message: str) -> XuanHttpsError:
    return XuanHttpsError("permission-denied", message)


def _set_outcome_feedback_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    post_id = data.get("postId")
    desc = data.get("outcome_description")
    if not post_id or not isinstance(post_id, str):
        raise invalid_argument("postId 不能为空")
    if not desc or not isinstance(desc, str) or not desc.strip():
        raise invalid_argument("outcome_description 不能为空")

    def _run() -> dict:
        client = db()
        post_snap = client.collection(COLLECTIONS["posts"]).document(post_id).get()
        if not post_snap.exists or (post_snap.to_dict() or {}).get("status") != "active":
            raise not_found("帖子不存在或已失效")
        if (post_snap.to_dict() or {}).get("author_provider_uid") != uid:
            raise _permission_denied("只有帖子作者可以设置最终反馈")

        existing = list(client.collection(COLLECTIONS["outcome_feedback"])
                        .where("post_id", "==", post_id)
                        .where("deleted_at", "==", None).get())
        if existing:
            raise already_exists("已有有效的最终反馈")

        ref = client.collection(COLLECTIONS["outcome_feedback"]).document()
        now = gcf.SERVER_TIMESTAMP
        # deleted_at 必须**显式写 None**（★ 坑 2），否则 == None 查询命不中
        ref.set({
            "id": ref.id,
            "post_id": post_id,
            "author_provider_uid": uid,
            "author_app_user_id": app_user_id,
            "outcome_description": desc.strip(),
            "deleted_at": None,
            "created_at": now,
        })
        client.collection(COLLECTIONS["posts"]).document(post_id).update({
            "has_outcome_feedback": True,
        })
        invalidate_guest_replies_cache(post_id)

        return {
            "id": ref.id,
            "post_id": post_id,
            "author_app_user_id": app_user_id,
            "outcome_description": desc.strip(),
            "created_at": _now_iso(),
        }

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def set_outcome_feedback_py(req: https_fn.CallableRequest) -> dict:
    """帖子作者填写最终反馈。"""
    return _set_outcome_feedback_impl(req.auth.uid if req.auth else None, req.data or {})


def _revoke_outcome_feedback_impl(uid: str, data: dict) -> dict:
    """撤销最终反馈（软删）并回写帖子标志。"""
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    post_id = data.get("postId")
    if not post_id or not isinstance(post_id, str):
        raise invalid_argument("postId 不能为空")

    def _run() -> dict:
        client = db()
        # ★ 坑 5：用 author_app_user_id 匹配（不是 uid）
        found = list(client.collection(COLLECTIONS["outcome_feedback"])
                     .where("post_id", "==", post_id)
                     .where("author_app_user_id", "==", app_user_id)
                     .where("deleted_at", "==", None)
                     .limit(1).get())
        if not found:
            raise not_found("没有有效的最终反馈")

        now = gcf.SERVER_TIMESTAMP
        found[0].reference.update({"deleted_at": now})
        client.collection(COLLECTIONS["posts"]).document(post_id).update({
            "has_outcome_feedback": False,
        })
        invalidate_guest_replies_cache(post_id)
        return {"success": True}

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def revoke_outcome_feedback_py(req: https_fn.CallableRequest) -> dict:
    """撤销自己填写的最终反馈。"""
    return _revoke_outcome_feedback_impl(req.auth.uid if req.auth else None, req.data or {})

