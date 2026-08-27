"""通知推送偏好测试。"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.subscriptions import _set_notification_preference_impl
from xuan.identity import resolve_app_user_id

UID = "uid_sub_user"


def _aid(uid: str) -> str:
    return resolve_app_user_id(uid)["appUserId"]


def test_未登录设置偏好被拒(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _set_notification_preference_impl(None, {"author_alerts": True})
    assert e.value.code == "unauthenticated"


def test_空设置参数被拒(clean_collections):
    for bad in [{}, {"preferences": {}}, {"preference": {}}]:
        with pytest.raises(XuanHttpsError) as e:
            _set_notification_preference_impl(UID, bad)
        assert e.value.code == "invalid-argument"


def test_更新通知偏好成功(clean_collections):
    aid = _aid(UID)
    payload = {
        "author_alerts": True,
        "dm_notifications": True,
        "mention_policy": "relations",
    }
    res = _set_notification_preference_impl(UID, payload)
    assert res["success"] is True
    assert res["app_user_id"] == aid
    assert res["preferences"]["author_alerts"] is True
    assert res["preferences"]["mention_policy"] == "relations"

    doc = clean_collections.collection(COLLECTIONS["subscriptions"]).document(aid).get().to_dict()
    assert doc["user_app_user_id"] == aid
    assert doc["author_alerts"] is True
    assert doc["mention_policy"] == "relations"


def test_合并更新不同偏好(clean_collections):
    aid = _aid(UID)
    _set_notification_preference_impl(UID, {"author_alerts": True})
    _set_notification_preference_impl(UID, {"dm_notifications": False})

    doc = clean_collections.collection(COLLECTIONS["subscriptions"]).document(aid).get().to_dict()
    assert doc["author_alerts"] is True
    assert doc["dm_notifications"] is False


def test_带幂等键正常返回(clean_collections):
    aid = _aid(UID)
    res1 = _set_notification_preference_impl(UID, {
        "author_alerts": True,
        "idempotency_key": "pref_idem_1",
    })
    assert res1["success"] is True

    res2 = _set_notification_preference_impl(UID, {
        "author_alerts": True,
        "idempotency_key": "pref_idem_1",
    })
    assert res2["success"] is True
