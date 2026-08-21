"""通知分发。基准实现：functions/src/notifications.ts

测试直接调用纯函数 handle_outbox_event，不走 Firebase 事件投递。
"""
import pytest

from xuan.config import COLLECTIONS
from xuan.handlers.notifications import handle_outbox_event

AUTHOR_APP = "app-author"
ACTOR_APP = "app-actor"


@pytest.fixture()
def no_push(monkeypatch):
    """拦住全部推送，并记录调用。"""
    calls = []
    monkeypatch.setattr(
        "xuan.handlers.notifications.send_push_notification",
        lambda *a, **k: calls.append(a) or True,
    )
    return calls


def _a_reply(client, reply_id="r1"):
    client.collection(COLLECTIONS["replies"]).document(reply_id).set(
        {"id": reply_id, "author_app_user_id": AUTHOR_APP})
    return reply_id


def test_未知事件类型不产生通知(clean_collections, no_push):
    assert handle_outbox_event("ev1", {"event_type": "根本没这种事件"}) is None
    assert list(clean_collections.collection(COLLECTIONS["notifications"]).stream()) == []


def test_空数据不崩(clean_collections, no_push):
    assert handle_outbox_event("ev1", {}) is None


def test_应验通知_写记录并推送(clean_collections, no_push):
    _a_reply(clean_collections)
    nid = handle_outbox_event("ev_v", {
        "event_type": "reply_verified", "post_id": "p1",
        "reply_id": "r1", "verifier_app_user_id": ACTOR_APP,
    })
    assert nid is not None
    row = clean_collections.collection(COLLECTIONS["notifications"]).document(nid).get().to_dict()
    assert row["recipient_app_user_id"] == AUTHOR_APP
    assert row["type"] == "reply_verified"
    assert row["is_read"] is False
    assert row["notification_event_id"] == "ev_v"
    assert len(no_push) == 1, "应验要推送"


def test_撤销应验_写记录但不推送(clean_collections, no_push):
    """★ 坑 1：五种事件里只有它不发推送。"""
    _a_reply(clean_collections)
    nid = handle_outbox_event("ev_rv", {
        "event_type": "verification_revoked", "post_id": "p1",
        "reply_id": "r1", "verifier_app_user_id": ACTOR_APP,
    })
    assert nid is not None
    assert len(no_push) == 0, "撤销应验不得推送"


def test_回复不存在则不产生通知(clean_collections, no_push):
    assert handle_outbox_event("ev_x", {
        "event_type": "reply_verified", "post_id": "p1",
        "reply_id": "不存在", "verifier_app_user_id": ACTOR_APP,
    }) is None


def test_去重_同一_outbox_文档只产生一次(clean_collections, no_push):
    """★ 坑 2：trigger 是 at-least-once，必须靠 notification_event_id 去重。"""
    _a_reply(clean_collections)
    payload = {"event_type": "reply_verified", "post_id": "p1",
               "reply_id": "r1", "verifier_app_user_id": ACTOR_APP}
    first = handle_outbox_event("同一个ev", payload)
    second = handle_outbox_event("同一个ev", payload)
    assert first is not None and second is None
    assert len(list(clean_collections.collection(COLLECTIONS["notifications"]).stream())) == 1
    assert len(no_push) == 1, "重复投递不得重复推送"


def test_点赞帖子通知(clean_collections, no_push):
    clean_collections.collection(COLLECTIONS["posts"]).document("p1").set(
        {"id": "p1", "author_app_user_id": AUTHOR_APP})
    nid = handle_outbox_event("ev_l", {
        "event_type": "like_added", "post_id": "p1",
        "reply_id": None, "user_app_user_id": ACTOR_APP,
    })
    row = clean_collections.collection(COLLECTIONS["notifications"]).document(nid).get().to_dict()
    assert row["type"] == "like_added" and row["post_id"] == "p1"
    assert row["reply_id"] is None
    assert len(no_push) == 1


def test_点赞回复通知(clean_collections, no_push):
    _a_reply(clean_collections)
    nid = handle_outbox_event("ev_l2", {
        "event_type": "like_added", "post_id": None,
        "reply_id": "r1", "user_app_user_id": ACTOR_APP,
    })
    row = clean_collections.collection(COLLECTIONS["notifications"]).document(nid).get().to_dict()
    assert row["reply_id"] == "r1" and row["post_id"] is None


def test_自赞不通知(clean_collections, no_push):
    """★ 坑 3。"""
    clean_collections.collection(COLLECTIONS["posts"]).document("p1").set(
        {"id": "p1", "author_app_user_id": ACTOR_APP})
    assert handle_outbox_event("ev_self", {
        "event_type": "like_added", "post_id": "p1",
        "reply_id": None, "user_app_user_id": ACTOR_APP,
    }) is None
    assert len(no_push) == 0


def test_点赞目标不存在不通知(clean_collections, no_push):
    assert handle_outbox_event("ev_l3", {
        "event_type": "like_added", "post_id": "没有",
        "reply_id": None, "user_app_user_id": ACTOR_APP,
    }) is None


def test_私信消息通知(clean_collections, no_push):
    nid = handle_outbox_event("ev_dm", {
        "event_type": "dm_message", "conversation_id": "c1",
        "sender_app_user_id": ACTOR_APP,
        "recipient_app_user_id": AUTHOR_APP, "message_id": "m1",
    })
    row = clean_collections.collection(COLLECTIONS["notifications"]).document(nid).get().to_dict()
    assert row["type"] == "dm_message"
    assert row["conversation_id"] == "c1" and row["message_id"] == "m1"
    assert len(no_push) == 1


def test_私信缺收件人不通知(clean_collections, no_push):
    assert handle_outbox_event("ev_dm2", {
        "event_type": "dm_message", "conversation_id": "c1",
        "sender_app_user_id": ACTOR_APP, "recipient_app_user_id": None,
        "message_id": "m1",
    }) is None


def test_私信被接受通知发起人(clean_collections, no_push):
    clean_collections.collection(COLLECTIONS["conversations"]).document("c1").set(
        {"id": "c1", "initiated_by": AUTHOR_APP})
    nid = handle_outbox_event("ev_ac", {
        "event_type": "dm_accepted", "conversation_id": "c1",
        "user_app_user_id": ACTOR_APP,
    })
    row = clean_collections.collection(COLLECTIONS["notifications"]).document(nid).get().to_dict()
    assert row["recipient_app_user_id"] == AUTHOR_APP
    assert len(no_push) == 1


def test_自己接受自己不通知(clean_collections, no_push):
    """★ 坑 3 的第二处。"""
    clean_collections.collection(COLLECTIONS["conversations"]).document("c1").set(
        {"id": "c1", "initiated_by": ACTOR_APP})
    assert handle_outbox_event("ev_ac2", {
        "event_type": "dm_accepted", "conversation_id": "c1",
        "user_app_user_id": ACTOR_APP,
    }) is None


def test_会话不存在不通知(clean_collections, no_push):
    assert handle_outbox_event("ev_ac3", {
        "event_type": "dm_accepted", "conversation_id": "无",
        "user_app_user_id": ACTOR_APP,
    }) is None


def test_trigger_壳存在且可导入():
    from xuan.handlers.notifications import on_outbox_created_py
    assert on_outbox_created_py is not None


def test_trigger_壳不含业务逻辑():
    """壳只负责解事件 + 转发，业务逻辑全在 handle_outbox_event。

    判据：壳函数源码不超过 12 行，且必须调用 handle_outbox_event。
    """
    import inspect

    from xuan.handlers import notifications

    src = inspect.getsource(notifications.on_outbox_created_py)
    assert "handle_outbox_event" in src, "壳必须转发给纯函数"
    body = [ln for ln in src.splitlines()
            if ln.strip() and not ln.strip().startswith(("#", '"', "@"))]
    assert len(body) <= 12, f"壳过厚（{len(body)} 行），业务逻辑应放进纯函数"
