"""验证 main.py 导出的 Callable 函数列表完整性与规范。"""
import main


def test_main_导出的9个目标callable():
    required_callables = [
        # 1 & 2: follow
        "follow_user_py",
        "unfollow_user_py",
        # 3 & 4: user_search
        "search_users_py",
        "get_mention_candidates_py",
        # 5 & 6: moderation
        "report_post_py",
        "report_reply_py",
        # 7 & 8: conversations
        "block_user_py",
        "unblock_user_py",
        # 9: subscriptions
        "set_notification_preference_py",
    ]

    for name in required_callables:
        assert hasattr(main, name), f"main.py 缺少目标导出函数: {name}"
        fn = getattr(main, name)
        assert callable(fn), f"{name} 不是可调用对象"


def test_main_已移除废弃导入():
    deprecated = [
        "register_fcm_token_py",
        "unregister_fcm_token_py",
        "on_outbox_created_py",
    ]
    for name in deprecated:
        assert not hasattr(main, name), f"main.py 仍存在废弃导出: {name}"
