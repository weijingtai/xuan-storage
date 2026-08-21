"""FCM 推送。基准实现：notifications.ts 的 sendPushNotification。

关键行为：**任何异常都被吞掉**，绝不让推送失败影响通知记录的写入。
"""
import pytest

from xuan.config import COLLECTIONS
from xuan.push import send_push_notification


def test_无令牌时不发送(clean_collections):
    assert send_push_notification("app-无令牌", "标题", "正文", {}) is False


def test_有令牌时发送(clean_collections, monkeypatch):
    sent = {}

    def fake_send(message):
        sent["tokens"] = list(message.tokens)
        sent["title"] = message.notification.title

        class _R:
            success_count = len(message.tokens)
        return _R()

    monkeypatch.setattr("xuan.push._send_multicast", fake_send)

    clean_collections.collection(COLLECTIONS["fcm_tokens"]).document("t1").set(
        {"app_user_id": "app-u", "token": "TOKEN_A"})
    clean_collections.collection(COLLECTIONS["fcm_tokens"]).document("t2").set(
        {"app_user_id": "app-u", "token": "TOKEN_B"})

    assert send_push_notification("app-u", "标题", "正文", {"type": "x"}) is True
    assert sorted(sent["tokens"]) == ["TOKEN_A", "TOKEN_B"]
    assert sent["title"] == "标题"


def test_只发给指定收件人(clean_collections, monkeypatch):
    seen = {}
    monkeypatch.setattr("xuan.push._send_multicast",
                        lambda m: seen.update(tokens=list(m.tokens)) or type("R", (), {"success_count": 1})())
    c = clean_collections.collection(COLLECTIONS["fcm_tokens"])
    c.document("a").set({"app_user_id": "app-a", "token": "A"})
    c.document("b").set({"app_user_id": "app-b", "token": "B"})
    send_push_notification("app-a", "t", "b", {})
    assert seen["tokens"] == ["A"]


def test_令牌字段为空被跳过(clean_collections, monkeypatch):
    monkeypatch.setattr("xuan.push._send_multicast",
                        lambda m: type("R", (), {"success_count": 0})())
    clean_collections.collection(COLLECTIONS["fcm_tokens"]).document("t").set(
        {"app_user_id": "app-u", "token": ""})
    assert send_push_notification("app-u", "t", "b", {}) is False, "空 token 应被过滤，无有效令牌则不发"


def test_发送异常被吞掉不外抛(clean_collections, monkeypatch):
    """★ 坑 4：推送失败绝不能影响调用方。"""
    def boom(_):
        raise RuntimeError("FCM 挂了")

    monkeypatch.setattr("xuan.push._send_multicast", boom)
    clean_collections.collection(COLLECTIONS["fcm_tokens"]).document("t").set(
        {"app_user_id": "app-u", "token": "T"})

    assert send_push_notification("app-u", "t", "b", {}) is False, "异常被吞，返回 False"
