"""通知订阅与推送偏好设置。

管理用户的通知推送偏好（例如 @ 策略、作者发帖提醒、互动通知开关等）。
"""

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import invalid_argument
from xuan.handlers._guard import guard_rate_limit
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id


def _set_notification_preference_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "set_notification_preference", data.get("idempotency_key"))

    # 提取所有有效的偏好设置字段（排除 idempotency_key）
    ignored_keys = {"idempotency_key", "idempotencyKey"}
    prefs = {}

    if "preferences" in data and isinstance(data["preferences"], dict):
        prefs.update(data["preferences"])
    if "preference" in data and isinstance(data["preference"], dict):
        prefs.update(data["preference"])

    for k, v in data.items():
        if k not in ignored_keys and k not in ("preferences", "preference"):
            prefs[k] = v

    if not prefs:
        raise invalid_argument("至少提供一个通知偏好设置")

    def _run() -> dict:
        client = db()
        doc_ref = client.collection(COLLECTIONS["subscriptions"]).document(app_user_id)

        update_doc = {
            "id": app_user_id,
            "user_app_user_id": app_user_id,
            "user_provider_uid": uid,
            "preferences": prefs,
            "updated_at": gcf.SERVER_TIMESTAMP,
        }
        for k, v in prefs.items():
            update_doc[k] = v

        doc_ref.set(update_doc, merge=True)

        return {
            "success": True,
            "app_user_id": app_user_id,
            "preferences": prefs,
        }

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def set_notification_preference_py(req: https_fn.CallableRequest) -> dict:
    """设置用户通知推送偏好。"""
    return _set_notification_preference_impl(req.auth.uid if req.auth else None, req.data or {})
