"""用户关注与取关。

管理关注关系与 profiles 上的 following_count / followers_count 计数器。
采用固定 ID follow_${follower}_${following} 进行事务写入与幂等保护。
"""

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import invalid_argument
from xuan.handlers._guard import guard_rate_limit
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id


def _follow_user_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "follow_user", data.get("idempotency_key"))

    target = data.get("targetAppUserId") or data.get("target_app_user_id")
    if not target or not isinstance(target, str) or not target.strip():
        raise invalid_argument("targetAppUserId 不能为空")
    target = target.strip()
    if target == app_user_id:
        raise invalid_argument("不能关注自己")

    def _run() -> dict:
        client = db()
        follow_id = f"follow_{app_user_id}_{target}"
        follow_ref = client.collection(COLLECTIONS["follows"]).document(follow_id)

        @gcf.transactional
        def _tx_follow(tx):
            snap = follow_ref.get(transaction=tx)
            if snap.exists:
                return {"success": True, "following": True, "already_followed": True, "target_app_user_id": target}

            now = gcf.SERVER_TIMESTAMP
            tx.set(follow_ref, {
                "id": follow_id,
                "follower_app_user_id": app_user_id,
                "following_app_user_id": target,
                "follower_provider_uid": uid,
                "created_at": now,
            })

            caller_profile_ref = client.collection(COLLECTIONS["profiles"]).document(app_user_id)
            tx.set(caller_profile_ref, {
                "following_count": gcf.Increment(1),
                "updated_at": now,
            }, merge=True)

            target_profile_ref = client.collection(COLLECTIONS["profiles"]).document(target)
            tx.set(target_profile_ref, {
                "followers_count": gcf.Increment(1),
                "updated_at": now,
            }, merge=True)

            outbox_ref = client.collection(COLLECTIONS["outbox"]).document()
            tx.set(outbox_ref, {
                "id": outbox_ref.id,
                "event_type": "user_followed",
                "follower_app_user_id": app_user_id,
                "following_app_user_id": target,
                "created_at": now,
            })
            return {"success": True, "following": True, "target_app_user_id": target}

        return _tx_follow(client.transaction())

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


def _unfollow_user_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "unfollow_user", data.get("idempotency_key"))

    target = data.get("targetAppUserId") or data.get("target_app_user_id")
    if not target or not isinstance(target, str) or not target.strip():
        raise invalid_argument("targetAppUserId 不能为空")
    target = target.strip()
    if target == app_user_id:
        raise invalid_argument("不能取关自己")

    def _run() -> dict:
        client = db()
        follow_id = f"follow_{app_user_id}_{target}"
        follow_ref = client.collection(COLLECTIONS["follows"]).document(follow_id)

        @gcf.transactional
        def _tx_unfollow(tx):
            snap = follow_ref.get(transaction=tx)
            if not snap.exists:
                return {"success": True, "following": False, "already_unfollowed": True, "target_app_user_id": target}

            tx.delete(follow_ref)
            now = gcf.SERVER_TIMESTAMP

            caller_profile_ref = client.collection(COLLECTIONS["profiles"]).document(app_user_id)
            tx.set(caller_profile_ref, {
                "following_count": gcf.Increment(-1),
                "updated_at": now,
            }, merge=True)

            target_profile_ref = client.collection(COLLECTIONS["profiles"]).document(target)
            tx.set(target_profile_ref, {
                "followers_count": gcf.Increment(-1),
                "updated_at": now,
            }, merge=True)

            outbox_ref = client.collection(COLLECTIONS["outbox"]).document()
            tx.set(outbox_ref, {
                "id": outbox_ref.id,
                "event_type": "user_unfollowed",
                "follower_app_user_id": app_user_id,
                "following_app_user_id": target,
                "created_at": now,
            })
            return {"success": True, "following": False, "target_app_user_id": target}

        return _tx_unfollow(client.transaction())

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def follow_user_py(req: https_fn.CallableRequest) -> dict:
    """关注目标用户。"""
    return _follow_user_impl(req.auth.uid if req.auth else None, req.data or {})


@https_fn.on_call(region=REGION)
def unfollow_user_py(req: https_fn.CallableRequest) -> dict:
    """取消关注目标用户。"""
    return _unfollow_user_impl(req.auth.uid if req.auth else None, req.data or {})
