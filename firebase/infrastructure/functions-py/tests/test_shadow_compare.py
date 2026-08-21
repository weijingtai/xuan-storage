"""影子比对。判定 Python 版与 TS 版的返回是否等价。

难点是「合理的不等价」要被识别出来，否则每次比对都是满屏噪音：
服务端时间戳、随机 id 这类字段两边必然不同，但不代表行为不一致。
"""
from tools.shadow_compare import compare, compare_replay, Normalizer


def test_完全相同判为一致():
    d = compare({"liked": True, "id": "x"}, {"liked": True, "id": "x"})
    assert d.equivalent
    assert d.differences == []


def test_值不同判为不一致():
    d = compare({"liked": True}, {"liked": False})
    assert not d.equivalent
    assert "liked" in d.differences[0]


def test_缺字段判为不一致():
    d = compare({"a": 1, "b": 2}, {"a": 1})
    assert not d.equivalent


def test_时间戳字段忽略():
    d = compare(
        {"id": "x", "created_at": "2026-08-19T10:00:00Z"},
        {"id": "x", "created_at": "2026-08-19T10:00:03Z"},
    )
    assert d.equivalent, "时间戳天然不同，不应算作不一致"


def test_嵌套结构逐层比对():
    d = compare({"a": {"b": {"c": 1}}}, {"a": {"b": {"c": 2}}})
    assert not d.equivalent
    assert "a.b.c" in d.differences[0]


def test_列表按序比对():
    assert compare({"xs": [1, 2]}, {"xs": [1, 2]}).equivalent
    assert not compare({"xs": [1, 2]}, {"xs": [2, 1]}).equivalent


def test_占位符归一化_引用一致判为通过():
    ts_resp = {"result": {"id": "12345678901234567890", "ok": True}}
    py_resp = {"result": {"id": "abcdefghijabcdefghij", "ok": True}}

    ts_snap = {
        "playground_posts": {
            "12345678901234567890": {
                "id": "12345678901234567890",
                "author_app_user_id": "app-ts-1234",
                "title": "post1",
                "created_at": "2026-08-20T10:00:00Z",
            }
        },
        "playground_outbox": {
            "outbox_ts_9876543210987654": {
                "id": "outbox_ts_9876543210987654",
                "event_type": "post_created",
                "post_id": "12345678901234567890",
                "author_app_user_id": "app-ts-1234",
            }
        },
    }

    py_snap = {
        "playground_posts": {
            "abcdefghijabcdefghij": {
                "id": "abcdefghijabcdefghij",
                "author_app_user_id": "app-py-5678",
                "title": "post1",
                "created_at": "2026-08-20T10:00:05Z",
            }
        },
        "playground_outbox": {
            "outbox_py_1234567890123456": {
                "id": "outbox_py_1234567890123456",
                "event_type": "post_created",
                "post_id": "abcdefghijabcdefghij",
                "author_app_user_id": "app-py-5678",
            }
        },
    }

    diff, ts_norm, py_norm = compare_replay(ts_resp, py_resp, ts_snap, py_snap)
    assert diff.equivalent, f"引用拓扑一致应比对通过，实际差异: {diff.differences}"
    assert diff.differences == []


def test_占位符归一化_引用错乱报出差异():
    ts_resp = {"result": {"id": "12345678901234567890"}}
    py_resp = {"result": {"id": "abcdefghijabcdefghij"}}

    ts_snap = {
        "playground_outbox": {
            "outbox_1": {
                "post_id": "12345678901234567890",  # 指向 post_id (<ID:1>)
                "author_app_user_id": "app-ts-1234",  # 指向 author (<ID:2>)
            }
        }
    }

    # Python 侧错把 author_app_user_id 写进了 post_id
    py_snap = {
        "playground_outbox": {
            "outbox_1": {
                "post_id": "app-py-5678",  # 错填为了 author (<ID:2>)
                "author_app_user_id": "app-py-5678",
            }
        }
    }

    diff, ts_norm, py_norm = compare_replay(ts_resp, py_resp, ts_snap, py_snap)
    assert not diff.equivalent, "引用错乱必须报出差异"
    assert any("post_id" in d for d in diff.differences)


def test_占位符归一化_各类时间戳形态均被识别():
    import datetime

    n = Normalizer()
    assert n.normalize_value({"created_at": "2026-08-20T12:00:00Z"}) == {"created_at": "<TS>"}
    assert n.normalize_value({"time": datetime.datetime(2026, 8, 20, 12, 0)}) == {"time": "<TS>"}
    assert n.normalize_value({"updated_at": {"_seconds": 1700000000, "_nanoseconds": 0}}) == {"updated_at": "<TS>"}
    assert n.normalize_value({"timestamp": 1755734400000}) == {"timestamp": "<TS>"}


def test_字段改名报出差异():
    ts = {"author_app_user_id": "app-a-1", "zz_other_field_name": 1}
    py = {"authorxappxuserxid": "app-b-2", "zz_other_field_name": 1}
    d, _, _ = compare_replay(ts, py, {}, {})
    assert not d.equivalent, "字段改名必须报出差异"
    assert any("author_app_user_id" in diff or "authorxappxuserxid" in diff for diff in d.differences)


def test_集合名不同报出差异():
    ts_snap = {"playground_posts": {"doc_1": {"text": "hello"}}}
    py_snap = {"playground_posts_renamed": {"doc_2": {"text": "hello"}}}
    d, _, _ = compare_replay({}, {}, ts_snap, py_snap)
    assert not d.equivalent, "集合名不同必须报出差异"
    assert any("playground_posts" in diff for diff in d.differences)


def test_文档ID不同但引用拓扑一致仍然通过():
    ts_snap = {
        "playground_posts": {
            "post_11111111111111111111": {
                "id": "post_11111111111111111111",
                "author": "app-user-1",
            }
        },
        "playground_profiles": {
            "app-user-1": {
                "user_id": "app-user-1",
                "latest_post_id": "post_11111111111111111111",
            }
        },
    }
    py_snap = {
        "playground_posts": {
            "post_22222222222222222222": {
                "id": "post_22222222222222222222",
                "author": "app-user-2",
            }
        },
        "playground_profiles": {
            "app-user-2": {
                "user_id": "app-user-2",
                "latest_post_id": "post_22222222222222222222",
            }
        },
    }
    d, ts_norm, py_norm = compare_replay({}, {}, ts_snap, py_snap)
    assert d.equivalent, f"引用拓扑一致应当通过，实际差异: {d.differences}"
