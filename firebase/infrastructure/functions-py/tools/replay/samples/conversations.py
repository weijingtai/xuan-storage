"""会话与访客回复相关样本集（A5 批次）。"""
from tools.replay.models import ReplaySample

SAMPLES = [
    ReplaySample(
        id="send_dm_request_normal",
        description="发起私聊申请：正常向目标用户发起申请，创建 pending 对话与消息",
        ts_function="sendDmRequest",
        py_function="send_dm_request_py",
        auth_email="dm_sender@example.com",
        auth_uid="dm_sender_uid",
        expected_status=200,
        data={
            "targetAppUserId": "target_user_app_id_999",
            "initialMessage": "你好，想向您请教命盘细节。",
        },
    ),
    ReplaySample(
        id="send_dm_request_to_self",
        description="向自己发起私聊申请：预期返回 400 INVALID_ARGUMENT",
        ts_function="sendDmRequest",
        py_function="send_dm_request_py",
        auth_email="dm_self_user@example.com",
        auth_uid="self_uid",
        expected_status=400,
        known_static_ids={"self_uid", "app_self_user"},
        seed_data={
            "identity_map": {
                "self_uid": {
                    "app_user_id": "app_self_user",
                    "provider_uid": "self_uid",
                    "provider_id": "firebase",
                }
            }
        },
        data={
            "targetAppUserId": "app_self_user",
            "initialMessage": "发给自己",
        },
    ),
    ReplaySample(
        id="respond_dm_request_accept",
        description="接受私聊申请：被邀请人同意申请，对话激活并投递 dm_accepted 事件",
        ts_function="respondDmRequest",
        py_function="respond_dm_request_py",
        auth_email="dm_recipient@example.com",
        auth_uid="recipient_uid",
        expected_status=200,
        known_static_ids={"recipient_uid", "app_recipient_user", "app_sender_user", "conv_to_accept"},
        seed_data={
            "identity_map": {
                "recipient_uid": {
                    "app_user_id": "app_recipient_user",
                    "provider_uid": "recipient_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_conversations": {
                "conv_to_accept": {
                    "id": "conv_to_accept",
                    "participants": ["app_sender_user", "app_recipient_user"],
                    "initiated_by": "app_sender_user",
                    "status": "pending",
                }
            },
        },
        data={
            "conversationId": "conv_to_accept",
            "accept": True,
        },
    ),
    ReplaySample(
        id="respond_dm_request_decline",
        description="拒绝私聊申请：被邀请人拒绝申请，对话状态变更为 declined",
        ts_function="respondDmRequest",
        py_function="respond_dm_request_py",
        auth_email="dm_recipient_dec@example.com",
        auth_uid="recipient_dec_uid",
        expected_status=200,
        known_static_ids={"recipient_dec_uid", "app_recipient_dec", "app_sender_user", "conv_to_decline"},
        seed_data={
            "identity_map": {
                "recipient_dec_uid": {
                    "app_user_id": "app_recipient_dec",
                    "provider_uid": "recipient_dec_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_conversations": {
                "conv_to_decline": {
                    "id": "conv_to_decline",
                    "participants": ["app_sender_user", "app_recipient_dec"],
                    "initiated_by": "app_sender_user",
                    "status": "pending",
                }
            },
        },
        data={
            "conversationId": "conv_to_decline",
            "accept": False,
        },
    ),
    ReplaySample(
        id="send_message_normal",
        description="在活跃会话中发送消息：成功写入 messages 与 outbox",
        ts_function="sendMessage",
        py_function="send_message_py",
        auth_email="msg_sender@example.com",
        auth_uid="msg_sender_uid",
        expected_status=200,
        known_static_ids={"msg_sender_uid", "app_msg_sender", "app_msg_receiver", "conv_active_1"},
        seed_data={
            "identity_map": {
                "msg_sender_uid": {
                    "app_user_id": "app_msg_sender",
                    "provider_uid": "msg_sender_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_conversations": {
                "conv_active_1": {
                    "id": "conv_active_1",
                    "participants": ["app_msg_sender", "app_msg_receiver"],
                    "status": "active",
                }
            },
        },
        data={
            "conversationId": "conv_active_1",
            "text": "这是一条正常的私信消息内容。",
        },
    ),
    ReplaySample(
        id="send_message_in_pending",
        description="在未激活（pending）会话中发消息：预期返回 400 FAILED_PRECONDITION",
        ts_function="sendMessage",
        py_function="send_message_py",
        auth_email="msg_sender_p@example.com",
        auth_uid="msg_sender_p_uid",
        expected_status=400,
        known_static_ids={"msg_sender_p_uid", "app_msg_sender_p", "app_msg_receiver_p", "conv_pending_1"},
        seed_data={
            "identity_map": {
                "msg_sender_p_uid": {
                    "app_user_id": "app_msg_sender_p",
                    "provider_uid": "msg_sender_p_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_conversations": {
                "conv_pending_1": {
                    "id": "conv_pending_1",
                    "participants": ["app_msg_sender_p", "app_msg_receiver_p"],
                    "status": "pending",
                }
            },
        },
        data={
            "conversationId": "conv_pending_1",
            "text": "偷发消息",
        },
    ),
    ReplaySample(
        id="block_user_normal",
        description="正常拉黑用户：在 blocks 集合写入拉黑记录",
        ts_function="blockUser",
        py_function="block_user_py",
        auth_email="blocker_user@example.com",
        auth_uid="uid_blocker_user",
        expected_status=200,
        data={
            "targetAppUserId": "target_bad_user_999",
        },
    ),
    ReplaySample(
        id="block_user_self",
        description="拉黑自己：预期返回 400 INVALID_ARGUMENT",
        ts_function="blockUser",
        py_function="block_user_py",
        auth_email="blocker_self@example.com",
        auth_uid="uid_blocker_self",
        expected_status=400,
        known_static_ids={"uid_blocker_self", "app_blocker_self"},
        seed_data={
            "identity_map": {
                "uid_blocker_self": {
                    "app_user_id": "app_blocker_self",
                    "provider_uid": "uid_blocker_self",
                    "provider_id": "firebase",
                }
            }
        },
        data={
            "targetAppUserId": "app_blocker_self",
        },
    ),
    ReplaySample(
        id="block_user_unauthenticated",
        description="未登录拉黑用户：预期返回 401 UNAUTHENTICATED",
        ts_function="blockUser",
        py_function="block_user_py",
        auth_email=None,
        expected_status=401,
        data={
            "targetAppUserId": "target_bad_user_999",
        },
    ),
    ReplaySample(
        id="unblock_user_normal",
        description="解除拉黑：删除已有的拉黑记录",
        ts_function="unblockUser",
        py_function="unblock_user_py",
        auth_email="unblocker_user@example.com",
        auth_uid="unblocker_uid",
        expected_status=200,
        known_static_ids={"unblocker_uid", "app_unblocker_user", "app_target_blocked_user", "block_doc_1"},
        seed_data={
            "identity_map": {
                "unblocker_uid": {
                    "app_user_id": "app_unblocker_user",
                    "provider_uid": "unblocker_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_blocks": {
                "block_doc_1": {
                    "id": "block_doc_1",
                    "blocker_app_user_id": "app_unblocker_user",
                    "blocked_app_user_id": "app_target_blocked_user",
                }
            },
        },
        data={
            "targetAppUserId": "app_target_blocked_user",
        },
    ),
    ReplaySample(
        id="unblock_user_unauthenticated",
        description="未登录解除拉黑：预期返回 401 UNAUTHENTICATED",
        ts_function="unblockUser",
        py_function="unblock_user_py",
        auth_email=None,
        expected_status=401,
        data={
            "targetAppUserId": "app_target_blocked_user",
        },
    ),
    ReplaySample(
        id="unblock_user_empty_target",
        description="解除拉黑入参为空：预期返回 400 INVALID_ARGUMENT",
        ts_function="unblockUser",
        py_function="unblock_user_py",
        auth_email="unblocker_user@example.com",
        auth_uid="unblocker_uid",
        expected_status=400,
        data={
            "targetAppUserId": "",
        },
    ),
    ReplaySample(
        id="unblock_user_self",
        description="解除拉黑自己（L-2 修复）：预期返回 400 INVALID_ARGUMENT",
        ts_function="unblockUser",
        py_function="unblock_user_py",
        auth_email="unblocker_self@example.com",
        auth_uid="uid_unblocker_self",
        expected_status=400,
        known_static_ids={"uid_unblocker_self", "app_unblocker_self"},
        seed_data={
            "identity_map": {
                "uid_unblocker_self": {
                    "app_user_id": "app_unblocker_self",
                    "provider_uid": "uid_unblocker_self",
                    "provider_id": "firebase",
                }
            }
        },
        data={
            "targetAppUserId": "app_unblocker_self",
        },
    ),
    ReplaySample(
        id="get_guest_replies_normal",
        description="游客查询代表性回复：按受信规则返回回复列表，隐藏敏感身份",
        ts_function="getGuestRepresentativeReplies",
        py_function="get_guest_representative_replies_py",
        auth_email=None,  # 允许游客调用
        expected_status=200,
        seed_data={
            "playground_posts": {
                "post_guest_1": {
                    "id": "post_guest_1",
                    "status": "active",
                }
            },
            "playground_replies": {
                "reply_g_1": {
                    "id": "reply_g_1",
                    "post_id": "post_guest_1",
                    "root_reply_id": None,
                    "depth": 0,
                    "body": "公开代表性回复1",
                    "like_count": 5,
                    "is_tombstoned": False,
                    "created_at": "2026-08-20T10:00:00Z",
                }
            },
        },
        data={
            "postId": "post_guest_1",
            "limit": 5,
        },
    ),
    ReplaySample(
        id="get_guest_replies_post_not_found",
        description="游客查询不存在帖子的回复：预期返回 404 NOT_FOUND",
        ts_function="getGuestRepresentativeReplies",
        py_function="get_guest_representative_replies_py",
        auth_email=None,
        expected_status=404,
        data={
            "postId": "nonexistent_guest_post_999",
        },
    ),
]
