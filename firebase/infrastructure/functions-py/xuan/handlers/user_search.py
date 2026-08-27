"""用户搜索与 @ 候选人列表。

支持根据昵称/用户名/应用 ID 前缀搜索，以及按关系优先级（关注/互关/会话）返回 @ 候选人。
"""

from typing import Dict, List, Set

from firebase_functions import https_fn

from xuan.config import COLLECTIONS, REGION, db
from xuan.identity import require_auth_uid, resolve_app_user_id


def _get_blocked_user_ids(client, app_user_id: str) -> Set[str]:
    """获取与当前用户相关的全部拉黑用户 ID（双向排除）。"""
    blocked = set()
    # 1. 我拉黑的人
    my_blocks = client.collection(COLLECTIONS["blocks"]) \
        .where("blocker_app_user_id", "==", app_user_id).get()
    for doc in my_blocks:
        b = (doc.to_dict() or {}).get("blocked_app_user_id")
        if b:
            blocked.add(b)

    # 2. 拉黑我的人
    blocked_me = client.collection(COLLECTIONS["blocks"]) \
        .where("blocked_app_user_id", "==", app_user_id).get()
    for doc in blocked_me:
        b = (doc.to_dict() or {}).get("blocker_app_user_id")
        if b:
            blocked.add(b)

    return blocked


def _fetch_user_display_info(client, user_id: str) -> dict:
    """获取用户公开展示资料（从 profiles 或 identity_map 提取）。"""
    prof_snap = client.collection(COLLECTIONS["profiles"]).document(user_id).get()
    if prof_snap.exists:
        data = prof_snap.to_dict() or {}
        display_name = data.get("display_name") or data.get("displayName") or user_id
        avatar_url = data.get("avatar_url") or data.get("avatarUrl") or ""
        bio = data.get("bio") or ""
        return {
            "app_user_id": user_id,
            "appUserId": user_id,
            "display_name": display_name,
            "displayName": display_name,
            "avatar_url": avatar_url,
            "avatarUrl": avatar_url,
            "bio": bio,
        }

    # 兜底查询 identity_map
    id_snaps = list(client.collection(COLLECTIONS["identity_map"])
                    .where("app_user_id", "==", user_id).limit(1).get())
    if id_snaps:
        data = id_snaps[0].to_dict() or {}
        display_name = (
            data.get("public_display_alias")
            or data.get("publicDisplayAlias")
            or user_id
        )
        return {
            "app_user_id": user_id,
            "appUserId": user_id,
            "display_name": display_name,
            "displayName": display_name,
            "avatar_url": "",
            "avatarUrl": "",
            "bio": "",
        }

    return {
        "app_user_id": user_id,
        "appUserId": user_id,
        "display_name": user_id,
        "displayName": user_id,
        "avatar_url": "",
        "avatarUrl": "",
        "bio": "",
    }


def _search_users_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    query = (data.get("query") or data.get("keyword") or data.get("prefix") or "").strip().lower()
    limit = int(data.get("limit", 20))
    limit = max(1, min(limit, 50))

    if not query:
        return {"users": [], "candidates": [], "total": 0}

    client = db()
    blocked_ids = _get_blocked_user_ids(client, app_user_id)
    blocked_ids.add(app_user_id)  # 排除自己

    results: List[dict] = []
    seen_ids: Set[str] = set()

    # 1. 扫描 profiles
    profiles = client.collection(COLLECTIONS["profiles"]).stream()
    for doc in profiles:
        u_id = doc.id
        if u_id in blocked_ids or u_id in seen_ids:
            continue
        p_data = doc.to_dict() or {}
        d_name = (p_data.get("display_name") or p_data.get("displayName") or "").lower()
        if query in u_id.lower() or (d_name and query in d_name):
            item = {
                "app_user_id": u_id,
                "appUserId": u_id,
                "display_name": p_data.get("display_name") or p_data.get("displayName") or u_id,
                "displayName": p_data.get("display_name") or p_data.get("displayName") or u_id,
                "avatar_url": p_data.get("avatar_url") or p_data.get("avatarUrl") or "",
                "avatarUrl": p_data.get("avatar_url") or p_data.get("avatarUrl") or "",
                "bio": p_data.get("bio") or "",
            }
            results.append(item)
            seen_ids.add(u_id)
            if len(results) >= limit:
                break

    # 2. 若数量未满，扫描 identity_map 兜底
    if len(results) < limit:
        identities = client.collection(COLLECTIONS["identity_map"]).stream()
        for doc in identities:
            i_data = doc.to_dict() or {}
            u_id = i_data.get("app_user_id") or i_data.get("appUserId")
            if not u_id or u_id in blocked_ids or u_id in seen_ids:
                continue
            alias = (i_data.get("public_display_alias") or i_data.get("publicDisplayAlias") or "").lower()
            if query in u_id.lower() or (alias and query in alias):
                item = {
                    "app_user_id": u_id,
                    "appUserId": u_id,
                    "display_name": (
                        i_data.get("public_display_alias")
                        or i_data.get("publicDisplayAlias")
                        or u_id
                    ),
                    "displayName": (
                        i_data.get("public_display_alias")
                        or i_data.get("publicDisplayAlias")
                        or u_id
                    ),
                    "avatar_url": "",
                    "avatarUrl": "",
                    "bio": "",
                }
                results.append(item)
                seen_ids.add(u_id)
                if len(results) >= limit:
                    break

    return {
        "users": results,
        "candidates": results,
        "total": len(results),
    }


def _get_mention_candidates_impl(uid: str, data: dict) -> dict:
    uid = require_auth_uid(uid)
    app_user_id = resolve_app_user_id(uid)["appUserId"]

    query = (data.get("query") or data.get("keyword") or "").strip().lower()
    limit = int(data.get("limit", 20))
    limit = max(1, min(limit, 50))

    client = db()
    blocked_ids = _get_blocked_user_ids(client, app_user_id)
    blocked_ids.add(app_user_id)

    # 收集 P0 候选：我关注的人、关注我的人、会话参与者
    p0_user_ids: List[str] = []
    p0_seen: Set[str] = set()

    # a. 我关注的人
    following_docs = client.collection(COLLECTIONS["follows"]) \
        .where("follower_app_user_id", "==", app_user_id).get()
    for doc in following_docs:
        target = (doc.to_dict() or {}).get("following_app_user_id")
        if target and target not in blocked_ids and target not in p0_seen:
            p0_user_ids.append(target)
            p0_seen.add(target)

    # b. 关注我的人
    followers_docs = client.collection(COLLECTIONS["follows"]) \
        .where("following_app_user_id", "==", app_user_id).get()
    for doc in followers_docs:
        follower = (doc.to_dict() or {}).get("follower_app_user_id")
        if follower and follower not in blocked_ids and follower not in p0_seen:
            p0_user_ids.append(follower)
            p0_seen.add(follower)

    # c. 会话参与者
    conv_docs = client.collection(COLLECTIONS["conversations"]) \
        .where("participants", "array_contains", app_user_id).get()
    for doc in conv_docs:
        parts = (doc.to_dict() or {}).get("participants", [])
        for p in parts:
            if p and p not in blocked_ids and p not in p0_seen:
                p0_user_ids.append(p)
                p0_seen.add(p)

    # 收集 P1 候选：其他已有 profile 的公开用户
    p1_user_ids: List[str] = []
    all_profiles = client.collection(COLLECTIONS["profiles"]).stream()
    for doc in all_profiles:
        u_id = doc.id
        if u_id not in blocked_ids and u_id not in p0_seen:
            p1_user_ids.append(u_id)

    candidates: List[dict] = []
    # 依次按 P0 -> P1 顺序组装展示信息并过滤 query
    for u_id in p0_user_ids + p1_user_ids:
        info = _fetch_user_display_info(client, u_id)
        d_name = (info.get("display_name") or "").lower()
        if query and query not in u_id.lower() and query not in d_name:
            continue
        candidates.append(info)
        if len(candidates) >= limit:
            break

    return {
        "candidates": candidates,
        "users": candidates,
        "total": len(candidates),
    }


@https_fn.on_call(region=REGION)
def search_users_py(req: https_fn.CallableRequest) -> dict:
    """按前缀/关键字搜索用户。"""
    return _search_users_impl(req.auth.uid if req.auth else None, req.data or {})


@https_fn.on_call(region=REGION)
def get_mention_candidates_py(req: https_fn.CallableRequest) -> dict:
    """获取 @ 提及候选人列表（按关系优先级排序）。"""
    return _get_mention_candidates_impl(req.auth.uid if req.auth else None, req.data or {})
