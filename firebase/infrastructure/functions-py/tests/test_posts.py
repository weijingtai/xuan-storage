"""createPost。基准实现：functions/src/posts.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.posts import _create_post_impl

UID = "uid_p1"


def test_text_为空报错(clean_collections):
    for bad in [None, "", "   ", 123]:
        with pytest.raises(XuanHttpsError) as e:
            _create_post_impl(UID, {"text": bad})
        assert e.value.code == "invalid-argument"


def test_创建成功返回完整_dto(clean_collections):
    got = _create_post_impl(UID, {"text": "  测试帖子  "})
    assert got["text"] == "测试帖子", "必须 trim"
    assert got["status"] == "active"
    assert got["presentation_mode"] == "stableAlias", "缺省即 stableAlias"
    assert got["allowed_chart_technique_ids"] == []
    assert got["attachments"] == []
    assert got["revisions"] == []
    assert got["created_at"].endswith("Z") or "+" in got["created_at"]


def test_落库字段与_ts_一致(clean_collections):
    got = _create_post_impl(UID, {"text": "内容"})
    row = clean_collections.collection(COLLECTIONS["posts"]).document(got["id"]).get().to_dict()
    assert row["author_provider_uid"] == UID
    assert row["status"] == "active"
    assert row["has_outcome_feedback"] is False
    assert row["revisions"] == []
    assert "updated_at" in row


def test_匿名模式的_presentation_identity_id(clean_collections):
    got = _create_post_impl(UID, {"text": "匿名帖", "presentation_mode": "oneTimeAnonymous"})
    assert got["presentation_mode"] == "oneTimeAnonymous"
    assert got["presentation_identity_id"] == f"post_{got['id']}"


def test_具名模式的_presentation_identity_id(clean_collections):
    got = _create_post_impl(UID, {"text": "具名帖"})
    assert got["presentation_identity_id"].startswith("user_app-")


def test_未知模式一律降级为_stableAlias(clean_collections):
    got = _create_post_impl(UID, {"text": "x", "presentation_mode": "乱写的模式"})
    assert got["presentation_mode"] == "stableAlias"


def test_具名帖使_public_post_count_加一(clean_collections):
    got = _create_post_impl(UID, {"text": "第一帖"})
    aid = got["author_app_user_id"]
    prof = clean_collections.collection(COLLECTIONS["profiles"]).document(aid).get().to_dict()
    assert prof["public_post_count"] == 1
    assert prof["public_reply_count"] == 0

    _create_post_impl(UID, {"text": "第二帖"})
    prof = clean_collections.collection(COLLECTIONS["profiles"]).document(aid).get().to_dict()
    assert prof["public_post_count"] == 2


def test_匿名帖不增加计数(clean_collections):
    got = _create_post_impl(UID, {"text": "匿名", "presentation_mode": "oneTimeAnonymous"})
    prof = clean_collections.collection(COLLECTIONS["profiles"]).document(got["author_app_user_id"]).get().to_dict()
    assert prof["public_post_count"] == 0, "匿名帖 increment(0)"


def test_幂等重放(clean_collections):
    payload = {"text": "幂等帖", "idempotency_key": "pk1"}
    a = _create_post_impl(UID, payload)
    b = _create_post_impl(UID, payload)
    assert a == b
    docs = list(clean_collections.collection(COLLECTIONS["posts"]).stream())
    assert len(docs) == 1, "重放不得创建第二个帖子"


from xuan.handlers.posts import _edit_post_impl, _tombstone_post_impl

OTHER = "uid_other"


def test_编辑_缺参报错(clean_collections):
    for bad in [{}, {"postId": "p"}, {"text": "t"}, {"postId": "p", "text": "  "}]:
        with pytest.raises(XuanHttpsError) as e:
            _edit_post_impl(UID, bad)
        assert e.value.code == "invalid-argument"


def test_编辑_帖子不存在(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _edit_post_impl(UID, {"postId": "无", "text": "t"})
    assert e.value.code == "not-found"


def test_编辑_他人帖子被拒(clean_collections):
    got = _create_post_impl(UID, {"text": "我的帖"})
    with pytest.raises(XuanHttpsError) as e:
        _edit_post_impl(OTHER, {"postId": got["id"], "text": "改"})
    assert e.value.code == "permission-denied"


def test_编辑_已删帖子报_failed_precondition(clean_collections):
    got = _create_post_impl(UID, {"text": "待删"})
    _tombstone_post_impl(UID, {"postId": got["id"]})
    with pytest.raises(XuanHttpsError) as e:
        _edit_post_impl(UID, {"postId": got["id"], "text": "改"})
    assert e.value.code == "failed-precondition"


def test_编辑_成功并_trim(clean_collections):
    got = _create_post_impl(UID, {"text": "原文"})
    res = _edit_post_impl(UID, {"postId": got["id"], "text": "  新文  "})
    assert res["text"] == "新文"
    row = clean_collections.collection(COLLECTIONS["posts"]).document(got["id"]).get().to_dict()
    assert row["text"] == "新文"


def test_编辑_数组字段仅在给出时更新(clean_collections):
    got = _create_post_impl(UID, {"text": "x", "allowed_chart_technique_ids": ["liuyao"]})
    _edit_post_impl(UID, {"postId": got["id"], "text": "y"})
    row = clean_collections.collection(COLLECTIONS["posts"]).document(got["id"]).get().to_dict()
    assert row["allowed_chart_technique_ids"] == ["liuyao"], "未给出就不该被清空"

    _edit_post_impl(UID, {"postId": got["id"], "text": "z", "allowed_chart_technique_ids": []})
    row = clean_collections.collection(COLLECTIONS["posts"]).document(got["id"]).get().to_dict()
    assert row["allowed_chart_technique_ids"] == []


def test_删除_他人帖子被拒(clean_collections):
    got = _create_post_impl(UID, {"text": "我的"})
    with pytest.raises(XuanHttpsError) as e:
        _tombstone_post_impl(OTHER, {"postId": got["id"]})
    assert e.value.code == "permission-denied"


def test_删除_成功置为_tombstoned(clean_collections):
    got = _create_post_impl(UID, {"text": "删我"})
    assert _tombstone_post_impl(UID, {"postId": got["id"]}) == {"success": True}
    row = clean_collections.collection(COLLECTIONS["posts"]).document(got["id"]).get().to_dict()
    assert row["status"] == "tombstoned"


def test_删除_重复调用不报错(clean_collections):
    """TS 版删除时不校验 status，重复删除是幂等的 —— 照抄。"""
    got = _create_post_impl(UID, {"text": "x"})
    _tombstone_post_impl(UID, {"postId": got["id"]})
    assert _tombstone_post_impl(UID, {"postId": got["id"]}) == {"success": True}

