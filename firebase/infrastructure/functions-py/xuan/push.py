"""FCM 推送。基准实现：notifications.ts 的 sendPushNotification。

独立成模块的原因：这是全项目唯一会打真实外部服务的代码，
独立后测试只需 monkeypatch 一个 `_send_multicast` 就能全部拦住。
"""

import logging
from typing import Dict

from firebase_admin import messaging

from xuan.config import COLLECTIONS, db

_log = logging.getLogger(__name__)


def _send_multicast(message: messaging.MulticastMessage):
    """真正发出去的那一下。测试通过 monkeypatch 本函数来拦截。"""
    return messaging.send_each_for_multicast(message)


def send_push_notification(
    recipient_app_user_id: str,
    title: str,
    body: str,
    data: Dict[str, str],
) -> bool:
    """给某个用户的全部设备推送。

    ★ 坑 4：**任何异常都被吞掉并返回 False**，绝不影响调用方
    （通知记录必须已经写入，推送只是尽力而为）。
    """
    try:
        snaps = db().collection(COLLECTIONS["fcm_tokens"]) \
            .where("app_user_id", "==", recipient_app_user_id).get()

        tokens = []
        for doc in snaps:
            t = (doc.to_dict() or {}).get("token")
            if t:
                tokens.append(t)
        if not tokens:
            return False

        message = messaging.MulticastMessage(
            tokens=tokens,
            notification=messaging.Notification(title=title, body=body),
            data=data,
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    channel_id="playground_notifications"),
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound="default", badge=1)),
            ),
        )
        _send_multicast(message)
        return True
    except Exception as err:  # noqa: BLE001 —— 有意吞掉，见 docstring
        _log.error("FCM push failed: %s", err)
        return False
