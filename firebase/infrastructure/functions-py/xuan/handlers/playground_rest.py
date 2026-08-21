"""FW1-S: 广场 Feed 与帖子详情 REST 端点实现。

符合 OpenAPI 3.1 契约 (repository-rest-adapter/openapi/openapi.yaml)
与 RFC 9457 Problem Details、RFC 7232 缓存协商标准。

特性：
1. 纯逻辑与 @https_fn.on_request 装饰器分离，_xxx_impl 脱离 FaaS runtime 独立可单测；
2. 无状态 MD5 ETag 算法（Q1 裁决，聚合 ID 与更新时间戳），0 外部 Redis 依赖；
3. If-None-Match 命中 304 短路（响应体为空，0 次数据层调用）；
4. 缓存故障平稳降级（后端抛异常仍正常返回结果）；
5. 游标分页连续稳定，非法游标返回 400 CURSOR_INVALID_OR_STALE；
6. 区域常量使用 xuan.config.REGION。
"""

from __future__ import annotations

import base64
from datetime import datetime, timezone
import hashlib
import json
import logging
from typing import Any, Optional

from firebase_functions import https_fn

from xuan.cache import (
    CachePort,
    CachedEntry,
    compute_query_fingerprint,
    get_global_cache,
    get_global_single_flight,
    matches_etag,
)
from xuan.config import COLLECTIONS, REGION, db
from xuan.public_dto import is_real_number, to_iso_string

logger = logging.getLogger(__name__)

VALID_TABS = {"recommended", "pendingDivination", "latest"}
DEFAULT_TAB = "recommended"
DEFAULT_LIMIT = 20
MAX_LIMIT = 1000
MIN_LIMIT = 1
MAX_TECHNIQUE_IDS = 10


# ============================================================================
# 1. DTO 转换投影（对齐 OpenAPI PlaygroundPost / PlaygroundFeedResponse）
# ============================================================================

def to_playground_attachment_dto(a: Any) -> dict:
    """转换为 OpenAPI PlaygroundAttachment 结构。"""
    if not isinstance(a, dict):
        return {"type": "image"}
    att_type = a.get("type", "image")
    res: dict[str, Any] = {"type": att_type}

    if att_type == "xuanChart":
        res["technique_id"] = a.get("technique_id")
        res["school_id"] = a.get("school_id")
        res["public_chart_snapshot"] = a.get("public_chart_snapshot", "")
        res["renderer_schema_version"] = (
            a.get("renderer_schema_version", 1)
            if is_real_number(a.get("renderer_schema_version"))
            else 1
        )
        res["chart_source"] = a.get("chart_source", "createdInPlayground")
    else:
        res["media_object_id"] = a.get("media_object_id")
        res["mime_type"] = a.get("mime_type", "image/jpeg" if att_type == "image" else "video/mp4")
        res["width"] = a.get("width") if is_real_number(a.get("width")) else None
        res["height"] = a.get("height") if is_real_number(a.get("height")) else None
        res["duration_seconds"] = a.get("duration_seconds") if is_real_number(a.get("duration_seconds")) else None
        res["moderation_state"] = a.get("moderation_state", "pending")

    return res


def to_playground_revision_dto(r: Any) -> dict:
    """转换为 OpenAPI PlaygroundRevision 结构。"""
    if not isinstance(r, dict):
        return {
            "body": "",
            "edited_by": "",
            "edited_at": "1970-01-01T00:00:00Z",
            "change_description": None,
        }
    return {
        "body": r.get("body", ""),
        "edited_by": r.get("edited_by", ""),
        "edited_at": to_iso_string(r.get("edited_at")) or "1970-01-01T00:00:00Z",
        "change_description": r.get("change_description"),
    }


def to_playground_post_dto(doc_id: str, data: dict) -> dict:
    """将 Firestore 帖子文档投影为契约标准的 PlaygroundPost DTO。"""
    data = data or {}
    app_user_id = data.get("author_app_user_id") or data.get("author_provider_uid") or ""
    created_at = to_iso_string(data.get("created_at")) or "1970-01-01T00:00:00Z"
    updated_at = to_iso_string(data.get("updated_at"))
    rev = updated_at or created_at

    attachments_raw = data.get("attachments")
    attachments = [
        to_playground_attachment_dto(a) for a in attachments_raw
    ] if isinstance(attachments_raw, list) else []

    revisions_raw = data.get("revisions")
    revisions = [
        to_playground_revision_dto(r) for r in revisions_raw
    ] if isinstance(revisions_raw, list) else []

    techniques_raw = data.get("allowed_chart_technique_ids")
    techniques = [str(t) for t in techniques_raw] if isinstance(techniques_raw, list) else []

    return {
        "id": doc_id,
        "text": data.get("text", ""),
        "author_user_id": app_user_id,
        "status": data.get("status", "active"),
        "allowed_chart_technique_ids": techniques,
        "attachments": attachments,
        "revisions": revisions,
        "created_at": created_at,
        "updated_at": updated_at,
        "has_outcome_feedback": bool(data.get("has_outcome_feedback", False)),
        "rev": rev,
    }


# ============================================================================
# 2. 无状态 MD5 ETag 算法（Q1 裁决）
# ============================================================================

def compute_feed_etag(items: list[dict]) -> str:
    """无状态聚合 MD5 ETag（基于返回列表记录 ID 与更新时间戳）。"""
    if not items:
        digest = hashlib.md5(b"empty_feed").hexdigest()
        return f'"{digest}"'

    parts = []
    for item in items:
        iid = str(item.get("id", ""))
        ts = str(item.get("updated_at") or item.get("created_at") or item.get("rev") or "")
        parts.append(f"{iid}:{ts}")

    payload = "|".join(parts).encode("utf-8")
    digest = hashlib.md5(payload).hexdigest()
    return f'"{digest}"'


def compute_post_etag(post: dict) -> str:
    """单条帖子无状态 MD5 ETag。"""
    iid = str(post.get("id", ""))
    ts = str(post.get("updated_at") or post.get("created_at") or post.get("rev") or "")
    payload = f"{iid}:{ts}".encode("utf-8")
    digest = hashlib.md5(payload).hexdigest()
    return f'"{digest}"'


# ============================================================================
# 3. 游标编解码（不透明 Token，防跨适配器漂移）
# ============================================================================

def encode_cursor(tab: str, doc_id: str, sort_value: Any, filter_hash: str = "") -> str:
    """编码不透明分页游标。"""
    payload = {
        "v": 1,
        "tab": tab,
        "id": doc_id,
        "s": sort_value,
        "fh": filter_hash,
    }
    raw = json.dumps(payload, separators=(",", ":")).encode("utf-8")
    return base64.urlsafe_b64encode(raw).decode("ascii").rstrip("=")


def decode_cursor(cursor_str: str, expected_tab: str) -> Optional[dict]:
    """解码并校验游标。非法/陈旧格式返回 None。"""
    if not cursor_str or not isinstance(cursor_str, str):
        return None
    try:
        # 补齐 base64 padding
        padded = cursor_str + "=" * (-len(cursor_str) % 4)
        raw = base64.urlsafe_b64decode(padded.encode("ascii"))
        payload = json.loads(raw.decode("utf-8"))
        if not isinstance(payload, dict):
            return None
        if payload.get("v") != 1:
            return None
        if payload.get("tab") != expected_tab:
            return None
        if not payload.get("id"):
            return None
        return payload
    except Exception:
        return None


# ============================================================================
# 4. RFC 9457 Problem Details 统一错误构造
# ============================================================================

def make_problem_details(
    type_code: str,
    title: str,
    status: int,
    detail: str,
    instance: Optional[str] = None,
    reason: Optional[str] = None,
    suggestion: Optional[str] = None,
    current_rev: Optional[str] = None,
    field: Optional[str] = None,
) -> dict:
    """构造标准 RFC 9457 Problem Details 错误响应体。"""
    problem = {
        "type": type_code,
        "title": title,
        "status": status,
        "detail": detail,
        "instance": instance,
        "reason": reason,
        "suggestion": suggestion,
    }
    if current_rev is not None:
        problem["currentRev"] = current_rev
    if field is not None:
        problem["field"] = field
    return problem


# ============================================================================
# 5. 纯业务逻辑函数（脱离 FaaS Runtime 独立可测）
# ============================================================================

def _list_playground_feed_impl(
    params: dict,
    if_none_match: Optional[str] = None,
    cache: Optional[CachePort] = None,
    db_client: Any = None,
) -> tuple[int, Optional[dict], dict[str, str]]:
    """GET /playground/feed 纯业务实现。

    返回: (status_code, body_dict_or_none, headers_dict)
    """
    params = params or {}
    cache = cache or get_global_cache()
    client = db_client or db()

    # 1. 参数校验
    tab = params.get("tab") or DEFAULT_TAB
    if tab not in VALID_TABS:
        return (
            400,
            make_problem_details(
                type_code="invalid_argument",
                title="Invalid Tab Parameter",
                status=400,
                detail=f"Unsupported tab '{tab}'. Valid tabs are: {', '.join(sorted(VALID_TABS))}",
                reason="INVALID_TAB",
            ),
            {"Content-Type": "application/problem+json"},
        )

    raw_limit = params.get("limit")
    limit = DEFAULT_LIMIT
    if raw_limit is not None:
        if is_real_number(raw_limit) and float(raw_limit).is_integer():
            limit = int(raw_limit)
            if limit < MIN_LIMIT or limit > MAX_LIMIT:
                return (
                    400,
                    make_problem_details(
                        type_code="invalid_argument",
                        title="Limit Out of Range",
                        status=400,
                        detail=f"limit must be between {MIN_LIMIT} and {MAX_LIMIT}",
                        reason="LIMIT_OUT_OF_RANGE",
                    ),
                    {"Content-Type": "application/problem+json"},
                )
        elif isinstance(raw_limit, str) and raw_limit.isdigit():
            limit = int(raw_limit)
            if limit < MIN_LIMIT or limit > MAX_LIMIT:
                return (
                    400,
                    make_problem_details(
                        type_code="invalid_argument",
                        title="Limit Out of Range",
                        status=400,
                        detail=f"limit must be between {MIN_LIMIT} and {MAX_LIMIT}",
                        reason="LIMIT_OUT_OF_RANGE",
                    ),
                    {"Content-Type": "application/problem+json"},
                )
        else:
            return (
                400,
                make_problem_details(
                    type_code="invalid_argument",
                    title="Invalid Limit Parameter",
                    status=400,
                    detail="limit must be an integer",
                    reason="INVALID_LIMIT",
                ),
                {"Content-Type": "application/problem+json"},
            )

    # techniqueIds 校验
    technique_ids = params.get("techniqueIds")
    if technique_ids is not None:
        if isinstance(technique_ids, str):
            technique_ids = [t.strip() for t in technique_ids.split(",") if t.strip()]
        elif not isinstance(technique_ids, list):
            return (
                400,
                make_problem_details(
                    type_code="invalid_argument",
                    title="Invalid techniqueIds Parameter",
                    status=400,
                    detail="techniqueIds must be a list of strings or comma-separated string",
                    reason="INVALID_TECHNIQUE_IDS",
                ),
                {"Content-Type": "application/problem+json"},
            )
        if len(technique_ids) > MAX_TECHNIQUE_IDS:
            return (
                400,
                make_problem_details(
                    type_code="invalid_argument",
                    title="Too Many Technique IDs",
                    status=400,
                    detail=f"techniqueIds array cannot exceed {MAX_TECHNIQUE_IDS} items",
                    reason="TECHNIQUE_IDS_EXCEEDED_MAX",
                ),
                {"Content-Type": "application/problem+json"},
            )
    else:
        technique_ids = []

    content_type = params.get("contentType")
    reply_status = params.get("replyStatus")
    feedback_status = params.get("feedbackStatus")
    raw_cursor = params.get("cursor")

    # 游标校验
    cursor_data = None
    if raw_cursor:
        cursor_data = decode_cursor(raw_cursor, expected_tab=tab)
        if cursor_data is None:
            return (
                400,
                make_problem_details(
                    type_code="invalid_argument",
                    title="Invalid Cursor",
                    status=400,
                    detail="The provided cursor is stale or incompatible with current transport adapter.",
                    reason="CURSOR_INVALID_OR_STALE",
                    suggestion="Reset cursor and fetch from first page.",
                ),
                {"Content-Type": "application/problem+json"},
            )

    # 2. 计算查询指纹 Key
    normalized_params = {
        "tab": tab,
        "limit": limit,
        "contentType": content_type,
        "replyStatus": reply_status,
        "feedbackStatus": feedback_status,
        "techniqueIds": sorted(technique_ids) if technique_ids else None,
        "cursor": raw_cursor,
    }
    cache_key = compute_query_fingerprint(
        route="/playground/feed",
        params=normalized_params,
        contract_version="1",
        default_params={"tab": DEFAULT_TAB, "limit": DEFAULT_LIMIT},
    )

    # 3. 查缓存与 ETag 304 短路
    cached_entry = cache.get(cache_key)
    if cached_entry is not None:
        etag = cached_entry.etag
        headers = {"ETag": etag, "Content-Type": "application/json"}
        if matches_etag(if_none_match, etag):
            return (304, None, headers)
        try:
            body_dict = json.loads(cached_entry.body.decode("utf-8"))
            return (200, body_dict, headers)
        except Exception:
            logger.warning("Failed to deserialize cached entry for key '%s'", cache_key)

    # 4. 缓存未命中，下探 Firestore 查询
    try:
        col = client.collection(COLLECTIONS["posts"])
        q = col.where("status", "==", "active")

        if content_type:
            q = q.where("content_type", "==", content_type)
        if reply_status:
            q = q.where("reply_status", "==", reply_status)
        if feedback_status:
            q = q.where("feedback_status", "==", feedback_status)
        if technique_ids:
            q = q.where("allowed_chart_technique_ids", "array_contains_any", technique_ids)

        # 多 Tab 排序规则
        if tab == "recommended":
            q = q.order_by("recommendation_score", "DESCENDING")
        elif tab == "pendingDivination":
            q = q.where("reply_status", "==", "pending")
            q = q.order_by("created_at", "ASCENDING")
        elif tab == "latest":
            q = q.order_by("created_at", "DESCENDING")

        # 游标定位
        if cursor_data:
            cursor_doc_id = cursor_data["id"]
            start_snap = col.document(cursor_doc_id).get()
            if hasattr(start_snap, "exists") and not start_snap.exists:
                return (
                    400,
                    make_problem_details(
                        type_code="invalid_argument",
                        title="Invalid Cursor",
                        status=400,
                        detail="The provided cursor is stale or incompatible with current transport adapter.",
                        reason="CURSOR_INVALID_OR_STALE",
                        suggestion="Reset cursor and fetch from first page.",
                    ),
                    {"Content-Type": "application/problem+json"},
                )
            q = q.start_after(start_snap)

        q = q.limit(limit)
        snaps = q.get()

        items = []
        for s in snaps:
            d = s.to_dict() or {}
            items.append(to_playground_post_dto(s.id, d))

        has_more = len(items) == limit
        next_cursor = None
        if has_more and items:
            last_item = items[-1]
            sort_val = (
                last_item.get("recommendation_score")
                if tab == "recommended"
                else last_item.get("created_at")
            )
            next_cursor = encode_cursor(tab, last_item["id"], sort_val)

        response_body = {
            "items": items,
            "nextCursor": next_cursor,
            "hasMore": has_more,
        }

        etag = compute_feed_etag(items)
        body_bytes = json.dumps(response_body, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        cache.set(cache_key, CachedEntry(body=body_bytes, etag=etag), ttl=60.0)

        headers = {"ETag": etag, "Content-Type": "application/json"}
        if matches_etag(if_none_match, etag):
            return (304, None, headers)

        return (200, response_body, headers)

    except Exception as exc:
        logger.exception("Firestore feed query failed")
        return (
            500,
            make_problem_details(
                type_code="internal",
                title="Internal Server Error",
                status=500,
                detail=str(exc),
            ),
            {"Content-Type": "application/problem+json"},
        )


def _get_playground_post_impl(
    post_id: str,
    if_none_match: Optional[str] = None,
    cache: Optional[CachePort] = None,
    db_client: Any = None,
) -> tuple[int, Optional[dict], dict[str, str]]:
    """GET /playground/posts/{id} 纯业务实现。

    返回: (status_code, body_dict_or_none, headers_dict)
    """
    if not post_id or not isinstance(post_id, str) or not post_id.strip():
        return (
            400,
            make_problem_details(
                type_code="invalid_argument",
                title="Invalid Post ID",
                status=400,
                detail="postId is required and cannot be empty",
                reason="INVALID_POST_ID",
            ),
            {"Content-Type": "application/problem+json"},
        )

    post_id = post_id.strip()
    cache = cache or get_global_cache()
    client = db_client or db()
    cache_key = f"playground/posts/{post_id}"

    # 1. 查缓存与 ETag 304 短路
    cached_entry = cache.get(cache_key)
    if cached_entry is not None:
        etag = cached_entry.etag
        headers = {"ETag": etag, "Content-Type": "application/json"}
        if matches_etag(if_none_match, etag):
            return (304, None, headers)
        try:
            body_dict = json.loads(cached_entry.body.decode("utf-8"))
            return (200, body_dict, headers)
        except Exception:
            logger.warning("Failed to deserialize cached entry for post '%s'", post_id)

    # 2. 下探 Firestore
    try:
        snap = client.collection(COLLECTIONS["posts"]).document(post_id).get()
        if not snap.exists:
            return (
                404,
                make_problem_details(
                    type_code="not_found",
                    title="Post Not Found",
                    status=404,
                    detail=f"Post with ID '{post_id}' does not exist.",
                    reason="POST_NOT_FOUND",
                ),
                {"Content-Type": "application/problem+json"},
            )

        data = snap.to_dict() or {}
        if data.get("status") == "tombstoned":
            return (
                404,
                make_problem_details(
                    type_code="not_found",
                    title="Post Not Found",
                    status=404,
                    detail=f"Post with ID '{post_id}' has been deleted.",
                    reason="POST_TOMBSTONED",
                ),
                {"Content-Type": "application/problem+json"},
            )

        post_dto = to_playground_post_dto(snap.id, data)
        etag = compute_post_etag(post_dto)
        body_bytes = json.dumps(post_dto, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        cache.set(cache_key, CachedEntry(body=body_bytes, etag=etag), ttl=60.0)

        headers = {"ETag": etag, "Content-Type": "application/json"}
        if matches_etag(if_none_match, etag):
            return (304, None, headers)

        return (200, post_dto, headers)

    except Exception as exc:
        logger.exception("Firestore get post failed for '%s'", post_id)
        return (
            500,
            make_problem_details(
                type_code="internal",
                title="Internal Server Error",
                status=500,
                detail=str(exc),
            ),
            {"Content-Type": "application/problem+json"},
        )


# ============================================================================
# 6. Cloud Functions HTTP 适配器入口 (@https_fn.on_request)
# ============================================================================

def _parse_technique_ids_from_req(req: Any) -> list[str]:
    """从 HTTP 请求中提取 techniqueIds 列表（支持重复参数与逗号分隔）。"""
    if hasattr(req, "args") and req.args is not None:
        getlist_fn = getattr(req.args, "getlist", None)
        if callable(getlist_fn):
            raw_list = getlist_fn("techniqueIds") or getlist_fn("techniqueIds[]")
            if raw_list:
                out = []
                for item in raw_list:
                    for sub in str(item).split(","):
                        if sub.strip():
                            out.append(sub.strip())
                return out
        if isinstance(req.args, dict) or hasattr(req.args, "get"):
            raw_single = req.args.get("techniqueIds")
            if raw_single:
                if isinstance(raw_single, list):
                    return [str(s).strip() for s in raw_single if str(s).strip()]
                return [s.strip() for s in str(raw_single).split(",") if s.strip()]
    return []


@https_fn.on_request(region=REGION)
def playground_feed_py(req: https_fn.Request) -> https_fn.Response:
    """GET /playground/feed 广场 Feed 分页查询端点。"""
    args = getattr(req, "args", {}) or {}
    technique_ids = _parse_technique_ids_from_req(req)

    params = {
        "tab": args.get("tab"),
        "contentType": args.get("contentType"),
        "replyStatus": args.get("replyStatus"),
        "feedbackStatus": args.get("feedbackStatus"),
        "techniqueIds": technique_ids if technique_ids else None,
        "cursor": args.get("cursor"),
        "limit": args.get("limit"),
    }

    if_none_match = req.headers.get("If-None-Match") if hasattr(req, "headers") else None

    status_code, body_dict, headers = _list_playground_feed_impl(
        params=params,
        if_none_match=if_none_match,
    )

    if status_code == 304:
        return https_fn.Response(
            response="",
            status=304,
            headers=headers,
        )

    response_str = json.dumps(body_dict, ensure_ascii=False) if body_dict is not None else ""
    return https_fn.Response(
        response=response_str,
        status=status_code,
        headers=headers,
        mimetype="application/json" if status_code == 200 else "application/problem+json",
    )


@https_fn.on_request(region=REGION)
def playground_posts_py(req: https_fn.Request) -> https_fn.Response:
    """GET /playground/posts/{id} 广场单帖详情查询端点。"""
    args = getattr(req, "args", {}) or {}
    post_id = args.get("id")

    if not post_id and hasattr(req, "path"):
        # 从 URL 路径提取最后的 post ID
        path_clean = req.path.strip("/")
        if path_clean:
            segments = path_clean.split("/")
            if segments:
                post_id = segments[-1]

    if_none_match = req.headers.get("If-None-Match") if hasattr(req, "headers") else None

    status_code, body_dict, headers = _get_playground_post_impl(
        post_id=post_id or "",
        if_none_match=if_none_match,
    )

    if status_code == 304:
        return https_fn.Response(
            response="",
            status=304,
            headers=headers,
        )

    response_str = json.dumps(body_dict, ensure_ascii=False) if body_dict is not None else ""
    return https_fn.Response(
        response=response_str,
        status=status_code,
        headers=headers,
        mimetype="application/json" if status_code == 200 else "application/problem+json",
    )
