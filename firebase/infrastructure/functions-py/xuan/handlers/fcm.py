"""FCM 推送令牌注册与注销。基准实现：functions/src/fcm.ts

两个 callable 都**无幂等包装**：文档 id 由 uid + token 确定性拼出，
重复注册即覆盖，注销即删除，天然幂等。
"""

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import invalid_argument
from xuan.identity import require_auth_uid, resolve_app_user_id


def _register_fcm_token_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    token = data.get("token")
    if not token or not isinstance(token, str):
        raise invalid_argument("token 不能为空")

    # ★ 坑 3：TS 用 `platform ?? 'unknown'`，是空值合并不是逻辑或。
    # 空字符串是有效值，必须保留 —— 用 `or` 会把它错误地替换掉。
    platform = data.get("platform")
    platform = "unknown" if platform is None else platform

    token_id = f"fcm_{uid}_{token}"
    now = gcf.SERVER_TIMESTAMP

    db().collection(COLLECTIONS["fcm_tokens"]).document(token_id).set({
        "id": token_id,
        "provider_uid": uid,
        "app_user_id": app_user_id,
        "token": token,
        "platform": platform,
        "registered_at": now,
        "last_used_at": now,
    })

    return {"success": True, "token_id": token_id}


def _unregister_fcm_token_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)

    token = data.get("token")
    if not token or not isinstance(token, str):
        raise invalid_argument("token 不能为空")

    # 不校验存在性，直接删 —— 与 TS 一致，天然幂等
    db().collection(COLLECTIONS["fcm_tokens"]).document(f"fcm_{uid}_{token}").delete()
    return {"success": True}


@https_fn.on_call(region=REGION)
def register_fcm_token_py(req: https_fn.CallableRequest) -> dict:
    """注册本设备的推送令牌。"""
    return _register_fcm_token_impl(req.auth.uid if req.auth else None, req.data or {})


@https_fn.on_call(region=REGION)
def unregister_fcm_token_py(req: https_fn.CallableRequest) -> dict:
    """注销本设备的推送令牌。"""
    return _unregister_fcm_token_impl(req.auth.uid if req.auth else None, req.data or {})
