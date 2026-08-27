"""用户关注与取关测试。"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.follow import _follow_user_impl, _unfollow_user_impl
from xuan.identity import resolve_app_user_id

UID_A = "uid_alice"
UID_B = "uid_bob"


def _aid(uid: str) -> str:
    return resolve_app_user_id(uid)["appUserId"]


def test_未登录关注被拒(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _follow_user_impl(None, {"targetAppUserId": "some_user"})
    assert e.value.code == "unauthenticated"


def test_关注参数校验(clean_collections):
    for bad in [{}, {"targetAppUserId": ""}, {"targetAppUserId": 123}, {"targetAppUserId": "   "}]:
        with pytest.raises(XuanHttpsError) as e:
            _follow_user_impl(UID_A, bad)
        assert e.value.code == "invalid-argument"


def test_不能关注自己(clean_collections):
    aid = _aid(UID_A)
    with pytest.raises(XuanHttpsError) as e:
        _follow_user_impl(UID_A, {"targetAppUserId": aid})
    assert e.value.code == "invalid-argument"


def test_关注成功_增加计数与outbox(clean_collections):
    aid, bid = _aid(UID_A), _aid(UID_B)
    res = _follow_user_impl(UID_A, {"targetAppUserId": bid})
    assert res["success"] is True
    assert res["following"] is True

    # 验证 follow 关系文档已写入
    follow_doc = clean_collections.collection(COLLECTIONS["follows"]).document(f"follow_{aid}_{bid}").get()
    assert follow_doc.exists
    f_data = follow_doc.to_dict()
    assert f_data["follower_app_user_id"] == aid
    assert f_data["following_app_user_id"] == bid

    # 验证 profiles 计数器
    a_prof = clean_collections.collection(COLLECTIONS["profiles"]).document(aid).get().to_dict()
    b_prof = clean_collections.collection(COLLECTIONS["profiles"]).document(bid).get().to_dict()
    assert a_prof.get("following_count") == 1
    assert b_prof.get("followers_count") == 1

    # 验证 outbox 事件
    outbox_events = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["outbox"]).stream()]
    follow_events = [e for e in outbox_events if e.get("event_type") == "user_followed"]
    assert len(follow_events) == 1
    assert follow_events[0]["follower_app_user_id"] == aid
    assert follow_events[0]["following_app_user_id"] == bid


def test_重复关注幂等_不重复增加计数(clean_collections):
    bid = _aid(UID_B)
    res1 = _follow_user_impl(UID_A, {"targetAppUserId": bid})
    assert res1["success"] is True

    res2 = _follow_user_impl(UID_A, {"targetAppUserId": bid})
    assert res2["success"] is True
    assert res2.get("already_followed") is True

    # 关系文档依然只有 1 篇
    follows = list(clean_collections.collection(COLLECTIONS["follows"]).stream())
    assert len(follows) == 1

    # 计数依然为 1
    aid = _aid(UID_A)
    a_prof = clean_collections.collection(COLLECTIONS["profiles"]).document(aid).get().to_dict()
    b_prof = clean_collections.collection(COLLECTIONS["profiles"]).document(bid).get().to_dict()
    assert a_prof.get("following_count") == 1
    assert b_prof.get("followers_count") == 1


def test_取关成功_减少计数(clean_collections):
    aid, bid = _aid(UID_A), _aid(UID_B)
    _follow_user_impl(UID_A, {"targetAppUserId": bid})

    unf_res = _unfollow_user_impl(UID_A, {"targetAppUserId": bid})
    assert unf_res["success"] is True
    assert unf_res["following"] is False

    # 验证 follow 关系文档已删除
    follow_doc = clean_collections.collection(COLLECTIONS["follows"]).document(f"follow_{aid}_{bid}").get()
    assert not follow_doc.exists

    # 验证计数扣减
    a_prof = clean_collections.collection(COLLECTIONS["profiles"]).document(aid).get().to_dict()
    b_prof = clean_collections.collection(COLLECTIONS["profiles"]).document(bid).get().to_dict()
    assert a_prof.get("following_count") == 0
    assert b_prof.get("followers_count") == 0


def test_未关注取关幂等(clean_collections):
    bid = _aid(UID_B)
    unf_res = _unfollow_user_impl(UID_A, {"targetAppUserId": bid})
    assert unf_res["success"] is True
    assert unf_res["following"] is False
    assert unf_res.get("already_unfollowed") is True


def test_不能取关自己(clean_collections):
    aid = _aid(UID_A)
    with pytest.raises(XuanHttpsError) as e:
        _unfollow_user_impl(UID_A, {"targetAppUserId": aid})
    assert e.value.code == "invalid-argument"
