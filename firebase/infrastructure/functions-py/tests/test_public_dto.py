"""guest_replies 的纯函数工具。零 IO，不需要 Emulator。"""
from datetime import datetime, timezone

import pytest

from xuan.public_dto import (
    MAX_SAFE_INTEGER, derive_presentation_id, is_real_number,
    is_verified, to_iso_string, to_ms,
)


class _FakeTimestamp:
    """模拟 Firestore Timestamp：有 to_datetime 方法。"""
    def __init__(self, dt): self._dt = dt
    def to_datetime(self): return self._dt


# ---- is_real_number：★ 坑 1 ----

@pytest.mark.parametrize("value,expected", [
    (1, True), (1.5, True), (0, True), (-3, True),
    (True, False), (False, False),      # ★ bool 必须被排除
    ("1", False), (None, False), ([], False),
])
def test_is_real_number_排除_bool(value, expected):
    assert is_real_number(value) is expected


# ---- to_iso_string ----

def test_to_iso_string_各种输入():
    assert to_iso_string(None) is None
    assert to_iso_string("2026-01-01T00:00:00Z") == "2026-01-01T00:00:00Z"
    dt = datetime(2026, 1, 1, tzinfo=timezone.utc)
    assert to_iso_string(dt).startswith("2026-01-01")
    assert to_iso_string(_FakeTimestamp(dt)).startswith("2026-01-01")
    assert to_iso_string(12345) is None, "无法识别的类型返回 None"


# ---- to_ms：★ 坑 2 ----

def test_to_ms_缺失取最大值排最后():
    assert to_ms(None) == MAX_SAFE_INTEGER
    assert to_ms("不是时间") == MAX_SAFE_INTEGER
    assert MAX_SAFE_INTEGER == 2 ** 53 - 1


def test_to_ms_正常解析():
    early = to_ms("2026-01-01T00:00:00Z")
    late = to_ms("2026-06-01T00:00:00Z")
    assert early < late < MAX_SAFE_INTEGER


# ---- is_verified ----

@pytest.mark.parametrize("value,expected", [
    ({"by": "x"}, True), ({}, True),
    (None, False), ("字符串", False), (123, False),
])
def test_is_verified_只认_dict(value, expected):
    assert is_verified({"verification": value}) is expected


def test_is_verified_字段缺失():
    assert is_verified({}) is False


# ---- derive_presentation_id ----

def test_derive_presentation_id_与_ts_一致():
    """anon_ + sha256(uid) 前 8 位 hex。"""
    import hashlib
    uid = "uid_abc"
    expect = "anon_" + hashlib.sha256(uid.encode()).hexdigest()[:8]
    assert derive_presentation_id(uid) == expect


def test_derive_presentation_id_空值回落到_anonymous():
    import hashlib
    expect = "anon_" + hashlib.sha256(b"anonymous").hexdigest()[:8]
    for bad in [None, "", 123, []]:
        assert derive_presentation_id(bad) == expect


def test_derive_presentation_id_稳定():
    assert derive_presentation_id("u1") == derive_presentation_id("u1")


from xuan.public_dto import (
    to_public_author, to_public_chart, to_public_media_attachments,
    to_public_reply, to_public_revision_summary,
)


# ---- chart ----

def test_chart_非对象或类型不符返回_none():
    assert to_public_chart(None) is None
    assert to_public_chart("字符串") is None
    assert to_public_chart({"type": "别的图"}) is None, "type 存在且不是 xuanChart → None"


def test_chart_缺_type_视为合法():
    got = to_public_chart({"technique_id": "liuyao"})
    assert got is not None and got["techniqueId"] == "liuyao"


def test_chart_字段投影与缺省():
    got = to_public_chart({"type": "xuanChart"})
    assert got == {
        "techniqueId": "unknown", "schoolId": None,
        "publicChartSnapshot": "", "rendererSchemaVersion": 1,
        "source": "createdInPlayground",
    }


# ---- media ----

def test_media_过滤非法项并生成安全_url():
    got = to_public_media_attachments([
        {"type": "image", "media_object_id": "m1", "mime_type": "image/png", "width": 10, "height": 20},
        {"type": "audio"},          # 非 image/video，滤掉
        None, "垃圾",
    ])
    assert len(got) == 1
    assert got[0]["secureUrl"] == "/public/media/m1"
    assert got[0]["mediaObjectId"] == "m1"
    assert got[0]["durationSeconds"] is None


def test_media_非列表返回空列表():
    assert to_public_media_attachments(None) == []
    assert to_public_media_attachments("x") == []


def test_media_不泄漏内部字段():
    got = to_public_media_attachments([
        {"type": "image", "media_object_id": "m1", "storage_path": "/internal/secret"},
    ])
    assert "storage_path" not in got[0]


# ---- revision ----

def test_revision_只取最后一条():
    got = to_public_revision_summary([
        {"edited_by": "早", "edited_at": "2026-01-01T00:00:00Z"},
        {"edited_by": "晚", "edited_at": "2026-02-01T00:00:00Z", "change_description": "改了"},
    ])
    assert got["editedByAlias"] == "晚"
    assert got["changeDescription"] == "改了"


def test_revision_空或非法返回_none():
    assert to_public_revision_summary([]) is None
    assert to_public_revision_summary(None) is None
    assert to_public_revision_summary(["不是对象"]) is None


def test_revision_缺省值():
    got = to_public_revision_summary([{}])
    assert got["editedByAlias"] == "未知"
    assert got["editedAt"] == "1970-01-01T00:00:00.000Z"
    assert got["changeDescription"] is None


# ---- author ----

def test_author_使用已有_presentation_id():
    got = to_public_author({"presentation_identity_id": "user_app-abc123"})
    assert got["publicPresentationUserId"] == "user_app-abc123"
    assert got["displayAlias"] == "盘友" + "abc123"[-6:]


def test_author_缺失时从_uid_派生():
    got = to_public_author({"author_provider_uid": "uid_x"})
    assert got["publicPresentationUserId"].startswith("anon_")
    assert got["displayAlias"].startswith("盘友")


def test_author_不泄漏敏感字段():
    got = to_public_author({
        "author_provider_uid": "uid_x", "author_app_user_id": "app-secret",
    })
    assert "app-secret" not in str(got)
    assert "uid_x" not in str(got)


# ---- reply ----

def test_reply_投影不含敏感字段():
    got = to_public_reply("r1", {
        "post_id": "p1", "body": "内容", "depth": 0,
        "author_provider_uid": "uid_secret", "author_app_user_id": "app-secret",
        "created_at": "2026-01-01T00:00:00Z",
    })
    s = str(got)
    assert "uid_secret" not in s and "app-secret" not in s
    assert got["publicReplyId"] == "r1"
    assert got["isTombstoned"] is False, "恒为 false（已在上游过滤）"
    assert got["presentationMode"] == "stableAlias", "恒定值"


def test_reply_缺省值():
    got = to_public_reply("r1", {})
    assert got["postId"] == "" and got["body"] == ""
    assert got["techniqueTags"] == [] and got["depth"] == 0
    assert got["createdAt"] == "1970-01-01T00:00:00.000Z"
    assert got["updatedAt"] is None

