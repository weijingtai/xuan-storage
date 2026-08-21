"""限流工具。基准实现：functions/src/abuse_control.ts

注意 TS 侧这两个函数是**死代码**（index.ts 未导出、生产零调用）。
本轮迁移并接线，但由开关控制，默认关闭。
"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.rate_limit import check_rate_limit, rate_limit_enabled, record_action


def test_开关默认关闭(monkeypatch):
    monkeypatch.delenv("XUAN_RATE_LIMIT_ENABLED", raising=False)
    assert rate_limit_enabled() is False


@pytest.mark.parametrize("value,expected", [
    ("true", True), ("True", True), ("1", True), ("yes", True),
    ("false", False), ("0", False), ("", False), ("随便什么", False),
])
def test_开关取值(monkeypatch, value, expected):
    monkeypatch.setenv("XUAN_RATE_LIMIT_ENABLED", value)
    assert rate_limit_enabled() is expected


def test_未超限时放行(clean_collections):
    check_rate_limit("app-u1", "create_post", 5)   # 不抛即通过


def test_超限抛_resource_exhausted(clean_collections):
    for i in range(5):
        record_action("app-u2", "create_post", f"key-{i}")
    with pytest.raises(XuanHttpsError) as e:
        check_rate_limit("app-u2", "create_post", 5)
    assert e.value.code == "resource-exhausted"
    assert "5" in str(e.value)


def test_按用户隔离(clean_collections):
    for i in range(3):
        record_action("app-ua", "create_post", f"ua-{i}")
    with pytest.raises(XuanHttpsError):
        check_rate_limit("app-ua", "create_post", 3)
    check_rate_limit("app-ub", "create_post", 3)   # 另一个用户不受影响


def test_按动作隔离(clean_collections):
    for i in range(3):
        record_action("app-uc", "create_post", f"uc-{i}")
    with pytest.raises(XuanHttpsError):
        check_rate_limit("app-uc", "create_post", 3)
    check_rate_limit("app-uc", "create_reply", 3)   # 另一个动作不受影响


def test_记录写入格式(clean_collections):
    record_action("app-ud", "create_post", "ud-1")
    row = clean_collections.collection(COLLECTIONS["idempotency"]).document("rate_ud-1").get().to_dict()
    assert row["app_user_id"] == "app-ud"
    assert row["action"] == "create_post"
    assert "timestamp" in row and "ttl" in row


def test_只统计一分钟窗口内的(clean_collections):
    from datetime import datetime, timedelta, timezone
    old = datetime.now(timezone.utc) - timedelta(minutes=5)
    for i in range(10):
        clean_collections.collection(COLLECTIONS["idempotency"]).document(f"rate_old-{i}").set({
            "app_user_id": "app-ue", "action": "create_post", "timestamp": old,
        })
    check_rate_limit("app-ue", "create_post", 3)   # 窗口外的不计入，应放行
