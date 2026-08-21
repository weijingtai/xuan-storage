"""identity 的两个基础函数。注意 resolve_app_user_id 会「不存在则创建」，
因此它对同一 uid 的第二次调用必须返回与第一次完全相同的值。"""
import pytest

from xuan.errors import XuanHttpsError
from xuan.identity import require_auth_uid, resolve_app_user_id


def test_未登录抛_unauthenticated():
    with pytest.raises(XuanHttpsError) as e:
        require_auth_uid(None)
    assert e.value.code == "unauthenticated"

    with pytest.raises(XuanHttpsError) as e:
        require_auth_uid("")
    assert e.value.code == "unauthenticated"


def test_已登录原样返回():
    assert require_auth_uid("uid_1") == "uid_1"


def test_首次解析会创建身份映射(clean_collections):
    got = resolve_app_user_id("uid_new")
    assert got["appUserId"].startswith("app-")
    assert got["publicPresentationId"]
    assert got["publicDisplayAlias"].startswith("玄友")
    assert len(got["publicPresentationId"]) == 32, "128-bit hex 应为 32 字符"


def test_二次解析返回相同身份(clean_collections):
    """幂等性：同一 uid 反复调用必须拿到同一个 appUserId，
    否则用户的历史数据会在第二次调用后全部失联。"""
    first = resolve_app_user_id("uid_same")
    second = resolve_app_user_id("uid_same")
    assert first == second


def test_解析空_uid_抛_unauthenticated(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        resolve_app_user_id(None)
    assert e.value.code == "unauthenticated"
