"""声誉、应验与反馈相关样本集（A6 批次）。"""
from tools.replay.models import ReplaySample

SAMPLES = [
    ReplaySample(
        id="recalculate_reputation_normal",
        description="重算信誉指标：统计有效点赞数与应验数并更新 profiles",
        ts_function="recalculateReputation",
        py_function="recalculate_reputation_py",
        auth_email="reputation_caller@example.com",
        auth_uid="reputation_caller_uid",
        expected_status=200,
        seed_data={
            "identity_map": {
                "reputation_caller_uid": {
                    "app_user_id": "app_rep_user_1",
                    "provider_uid": "reputation_caller_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_profiles": {
                "app_rep_user_1": {
                    "app_user_id": "app_rep_user_1",
                    "playground_like_count": 0,
                    "playground_verification_count": 0,
                }
            },
            "playground_likes": {
                "like_1": {
                    "id": "like_1",
                    "user_app_user_id": "app_rep_user_1",
                    "target_id": "post_x",
                }
            },
            "playground_verifications": {
                "verif_1": {
                    "id": "verif_1",
                    "verifier_app_user_id": "app_rep_user_1",
                    "revoked_at": None,
                },
                "verif_revoked": {
                    "id": "verif_revoked",
                    "verifier_app_user_id": "app_rep_user_1",
                    "revoked_at": "2026-08-20T12:00:00Z",
                },
            },
        },
        data={
            "appUserId": "app_rep_user_1",
        },
    ),
    ReplaySample(
        id="recalculate_reputation_legacy_gap",
        description="重算他人信誉（L-1 修复）：非本人操作返回 403 PERMISSION_DENIED",
        ts_function="recalculateReputation",
        py_function="recalculate_reputation_py",
        auth_email="caller_other@example.com",
        auth_uid="caller_other_uid",
        expected_status=403,
        seed_data={
            "identity_map": {
                "caller_other_uid": {
                    "app_user_id": "app_caller_other_1",
                    "provider_uid": "caller_other_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_profiles": {
                "app_other_user_2": {
                    "app_user_id": "app_other_user_2",
                }
            }
        },
        data={
            "appUserId": "app_other_user_2",
        },
    ),
    ReplaySample(
        id="verify_root_reply_normal",
        description="帖子作者正常应验根回复：三处联动写入 verifications、replies 与 profiles",
        ts_function="verifyRootReply",
        py_function="verify_root_reply_py",
        auth_email="post_author_v@example.com",
        auth_uid="author_v_uid",
        expected_status=200,
        known_static_ids={"author_v_uid", "app_author_v", "post_v_1", "reply_v_1", "other_solver_uid", "app_solver"},
        seed_data={
            "identity_map": {
                "author_v_uid": {
                    "app_user_id": "app_author_v",
                    "provider_uid": "author_v_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_posts": {
                "post_v_1": {
                    "id": "post_v_1",
                    "author_provider_uid": "author_v_uid",
                    "author_app_user_id": "app_author_v",
                    "status": "active",
                }
            },
            "playground_replies": {
                "reply_v_1": {
                    "id": "reply_v_1",
                    "post_id": "post_v_1",
                    "root_reply_id": None,
                    "depth": 0,
                    "author_provider_uid": "other_solver_uid",
                    "author_app_user_id": "app_solver",
                    "body": "准确预测",
                }
            },
        },
        data={
            "postId": "post_v_1",
            "rootReplyId": "reply_v_1",
        },
    ),
    ReplaySample(
        id="verify_root_reply_non_post_author",
        description="非帖子作者尝试应验回复：预期返回 403 PERMISSION_DENIED",
        ts_function="verifyRootReply",
        py_function="verify_root_reply_py",
        auth_email="stranger_user@example.com",
        auth_uid="stranger_user_uid",
        expected_status=403,
        known_static_ids={"stranger_user_uid", "real_post_author_uid", "post_v_2", "reply_v_2", "solver_uid"},
        seed_data={
            "playground_posts": {
                "post_v_2": {
                    "id": "post_v_2",
                    "author_provider_uid": "real_post_author_uid",
                    "status": "active",
                }
            },
            "playground_replies": {
                "reply_v_2": {
                    "id": "reply_v_2",
                    "post_id": "post_v_2",
                    "root_reply_id": None,
                    "depth": 0,
                    "author_provider_uid": "solver_uid",
                }
            },
        },
        data={
            "postId": "post_v_2",
            "rootReplyId": "reply_v_2",
        },
    ),
    ReplaySample(
        id="revoke_verification_normal",
        description="作者正常撤销应验：写入 revoked_at 并清除回复 verification 标记",
        ts_function="revokeVerification",
        py_function="revoke_verification_py",
        auth_email="post_author_rev@example.com",
        auth_uid="author_rev_uid",
        expected_status=200,
        known_static_ids={"author_rev_uid", "app_author_rev", "post_rev_1", "reply_rev_1", "verif_to_revoke"},
        seed_data={
            "identity_map": {
                "author_rev_uid": {
                    "app_user_id": "app_author_rev",
                    "provider_uid": "author_rev_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_posts": {
                "post_rev_1": {
                    "id": "post_rev_1",
                    "author_provider_uid": "author_rev_uid",
                    "author_app_user_id": "app_author_rev",
                    "status": "active",
                }
            },
            "playground_replies": {
                "reply_rev_1": {
                    "id": "reply_rev_1",
                    "post_id": "post_rev_1",
                    "root_reply_id": None,
                    "depth": 0,
                    "verification": {"is_verified": True},
                }
            },
            "playground_verifications": {
                "verif_to_revoke": {
                    "id": "verif_to_revoke",
                    "post_id": "post_rev_1",
                    "root_reply_id": "reply_rev_1",
                    "verifier_app_user_id": "app_author_rev",
                    "verifier_provider_uid": "author_rev_uid",
                    "revoked_at": None,
                }
            },
        },
        data={
            "postId": "post_rev_1",
            "rootReplyId": "reply_rev_1",
        },
    ),
    ReplaySample(
        id="revoke_verification_not_found",
        description="撤销不存在的应验记录：预期返回 404 NOT_FOUND",
        ts_function="revokeVerification",
        py_function="revoke_verification_py",
        auth_email="post_author_rev_nf@example.com",
        auth_uid="author_rev_uid_nf",
        expected_status=404,
        data={
            "postId": "nonexistent_post_rev",
            "rootReplyId": "nonexistent_reply_rev",
        },
    ),
    ReplaySample(
        id="set_outcome_feedback_normal",
        description="帖子作者正常设置最终反馈：写入 outcome_feedback 并标记帖子 has_outcome_feedback",
        ts_function="setOutcomeFeedback",
        py_function="set_outcome_feedback_py",
        auth_email="feedback_author@example.com",
        auth_uid="fb_author_uid",
        expected_status=200,
        known_static_ids={"fb_author_uid", "app_fb_author", "post_fb_1"},
        seed_data={
            "identity_map": {
                "fb_author_uid": {
                    "app_user_id": "app_fb_author",
                    "provider_uid": "fb_author_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_posts": {
                "post_fb_1": {
                    "id": "post_fb_1",
                    "author_provider_uid": "fb_author_uid",
                    "author_app_user_id": "app_fb_author",
                    "status": "active",
                    "has_outcome_feedback": False,
                }
            },
        },
        data={
            "postId": "post_fb_1",
            "outcome_description": "事情最终如各位断语所言，已顺利解决。",
        },
    ),
    ReplaySample(
        id="set_outcome_feedback_non_author",
        description="非帖子作者尝试设置最终反馈：预期返回 403 PERMISSION_DENIED",
        ts_function="setOutcomeFeedback",
        py_function="set_outcome_feedback_py",
        auth_email="feedback_hacker@example.com",
        auth_uid="uid_fb_hacker",
        expected_status=403,
        known_static_ids={"uid_fb_hacker", "real_author_fb_uid", "post_fb_other"},
        seed_data={
            "playground_posts": {
                "post_fb_other": {
                    "id": "post_fb_other",
                    "author_provider_uid": "real_author_fb_uid",
                    "status": "active",
                    "has_outcome_feedback": False,
                }
            }
        },
        data={
            "postId": "post_fb_other",
            "outcome_description": "非法反馈",
        },
    ),
    ReplaySample(
        id="set_outcome_feedback_post_not_found",
        description="为不存在的帖子设置最终反馈：预期返回 404 NOT_FOUND",
        ts_function="setOutcomeFeedback",
        py_function="set_outcome_feedback_py",
        auth_email="feedback_author@example.com",
        auth_uid="fb_author_uid",
        expected_status=404,
        data={
            "postId": "nonexistent_post_fb_999",
            "outcome_description": "反馈内容",
        },
    ),
    ReplaySample(
        id="revoke_outcome_feedback_normal",
        description="帖子作者正常撤销反馈：deleted_at 设为时间戳并恢复帖子 has_outcome_feedback 为 false",
        ts_function="revokeOutcomeFeedback",
        py_function="revoke_outcome_feedback_py",
        auth_email="feedback_author_del@example.com",
        auth_uid="fb_author_del_uid",
        expected_status=200,
        known_static_ids={"fb_author_del_uid", "app_fb_author_del", "post_fb_del", "fb_doc_1"},
        seed_data={
            "identity_map": {
                "fb_author_del_uid": {
                    "app_user_id": "app_fb_author_del",
                    "provider_uid": "fb_author_del_uid",
                    "provider_id": "firebase",
                }
            },
            "playground_posts": {
                "post_fb_del": {
                    "id": "post_fb_del",
                    "author_provider_uid": "fb_author_del_uid",
                    "author_app_user_id": "app_fb_author_del",
                    "status": "active",
                    "has_outcome_feedback": True,
                }
            },
            "playground_outcome_feedback": {
                "fb_doc_1": {
                    "id": "fb_doc_1",
                    "post_id": "post_fb_del",
                    "author_provider_uid": "fb_author_del_uid",
                    "author_app_user_id": "app_fb_author_del",
                    "deleted_at": None,
                }
            },
        },
        data={
            "postId": "post_fb_del",
        },
    ),
    ReplaySample(
        id="revoke_outcome_feedback_not_found",
        description="撤销不存在或未反馈的帖子反馈：预期返回 404 NOT_FOUND",
        ts_function="revokeOutcomeFeedback",
        py_function="revoke_outcome_feedback_py",
        auth_email="feedback_author_del@example.com",
        auth_uid="fb_author_del_uid",
        expected_status=404,
        data={
            "postId": "nonexistent_post_fb_del",
        },
    ),
]
