"""其余 Callable 样本集（A7 批次）。"""
from tools.replay.models import ReplaySample

SAMPLES = [
    ReplaySample(
        id="set_like_post_on",
        description="点赞帖子：action='like'，在 likes 集合新增点赞记录",
        ts_function="setLike",
        py_function="set_like_py",
        auth_email="liker_1@example.com",
        auth_uid="liker_1_uid",
        expected_status=200,
        seed_data={
            "playground_posts": {
                "post_to_like_1": {
                    "id": "post_to_like_1",
                    "status": "active",
                }
            }
        },
        data={
            "postId": "post_to_like_1",
            "action": "like",
        },
    ),
    ReplaySample(
        id="set_like_post_off",
        description="取消点赞帖子：action='unlike'，删除已有点赞记录",
        ts_function="setLike",
        py_function="set_like_py",
        auth_email="liker_2@example.com",
        auth_uid="liker_2_uid",
        expected_status=200,
        known_static_ids={"liker_2_uid", "app_liker_2_user", "post_to_like_2", "like_post_existing"},
        seed_data={
            "identity_map": {
                "liker_2_uid": {
                    "app_user_id": "app_liker_2_user",
                    "provider_uid": "liker_2_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_posts": {
                "post_to_like_2": {
                    "id": "post_to_like_2",
                    "status": "active",
                }
            },
            "playground_likes": {
                "like_post_existing": {
                    "id": "like_post_existing",
                    "post_id": "post_to_like_2",
                    "user_app_user_id": "app_liker_2_user",
                    "user_provider_uid": "liker_2_uid",
                }
            },
        },
        data={
            "postId": "post_to_like_2",
            "action": "unlike",
        },
    ),
    ReplaySample(
        id="set_bookmark_on",
        description="收藏帖子：action='bookmark'，在 bookmarks 集合新增记录",
        ts_function="setBookmark",
        py_function="set_bookmark_py",
        auth_email="bookmarker_1@example.com",
        auth_uid="bookmarker_1_uid",
        expected_status=200,
        seed_data={
            "playground_posts": {
                "post_to_bm_1": {
                    "id": "post_to_bm_1",
                    "status": "active",
                }
            }
        },
        data={
            "postId": "post_to_bm_1",
            "action": "bookmark",
        },
    ),
    ReplaySample(
        id="set_bookmark_off",
        description="取消收藏帖子：action='unbookmark'，删除已有记录",
        ts_function="setBookmark",
        py_function="set_bookmark_py",
        auth_email="bookmarker_2@example.com",
        auth_uid="bookmarker_2_uid",
        expected_status=200,
        known_static_ids={"bookmarker_2_uid", "app_bm_2_user", "post_to_bm_2", "bm_doc_1"},
        seed_data={
            "identity_map": {
                "bookmarker_2_uid": {
                    "app_user_id": "app_bm_2_user",
                    "provider_uid": "bookmarker_2_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_posts": {
                "post_to_bm_2": {
                    "id": "post_to_bm_2",
                    "status": "active",
                }
            },
            "playground_bookmarks": {
                "bm_doc_1": {
                    "id": "bm_doc_1",
                    "post_id": "post_to_bm_2",
                    "user_app_user_id": "app_bm_2_user",
                    "user_provider_uid": "bookmarker_2_uid",
                }
            },
        },
        data={
            "postId": "post_to_bm_2",
            "action": "unbookmark",
        },
    ),
    ReplaySample(
        id="update_my_profile_normal",
        description="正常更新个人资料：更新 displayName 与 bio",
        ts_function="updateMyProfile",
        py_function="update_my_profile_py",
        auth_email="profile_updater@example.com",
        auth_uid="profile_updater_uid",
        expected_status=200,
        data={
            "displayName": "星盘大师",
            "bio": "研习紫微斗数与子平八字十余年。",
            "commonTechniques": ["ziwei", "bazi"],
        },
    ),
    ReplaySample(
        id="update_my_profile_invalid_empty",
        description="更新个人资料未传有效字段：预期返回 400 INVALID_ARGUMENT",
        ts_function="updateMyProfile",
        py_function="update_my_profile_py",
        auth_email="profile_updater@example.com",
        auth_uid="profile_updater_uid",
        expected_status=400,
        data={},
    ),
    ReplaySample(
        id="resolve_my_identity_existing",
        description="解析既有用户身份：从 identity_map 返回已有 app_user_id 等信息",
        ts_function="resolveMyIdentity",
        py_function="resolve_my_identity_py",
        auth_email="identity_user_1@example.com",
        auth_uid="identity_user_1_uid",
        expected_status=200,
        known_static_ids={"identity_user_1_uid", "app_identity_user_1", "pres_id_1"},
        seed_data={
            "identity_map": {
                "identity_user_1_uid": {
                    "app_user_id": "app_identity_user_1",
                    "provider_uid": "identity_user_1_uid",
                    "provider_id": "firebase",
                    "public_presentation_id": "pres_id_1",
                    "public_display_alias": "玄友6666",
                }
            }
        },
        data={},
    ),
    ReplaySample(
        id="resolve_my_identity_unauthenticated",
        description="未登录解析身份：预期返回 401 UNAUTHENTICATED",
        ts_function="resolveMyIdentity",
        py_function="resolve_my_identity_py",
        auth_email=None,
        expected_status=401,
        data={},
    ),
    ReplaySample(
        id="report_content_post",
        description="举报帖子：在 reports 集合创建 status='pending' 记录",
        ts_function="reportContent",
        py_function="report_content_py",
        auth_email="reporter_1@example.com",
        auth_uid="reporter_1_uid",
        expected_status=200,
        data={
            "postId": "post_bad_content_1",
            "reportedUserId": "app_bad_actor_1",
            "reason": "spam",
            "description": "含有违规广告内容",
        },
    ),
    ReplaySample(
        id="report_content_unauthenticated",
        description="未登录举报内容：预期返回 401 UNAUTHENTICATED",
        ts_function="reportContent",
        py_function="report_content_py",
        auth_email=None,
        expected_status=401,
        data={
            "postId": "post_bad_1",
            "reportedUserId": "app_bad_1",
            "reason": "spam",
        },
    ),
    ReplaySample(
        id="register_fcm_token_normal",
        description="注册 FCM 设备 Token：写入 fcm_tokens 集合",
        ts_function="registerFcmToken",
        py_function="register_fcm_token_py",
        auth_email="device_owner@example.com",
        auth_uid="device_owner_uid",
        expected_status=200,
        data={
            "token": "fake_fcm_token_string_abc123",
            "platform": "ios",
        },
    ),
    ReplaySample(
        id="register_fcm_token_empty",
        description="注册 FCM 设备 Token 为空：预期返回 400 INVALID_ARGUMENT",
        ts_function="registerFcmToken",
        py_function="register_fcm_token_py",
        auth_email="device_owner@example.com",
        auth_uid="device_owner_uid",
        expected_status=400,
        data={
            "token": "",
            "platform": "ios",
        },
    ),
    ReplaySample(
        id="register_fcm_token_unauthenticated",
        description="未登录注册 FCM 设备 Token：预期返回 401 UNAUTHENTICATED",
        ts_function="registerFcmToken",
        py_function="register_fcm_token_py",
        auth_email=None,
        expected_status=401,
        data={
            "token": "fake_fcm_token_string_abc123",
            "platform": "ios",
        },
    ),
    ReplaySample(
        id="unregister_fcm_token_normal",
        description="注销 FCM 设备 Token：删除 fcm_tokens 记录",
        ts_function="unregisterFcmToken",
        py_function="unregister_fcm_token_py",
        auth_email="device_owner_2@example.com",
        auth_uid="device_owner_2_uid",
        expected_status=200,
        known_static_ids={"device_owner_2_uid", "app_dev_owner_2", "fcm_old_token"},
        seed_data={
            "identity_map": {
                "device_owner_2_uid": {
                    "app_user_id": "app_dev_owner_2",
                    "provider_uid": "device_owner_2_uid",
                    "provider_id": "firebase",
                }
            },
            "fcm_tokens": {
                "fcm_old_token": {
                    "id": "fcm_old_token",
                    "token": "token_to_remove_xyz",
                    "app_user_id": "app_dev_owner_2",
                    "provider_uid": "device_owner_2_uid",
                }
            },
        },
        data={
            "token": "token_to_remove_xyz",
        },
    ),
    ReplaySample(
        id="unregister_fcm_token_empty",
        description="注销 FCM 设备 Token 为空：预期返回 400 INVALID_ARGUMENT",
        ts_function="unregisterFcmToken",
        py_function="unregister_fcm_token_py",
        auth_email="device_owner_2@example.com",
        auth_uid="device_owner_2_uid",
        expected_status=400,
        data={
            "token": "",
        },
    ),
    ReplaySample(
        id="unregister_fcm_token_unauthenticated",
        description="未登录注销 FCM 设备 Token：预期返回 401 UNAUTHENTICATED",
        ts_function="unregisterFcmToken",
        py_function="unregister_fcm_token_py",
        auth_email=None,
        expected_status=401,
        data={
            "token": "token_to_remove_xyz",
        },
    ),
]
