"""updateMyProfile。基准实现：functions/src/profiles.ts

要点：字段全部可选但至少给一个；文档 id 由服务端派生，调用方不能指定。
"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.profiles import _update_my_profile_impl


def test_一个字段都不给报错(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _update_my_profile_impl("uid_1", {})
    assert e.value.code == "invalid-argument"


@pytest.mark.parametrize("field,bad_value", [
    ("displayName", 123),
    ("avatarUrl", []),
    ("bio", {}),
    ("commonTechniques", "不是数组"),
    ("commonTechniques", ["ok", 123]),
])
def test_字段类型错误报错(clean_collections, field, bad_value):
    with pytest.raises(XuanHttpsError) as e:
        _update_my_profile_impl("uid_1", {field: bad_value})
    assert e.value.code == "invalid-argument"


def test_部分更新只写给出的字段(clean_collections):
    got = _update_my_profile_impl("uid_1", {"displayName": "玄友测试"})
    assert got["success"] is True
    app_user_id = got["appUserId"]

    data = clean_collections.collection(COLLECTIONS["profiles"]).document(app_user_id).get().to_dict()
    assert data["display_name"] == "玄友测试"
    assert data["user_provider_uid"] == "uid_1"
    assert "bio" not in data, "未给出的字段不应被写入"


def test_字段名转为_snake_case(clean_collections):
    got = _update_my_profile_impl("uid_1", {
        "displayName": "n", "avatarUrl": "u", "bio": "b",
        "commonTechniques": ["六爻", "紫微"],
    })
    data = clean_collections.collection(COLLECTIONS["profiles"]).document(got["appUserId"]).get().to_dict()
    assert data["display_name"] == "n"
    assert data["avatar_url"] == "u"
    assert data["bio"] == "b"
    assert data["common_techniques"] == ["六爻", "紫微"]


def test_合并写入不覆盖既有字段(clean_collections):
    first = _update_my_profile_impl("uid_1", {"displayName": "第一次"})
    _update_my_profile_impl("uid_1", {"bio": "第二次"})
    data = clean_collections.collection(COLLECTIONS["profiles"]).document(first["appUserId"]).get().to_dict()
    assert data["display_name"] == "第一次", "merge 写入不得清掉上次的字段"
    assert data["bio"] == "第二次"
