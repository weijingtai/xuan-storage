"""游客公开视图的纯函数工具与 DTO 投影。

对应 TS 侧 functions/src/guest_replies.ts 顶部的十个辅助函数。
本模块**零 IO**，可脱离 Emulator 单测。
"""

import hashlib
from datetime import datetime
from typing import Any, Optional

# JS Number.MAX_SAFE_INTEGER。缺失时间戳取它 → 升序排序时排最后。
MAX_SAFE_INTEGER = 2 ** 53 - 1


def is_real_number(value: Any) -> bool:
    """等价于 JS 的 `typeof v === 'number'`。

    ★ 必须排除 bool：Python 里 bool 是 int 的子类，
    不排除会让 limit=True 被当成 limit=1 静默通过（JS 没有这个问题）。
    """
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def to_iso_string(value: Any) -> Optional[str]:
    """归一化为 ISO 字符串。支持 datetime / str / Firestore Timestamp。"""
    if value is None:
        return None
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, str):
        return value
    to_dt = getattr(value, "to_datetime", None)
    if callable(to_dt):
        got = to_dt()
        return got.isoformat() if isinstance(got, datetime) else None
    return None


def to_ms(value: Any) -> int:
    """时间戳毫秒。无法解析 → MAX_SAFE_INTEGER（升序时排最后）。"""
    iso = to_iso_string(value)
    if not iso:
        return MAX_SAFE_INTEGER
    try:
        normalized = iso.replace("Z", "+00:00")
        return int(datetime.fromisoformat(normalized).timestamp() * 1000)
    except (ValueError, TypeError, OverflowError):
        return MAX_SAFE_INTEGER


def is_verified(data: dict) -> bool:
    """已应验 = verification 字段是个对象（TS: typeof v === 'object' 且非 null）。"""
    v = data.get("verification")
    return v is not None and isinstance(v, dict)


def derive_presentation_id(provider_uid: Any) -> str:
    """展示用匿名 ID：anon_ + sha256(uid) 前 8 位。不暴露原始 uid。"""
    raw = provider_uid if isinstance(provider_uid, str) and provider_uid else "anonymous"
    return f"anon_{hashlib.sha256(raw.encode('utf-8')).hexdigest()[:8]}"


def to_public_chart(chart: Any) -> Optional[dict]:
    """公开排盘投影。type 显式存在且不是 xuanChart → None。"""
    if not chart or not isinstance(chart, dict):
        return None
    chart_type = chart.get("type")
    if chart_type is not None and chart_type != "xuanChart":
        return None
    return {
        "techniqueId": chart["technique_id"] if isinstance(chart.get("technique_id"), str) else "unknown",
        "schoolId": chart["school_id"] if isinstance(chart.get("school_id"), str) else None,
        "publicChartSnapshot": chart["public_chart_snapshot"] if isinstance(chart.get("public_chart_snapshot"), str) else "",
        "rendererSchemaVersion": chart["renderer_schema_version"] if is_real_number(chart.get("renderer_schema_version")) else 1,
        "source": chart["chart_source"] if isinstance(chart.get("chart_source"), str) else "createdInPlayground",
    }


def to_public_media_attachments(items: Any) -> list:
    """公开媒体投影。只留 image/video，只暴露安全 URL，**禁止内部存储路径**。"""
    if not isinstance(items, list):
        return []
    out = []
    for m in items:
        if not isinstance(m, dict) or m.get("type") not in ("image", "video"):
            continue
        oid = m["media_object_id"] if isinstance(m.get("media_object_id"), str) else "unknown"
        out.append({
            "type": m["type"],
            "mediaObjectId": oid,
            "mimeType": m["mime_type"] if isinstance(m.get("mime_type"), str) else "",
            "width": m["width"] if is_real_number(m.get("width")) else None,
            "height": m["height"] if is_real_number(m.get("height")) else None,
            "durationSeconds": m["duration_seconds"] if is_real_number(m.get("duration_seconds")) else None,
            "secureUrl": f"/public/media/{oid}",
        })
    return out


def to_public_revision_summary(revisions: Any) -> Optional[dict]:
    """公开修订摘要：只给最新一条的元数据，**不返回全文**。"""
    if not isinstance(revisions, list) or not revisions:
        return None
    last = revisions[-1]
    if not isinstance(last, dict):
        return None
    return {
        "editedByAlias": last["edited_by"] if isinstance(last.get("edited_by"), str) else "未知",
        "editedAt": to_iso_string(last.get("edited_at")) or "1970-01-01T00:00:00.000Z",
        "changeDescription": last["change_description"] if isinstance(last.get("change_description"), str) else None,
    }


def to_public_author(data: dict) -> dict:
    """公开作者投影：只有展示 ID 与别名，**没有 appUserId、没有 provider uid**。"""
    pid = data.get("presentation_identity_id")
    presentation_id = pid if isinstance(pid, str) and pid else derive_presentation_id(data.get("author_provider_uid"))
    return {
        "publicPresentationUserId": presentation_id,
        "displayAlias": f"盘友{presentation_id[-6:]}",
        "avatarUrl": None,
        "publicProfileRef": None,
    }


def to_public_reply(reply_id: str, data: dict) -> dict:
    """PublicReply DTO。键名与 Dart 侧约定一致（camelCase）。"""
    return {
        "publicReplyId": reply_id,
        "postId": data["post_id"] if isinstance(data.get("post_id"), str) else "",
        "body": data["body"] if isinstance(data.get("body"), str) else "",
        "techniqueTags": data["technique_tags"] if isinstance(data.get("technique_tags"), list) else [],
        "chart": to_public_chart(data.get("chart_attachment")),
        "mediaAttachments": to_public_media_attachments(data.get("media_attachments")),
        "author": to_public_author(data),
        "depth": data["depth"] if is_real_number(data.get("depth")) else 0,
        "rootReplyId": data["root_reply_id"] if isinstance(data.get("root_reply_id"), str) else None,
        "replyToReplyId": data["reply_to_reply_id"] if isinstance(data.get("reply_to_reply_id"), str) else None,
        "isVerified": is_verified(data),
        # 恒为 false / 恒为 stableAlias：tombstone 已在上游过滤，游客视图不区分展示模式
        "isTombstoned": False,
        "presentationMode": "stableAlias",
        "createdAt": to_iso_string(data.get("created_at")) or "1970-01-01T00:00:00.000Z",
        "updatedAt": to_iso_string(data.get("updated_at")),
        "latestRevision": to_public_revision_summary(data.get("revisions")),
    }

