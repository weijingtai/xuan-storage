"""身份查询 callable。基准实现：functions/src/identity.ts 末段。

只是 P1 已交付的 resolve_app_user_id 的一层壳。
**不接受任何客户端传入的身份值** —— 身份完全由服务端从 auth uid 派生。
"""

from firebase_functions import https_fn

from xuan.config import REGION
from xuan.identity import require_auth_uid, resolve_app_user_id


def _resolve_my_identity_impl(uid: str) -> dict:
    uid = require_auth_uid(uid)
    identity = resolve_app_user_id(uid)
    return {
        "appUserId": identity["appUserId"],
        "publicPresentationId": identity["publicPresentationId"],
        "publicDisplayAlias": identity["publicDisplayAlias"],
    }


@https_fn.on_call(region=REGION)
def resolve_my_identity_py(req: https_fn.CallableRequest) -> dict:
    """返回当前登录用户的应用内身份。"""
    return _resolve_my_identity_impl(req.auth.uid if req.auth else None)
