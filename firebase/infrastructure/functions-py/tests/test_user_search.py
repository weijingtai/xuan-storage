"""用户搜索与 @ 候选测试。"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.conversations import _block_user_impl
from xuan.handlers.follow import _follow_user_impl
from xuan.handlers.user_search import (
    _get_mention_candidates_impl,
    _search_users_impl,
)
from xuan.identity import resolve_app_user_id

UID_ME = "uid_search_me"
UID_ALICE = "uid_search_alice"
UID_BOB = "uid_search_bob"
UID_CHARLIE = "uid_search_charlie"


def _aid(uid: str) -> str:
    return resolve_app_user_id(uid)["appUserId"]


def test_未登录搜索被拒(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _search_users_impl(None, {"query": "alice"})
    assert e.value.code == "unauthenticated"


def test_空搜索词返回空列表(clean_collections):
    res = _search_users_impl(UID_ME, {"query": "  "})
    assert res["users"] == []
    assert res["total"] == 0


def test_用户名前缀搜索成功(clean_collections):
    alice_id = _aid(UID_ALICE)
    bob_id = _aid(UID_BOB)

    # 写入 profiles
    clean_collections.collection(COLLECTIONS["profiles"]).document(alice_id).set({
        "display_name": "Alice Wonderland",
        "avatar_url": "https://example.com/alice.png",
        "bio": "Magic practitioner",
    })
    clean_collections.collection(COLLECTIONS["profiles"]).document(bob_id).set({
        "display_name": "Bob The Builder",
        "avatar_url": "https://example.com/bob.png",
        "bio": "Astrology fan",
    })

    res = _search_users_impl(UID_ME, {"query": "Alice"})
    assert res["total"] == 1
    assert res["users"][0]["app_user_id"] == alice_id
    assert res["users"][0]["display_name"] == "Alice Wonderland"


def test_拉黑用户在搜索结果中排除(clean_collections):
    alice_id = _aid(UID_ALICE)
    bob_id = _aid(UID_BOB)

    clean_collections.collection(COLLECTIONS["profiles"]).document(alice_id).set({
        "display_name": "Alice Blocked",
    })
    clean_collections.collection(COLLECTIONS["profiles"]).document(bob_id).set({
        "display_name": "Bob Normal",
    })

    # 我拉黑 Alice
    _block_user_impl(UID_ME, {"targetAppUserId": alice_id})

    res = _search_users_impl(UID_ME, {"query": "Block"})
    assert res["total"] == 0
    assert not any(u["app_user_id"] == alice_id for u in res["users"])


def test_未登录获取mention候选被拒(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _get_mention_candidates_impl(None, {})
    assert e.value.code == "unauthenticated"


def test_mention候选_优先返回P0关注和互动用户(clean_collections):
    my_id = _aid(UID_ME)
    alice_id = _aid(UID_ALICE)
    bob_id = _aid(UID_BOB)
    charlie_id = _aid(UID_CHARLIE)

    # 设置 profile
    clean_collections.collection(COLLECTIONS["profiles"]).document(alice_id).set({"display_name": "Alice"})
    clean_collections.collection(COLLECTIONS["profiles"]).document(bob_id).set({"display_name": "Bob"})
    clean_collections.collection(COLLECTIONS["profiles"]).document(charlie_id).set({"display_name": "Charlie"})

    # ME 关注 Alice (P0)
    _follow_user_impl(UID_ME, {"targetAppUserId": alice_id})
    # Bob 关注 ME (P0)
    _follow_user_impl(UID_BOB, {"targetAppUserId": my_id})

    res = _get_mention_candidates_impl(UID_ME, {})
    c_ids = [c["app_user_id"] for c in res["candidates"]]

    # Alice 与 Bob 属于 P0，必须出现在 Charlie (P1) 之前
    assert alice_id in c_ids[:2]
    assert bob_id in c_ids[:2]
    assert my_id not in c_ids, "不得出现自己"


def test_mention候选_排除拉黑用户(clean_collections):
    alice_id = _aid(UID_ALICE)
    clean_collections.collection(COLLECTIONS["profiles"]).document(alice_id).set({"display_name": "Alice"})
    _follow_user_impl(UID_ME, {"targetAppUserId": alice_id})

    # 拉黑 Alice
    _block_user_impl(UID_ME, {"targetAppUserId": alice_id})

    res = _get_mention_candidates_impl(UID_ME, {})
    c_ids = [c["app_user_id"] for c in res["candidates"]]
    assert alice_id not in c_ids
