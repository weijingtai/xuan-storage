"""replies。基准实现：functions/src/replies.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.posts import _create_post_impl, _tombstone_post_impl
from xuan.handlers.replies import _create_root_reply_impl

UID = "uid_r1"
OTHER = "uid_r2"


def _a_post(uid=UID) -> str:
    return _create_post_impl(uid, {"text": "宿主帖"})["id"]


def test_body_为空报错(clean_collections):
    pid = _a_post()
    for bad in [None, "", "  ", 42]:
        with pytest.raises(XuanHttpsError) as e:
            _create_root_reply_impl(UID, {"postId": pid, "body": bad})
        assert e.value.code == "invalid-argument"


def test_postId_为空报错(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _create_root_reply_impl(UID, {"body": "内容"})
    assert e.value.code == "invalid-argument"


def test_帖子不存在或已删都报_not_found(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _create_root_reply_impl(UID, {"postId": "无", "body": "x"})
    assert e.value.code == "not-found"

    pid = _a_post()
    _tombstone_post_impl(UID, {"postId": pid})
    with pytest.raises(XuanHttpsError) as e:
        _create_root_reply_impl(UID, {"postId": pid, "body": "x"})
    assert e.value.code == "not-found", "已 tombstone 的帖子同样报 not-found"


def test_根回复字段(clean_collections):
    pid = _a_post()
    got = _create_root_reply_impl(UID, {"postId": pid, "body": "  回复内容  "})
    assert got["body"] == "回复内容"
    assert got["depth"] == 0
    assert got["root_reply_id"] is None
    assert got["reply_to_reply_id"] is None
    assert got["is_tombstoned"] is False
    assert got["verification"] is None


def test_落库带可选字段(clean_collections):
    pid = _a_post()
    got = _create_root_reply_impl(UID, {
        "postId": pid, "body": "x",
        "techniqueTags": ["liuyao"],
        "chartAttachment": {"type": "xuanChart"},
        "mediaAttachments": [{"type": "image"}],
    })
    row = clean_collections.collection(COLLECTIONS["replies"]).document(got["id"]).get().to_dict()
    assert row["technique_tags"] == ["liuyao"]
    assert row["chart_attachment"] == {"type": "xuanChart"}
    assert row["media_attachments"] == [{"type": "image"}]
    assert row["presentation_identity_id"].startswith("user_app-")


def test_可选字段缺省值(clean_collections):
    pid = _a_post()
    got = _create_root_reply_impl(UID, {"postId": pid, "body": "x"})
    row = clean_collections.collection(COLLECTIONS["replies"]).document(got["id"]).get().to_dict()
    assert row["technique_tags"] == []
    assert row["chart_attachment"] is None
    assert row["media_attachments"] == []
    assert row["revisions"] == []


def test_幂等重放(clean_collections):
    pid = _a_post()
    payload = {"postId": pid, "body": "幂等回复", "idempotency_key": "rk1"}
    a = _create_root_reply_impl(UID, payload)
    b = _create_root_reply_impl(UID, payload)
    assert a == b
    assert len(list(clean_collections.collection(COLLECTIONS["replies"]).stream())) == 1


from xuan.handlers.replies import _create_discussion_reply_impl


def _post_and_root(uid=UID):
    pid = _create_post_impl(uid, {"text": "宿主"})["id"]
    rid = _create_root_reply_impl(uid, {"postId": pid, "body": "根回复"})["id"]
    return pid, rid


def test_讨论回复_必填校验(clean_collections):
    pid, rid = _post_and_root()
    for bad in [
        {"postId": pid, "rootReplyId": rid},                 # 缺 body
        {"postId": pid, "rootReplyId": rid, "body": "  "},   # 空 body
        {"rootReplyId": rid, "body": "x"},                   # 缺 postId
        {"postId": pid, "body": "x"},                        # 缺 rootReplyId
    ]:
        with pytest.raises(XuanHttpsError) as e:
            _create_discussion_reply_impl(UID, bad)
        assert e.value.code == "invalid-argument"


def test_根回复不存在(clean_collections):
    pid, _ = _post_and_root()
    with pytest.raises(XuanHttpsError) as e:
        _create_discussion_reply_impl(UID, {"postId": pid, "rootReplyId": "无", "body": "x"})
    assert e.value.code == "not-found"


def test_目标不是根回复(clean_collections):
    """拿一条 depth==1 的回复当 rootReplyId 必须被拒。"""
    pid, rid = _post_and_root()
    child = _create_discussion_reply_impl(UID, {"postId": pid, "rootReplyId": rid, "body": "子"})
    with pytest.raises(XuanHttpsError) as e:
        _create_discussion_reply_impl(UID, {"postId": pid, "rootReplyId": child["id"], "body": "孙"})
    assert e.value.code == "invalid-argument"


def test_根回复不属于该帖子(clean_collections):
    _, rid = _post_and_root()
    other_pid = _create_post_impl(UID, {"text": "别的帖"})["id"]
    with pytest.raises(XuanHttpsError) as e:
        _create_discussion_reply_impl(UID, {"postId": other_pid, "rootReplyId": rid, "body": "x"})
    assert e.value.code == "invalid-argument"


def test_根回复已删(clean_collections):
    from xuan.handlers.replies import _delete_reply_impl
    pid, rid = _post_and_root()
    _delete_reply_impl(UID, {"replyId": rid})
    with pytest.raises(XuanHttpsError) as e:
        _create_discussion_reply_impl(UID, {"postId": pid, "rootReplyId": rid, "body": "x"})
    assert e.value.code == "failed-precondition"


def test_不给_replyToReplyId_时默认指向根回复(clean_collections):
    pid, rid = _post_and_root()
    got = _create_discussion_reply_impl(UID, {"postId": pid, "rootReplyId": rid, "body": "子"})
    assert got["depth"] == 1
    assert got["root_reply_id"] == rid
    assert got["reply_to_reply_id"] == rid, "缺省时回落到 rootReplyId"


def test_直接回复根回复本身必须被允许(clean_collections):
    """★ 坑 5：运算符优先级写错会让这个最常见的操作失败。

    根回复自身的 root_reply_id 是 None，不等于 rootReplyId，
    但因为 replyToReplyId === rootReplyId，第三个条件整体为假，必须放行。
    """
    pid, rid = _post_and_root()
    got = _create_discussion_reply_impl(
        UID, {"postId": pid, "rootReplyId": rid, "replyToReplyId": rid, "body": "回复根"})
    assert got["reply_to_reply_id"] == rid
    assert got["depth"] == 1


def test_回复同树的兄弟回复被允许(clean_collections):
    pid, rid = _post_and_root()
    sib = _create_discussion_reply_impl(UID, {"postId": pid, "rootReplyId": rid, "body": "兄"})
    got = _create_discussion_reply_impl(
        UID, {"postId": pid, "rootReplyId": rid, "replyToReplyId": sib["id"], "body": "弟"})
    assert got["reply_to_reply_id"] == sib["id"]


def test_回复别的讨论树的回复被拒(clean_collections):
    pid, rid = _post_and_root()
    other_rid = _create_root_reply_impl(UID, {"postId": pid, "body": "另一根"})["id"]
    other_child = _create_discussion_reply_impl(
        UID, {"postId": pid, "rootReplyId": other_rid, "body": "另一子"})
    with pytest.raises(XuanHttpsError) as e:
        _create_discussion_reply_impl(
            UID, {"postId": pid, "rootReplyId": rid,
                  "replyToReplyId": other_child["id"], "body": "跨树"})
    assert e.value.code == "invalid-argument"


def test_replyToReplyId_类型错误(clean_collections):
    pid, rid = _post_and_root()
    with pytest.raises(XuanHttpsError) as e:
        _create_discussion_reply_impl(
            UID, {"postId": pid, "rootReplyId": rid, "replyToReplyId": 123, "body": "x"})
    assert e.value.code == "invalid-argument"


def test_讨论回复固定字段(clean_collections):
    pid, rid = _post_and_root()
    got = _create_discussion_reply_impl(UID, {"postId": pid, "rootReplyId": rid, "body": "x"})
    row = clean_collections.collection(COLLECTIONS["replies"]).document(got["id"]).get().to_dict()
    assert row["technique_tags"] == [], "讨论回复不接受 techniqueTags"
    assert row["chart_attachment"] is None, "讨论回复不接受 chartAttachment"


from xuan.handlers.replies import _edit_reply_impl, _delete_reply_impl


def test_编辑回复_缺参(clean_collections):
    for bad in [{}, {"replyId": "r"}, {"body": "b"}, {"replyId": "r", "body": " "}]:
        with pytest.raises(XuanHttpsError) as e:
            _edit_reply_impl(UID, bad)
        assert e.value.code == "invalid-argument"


def test_编辑回复_不存在(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _edit_reply_impl(UID, {"replyId": "无", "body": "x"})
    assert e.value.code == "not-found"


def test_编辑回复_非作者被拒(clean_collections):
    pid, rid = _post_and_root()
    with pytest.raises(XuanHttpsError) as e:
        _edit_reply_impl(OTHER, {"replyId": rid, "body": "改"})
    assert e.value.code == "permission-denied"


def test_编辑回复_已删被拒(clean_collections):
    pid, rid = _post_and_root()
    _delete_reply_impl(UID, {"replyId": rid})
    with pytest.raises(XuanHttpsError) as e:
        _edit_reply_impl(UID, {"replyId": rid, "body": "改"})
    assert e.value.code == "failed-precondition"


def test_编辑回复_成功且可选字段按需更新(clean_collections):
    pid, rid = _post_and_root()
    _edit_reply_impl(UID, {"replyId": rid, "body": "  新内容  ", "techniqueTags": ["ziwei"]})
    row = clean_collections.collection(COLLECTIONS["replies"]).document(rid).get().to_dict()
    assert row["body"] == "新内容"
    assert row["technique_tags"] == ["ziwei"]

    # chartAttachment 用 !== undefined 判断，因此显式传 None 会被写入
    _edit_reply_impl(UID, {"replyId": rid, "body": "再改", "chartAttachment": None})
    row = clean_collections.collection(COLLECTIONS["replies"]).document(rid).get().to_dict()
    assert row["chart_attachment"] is None
    assert row["technique_tags"] == ["ziwei"], "未给出的字段保持不变"


def test_删除回复_非作者被拒(clean_collections):
    pid, rid = _post_and_root()
    with pytest.raises(XuanHttpsError) as e:
        _delete_reply_impl(OTHER, {"replyId": rid})
    assert e.value.code == "permission-denied"


def test_删除回复_置_is_tombstoned(clean_collections):
    pid, rid = _post_and_root()
    assert _delete_reply_impl(UID, {"replyId": rid}) == {"success": True}
    row = clean_collections.collection(COLLECTIONS["replies"]).document(rid).get().to_dict()
    assert row["is_tombstoned"] is True


def test_删除回复_重复调用不报错(clean_collections):
    """TS 版删除不校验 is_tombstoned，重复删除幂等 —— 照抄。"""
    pid, rid = _post_and_root()
    _delete_reply_impl(UID, {"replyId": rid})
    assert _delete_reply_impl(UID, {"replyId": rid}) == {"success": True}


