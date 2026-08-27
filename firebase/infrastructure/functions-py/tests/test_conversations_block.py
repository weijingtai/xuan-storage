"""拉黑与解除拉黑（固定 ID 事务机制）专项测试。"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.conversations import _block_user_impl, _unblock_user_impl
from xuan.identity import resolve_app_user_id

UID_A = "uid_block_a"
UID_B = "uid_block_b"


def _aid(uid: str) -> str:
    return resolve_app_user_id(uid)["appUserId"]


def test_拉黑写入确定性固定ID文档(clean_collections):
    aid, bid = _aid(UID_A), _aid(UID_B)
    expected_doc_id = f"block_{aid}_{bid}"

    res = _block_user_impl(UID_A, {"targetAppUserId": bid})
    assert res == {"blocked": True}

    doc = clean_collections.collection(COLLECTIONS["blocks"]).document(expected_doc_id).get()
    assert doc.exists, "必须以 block_${caller}_${target} 为文档 ID"
    d_data = doc.to_dict()
    assert d_data["id"] == expected_doc_id
    assert d_data["blocker_app_user_id"] == aid
    assert d_data["blocked_app_user_id"] == bid


def test_重复拉黑事务防并发_返回_already_blocked(clean_collections):
    aid, bid = _aid(UID_A), _aid(UID_B)
    res1 = _block_user_impl(UID_A, {"targetAppUserId": bid})
    assert res1 == {"blocked": True}

    res2 = _block_user_impl(UID_A, {"targetAppUserId": bid, "idempotency_key": "diff_key"})
    assert res2 == {"blocked": True, "already_blocked": True}

    rows = list(clean_collections.collection(COLLECTIONS["blocks"]).stream())
    assert len(rows) == 1, "不得产生多条拉黑记录"


def test_取消拉黑事务删除确定性文档(clean_collections):
    aid, bid = _aid(UID_A), _aid(UID_B)
    expected_doc_id = f"block_{aid}_{bid}"
    _block_user_impl(UID_A, {"targetAppUserId": bid})

    unb_res = _unblock_user_impl(UID_A, {"targetAppUserId": bid})
    assert unb_res == {"unblocked": True, "removed": 1}

    doc = clean_collections.collection(COLLECTIONS["blocks"]).document(expected_doc_id).get()
    assert not doc.exists


def test_取消拉黑兼容清理旧格式文档(clean_collections):
    aid, bid = _aid(UID_A), _aid(UID_B)
    # 模拟历史非固定 ID 文档
    clean_collections.collection(COLLECTIONS["blocks"]).document("legacy_blk_1").set({
        "id": "legacy_blk_1",
        "blocker_app_user_id": aid,
        "blocked_app_user_id": bid,
    })

    unb_res = _unblock_user_impl(UID_A, {"targetAppUserId": bid})
    assert unb_res == {"unblocked": True, "removed": 1}
    assert list(clean_collections.collection(COLLECTIONS["blocks"]).stream()) == []


def test_自我拉黑与自我取消拉黑校验(clean_collections):
    aid = _aid(UID_A)
    with pytest.raises(XuanHttpsError) as e:
        _block_user_impl(UID_A, {"targetAppUserId": aid})
    assert e.value.code == "invalid-argument"

    with pytest.raises(XuanHttpsError) as e:
        _unblock_user_impl(UID_A, {"targetAppUserId": aid})
    assert e.value.code == "invalid-argument"
