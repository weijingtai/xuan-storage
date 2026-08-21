"""回复相关样本集（A4 批次）。"""
from tools.replay.models import ReplaySample

SAMPLES = [
    ReplaySample(
        id="create_root_reply_normal",
        description="正常创建根回复：登录用户对活跃帖子发表深度为 0 的回复",
        ts_function="createRootReply",
        py_function="create_root_reply_py",
        auth_email="reply_author@example.com",
        auth_uid="uid_reply_author_1",
        expected_status=200,
        seed_data={
            "playground_posts": {
                "active_post_1": {
                    "id": "active_post_1",
                    "text": "这是一个帖子",
                    "status": "active",
                }
            }
        },
        data={
            "postId": "active_post_1",
            "body": "这是一条专业的根回复解盘内容。",
            "techniqueTags": ["bazi"],
        },
    ),
    ReplaySample(
        id="create_root_reply_post_not_found",
        description="对不存在的帖子发表回复：预期返回 404 NOT_FOUND",
        ts_function="createRootReply",
        py_function="create_root_reply_py",
        auth_email="reply_author@example.com",
        auth_uid="uid_reply_author_1",
        expected_status=404,
        data={
            "postId": "nonexistent_post_999",
            "body": "回复内容",
        },
    ),
    ReplaySample(
        id="create_root_reply_unauthenticated",
        description="未登录发表根回复：预期返回 401 UNAUTHENTICATED",
        ts_function="createRootReply",
        py_function="create_root_reply_py",
        auth_email=None,
        expected_status=401,
        data={
            "postId": "active_post_1",
            "body": "未登录回复",
        },
    ),
    ReplaySample(
        id="create_discussion_reply_normal",
        description="正常创建讨论回复：针对根回复进行讨论回复（depth=1）",
        ts_function="createDiscussionReply",
        py_function="create_discussion_reply_py",
        auth_email="discuss_user@example.com",
        auth_uid="uid_discuss_user_1",
        expected_status=200,
        known_static_ids={"post_discuss_1", "root_reply_1"},
        seed_data={
            "playground_posts": {
                "post_discuss_1": {
                    "id": "post_discuss_1",
                    "text": "讨论主贴",
                    "status": "active",
                }
            },
            "playground_replies": {
                "root_reply_1": {
                    "id": "root_reply_1",
                    "post_id": "post_discuss_1",
                    "root_reply_id": None,
                    "depth": 0,
                    "body": "根回复",
                    "is_tombstoned": False,
                }
            },
        },
        data={
            "postId": "post_discuss_1",
            "rootReplyId": "root_reply_1",
            "body": "对根回复的补充讨论。",
        },
    ),
    ReplaySample(
        id="create_discussion_reply_nested",
        description="多级讨论回复：针对讨论回复指定 replyToReplyId",
        ts_function="createDiscussionReply",
        py_function="create_discussion_reply_py",
        auth_email="discuss_user_2@example.com",
        auth_uid="uid_discuss_user_2",
        expected_status=200,
        known_static_ids={
            "post_discuss_2",
            "root_reply_2",
            "sub_reply_2",
            "uid_discuss_user_2",
            "app_discuss_user_2",
            "pres_discuss_2",
        },
        seed_data={
            "identity_map": {
                "uid_discuss_user_2": {
                    "app_user_id": "app_discuss_user_2",
                    "provider_uid": "uid_discuss_user_2",
                    "provider_id": "firebase",
                    "public_presentation_id": "pres_discuss_2",
                    "public_display_alias": "玄友8888",
                }
            },
            "playground_posts": {
                "post_discuss_2": {
                    "id": "post_discuss_2",
                    "text": "讨论主贴2",
                    "status": "active",
                }
            },
            "playground_replies": {
                "root_reply_2": {
                    "id": "root_reply_2",
                    "post_id": "post_discuss_2",
                    "root_reply_id": None,
                    "depth": 0,
                    "body": "根回复2",
                    "is_tombstoned": False,
                },
                "sub_reply_2": {
                    "id": "sub_reply_2",
                    "post_id": "post_discuss_2",
                    "root_reply_id": "root_reply_2",
                    "reply_to_reply_id": "root_reply_2",
                    "depth": 1,
                    "body": "一级讨论",
                    "is_tombstoned": False,
                },
            },
        },
        data={
            "postId": "post_discuss_2",
            "rootReplyId": "root_reply_2",
            "replyToReplyId": "sub_reply_2",
            "body": "对一级讨论的楼中楼回复。",
        },
    ),
    ReplaySample(
        id="create_discussion_reply_root_not_found",
        description="根回复不存在时创建讨论回复：预期返回 404 NOT_FOUND",
        ts_function="createDiscussionReply",
        py_function="create_discussion_reply_py",
        auth_email="discuss_user@example.com",
        auth_uid="uid_discuss_user_1",
        expected_status=404,
        seed_data={
            "playground_posts": {
                "post_discuss_3": {
                    "id": "post_discuss_3",
                    "text": "主贴3",
                    "status": "active",
                }
            }
        },
        data={
            "postId": "post_discuss_3",
            "rootReplyId": "nonexistent_root_999",
            "body": "回复内容",
        },
    ),
    ReplaySample(
        id="edit_reply_normal",
        description="作者正常编辑回复：更新 body 内容",
        ts_function="editReply",
        py_function="edit_reply_py",
        auth_email="reply_editor@example.com",
        auth_uid="reply_editor_uid",
        expected_status=200,
        known_static_ids={"reply_editor_uid", "app_reply_editor", "reply_to_edit_1"},
        seed_data={
            "identity_map": {
                "reply_editor_uid": {
                    "app_user_id": "app_reply_editor",
                    "provider_uid": "reply_editor_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_replies": {
                "reply_to_edit_1": {
                    "id": "reply_to_edit_1",
                    "author_provider_uid": "reply_editor_uid",
                    "author_app_user_id": "app_reply_editor",
                    "body": "原回复内容",
                    "is_tombstoned": False,
                    "created_at": "2026-08-20T10:00:00Z",
                    "updated_at": "2026-08-20T10:00:00Z",
                }
            },
        },
        data={
            "replyId": "reply_to_edit_1",
            "body": "修改后的回复内容",
        },
    ),
    ReplaySample(
        id="edit_reply_non_author",
        description="非作者尝试编辑回复：预期返回 403 PERMISSION_DENIED",
        ts_function="editReply",
        py_function="edit_reply_py",
        auth_email="hacker_user@example.com",
        auth_uid="uid_hacker_user",
        expected_status=403,
        known_static_ids={"uid_hacker_user", "other_author_uid", "reply_to_edit_other"},
        seed_data={
            "playground_replies": {
                "reply_to_edit_other": {
                    "id": "reply_to_edit_other",
                    "author_provider_uid": "other_author_uid",
                    "body": "他人回复",
                    "is_tombstoned": False,
                }
            }
        },
        data={
            "replyId": "reply_to_edit_other",
            "body": "篡改内容",
        },
    ),
    ReplaySample(
        id="delete_reply_normal",
        description="作者正常删除回复：is_tombstoned 设为 true",
        ts_function="deleteReply",
        py_function="delete_reply_py",
        auth_email="reply_deleter@example.com",
        auth_uid="reply_deleter_uid",
        expected_status=200,
        known_static_ids={"reply_deleter_uid", "app_reply_deleter", "reply_to_delete_1"},
        seed_data={
            "identity_map": {
                "reply_deleter_uid": {
                    "app_user_id": "app_reply_deleter",
                    "provider_uid": "reply_deleter_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_replies": {
                "reply_to_delete_1": {
                    "id": "reply_to_delete_1",
                    "author_provider_uid": "reply_deleter_uid",
                    "author_app_user_id": "app_reply_deleter",
                    "body": "待删除回复",
                    "is_tombstoned": False,
                }
            },
        },
        data={
            "replyId": "reply_to_delete_1",
        },
    ),
    ReplaySample(
        id="delete_reply_non_author",
        description="非作者尝试删除回复：预期返回 403 PERMISSION_DENIED",
        ts_function="deleteReply",
        py_function="delete_reply_py",
        auth_email="hacker_user@example.com",
        auth_uid="uid_hacker_user",
        expected_status=403,
        known_static_ids={"uid_hacker_user", "real_owner_reply_uid", "reply_delete_other"},
        seed_data={
            "playground_replies": {
                "reply_delete_other": {
                    "id": "reply_delete_other",
                    "author_provider_uid": "real_owner_reply_uid",
                    "body": "他人回复",
                    "is_tombstoned": False,
                }
            }
        },
        data={
            "replyId": "reply_delete_other",
        },
    ),
]
