"""回复。基准实现：functions/src/replies.ts

四个 callable 中只有两个 create 带幂等包装；edit/delete 本身幂等，照抄不加。
回复深度上限由 config.MAX_REPLY_DEPTH 控制（=1，即只有 depth 0 与 1）。
"""

from datetime import datetime, timezone

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.cache import invalidate_guest_replies_cache
from xuan.config import COLLECTIONS, MAX_REPLY_DEPTH, REGION, db
from xuan.errors import XuanHttpsError, failed_precondition, invalid_argument, not_found
from xuan.handlers._guard import guard_rate_limit
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _permission_denied(message: str) -> XuanHttpsError:
    return XuanHttpsError("permission-denied", message)


def _create_root_reply_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "create_root_reply", data.get("idempotency_key"))

    body = data.get("body")
    post_id = data.get("postId")
    if not body or not isinstance(body, str) or not body.strip():
        raise invalid_argument("body 不能为空")
    if not post_id or not isinstance(post_id, str):
        raise invalid_argument("postId 不能为空")

    def _run() -> dict:
        client = db()
        post_snap = client.collection(COLLECTIONS["posts"]).document(post_id).get()
        # 注意：不存在与已 tombstone 合并为同一个 not-found，不泄漏帖子是否存在过
        if not post_snap.exists or (post_snap.to_dict() or {}).get("status") != "active":
            raise not_found("帖子不存在或已失效")

        reply_ref = client.collection(COLLECTIONS["replies"]).document()
        now = gcf.SERVER_TIMESTAMP

        reply_data = {
            "id": reply_ref.id,
            "post_id": post_id,
            "root_reply_id": None,
            "reply_to_reply_id": None,
            "depth": 0,
            "author_provider_uid": uid,
            "author_app_user_id": app_user_id,
            "body": body.strip(),
            "is_tombstoned": False,
            "verification": None,
            "created_at": now,
            "updated_at": now,
            "technique_tags": data.get("techniqueTags") or [],
            "chart_attachment": data.get("chartAttachment"),
            "media_attachments": data.get("mediaAttachments") or [],
            "presentation_identity_id": f"user_{app_user_id}",
            "revisions": [],
            "idempotency_key": data.get("idempotency_key"),
        }
        reply_ref.set(reply_data)
        invalidate_guest_replies_cache(post_id)

        return {
            "id": reply_ref.id,
            "post_id": post_id,
            "root_reply_id": None,
            "reply_to_reply_id": None,
            "depth": 0,
            "author_app_user_id": app_user_id,
            "body": reply_data["body"],
            "is_tombstoned": False,
            "verification": None,
            "created_at": _now_iso(),
        }

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def create_root_reply_py(req: https_fn.CallableRequest) -> dict:
    """在帖子下发一条根回复。"""
    return _create_root_reply_impl(req.auth.uid if req.auth else None, req.data or {})


def _create_discussion_reply_impl(uid: str, data: dict) -> dict:
    """在某条根回复下发讨论回复（depth=1）。"""
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "create_discussion_reply", data.get("idempotency_key"))

    body = data.get("body")
    post_id = data.get("postId")
    root_reply_id = data.get("rootReplyId")
    reply_to_reply_id = data.get("replyToReplyId")

    if not body or not isinstance(body, str) or not body.strip():
        raise invalid_argument("body 不能为空")
    if not post_id or not isinstance(post_id, str):
        raise invalid_argument("postId 不能为空")
    if not root_reply_id or not isinstance(root_reply_id, str):
        raise invalid_argument("rootReplyId 不能为空")
    if MAX_REPLY_DEPTH <= 0:
        raise invalid_argument(f"回复深度最大为 {MAX_REPLY_DEPTH}")

    def _run() -> dict:
        client = db()
        root_snap = client.collection(COLLECTIONS["replies"]).document(root_reply_id).get()
        if not root_snap.exists:
            raise not_found("根回复不存在")

        root = root_snap.to_dict() or {}
        if root.get("depth") != 0:
            raise invalid_argument("目标回复不是根回复")
        if root.get("post_id") != post_id:
            raise invalid_argument("回复不属于该帖子")
        if root.get("is_tombstoned"):
            raise failed_precondition("根回复已被删除")

        if reply_to_reply_id is not None:
            if not isinstance(reply_to_reply_id, str):
                raise invalid_argument("replyToReplyId 必须为字符串")
            target_snap = client.collection(COLLECTIONS["replies"]).document(reply_to_reply_id).get()
            target = target_snap.to_dict() or {}
            # ★ 括号不可省（计划坑 5）。JS 里 && 优先级高于 ||，语义是：
            #   不存在 || 帖子不符 || (root_reply_id 不符 AND 被回复对象本身不是根回复)
            # 少了括号会让「直接回复根回复」这个最常见操作被误拒。
            if (not target_snap.exists
                    or target.get("post_id") != post_id
                    or (target.get("root_reply_id") != root_reply_id
                        and reply_to_reply_id != root_reply_id)):
                raise invalid_argument("被回复对象不属于该讨论树")

        reply_ref = client.collection(COLLECTIONS["replies"]).document()
        now = gcf.SERVER_TIMESTAMP

        reply_data = {
            "id": reply_ref.id,
            "post_id": post_id,
            "root_reply_id": root_reply_id,
            # 缺省回落到根回复
            "reply_to_reply_id": reply_to_reply_id if reply_to_reply_id is not None else root_reply_id,
            "depth": 1,
            "author_provider_uid": uid,
            "author_app_user_id": app_user_id,
            "body": body.strip(),
            "is_tombstoned": False,
            "verification": None,
            "created_at": now,
            "updated_at": now,
            # 讨论回复固定为空，不接受调用方传入（与 TS 一致）
            "technique_tags": [],
            "chart_attachment": None,
            "media_attachments": data.get("mediaAttachments") or [],
            "presentation_identity_id": f"user_{app_user_id}",
            "revisions": [],
            "idempotency_key": data.get("idempotency_key"),
        }
        reply_ref.set(reply_data)

        return {
            "id": reply_ref.id,
            "post_id": post_id,
            "root_reply_id": root_reply_id,
            "reply_to_reply_id": reply_data["reply_to_reply_id"],
            "depth": 1,
            "author_app_user_id": app_user_id,
            "body": reply_data["body"],
            "is_tombstoned": False,
            "verification": None,
            "created_at": _now_iso(),
        }

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def create_discussion_reply_py(req: https_fn.CallableRequest) -> dict:
    """在根回复下发讨论回复。"""
    return _create_discussion_reply_impl(req.auth.uid if req.auth else None, req.data or {})


def _edit_reply_impl(uid: str, data: dict) -> dict:
    """编辑回复。**无幂等包装**。"""
    uid = require_auth_uid(uid)
    reply_id = data.get("replyId")
    body = data.get("body")

    if (not reply_id or not isinstance(reply_id, str)
            or not body or not isinstance(body, str) or not body.strip()):
        raise invalid_argument("replyId 和 body 必填")

    client = db()
    ref = client.collection(COLLECTIONS["replies"]).document(reply_id)
    snap = ref.get()
    if not snap.exists:
        raise not_found("回复不存在")

    row = snap.to_dict() or {}
    if row.get("author_provider_uid") != uid:
        raise _permission_denied("只能编辑自己的回复")
    if row.get("is_tombstoned") is True:
        raise failed_precondition("回复已删除")

    update = {"body": body.strip(), "updated_at": gcf.SERVER_TIMESTAMP}
    if isinstance(data.get("techniqueTags"), list):
        update["technique_tags"] = data["techniqueTags"]
    # ⚠ TS 用 `chartAttachment !== undefined`：显式传 null 也会写入，
    # 与「键不存在」是两种情况。Python 用 in 判断键是否存在来对齐。
    if "chartAttachment" in data:
        update["chart_attachment"] = data["chartAttachment"]
    if isinstance(data.get("mediaAttachments"), list):
        update["media_attachments"] = data["mediaAttachments"]

    ref.update(update)
    invalidate_guest_replies_cache(row.get("post_id"))

    # 与 TS 的已知有意差异（计划坑 4）：哨兵不可序列化，回填 ISO 串
    merged = {**row, **update, "id": reply_id}
    merged["updated_at"] = _now_iso()
    merged["created_at"] = _now_iso()
    return merged


def _delete_reply_impl(uid: str, data: dict) -> dict:
    """软删回复。**无幂等包装**，且不校验当前是否已删（重复调用幂等）。"""
    uid = require_auth_uid(uid)
    reply_id = data.get("replyId")
    if not reply_id or not isinstance(reply_id, str):
        raise invalid_argument("replyId 不能为空")

    client = db()
    ref = client.collection(COLLECTIONS["replies"]).document(reply_id)
    snap = ref.get()
    if not snap.exists:
        raise not_found("回复不存在")
    if (snap.to_dict() or {}).get("author_provider_uid") != uid:
        raise _permission_denied("只能删除自己的回复")

    ref.update({"is_tombstoned": True, "updated_at": gcf.SERVER_TIMESTAMP})
    invalidate_guest_replies_cache((snap.to_dict() or {}).get("post_id"))
    return {"success": True}


@https_fn.on_call(region=REGION)
def edit_reply_py(req: https_fn.CallableRequest) -> dict:
    """编辑自己的回复。"""
    return _edit_reply_impl(req.auth.uid if req.auth else None, req.data or {})


@https_fn.on_call(region=REGION)
def delete_reply_py(req: https_fn.CallableRequest) -> dict:
    """软删自己的回复。"""
    return _delete_reply_impl(req.auth.uid if req.auth else None, req.data or {})


