"""内容举报。基准实现：functions/src/moderation.ts

⚠ **无幂等包装、无去重**：同一用户可对同一内容反复举报，每次产生一条新记录。
这是 TS 现状且对举报场景合理（次数可作严重程度信号），**不要"顺手"加去重**。
另注：本接口**不校验被举报的 post/reply 是否真实存在**。
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

    post_id = data.get("postId")
    reply_id = data.get("replyId")
    reported_user_id = data.get("reportedUserId")
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
        "status": "pending",
        "created_at": datetime.now(timezone.utc).isoformat(),
    }


@https_fn.on_call(region=REGION)
def report_content_py(req: https_fn.CallableRequest) -> dict:
    """举报一条帖子或回复。"""
    return _report_content_impl(req.auth.uid if req.auth else None, req.data or {})
