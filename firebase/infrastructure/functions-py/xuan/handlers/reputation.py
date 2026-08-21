"""信誉重算。基准实现：functions/src/reputation.ts

校验调用者身份与归属：只允许重算调用者本人的广场信誉计数。
若传入的 appUserId 与调用者自身 appUserId 不符，抛 permission-denied。
"""

from firebase_functions import https_fn

from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import XuanHttpsError, invalid_argument
from xuan.identity import require_auth_uid, resolve_app_user_id


def _permission_denied(message: str) -> XuanHttpsError:
    return XuanHttpsError("permission-denied", message)


def _recalculate_reputation_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    caller_app_user_id = resolve_app_user_id(uid)["appUserId"]

    app_user_id = data.get("appUserId")
    if not app_user_id or not isinstance(app_user_id, str):
        raise invalid_argument("appUserId 不能为空")

    if app_user_id != caller_app_user_id:
        raise _permission_denied("无权操作他人信誉")

    client = db()

    likes = client.collection(COLLECTIONS["likes"]) \
        .where("user_app_user_id", "==", app_user_id).get()
    like_count = len(list(likes))

    # ★ 坑 2：== None 只命中显式存了 null 的文档
    verifications = client.collection(COLLECTIONS["verifications"]) \
        .where("verifier_app_user_id", "==", app_user_id) \
        .where("revoked_at", "==", None).get()
    verification_count = len(list(verifications))

    profile_ref = client.collection(COLLECTIONS["profiles"]).document(app_user_id)
    if profile_ref.get().exists:
        # 已存在用 update：保留 display_name 等既有字段
        profile_ref.update({
            "playground_like_count": like_count,
            "playground_verification_count": verification_count,
        })
    else:
        # 不存在用 set，并补上 app_user_id
        profile_ref.set({
            "app_user_id": app_user_id,
            "playground_like_count": like_count,
            "playground_verification_count": verification_count,
        })

    return {
        "app_user_id": app_user_id,
        "playground_like_count": like_count,
        "playground_verification_count": verification_count,
    }


@https_fn.on_call(region=REGION)
def recalculate_reputation_py(req: https_fn.CallableRequest) -> dict:
    """重算某个用户的广场信誉计数。"""
    return _recalculate_reputation_impl(req.auth.uid if req.auth else None, req.data or {})
