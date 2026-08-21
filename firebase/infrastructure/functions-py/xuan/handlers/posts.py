"""帖子。基准实现：functions/src/posts.ts

三个 callable 中只有 create_post 带幂等包装；edit/tombstone 本身幂等，
TS 版没有包，此处照抄不加。
"""

from datetime import datetime, timezone

from firebase_functions import https_fn
from google.cloud import firestore as gcf

from xuan.cache import invalidate_guest_replies_cache
from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import failed_precondition, invalid_argument, not_found
from xuan.errors import XuanHttpsError  # noqa: F401  （供类型标注与测试导入）
from xuan.handlers._guard import guard_rate_limit
from xuan.hashing import hash_payload
from xuan.idempotency import with_idempotency
from xuan.identity import require_auth_uid, resolve_app_user_id


def _now_iso() -> str:
    """返回体用的时间串。注意落库用 SERVER_TIMESTAMP，二者有意不同（见计划坑 3）。"""
    return datetime.now(timezone.utc).isoformat()


def _permission_denied(message: str) -> XuanHttpsError:
    return XuanHttpsError("permission-denied", message)


def _create_post_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]
    guard_rate_limit(app_user_id, "create_post", data.get("idempotency_key"))

    text = data.get("text")
    if not text or not isinstance(text, str) or not text.strip():
        raise invalid_argument("text 不能为空")

    def _run() -> dict:
        client = db()
        post_ref = client.collection(COLLECTIONS["posts"]).document()
        now = gcf.SERVER_TIMESTAMP

        # 只认 oneTimeAnonymous，其余一律降级为 stableAlias（含拼错与缺省）
        mode = "oneTimeAnonymous" if data.get("presentation_mode") == "oneTimeAnonymous" else "stableAlias"
        identity_id = f"post_{post_ref.id}" if mode == "oneTimeAnonymous" else f"user_{app_user_id}"

        post_data = {
            "id": post_ref.id,
            "text": text.strip(),
            "author_provider_uid": uid,
            "author_app_user_id": app_user_id,
            "presentation_mode": mode,
            "presentation_identity_id": identity_id,
            "status": "active",
            "allowed_chart_technique_ids": data.get("allowed_chart_technique_ids") or [],
            "attachments": data.get("attachments") or [],
            "revisions": [],
            "has_outcome_feedback": False,
            "idempotency_key": data.get("idempotency_key"),
            "created_at": now,
            "updated_at": now,
        }

        post_ref.set(post_data)
        # 匿名帖不计入公开帖数：TS 用 increment(0)，此处照抄语义
        client.collection(COLLECTIONS["profiles"]).document(app_user_id).set({
            "user_provider_uid": uid,
            "public_post_count": gcf.Increment(1 if mode == "stableAlias" else 0),
            "public_reply_count": gcf.Increment(0),
            "updated_at": now,
        }, merge=True)

        return {
            "id": post_ref.id,
            "text": post_data["text"],
            "author_app_user_id": app_user_id,
            "presentation_mode": mode,
            "presentation_identity_id": identity_id,
            "status": "active",
            "allowed_chart_technique_ids": post_data["allowed_chart_technique_ids"],
            "attachments": post_data["attachments"],
            "revisions": [],
            "created_at": _now_iso(),
        }

    return with_idempotency(data.get("idempotency_key"), hash_payload(data), _run)


@https_fn.on_call(region=REGION)
def create_post_py(req: https_fn.CallableRequest) -> dict:
    """发帖。"""
    return _create_post_impl(req.auth.uid if req.auth else None, req.data or {})


def _edit_post_impl(uid: str, data: dict) -> dict:
    """编辑帖子。**无幂等包装**——TS 版如此，编辑本身幂等。"""
    uid = require_auth_uid(uid)
    post_id = data.get("postId")
    text = data.get("text")

    if (not post_id or not isinstance(post_id, str)
            or not text or not isinstance(text, str) or not text.strip()):
        raise invalid_argument("postId 和 text 必填")

    client = db()
    ref = client.collection(COLLECTIONS["posts"]).document(post_id)
    snap = ref.get()
    if not snap.exists:
        raise not_found("帖子不存在")

    row = snap.to_dict() or {}
    if row.get("author_provider_uid") != uid:
        raise _permission_denied("只能编辑自己的帖子")
    if row.get("status") != "active":
        raise failed_precondition("帖子已删除")

    update = {"text": text.strip(), "updated_at": gcf.SERVER_TIMESTAMP}
    # 只有显式给出数组时才更新，未给出保持原值（与 TS 的 Array.isArray 判断等价）
    if isinstance(data.get("allowed_chart_technique_ids"), list):
        update["allowed_chart_technique_ids"] = data["allowed_chart_technique_ids"]
    if isinstance(data.get("attachments"), list):
        update["attachments"] = data["attachments"]

    ref.update(update)
    invalidate_guest_replies_cache(post_id)

    # ⚠ 与 TS 的已知有意差异（见计划坑 4）：
    # TS 直接把含 serverTimestamp 哨兵的 update 展开进返回体；
    # Python 的哨兵无法 JSON 序列化，因此这里回填 ISO 字符串。
    # updated_at 已在影子比对的忽略清单内，不会造成误报。
    merged = {**row, **update, "id": post_id}
    merged["updated_at"] = _now_iso()
    merged.pop("created_at", None)
    merged["created_at"] = _now_iso()
    return merged


def _tombstone_post_impl(uid: str, data: dict) -> dict:
    """软删帖子。**无幂等包装**，且 TS 版不校验当前 status，重复删除返回成功。"""
    uid = require_auth_uid(uid)
    post_id = data.get("postId")
    if not post_id or not isinstance(post_id, str):
        raise invalid_argument("postId 必填")

    client = db()
    ref = client.collection(COLLECTIONS["posts"]).document(post_id)
    snap = ref.get()
    if not snap.exists:
        raise not_found("帖子不存在")
    if (snap.to_dict() or {}).get("author_provider_uid") != uid:
        raise _permission_denied("只能删除自己的帖子")

    ref.update({"status": "tombstoned", "updated_at": gcf.SERVER_TIMESTAMP})
    invalidate_guest_replies_cache(post_id)
    return {"success": True}


@https_fn.on_call(region=REGION)
def edit_post_py(req: https_fn.CallableRequest) -> dict:
    """编辑自己的帖子。"""
    return _edit_post_impl(req.auth.uid if req.auth else None, req.data or {})


@https_fn.on_call(region=REGION)
def tombstone_post_py(req: https_fn.CallableRequest) -> dict:
    """软删自己的帖子。"""
    return _tombstone_post_impl(req.auth.uid if req.auth else None, req.data or {})

