"""触发器相关样本集（A8 批次：onOutboxCreated、onMediaUploaded）。"""
from tools.replay.models import ReplaySample

SAMPLES = [
    ReplaySample(
        id="trigger_outbox_reply_verified",
        description="Outbox 触发器（reply_verified）：写入 outbox 事件，下游触发写入 notifications",
        ts_function="onOutboxCreated",
        py_function="on_outbox_created_py",
        is_trigger=True,
        trigger_type="outbox",
        expected_status=200,
        known_static_ids={"reply_t_1", "app_author_rep", "post_t_1", "outbox_event_v1", "app_verifier_1"},
        seed_data={
            "playground_replies": {
                "reply_t_1": {
                    "id": "reply_t_1",
                    "author_app_user_id": "app_author_rep",
                    "post_id": "post_t_1",
                    "depth": 0,
                    "is_tombstoned": False,
                }
            }
        },
        trigger_action={
            "collection": "playground_outbox",
            "doc_id": "outbox_event_v1",
            "doc_data": {
                "event_type": "reply_verified",
                "post_id": "post_t_1",
                "reply_id": "reply_t_1",
                "verifier_app_user_id": "app_verifier_1",
            },
        },
    ),
    ReplaySample(
        id="trigger_outbox_dm_message",
        description="Outbox 触发器（dm_message）：写入私信 outbox 事件，下游触发写入私信通知",
        ts_function="onOutboxCreated",
        py_function="on_outbox_created_py",
        is_trigger=True,
        trigger_type="outbox",
        expected_status=200,
        known_static_ids={"outbox_event_dm1", "conv_dm_1", "msg_dm_1", "app_recipient_dm", "app_sender_dm"},
        seed_data={},
        trigger_action={
            "collection": "playground_outbox",
            "doc_id": "outbox_event_dm1",
            "doc_data": {
                "event_type": "dm_message",
                "conversation_id": "conv_dm_1",
                "message_id": "msg_dm_1",
                "recipient_app_user_id": "app_recipient_dm",
                "sender_app_user_id": "app_sender_dm",
            },
        },
    ),
    ReplaySample(
        id="trigger_media_upload_finalized",
        description="Storage 触发器（onMediaUploaded）：上传图片对象，下游触发将 media 记录状态由 pending 更新为 ready",
        ts_function="onMediaUploaded",
        py_function="on_media_uploaded_py",
        is_trigger=True,
        trigger_type="storage",
        auth_email="media_uploader@example.com",
        auth_uid="user_media_uploader_1",
        expected_status=200,
        known_static_ids={"media_rec_1", "session_upl_123", "user_media_uploader_1"},
        seed_data={
            "playground_media": {
                "media_rec_1": {
                    "id": "media_rec_1",
                    "upload_session_id": "session_upl_123",
                    "owner_user_id": "user_media_uploader_1",
                    "status": "pending",
                }
            }
        },
        trigger_action={
            "file_path": "playground_media/user_media_uploader_1/session_upl_123/chart.jpg",
            "content_type": "image/jpeg",
        },
    ),
]
