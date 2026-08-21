"""recalculateReputation。基准实现：functions/src/reputation.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.reputation import _recalculate_reputation_impl as recalc

UID = "uid_rep"
APP_USER_ID = "app_user_rep"


@pytest.fixture(autouse=True)
def _setup_identity(clean_collections):
    clean_collections.collection(COLLECTIONS["identity_map"]).document(UID).set({
        "app_user_id": APP_USER_ID,
        "provider_uid": UID,
        "provider_id": "firebase",
    })


def test_未登录被拒(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        recalc(None, {"appUserId": APP_USER_ID})
    assert e.value.code == "unauthenticated"


def test_appUserId_必填(clean_collections):
    for bad in [{}, {"appUserId": ""}, {"appUserId": 123}]:
        with pytest.raises(XuanHttpsError) as e:
            recalc(UID, bad)
        assert e.value.code == "invalid-argument"


def test_零数据时计数为零并创建_profile(clean_collections):
    got = recalc(UID, {"appUserId": APP_USER_ID})
    assert got == {
        "app_user_id": APP_USER_ID,
        "playground_like_count": 0,
        "playground_verification_count": 0,
    }
    row = clean_collections.collection(COLLECTIONS["profiles"]).document(APP_USER_ID).get().to_dict()
    assert row["app_user_id"] == APP_USER_ID, "profile 不存在时用 set 创建"


def test_统计点赞数(clean_collections):
    for i in range(3):
        clean_collections.collection(COLLECTIONS["likes"]).document(f"l{i}").set(
            {"user_app_user_id": APP_USER_ID})
    clean_collections.collection(COLLECTIONS["likes"]).document("other").set(
        {"user_app_user_id": "app-other"})
    got = recalc(UID, {"appUserId": APP_USER_ID})
    assert got["playground_like_count"] == 3


def test_统计应验数且排除已撤销(clean_collections):
    """★ 坑 2：revoked_at == None 只命中显式 null。"""
    col = clean_collections.collection(COLLECTIONS["verifications"])
    col.document("v1").set({"verifier_app_user_id": APP_USER_ID, "revoked_at": None})
    col.document("v2").set({"verifier_app_user_id": APP_USER_ID, "revoked_at": None})
    col.document("v3").set({"verifier_app_user_id": APP_USER_ID, "revoked_at": "2026-01-01"})
    got = recalc(UID, {"appUserId": APP_USER_ID})
    assert got["playground_verification_count"] == 2, "已撤销的不计入"


def test_已有_profile_时用_update_不覆盖其他字段(clean_collections):
    ref = clean_collections.collection(COLLECTIONS["profiles"]).document(APP_USER_ID)
    ref.set({"display_name": "原名", "bio": "原简介"})
    recalc(UID, {"appUserId": APP_USER_ID})
    row = ref.get().to_dict()
    assert row["display_name"] == "原名", "update 不得清掉既有字段"
    assert row["playground_like_count"] == 0


def test_非本人重算信誉被拒_返回_permission_denied(clean_collections):
    """L-1 修复：只允许重算调用者自己的信誉，操作他人抛 permission-denied。"""
    with pytest.raises(XuanHttpsError) as e:
        recalc(UID, {"appUserId": "app-别人的"})
    assert e.value.code == "permission-denied"

