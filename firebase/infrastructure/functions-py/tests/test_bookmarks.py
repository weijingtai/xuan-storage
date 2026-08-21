"""setBookmark。基准实现：functions/src/bookmarks.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.bookmarks import _set_bookmark_impl


def _seed_post(client, post_id="p1"):
    client.collection(COLLECTIONS["posts"]).document(post_id).set({"id": post_id})


def test_缺少_postId_报错(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _set_bookmark_impl("uid_1", {"action": "bookmark"})
    assert e.value.code == "invalid-argument"


def test_action_非法报错(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _set_bookmark_impl("uid_1", {"postId": "p1", "action": "收藏"})
    assert e.value.code == "invalid-argument"


def test_帖子不存在报错(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _set_bookmark_impl("uid_1", {"postId": "不存在", "action": "bookmark"})
    assert e.value.code == "not-found"


def test_收藏写入文档且_id_格式与_ts_一致(clean_collections):
    _seed_post(clean_collections)
    got = _set_bookmark_impl("uid_1", {"postId": "p1", "action": "bookmark"})

    assert got == {"bookmarked": True, "id": "bookmark_uid_1_p1"}
    snap = clean_collections.collection(COLLECTIONS["bookmarks"]).document("bookmark_uid_1_p1").get()
    assert snap.exists
    data = snap.to_dict()
    assert data["post_id"] == "p1"
    assert data["user_provider_uid"] == "uid_1"
    assert "user_app_user_id" in data
    assert "created_at" in data


def test_取消收藏删除文档(clean_collections):
    _seed_post(clean_collections)
    _set_bookmark_impl("uid_1", {"postId": "p1", "action": "bookmark"})
    got = _set_bookmark_impl("uid_1", {"postId": "p1", "action": "unbookmark"})

    assert got == {"bookmarked": False, "id": "bookmark_uid_1_p1"}
    snap = clean_collections.collection(COLLECTIONS["bookmarks"]).document("bookmark_uid_1_p1").get()
    assert not snap.exists


def test_带幂等键重放不重复执行(clean_collections):
    _seed_post(clean_collections)
    payload = {"postId": "p1", "action": "bookmark", "idempotency_key": "ik1"}
    first = _set_bookmark_impl("uid_1", payload)
    second = _set_bookmark_impl("uid_1", payload)
    assert first == second
