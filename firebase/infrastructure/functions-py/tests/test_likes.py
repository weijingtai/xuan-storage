"""setLike。基准实现：functions/src/likes.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.likes import _set_like_impl


def _seed(client):
    client.collection(COLLECTIONS["posts"]).document("p1").set({"id": "p1"})
    client.collection(COLLECTIONS["replies"]).document("r1").set({"id": "r1"})


def test_两个目标都不给报错(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _set_like_impl("uid_1", {"action": "like"})
    assert e.value.code == "invalid-argument"


def test_点赞帖子_id_格式(clean_collections):
    _seed(clean_collections)
    got = _set_like_impl("uid_1", {"postId": "p1", "action": "like"})
    assert got == {"liked": True, "id": "like_post_uid_1_p1", "target_type": "post"}


def test_点赞回复_id_格式(clean_collections):
    _seed(clean_collections)
    got = _set_like_impl("uid_1", {"replyId": "r1", "action": "like"})
    assert got == {"liked": True, "id": "like_reply_uid_1_r1", "target_type": "reply"}


def test_点赞产生_outbox_事件(clean_collections):
    _seed(clean_collections)
    _set_like_impl("uid_1", {"postId": "p1", "action": "like"})
    events = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["outbox"]).stream()]
    assert len(events) == 1
    assert events[0]["event_type"] == "like_added"
    assert events[0]["post_id"] == "p1"
    assert events[0]["reply_id"] is None


def test_取消点赞产生_removed_事件(clean_collections):
    _seed(clean_collections)
    _set_like_impl("uid_1", {"postId": "p1", "action": "like"})
    _set_like_impl("uid_1", {"postId": "p1", "action": "unlike"})
    types = sorted(
        d.to_dict()["event_type"]
        for d in clean_collections.collection(COLLECTIONS["outbox"]).stream()
    )
    assert types == ["like_added", "like_removed"]


def test_取消一个不存在的赞不产生事件(clean_collections):
    """TS 版只在 like 文档确实存在时才写 removed 事件 —— 必须照抄。"""
    _seed(clean_collections)
    got = _set_like_impl("uid_1", {"postId": "p1", "action": "unlike"})
    assert got == {"liked": False, "id": "like_post_uid_1_p1", "target_type": "post"}
    events = list(clean_collections.collection(COLLECTIONS["outbox"]).stream())
    assert events == [], "不存在的赞不应产生 removed 事件"


def test_目标不存在报错(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _set_like_impl("uid_1", {"postId": "没有这个帖子", "action": "like"})
    assert e.value.code == "not-found"
