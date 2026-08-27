"""内容举报。基准实现：functions/src/moderation.ts

支持举报帖子（report_post_py）、回复（report_reply_py）以及通用内容（report_content_py）。
⚠ **无幂等包装、无去重**：同一用户可对同一内容反复举报，每次产生一条新记录。
这是 TS 现状且对举报场景合理（次数可作严重程度信号），**不要"顺手"加去重**。
另注：本接口**不强制校验被举报的 post/reply 是否真实存在**。
"""

from datetime import datetime, timezone

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import invalid_argument
from xuan.handlers._guard import guard_rate_limit
from xuan.identity import require_auth_uid, resolve_app_user_id


def _report_content_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "report_content", data.get("idempotency_key"))

    post_id = data.get("postId") or data.get("post_id")
    reply_id = data.get("replyId") or data.get("reply_id")
    reported_user_id = data.get("reportedUserId") or data.get("reported_user_id")
    reason = data.get("reason")
    description = data.get("description")

    if not post_id and not reply_id:
        raise invalid_argument("postId 或 replyId 必须提供一个")
    if not reported_user_id or not isinstance(reported_user_id, str):
        raise invalid_argument("reportedUserId 不能为空")
    if not reason or not isinstance(reason, str):
        raise invalid_argument("reason 不能为空")

    ref = db().collection(COLLECTIONS["reports"]).document()
    ref.set({
        "id": ref.id,
        # 未给出的一侧显式写 null，便于后续按字段查询
        "post_id": post_id if post_id else None,
        "reply_id": reply_id if reply_id else None,
        "reporter_provider_uid": uid,
        "reporter_app_user_id": app_user_id,
        "reported_user_id": reported_user_id,
        "reason": reason,
        "description": description if description is not None else None,
        "status": "pending",
        "created_at": gcf.SERVER_TIMESTAMP,
    })

    return {
        "id": ref.id,
        "report_id": ref.id,
        "status": "pending",
        "created_at": datetime.now(timezone.utc).isoformat(),
    }


def _report_post_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "report_post", data.get("idempotency_key"))

    post_id = data.get("postId") or data.get("post_id")
    reason = data.get("reason")
    description = data.get("description")
    reported_user_id = data.get("reportedUserId") or data.get("reported_user_id")

    if not post_id or not isinstance(post_id, str) or not post_id.strip():
        raise invalid_argument("postId 不能为空")
    if not reason or not isinstance(reason, str) or not reason.strip():
        raise invalid_argument("reason 不能为空")

    client = db()
    if not reported_user_id:
        p_snap = client.collection(COLLECTIONS["posts"]).document(post_id).get()
        if p_snap.exists:
            p_data = p_snap.to_dict() or {}
            reported_user_id = p_data.get("author_app_user_id") or p_data.get("authorAppUserId") or ""

    ref = client.collection(COLLECTIONS["reports"]).document()
    ref.set({
        "id": ref.id,
        "post_id": post_id.strip(),
        "reply_id": None,
        "reporter_provider_uid": uid,
        "reporter_app_user_id": app_user_id,
        "reported_user_id": reported_user_id if reported_user_id else None,
        "reason": reason.strip(),
        "description": description.strip() if (isinstance(description, str) and description.strip()) else None,
        "status": "pending",
        "created_at": gcf.SERVER_TIMESTAMP,
    })

    return {
        "id": ref.id,
        "report_id": ref.id,
        "status": "pending",
        "created_at": datetime.now(timezone.utc).isoformat(),
    }


def _report_reply_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "report_reply", data.get("idempotency_key"))

    reply_id = data.get("replyId") or data.get("reply_id")
    reason = data.get("reason")
    description = data.get("description")
    reported_user_id = data.get("reportedUserId") or data.get("reported_user_id")

    if not reply_id or not isinstance(reply_id, str) or not reply_id.strip():
        raise invalid_argument("replyId 不能为空")
    if not reason or not isinstance(reason, str) or not reason.strip():
        raise invalid_argument("reason 不能为空")

    client = db()
    if not reported_user_id:
        r_snap = client.collection(COLLECTIONS["replies"]).document(reply_id).get()
        if r_snap.exists:
            r_data = r_snap.to_dict() or {}
            reported_user_id = r_data.get("author_app_user_id") or r_data.get("authorAppUserId") or ""

    ref = client.collection(COLLECTIONS["reports"]).document()
    ref.set({
        "id": ref.id,
        "post_id": None,
        "reply_id": reply_id.strip(),
        "reporter_provider_uid": uid,
        "reporter_app_user_id": app_user_id,
        "reported_user_id": reported_user_id if reported_user_id else None,
        "reason": reason.strip(),
        "description": description.strip() if (isinstance(description, str) and description.strip()) else None,
        "status": "pending",
        "created_at": gcf.SERVER_TIMESTAMP,
    })

    return {
        "id": ref.id,
        "report_id": ref.id,
        "status": "pending",
        "created_at": datetime.now(timezone.utc).isoformat(),
    }


@https_fn.on_call(region=REGION)
def report_content_py(req: https_fn.CallableRequest) -> dict:
    """举报一条帖子或回复（通用入口）。"""
    return _report_content_impl(req.auth.uid if req.auth else None, req.data or {})


@https_fn.on_call(region=REGION)
def report_post_py(req: https_fn.CallableRequest) -> dict:
    """举报一条帖子。"""
    return _report_post_impl(req.auth.uid if req.auth else None, req.data or {})


@https_fn.on_call(region=REGION)
def report_reply_py(req: https_fn.CallableRequest) -> dict:
    """举报一条回复。"""
    return _report_reply_impl(req.auth.uid if req.auth else None, req.data or {})
