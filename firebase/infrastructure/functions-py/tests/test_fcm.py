"""FCM 令牌注册。基准实现：functions/src/fcm.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.fcm import (
    _register_fcm_token_impl as reg,
    _unregister_fcm_token_impl as unreg,
)

UID = "uid_fcm"
TOKEN = "cXyZ123:APA91bF_long_token_value-with_dashes"


def test_未登录被拒(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        reg(None, {"token": TOKEN})
    assert e.value.code == "unauthenticated"


def test_token_必填(clean_collections):
    for bad in [{}, {"token": ""}, {"token": 123}, {"token": None}]:
        with pytest.raises(XuanHttpsError) as e:
            reg(UID, bad)
        assert e.value.code == "invalid-argument"


def test_注册成功_文档_id_格式(clean_collections):
    got = reg(UID, {"token": TOKEN, "platform": "android"})
    assert got == {"success": True, "token_id": f"fcm_{UID}_{TOKEN}"}

    row = clean_collections.collection(COLLECTIONS["fcm_tokens"]).document(got["token_id"]).get().to_dict()
    assert row["provider_uid"] == UID
    assert row["token"] == TOKEN
    assert row["platform"] == "android"
    assert "app_user_id" in row
    assert "registered_at" in row and "last_used_at" in row


def test_platform_缺省为_unknown(clean_collections):
    got = reg(UID, {"token": TOKEN})
    row = clean_collections.collection(COLLECTIONS["fcm_tokens"]).document(got["token_id"]).get().to_dict()
    assert row["platform"] == "unknown"


def test_platform_空串被保留而不是替换(clean_collections):
    """★ 坑 3：TS 用 ?? 不是 ||，空串是有效值。"""
    got = reg(UID, {"token": TOKEN, "platform": ""})
    row = clean_collections.collection(COLLECTIONS["fcm_tokens"]).document(got["token_id"]).get().to_dict()
    assert row["platform"] == "", "空串必须原样保留，不得回落到 unknown"


def test_长_token_不超出文档_id_限制(clean_collections):
    """★ 坑 2：真实 FCM token 约 150+ 字符，确认没踩 1500 字节上限。"""
    long_token = "d" * 200 + ":APA91b" + "X" * 140
    got = reg(UID, {"token": long_token})
    assert len(got["token_id"].encode("utf-8")) < 1500
    assert clean_collections.collection(COLLECTIONS["fcm_tokens"]).document(got["token_id"]).get().exists


def test_重复注册同一_token_覆盖而非新增(clean_collections):
    """确定性文档 id 天然幂等。"""
    reg(UID, {"token": TOKEN, "platform": "ios"})
    reg(UID, {"token": TOKEN, "platform": "android"})
    rows = list(clean_collections.collection(COLLECTIONS["fcm_tokens"]).stream())
    assert len(rows) == 1
    assert rows[0].to_dict()["platform"] == "android", "后写覆盖"


def test_不同用户同一_token_互不影响(clean_collections):
    reg("uid_a", {"token": TOKEN})
    reg("uid_b", {"token": TOKEN})
    assert len(list(clean_collections.collection(COLLECTIONS["fcm_tokens"]).stream())) == 2


def test_注销_必填校验(clean_collections):
    for bad in [{}, {"token": ""}, {"token": 42}]:
        with pytest.raises(XuanHttpsError) as e:
            unreg(UID, bad)
        assert e.value.code == "invalid-argument"


def test_注销成功(clean_collections):
    reg(UID, {"token": TOKEN})
    assert unreg(UID, {"token": TOKEN}) == {"success": True}
    assert list(clean_collections.collection(COLLECTIONS["fcm_tokens"]).stream()) == []


def test_注销不存在的_token_不报错(clean_collections):
    """TS 版直接 delete，不校验存在性 —— 天然幂等。"""
    assert unreg(UID, {"token": "从未注册过"}) == {"success": True}


def test_注销只删自己的(clean_collections):
    reg("uid_a", {"token": TOKEN})
    reg("uid_b", {"token": TOKEN})
    unreg("uid_a", {"token": TOKEN})
    rows = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["fcm_tokens"]).stream()]
    assert len(rows) == 1 and rows[0]["provider_uid"] == "uid_b"
