"""入口注册闸门。

P1 曾出现「handler 写完但忘了在 main.py 注册」的隐患——
函数注册不上，部署了也调不到，且测试全绿看不出来。本测试堵住这个洞。
"""
import main


EXPECTED = [
    # P1
    "set_bookmark_py", "set_like_py", "update_my_profile_py",
    # P2
    "create_post_py", "edit_post_py", "tombstone_post_py",
    "create_root_reply_py", "create_discussion_reply_py",
    "edit_reply_py", "delete_reply_py",
    # P3
    "get_guest_representative_replies_py",
    "send_dm_request_py", "respond_dm_request_py", "send_message_py",
    "block_user_py", "unblock_user_py",
    # P4
    "recalculate_reputation_py", "resolve_my_identity_py",
    "verify_root_reply_py", "revoke_verification_py",
    "set_outcome_feedback_py", "revoke_outcome_feedback_py",
    # P5
    "register_fcm_token_py", "unregister_fcm_token_py", "report_content_py",
]

EXPECTED_TRIGGERS = [
    "on_outbox_created_py",
    "on_media_uploaded_py",
    "cleanup_orphan_media_py",
]


def test_全部_callable_已在入口注册():
    missing = [name for name in EXPECTED if not hasattr(main, name)]
    assert missing == [], f"main.py 未注册：{missing}"


def test_三个_trigger_已注册():
    missing = [n for n in EXPECTED_TRIGGERS if not hasattr(main, n)]
    assert missing == [], f"main.py 未注册 trigger：{missing}"


def test_与_ts_侧数量对齐():
    """TS 侧 25 callable + 3 trigger = 28 个入口，Python 侧必须一致。"""
    entries = {n for n in dir(main) if n.endswith("_py") and not n.startswith("_")}
    assert len(entries) == 28, f"入口数不符：{len(entries)}，应为 28"


def test_没有多余的未声明导出():
    """新增 callable 必须同时更新本清单，避免注册了却没人知道。"""
    exported = {
        n for n in dir(main)
        if n.endswith("_py") and not n.startswith("_")
    }
    all_expected = set(EXPECTED) | set(EXPECTED_TRIGGERS)
    assert exported == all_expected, f"清单与实际不符：多出 {exported - all_expected}，缺少 {all_expected - exported}"
