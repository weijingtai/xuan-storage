"""个人资料。基准实现：functions/src/profiles.ts

安全要点：文档 id 与 provider uid 均由服务端派生，调用方无法指定 —— 因此
一个用户永远只能改自己的资料。
"""

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import invalid_argument
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id

# 入参名 → Firestore 字段名
_STRING_FIELDS = {
    "displayName": "display_name",
    "avatarUrl": "avatar_url",
    "bio": "bio",
}


def _update_my_profile_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    identity = resolve_app_user_id(uid)
    app_user_id = identity["appUserId"]

    update: dict = {"updated_at": gcf.SERVER_TIMESTAMP}

    for in_name, out_name in _STRING_FIELDS.items():
        if in_name in data:
            value = data[in_name]
            if not isinstance(value, str):
                raise invalid_argument(f"{in_name} 必须为字符串")
            update[out_name] = value

    if "commonTechniques" in data:
        value = data["commonTechniques"]
        if not isinstance(value, list) or any(not isinstance(x, str) for x in value):
            raise invalid_argument("commonTechniques 必须为字符串数组")
        update["common_techniques"] = value

    # 只有 updated_at 说明调用方一个业务字段都没给
    if len(update) == 1:
        raise invalid_argument("至少更新一个资料字段")

    def _run() -> dict:
        db().collection(COLLECTIONS["profiles"]).document(app_user_id).set(
            {**update, "user_provider_uid": uid},
            merge=True,
        )
        return {"appUserId": app_user_id, "success": True}

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def update_my_profile_py(req: https_fn.CallableRequest) -> dict:
    """更新当前登录用户自己的资料。"""
    uid = req.auth.uid if req.auth else None
    return _update_my_profile_impl(uid, req.data or {})
