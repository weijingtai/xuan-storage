"""resolveMyIdentity。基准实现：functions/src/identity.ts 末段。

它只是 P1 已实现的 resolve_app_user_id 的一层壳，
关键是**不接受任何客户端传入的身份值**。
"""
import pytest

from xuan.errors import XuanHttpsError
from xuan.handlers.identity_callable import _resolve_my_identity_impl as resolve

UID = "uid_ident"


def test_未登录被拒(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        resolve(None)
    assert e.value.code == "unauthenticated"


def test_返回三元组(clean_collections):
    got = resolve(UID)
    assert set(got.keys()) == {"appUserId", "publicPresentationId", "publicDisplayAlias"}
    assert got["appUserId"].startswith("app-")
    assert len(got["publicPresentationId"]) == 32
    assert got["publicDisplayAlias"].startswith("玄友")


def test_重复调用身份稳定(clean_collections):
    assert resolve(UID) == resolve(UID)


def test_不同用户身份不同(clean_collections):
    assert resolve("uid_a")["appUserId"] != resolve("uid_b")["appUserId"]
