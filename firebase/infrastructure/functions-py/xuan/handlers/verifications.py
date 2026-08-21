"""应验与撤销。基准实现：functions/src/verifications.ts

★ 应验与撤销都是**三处联动写入**：
  verifications 记录 / replies.verification 字段 / outbox 事件。
其中 replies.verification 是游客视图排序的第一顺位键（见 P3），漏写会导致
"应验了却不置顶"。
"""

from datetime import datetime, timezone

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.cache import invalidate_guest_replies_cache
from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import XuanHttpsError, invalid_argument, not_found
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id
from xuan.public_dto import to_iso_string


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _permission_denied(message: str) -> XuanHttpsError:
    return XuanHttpsError("permission-denied", message)


def _verify_root_reply_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    post_id = data.get("postId")
    root_reply_id = data.get("rootReplyId")
    if not post_id or not isinstance(post_id, str):
        raise invalid_argument("postId 不能为空")
    if not root_reply_id or not isinstance(root_reply_id, str):
        raise invalid_argument("rootReplyId 不能为空")

    def _run() -> dict:
        client = db()
        post_snap = client.collection(COLLECTIONS["posts"]).document(post_id).get()
        if not post_snap.exists or (post_snap.to_dict() or {}).get("status") != "active":
            raise not_found("帖子不存在或已失效")
        post = post_snap.to_dict() or {}
        if post.get("author_provider_uid") != uid:
            raise _permission_denied("只有帖子作者可以应验")

        reply_snap = client.collection(COLLECTIONS["replies"]).document(root_reply_id).get()
        if not reply_snap.exists:
            raise not_found("回复不存在")
        reply = reply_snap.to_dict() or {}

        # 顺序与 TS 一致：先判自证，再判深度与归属
        if reply.get("author_provider_uid") == uid:
            raise _permission_denied("不能应验自己的回复")
        if reply.get("depth") != 0:
            raise invalid_argument("只能应验根回复")
        if reply.get("post_id") != post_id:
            raise invalid_argument("回复不属于该帖子")

        existing = list(client.collection(COLLECTIONS["verifications"])
                        .where("post_id", "==", post_id)
                        .where("root_reply_id", "==", root_reply_id)
                        .where("revoked_at", "==", None).get())
        if existing:
            # ★ 坑 4：已应验则原样返回既有记录，不新增、不再发通知，返回体多 existing
            doc = existing[0]
            return {
                "id": doc.id,
                "post_id": post_id,
                "root_reply_id": root_reply_id,
                "verifier_app_user_id": app_user_id,
                "created_at": to_iso_string((doc.to_dict() or {}).get("created_at")),
                "existing": True,
            }

        ref = client.collection(COLLECTIONS["verifications"]).document()
        now = gcf.SERVER_TIMESTAMP

        # ① verifications：revoked_at 必须**显式写 None**（★ 坑 2）
        ref.set({
            "id": ref.id,
            "post_id": post_id,
            "root_reply_id": root_reply_id,
            "verifier_provider_uid": uid,
            "verifier_app_user_id": app_user_id,
            "revoked_at": None,
            "created_at": now,
        })

        # ② outbox
        outbox_ref = client.collection(COLLECTIONS["outbox"]).document()
        outbox_ref.set({
            "id": outbox_ref.id,
            "event_type": "reply_verified",
            "post_id": post_id,
            "reply_id": root_reply_id,
            "verifier_app_user_id": app_user_id,
            "created_at": now,
        })

        # ③ replies.verification —— 游客视图排序依赖它
        client.collection(COLLECTIONS["replies"]).document(root_reply_id).update({
            "verification": {
                "verifier_app_user_id": app_user_id,
                "verified_at": now,
            },
        })
        invalidate_guest_replies_cache(post_id)

        return {
            "id": ref.id,
            "post_id": post_id,
            "root_reply_id": root_reply_id,
            "verifier_app_user_id": app_user_id,
            "created_at": _now_iso(),
        }

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def verify_root_reply_py(req: https_fn.CallableRequest) -> dict:
    """帖子作者应验某条根回复。"""
    return _verify_root_reply_impl(req.auth.uid if req.auth else None, req.data or {})


def _revoke_verification_impl(uid: str, data: dict) -> dict:
    """撤销应验。三处联动：verifications.revoked_at / replies.verification=None / outbox。"""
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    post_id = data.get("postId")
    root_reply_id = data.get("rootReplyId")
    if not post_id or not isinstance(post_id, str):
        raise invalid_argument("postId 不能为空")
    if not root_reply_id or not isinstance(root_reply_id, str):
        raise invalid_argument("rootReplyId 不能为空")

    def _run() -> dict:
        client = db()
        # ★ 坑 5：用 verifier_app_user_id 匹配（不是 uid），别人撤不了我的应验
        found = list(client.collection(COLLECTIONS["verifications"])
                     .where("post_id", "==", post_id)
                     .where("root_reply_id", "==", root_reply_id)
                     .where("verifier_app_user_id", "==", app_user_id)
                     .where("revoked_at", "==", None)
                     .limit(1).get())
        if not found:
            raise not_found("没有有效的应验记录")

        now = gcf.SERVER_TIMESTAMP
        found[0].reference.update({"revoked_at": now})

        # 清掉回复上的应验标记，游客视图随之不再置顶
        client.collection(COLLECTIONS["replies"]).document(root_reply_id).update({
            "verification": None,
        })
        invalidate_guest_replies_cache(post_id)

        outbox_ref = client.collection(COLLECTIONS["outbox"]).document()
        outbox_ref.set({
            "id": outbox_ref.id,
            "event_type": "verification_revoked",
            "post_id": post_id,
            "reply_id": root_reply_id,
            "verifier_app_user_id": app_user_id,
            "created_at": now,
        })

        return {"success": True}

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def revoke_verification_py(req: https_fn.CallableRequest) -> dict:
    """撤销自己做出的应验。"""
    return _revoke_verification_impl(req.auth.uid if req.auth else None, req.data or {})

