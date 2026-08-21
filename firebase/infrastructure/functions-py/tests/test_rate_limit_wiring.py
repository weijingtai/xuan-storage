"""限流接线。

核心断言有两条：
  1. 开关关闭时（默认）行为与 P1–P5 完全一致 —— 这是影子比对能继续的前提
  2. 开关打开时超限被拒
"""
import pytest

from xuan.errors import XuanHttpsError
from xuan.handlers.posts import _create_post_impl

UID = "uid_rl"


@pytest.fixture()
def rl_on(monkeypatch):
    monkeypatch.setenv("XUAN_RATE_LIMIT_ENABLED", "true")


@pytest.fixture()
def rl_off(monkeypatch):
    monkeypatch.delenv("XUAN_RATE_LIMIT_ENABLED", raising=False)


def test_默认关闭时不受限(clean_collections, rl_off):
    """★ 影子比对期的关键保证：不开开关就跟以前一模一样。"""
    for i in range(40):
        _create_post_impl(UID, {"text": f"帖子{i}"})
    assert len(list(clean_collections.collection("playground_posts").stream())) == 40


def test_关闭时不写限流记录(clean_collections, rl_off):
    _create_post_impl(UID, {"text": "x"})
    rate_rows = [d for d in clean_collections.collection("playground_idempotency").stream()
                 if d.id.startswith("rate_")]
    assert rate_rows == [], "关闭时不应产生限流记录"


def test_打开后超限被拒(clean_collections, rl_on):
    from xuan.rate_limit import record_action
    for i in range(30):
        record_action(_app_id(UID), "create_post", f"pre-{i}")
    with pytest.raises(XuanHttpsError) as e:
        _create_post_impl(UID, {"text": "第31个"})
    assert e.value.code == "resource-exhausted"


def test_打开后未超限正常(clean_collections, rl_on):
    got = _create_post_impl(UID, {"text": "正常发帖"})
    assert got["status"] == "active"


def _app_id(uid: str) -> str:
    from xuan.identity import resolve_app_user_id
    return resolve_app_user_id(uid)["appUserId"]
