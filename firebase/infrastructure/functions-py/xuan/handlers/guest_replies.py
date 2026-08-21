"""游客代表性回复。基准实现：functions/src/guest_replies.ts

★ 本模块是唯一允许未认证调用的 callable —— 游客读完整回复走这里，
客户端直连 playground_replies 仍被 Rules 拒绝。
因此 `_impl` 的签名里**没有 uid**，不要加。
"""

import json

from firebase_functions import https_fn

from xuan.cache import (
    cached_query,
    compute_query_fingerprint,
    get_global_cache,
    get_global_single_flight,
)
from xuan.config import COLLECTIONS, REGION, db
from xuan.errors import invalid_argument, not_found
from xuan.public_dto import (
    is_real_number, is_verified, to_iso_string, to_ms, to_public_reply,
)

SELECTION_POLICY_VERSION = 1
MIN_GUEST_LIMIT = 5
MAX_GUEST_LIMIT = 10


def _load_outcome_feedback(post_id: str):
    """取该帖最新的有效最终反馈（deleted_at 为空）。无 → None。"""
    client = db()
    snaps = client.collection(COLLECTIONS["outcome_feedback"]).where("post_id", "==", post_id).get()
    active = [(d.id, d.to_dict() or {}) for d in snaps]
    active = [x for x in active if x[1].get("deleted_at") is None]
    if not active:
        return None

    # 最新在前；同一时刻用 id **降序** tie-break（★ 坑 5：与主排序方向相反）
    active.sort(key=lambda x: (to_ms(x[1].get("created_at")), x[0]), reverse=True)
    latest = active[0][1]

    published_at = to_iso_string(latest.get("created_at")) or "1970-01-01T00:00:00.000Z"
    updated_at = to_iso_string(latest.get("updated_at"))
    return {
        "body": latest["outcome_description"] if isinstance(latest.get("outcome_description"), str) else "",
        "isEdited": updated_at is not None and updated_at != published_at,
        "publishedAt": published_at,
        "updatedAt": updated_at,
    }


def _get_guest_representative_replies_impl(data: dict) -> dict:
    """★ 无 uid 参数：游客可调。

    已接入 CachePort 读缓存网关（查询指纹 + 单飞防击穿 + TTL 抖动 + ETag 304 短路）。
    """
    data = data or {}

    post_id = data.get("postId")
    if not isinstance(post_id, str) or not post_id.strip():
        raise invalid_argument("postId 不能为空")

    # limit：只接受真整数（★ 坑 1：必须排除 bool），clamp 到 [5,10]，否则回落 5
    limit = MIN_GUEST_LIMIT
    raw_limit = data.get("limit")
    if is_real_number(raw_limit) and float(raw_limit).is_integer():
        limit = min(MAX_GUEST_LIMIT, max(MIN_GUEST_LIMIT, int(raw_limit)))

    # policyVersion：仅支持 1；缺省/None → 1；其余一律非法（bool 同样非法）
    raw_version = data.get("selectionPolicyVersion")
    policy_version = SELECTION_POLICY_VERSION if raw_version is None else raw_version
    if not is_real_number(policy_version) or policy_version != SELECTION_POLICY_VERSION:
        raise invalid_argument(f"不支持的 selectionPolicyVersion: {policy_version}")

    cache_key = compute_query_fingerprint(
        route=f"guest_replies/{post_id}",
        params={"limit": limit, "selectionPolicyVersion": policy_version},
        contract_version="1",
        default_params={"limit": MIN_GUEST_LIMIT, "selectionPolicyVersion": SELECTION_POLICY_VERSION},
    )

    if_none_match = data.get("ifNoneMatch") or data.get("if_none_match")

    def _loader() -> dict:
        client = db()
        post_snap = client.collection(COLLECTIONS["posts"]).document(post_id).get()
        if not post_snap.exists or (post_snap.to_dict() or {}).get("status") != "active":
            raise not_found("帖子不存在或已失效")

        roots = client.collection(COLLECTIONS["replies"]) \
            .where("post_id", "==", post_id).where("depth", "==", 0).get()

        candidates = []
        for doc in roots:
            d = doc.to_dict() or {}
            if d.get("is_tombstoned") is True:
                continue   # tombstone 不入 total，也不入 visible
            candidates.append((doc.id, d, to_ms(d.get("created_at"))))

        # 批量查询 likes（Firestore 'in' 限制单批最多 30 个），并在内存中归组计数
        # 保证 0 赞的 reply_id 仍然存在且计数为 0
        like_counts = {cid: 0 for cid, _, _ in candidates}
        cids = [cid for cid, _, _ in candidates]
        batch_size = 30
        for i in range(0, len(cids), batch_size):
            chunk = cids[i:i + batch_size]
            if not chunk:
                continue
            likes_docs = client.collection(COLLECTIONS["likes"]).where("reply_id", "in", chunk).get()
            for doc in likes_docs:
                d = doc.to_dict() or {}
                rid = d.get("reply_id")
                if rid in like_counts:
                    like_counts[rid] += 1

        # ★ 坑 3：[isVerified desc, likeCount desc, createdAt asc, replyId asc]
        ordered = sorted(candidates, key=lambda c: (
            0 if is_verified(c[1]) else 1,   # 已验在前
            -like_counts[c[0]],              # 赞多在前
            c[2],                            # 早的在前
            c[0],                            # 最终 tie-break，保证确定性
        ))

        visible = ordered[:min(limit, len(ordered))]
        total = len(candidates)

        return {
            "postId": post_id,
            "visibleReplies": [to_public_reply(cid, d) for cid, d, _ in visible],
            "totalReplyCount": total,
            "hiddenReplyCount": max(0, total - len(visible)),
            "selectionPolicyVersion": policy_version,
            "registrationUnlock": {
                "requiresRegistration": True,
                "ctaMessageKey": "register_to_unlock_replies",
                "unlockRoute": "/register",
            },
            "outcomeFeedback": _load_outcome_feedback(post_id),
        }

    cached_resp = cached_query(
        cache=get_global_cache(),
        key=cache_key,
        loader=_loader,
        if_none_match=if_none_match,
        ttl=60.0,
        single_flight=get_global_single_flight(),
    )

    if cached_resp.status_code == 304:
        return {"_status_code": 304, "_etag": cached_resp.etag}

    if isinstance(cached_resp.body, (bytes, bytearray)):
        res_dict = json.loads(cached_resp.body.decode("utf-8"))
    elif isinstance(cached_resp.body, str):
        res_dict = json.loads(cached_resp.body)
    else:
        res_dict = cached_resp.body

    if cached_resp.etag:
        res_dict["_etag"] = cached_resp.etag
    return res_dict


@https_fn.on_call(region=REGION)
def get_guest_representative_replies_py(req: https_fn.CallableRequest) -> dict:
    """游客读代表性回复。**不校验登录**，req.auth 可为 None。"""
    return _get_guest_representative_replies_impl(req.data or {})
