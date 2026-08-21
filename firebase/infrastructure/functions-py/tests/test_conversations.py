"""conversations。基准实现：functions/src/conversations.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.conversations import _respond_dm_request_impl, _send_dm_request_impl
from xuan.identity import resolve_app_user_id

A = "uid_a"
B = "uid_b"


def _aid(uid: str) -> str:
    return resolve_app_user_id(uid)["appUserId"]


def test_申请_必填校验(clean_collections):
    bid = _aid(B)
    for bad in [
        {}, {"targetAppUserId": bid}, {"initialMessage": "hi"},
        {"targetAppUserId": bid, "initialMessage": "  "},
        {"targetAppUserId": 123, "initialMessage": "hi"},
    ]:
        with pytest.raises(XuanHttpsError) as e:
            _send_dm_request_impl(A, bad)
        assert e.value.code == "invalid-argument"


def test_不能给自己发申请(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _send_dm_request_impl(A, {"targetAppUserId": _aid(A), "initialMessage": "hi"})
    assert e.value.code == "invalid-argument"


def test_申请成功建会话与首条消息(clean_collections):
    aid, bid = _aid(A), _aid(B)
    got = _send_dm_request_impl(A, {"targetAppUserId": bid, "initialMessage": "  你好  "})
    assert got["status"] == "pending"
    assert set(got["participants"]) == {aid, bid}
    assert got["initiated_by"] == aid

    conv = clean_collections.collection(COLLECTIONS["conversations"]).document(got["conversation_id"]).get().to_dict()
    assert conv["status"] == "pending"
    msgs = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["messages"]).stream()]
    assert len(msgs) == 1
    assert msgs[0]["type"] == "dm_request"
    assert msgs[0]["text"] == "你好", "必须 trim"


def test_重复申请报_already_exists(clean_collections):
    bid = _aid(B)
    _send_dm_request_impl(A, {"targetAppUserId": bid, "initialMessage": "hi"})
    with pytest.raises(XuanHttpsError) as e:
        _send_dm_request_impl(A, {"targetAppUserId": bid, "initialMessage": "再来"})
    assert e.value.code == "already-exists"


def test_send_dm_request_写入_pair_key_且重复请求走点查(clean_collections, monkeypatch):
    """L-4 验证：会话写入 participant_pair_key，且重复申请时通过 pair_key 精确点查（limit=1，读取 1 篇文档而非拉全量）。"""
    aid, bid = _aid(A), _aid(B)
    expected_pair_key = ":".join(sorted([aid, bid]))

    # 预置用户 A 的另外 5 个会话
    for i in range(5):
        other_user = f"app_other_{i}"
        other_key = ":".join(sorted([aid, other_user]))
        clean_collections.collection(COLLECTIONS["conversations"]).document(f"conv_other_{i}").set({
            "id": f"conv_other_{i}",
            "participants": [aid, other_user],
            "participant_pair_key": other_key,
            "status": "active",
        })

    # A 向 B 发起请求
    got = _send_dm_request_impl(A, {"targetAppUserId": bid, "initialMessage": "hi"})
    conv = clean_collections.collection(COLLECTIONS["conversations"]).document(got["conversation_id"]).get().to_dict()
    assert conv.get("participant_pair_key") == expected_pair_key, "新建会话必须写入 participant_pair_key"

    # 监控重复申请时的查询与读取文档数
    pair_key_query_count = 0
    array_contains_query_count = 0

    from google.cloud.firestore_v1.query import Query
    orig_where = Query.where

    def counting_where(self, *args, **kwargs):
        nonlocal pair_key_query_count, array_contains_query_count
        field_path = args[0] if args else kwargs.get("field_path")
        op = args[1] if len(args) > 1 else kwargs.get("op_string")
        if field_path == "participant_pair_key":
            pair_key_query_count += 1
        elif field_path == "participants" and op == "array_contains":
            array_contains_query_count += 1
        return orig_where(self, *args, **kwargs)

    monkeypatch.setattr(Query, "where", counting_where)

    with pytest.raises(XuanHttpsError) as e:
        _send_dm_request_impl(A, {"targetAppUserId": bid, "initialMessage": "重复发"})
    assert e.value.code == "already-exists"

    assert pair_key_query_count == 1, "重复查询时必须走 participant_pair_key 点查"
    assert array_contains_query_count == 0, "命中 pair_key 后不得回落到 array_contains 扫描"


def test_send_dm_request_存量会话无_pair_key_兜底回填且不重复建会话(clean_collections):
    """L-4 验证：存量历史会话无 participant_pair_key 时，通过 array_contains 兜底命中，不重复创建，并惰性回填 key。"""
    aid, bid = _aid(A), _aid(B)
    expected_pair_key = ":".join(sorted([aid, bid]))

    legacy_doc_ref = clean_collections.collection(COLLECTIONS["conversations"]).document("conv_legacy_1")
    legacy_doc_ref.set({
        "id": "conv_legacy_1",
        "participants": [aid, bid],
        # 故意没有 participant_pair_key
        "status": "pending",
        "initiated_by": aid,
    })

    with pytest.raises(XuanHttpsError) as e:
        _send_dm_request_impl(A, {"targetAppUserId": bid, "initialMessage": "再次发起"})
    assert e.value.code == "already-exists"

    # 验证没有创建重复会话
    all_convs = list(clean_collections.collection(COLLECTIONS["conversations"]).stream())
    assert len(all_convs) == 1, "不得重复创建会话"

    # 验证惰性回填了 participant_pair_key
    updated_doc = legacy_doc_ref.get().to_dict()
    assert updated_doc.get("participant_pair_key") == expected_pair_key, "兜底命中必须惰性回填 participant_pair_key"



def test_响应_必填校验(clean_collections):
    for bad in [{}, {"conversationId": "c"}, {"conversationId": "c", "accept": "yes"}]:
        with pytest.raises(XuanHttpsError) as e:
            _respond_dm_request_impl(B, bad)
        assert e.value.code == "invalid-argument"


def test_响应_会话不存在(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _respond_dm_request_impl(B, {"conversationId": "无", "accept": True})
    assert e.value.code == "not-found"


def test_响应_非参与者被拒(clean_collections):
    got = _send_dm_request_impl(A, {"targetAppUserId": _aid(B), "initialMessage": "hi"})
    with pytest.raises(XuanHttpsError) as e:
        _respond_dm_request_impl("uid_c", {"conversationId": got["conversation_id"], "accept": True})
    assert e.value.code == "permission-denied"


def test_响应_发起人不能自己响应(clean_collections):
    got = _send_dm_request_impl(A, {"targetAppUserId": _aid(B), "initialMessage": "hi"})
    with pytest.raises(XuanHttpsError) as e:
        _respond_dm_request_impl(A, {"conversationId": got["conversation_id"], "accept": True})
    assert e.value.code == "permission-denied"


def test_接受_置_active_并写_outbox(clean_collections):
    got = _send_dm_request_impl(A, {"targetAppUserId": _aid(B), "initialMessage": "hi"})
    cid = got["conversation_id"]
    res = _respond_dm_request_impl(B, {"conversationId": cid, "accept": True})
    assert res["status"] == "active" and res["success"] is True
    conv = clean_collections.collection(COLLECTIONS["conversations"]).document(cid).get().to_dict()
    assert conv["status"] == "active"
    events = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["outbox"]).stream()]
    assert [e["event_type"] for e in events] == ["dm_accepted"]


def test_拒绝_置_declined_且不写_outbox(clean_collections):
    got = _send_dm_request_impl(A, {"targetAppUserId": _aid(B), "initialMessage": "hi"})
    cid = got["conversation_id"]
    res = _respond_dm_request_impl(B, {"conversationId": cid, "accept": False})
    assert res["status"] == "declined"
    conv = clean_collections.collection(COLLECTIONS["conversations"]).document(cid).get().to_dict()
    assert conv["status"] == "declined"
    assert list(clean_collections.collection(COLLECTIONS["outbox"]).stream()) == [], "拒绝不发通知"


from xuan.handlers.conversations import _send_message_impl


def _active_conv():
    got = _send_dm_request_impl(A, {"targetAppUserId": _aid(B), "initialMessage": "hi"})
    cid = got["conversation_id"]
    _respond_dm_request_impl(B, {"conversationId": cid, "accept": True})
    return cid


def test_发消息_必填校验(clean_collections):
    cid = _active_conv()
    for bad in [{}, {"conversationId": cid}, {"text": "x"}, {"conversationId": cid, "text": " "}]:
        with pytest.raises(XuanHttpsError) as e:
            _send_message_impl(A, bad)
        assert e.value.code == "invalid-argument"


def test_发消息_会话不存在(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _send_message_impl(A, {"conversationId": "无", "text": "x"})
    assert e.value.code == "not-found"


def test_发消息_未激活会话被拒(clean_collections):
    got = _send_dm_request_impl(A, {"targetAppUserId": _aid(B), "initialMessage": "hi"})
    with pytest.raises(XuanHttpsError) as e:
        _send_message_impl(A, {"conversationId": got["conversation_id"], "text": "x"})
    assert e.value.code == "failed-precondition"


def test_发消息_非参与者被拒(clean_collections):
    cid = _active_conv()
    with pytest.raises(XuanHttpsError) as e:
        _send_message_impl("uid_c", {"conversationId": cid, "text": "x"})
    assert e.value.code == "permission-denied"


def test_发消息_成功并写_outbox(clean_collections):
    cid = _active_conv()
    res = _send_message_impl(A, {"conversationId": cid, "text": "  正文  "})
    assert res["text"] == "正文"
    msgs = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["messages"]).stream()]
    assert sorted(m["type"] for m in msgs) == ["dm_request", "message"]
    events = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["outbox"]).stream()]
    dm = [e for e in events if e["event_type"] == "dm_message"]
    assert len(dm) == 1
    assert dm[0]["recipient_app_user_id"] == _aid(B)


def test_发消息_被对方拉黑则拒绝(clean_collections):
    """拦截方向：对方拉黑了我。"""
    cid = _active_conv()
    clean_collections.collection(COLLECTIONS["blocks"]).document("blk").set({
        "blocker_app_user_id": _aid(B), "blocked_app_user_id": _aid(A),
    })
    with pytest.raises(XuanHttpsError) as e:
        _send_message_impl(A, {"conversationId": cid, "text": "x"})
    assert e.value.code == "permission-denied"


def test_发消息_我拉黑对方不影响我发送(clean_collections):
    """反方向不拦：我拉黑了对方，我仍可发（与 TS 一致）。"""
    cid = _active_conv()
    clean_collections.collection(COLLECTIONS["blocks"]).document("blk2").set({
        "blocker_app_user_id": _aid(A), "blocked_app_user_id": _aid(B),
    })
    res = _send_message_impl(A, {"conversationId": cid, "text": "仍可发"})
    assert res["text"] == "仍可发"


from xuan.handlers.conversations import _block_user_impl, _unblock_user_impl


def test_拉黑_必填与自拉黑(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _block_user_impl(A, {})
    assert e.value.code == "invalid-argument"
    with pytest.raises(XuanHttpsError) as e:
        _block_user_impl(A, {"targetAppUserId": _aid(A)})
    assert e.value.code == "invalid-argument"


def test_拉黑成功(clean_collections):
    got = _block_user_impl(A, {"targetAppUserId": _aid(B)})
    assert got == {"blocked": True}
    rows = list(clean_collections.collection(COLLECTIONS["blocks"]).stream())
    assert len(rows) == 1


def test_重复拉黑不写第二条(clean_collections):
    """★ 坑 6：已拉黑时直接返回，且返回体多一个 already_blocked。"""
    bid = _aid(B)
    _block_user_impl(A, {"targetAppUserId": bid})
    got = _block_user_impl(A, {"targetAppUserId": bid, "idempotency_key": "diff_key"})
    assert got == {"blocked": True, "already_blocked": True}
    rows = list(clean_collections.collection(COLLECTIONS["blocks"]).stream())
    assert len(rows) == 1, "不得堆积第二条 block 记录"


def test_取消拉黑_返回删除条数(clean_collections):
    bid = _aid(B)
    _block_user_impl(A, {"targetAppUserId": bid})
    got = _unblock_user_impl(A, {"targetAppUserId": bid})
    assert got == {"unblocked": True, "removed": 1}
    assert list(clean_collections.collection(COLLECTIONS["blocks"]).stream()) == []


def test_取消未拉黑的人_removed_为零(clean_collections):
    got = _unblock_user_impl(A, {"targetAppUserId": _aid(B)})
    assert got == {"unblocked": True, "removed": 0}


def test_取消拉黑_必填校验(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        _unblock_user_impl(A, {})
    assert e.value.code == "invalid-argument"


def test_取消拉黑_不能取消拉黑自己_返回_invalid_argument(clean_collections):
    """L-2 修复：unblockUser 补上自我校验，抛 invalid-argument。"""
    with pytest.raises(XuanHttpsError) as e:
        _unblock_user_impl(A, {"targetAppUserId": _aid(A)})
    assert e.value.code == "invalid-argument"



