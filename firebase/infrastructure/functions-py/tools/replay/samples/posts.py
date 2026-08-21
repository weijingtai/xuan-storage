"""帖子相关样本集（A4 批次）。"""
from tools.replay.models import ReplaySample

SAMPLES = [
    ReplaySample(
        id="create_post_normal",
        description="正常创建帖子：登录用户提交内容，预期成功并写入 posts、profiles 与 identity_map 绑定",
        ts_function="createPost",
        py_function="create_post_py",
        auth_email="post_author_1@example.com",
        auth_uid="uid_post_author_1",
        expected_status=200,
        data={
            "text": "这是一个用于离线回放比对的测试帖子内容。",
            "allowed_chart_technique_ids": ["ziwei"],
            "attachments": [],
            "presentation_mode": "stableAlias",
        },
    ),
    ReplaySample(
        id="create_post_anonymous",
        description="匿名创建帖子：使用 oneTimeAnonymous 模式",
        ts_function="createPost",
        py_function="create_post_py",
        auth_email="post_author_anon@example.com",
        auth_uid="uid_post_author_anon",
        expected_status=200,
        data={
            "text": "这是一个单次匿名的测试帖子。",
            "allowed_chart_technique_ids": [],
            "attachments": [],
            "presentation_mode": "oneTimeAnonymous",
        },
    ),
    ReplaySample(
        id="create_post_unauthenticated",
        description="未登录创建帖子：未提供 Auth Token，预期返回 401 UNAUTHENTICATED 且无数据库脏写",
        ts_function="createPost",
        py_function="create_post_py",
        auth_email=None,
        expected_status=401,
        data={
            "text": "应当被鉴权中间件拦截的内容。",
        },
    ),
    ReplaySample(
        id="create_post_invalid_empty_text",
        description="空文本创建帖子：入参校验失败，预期返回 400 INVALID_ARGUMENT",
        ts_function="createPost",
        py_function="create_post_py",
        auth_email="post_author_1@example.com",
        auth_uid="uid_post_author_1",
        expected_status=400,
        data={
            "text": "   ",
        },
    ),
    ReplaySample(
        id="edit_post_normal",
        description="作者正常编辑帖子：更新 text 与 tags，返回最新数据",
        ts_function="editPost",
        py_function="edit_post_py",
        auth_email="author_editor@example.com",
        auth_uid="user_editor_uid",
        expected_status=200,
        known_static_ids={"user_editor_uid", "app_user_editor", "target_post_to_edit", "pres_editor"},
        seed_data={
            "identity_map": {
                "user_editor_uid": {
                    "app_user_id": "app_user_editor",
                    "provider_uid": "user_editor_uid",
                    "provider_id": "firebase",
                    "public_presentation_id": "pres_editor",
                    "public_display_alias": "玄友1111",
                }
            },
            "playground_posts": {
                "target_post_to_edit": {
                    "id": "target_post_to_edit",
                    "author_provider_uid": "user_editor_uid",
                    "author_app_user_id": "app_user_editor",
                    "text": "原始内容",
                    "status": "active",
                    "allowed_chart_technique_ids": ["bazi"],
                    "attachments": [],
                    "revisions": [],
                    "presentation_mode": "stableAlias",
                    "created_at": "2026-08-20T10:00:00Z",
                    "updated_at": "2026-08-20T10:00:00Z",
                }
            },
        },
        data={
            "postId": "target_post_to_edit",
            "text": "修改后的帖子内容",
            "allowed_chart_technique_ids": ["bazi", "ziwei"],
        },
    ),
    ReplaySample(
        id="edit_post_non_author",
        description="非作者尝试编辑帖子：预期返回 403 PERMISSION_DENIED",
        ts_function="editPost",
        py_function="edit_post_py",
        auth_email="hacker_user@example.com",
        auth_uid="uid_hacker_user",
        expected_status=403,
        known_static_ids={"uid_hacker_user", "real_author_uid", "app_real_author", "target_post_other"},
        seed_data={
            "playground_posts": {
                "target_post_other": {
                    "id": "target_post_other",
                    "author_provider_uid": "real_author_uid",
                    "author_app_user_id": "app_real_author",
                    "text": "他人内容",
                    "status": "active",
                }
            },
        },
        data={
            "postId": "target_post_other",
            "text": "恶意篡改",
        },
    ),
    ReplaySample(
        id="edit_post_not_found",
        description="编辑不存在的帖子：预期返回 404 NOT_FOUND",
        ts_function="editPost",
        py_function="edit_post_py",
        auth_email="author_editor@example.com",
        auth_uid="user_editor_uid",
        expected_status=404,
        data={
            "postId": "nonexistent_post_id_999",
            "text": "修改内容",
        },
    ),
    ReplaySample(
        id="tombstone_post_normal",
        description="作者正常软删除（墓碑化）帖子：status 变为 tombstoned",
        ts_function="tombstonePost",
        py_function="tombstone_post_py",
        auth_email="author_tomb@example.com",
        auth_uid="author_tomb_uid",
        expected_status=200,
        known_static_ids={"author_tomb_uid", "app_author_tomb", "target_post_to_delete"},
        seed_data={
            "identity_map": {
                "author_tomb_uid": {
                    "app_user_id": "app_author_tomb",
                    "provider_uid": "author_tomb_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_posts": {
                "target_post_to_delete": {
                    "id": "target_post_to_delete",
                    "author_provider_uid": "author_tomb_uid",
                    "author_app_user_id": "app_author_tomb",
                    "text": "待删除内容",
                    "status": "active",
                }
            },
        },
        data={
            "postId": "target_post_to_delete",
        },
    ),
    ReplaySample(
        id="tombstone_post_non_author",
        description="非作者尝试删除帖子：预期返回 403 PERMISSION_DENIED",
        ts_function="tombstonePost",
        py_function="tombstone_post_py",
        auth_email="hacker_user@example.com",
        auth_uid="uid_hacker_user",
        expected_status=403,
        known_static_ids={"uid_hacker_user", "real_owner_uid", "app_real_owner", "target_post_delete_other"},
        seed_data={
            "playground_posts": {
                "target_post_delete_other": {
                    "id": "target_post_delete_other",
                    "author_provider_uid": "real_owner_uid",
                    "author_app_user_id": "app_real_owner",
                    "text": "他人内容",
                    "status": "active",
                }
            },
        },
        data={
            "postId": "target_post_delete_other",
        },
    ),
]
