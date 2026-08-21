"""内容举报。基准实现：functions/src/moderation.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.moderation import _report_content_impl as report

UID = "uid_reporter"


def test_未登录被拒(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        report(None, {"postId": "p1", "reportedUserId": "app-x", "reason": "spam"})
    assert e.value.code == "unauthenticated"


def test_两个目标都不给报错(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        report(UID, {"reportedUserId": "app-x", "reason": "spam"})
    assert e.value.code == "invalid-argument"


def test_reportedUserId_必填(clean_collections):
    for bad in [{}, {"reportedUserId": ""}, {"reportedUserId": 123}]:
        payload = {"postId": "p1", "reason": "spam", **bad}
        with pytest.raises(XuanHttpsError) as e:
            report(UID, payload)
        assert e.value.code == "invalid-argument"


def test_reason_必填(clean_collections):
    for bad in [{}, {"reason": ""}, {"reason": 42}]:
        payload = {"postId": "p1", "reportedUserId": "app-x", **bad}
        with pytest.raises(XuanHttpsError) as e:
            report(UID, payload)
        assert e.value.code == "invalid-argument"


def test_举报帖子成功(clean_collections):
    got = report(UID, {"postId": "p1", "reportedUserId": "app-bad", "reason": "spam"})
    assert got["status"] == "pending"
    assert "id" in got and "created_at" in got

    row = clean_collections.collection(COLLECTIONS["reports"]).document(got["id"]).get().to_dict()
    assert row["post_id"] == "p1"
    assert row["reply_id"] is None, "未给出的目标必须显式写 null"
    assert row["reporter_provider_uid"] == UID
    assert row["reported_user_id"] == "app-bad"
    assert row["reason"] == "spam"
    assert row["description"] is None
    assert row["status"] == "pending"


def test_举报回复成功(clean_collections):
    got = report(UID, {"replyId": "r1", "reportedUserId": "app-bad", "reason": "abuse"})
    row = clean_collections.collection(COLLECTIONS["reports"]).document(got["id"]).get().to_dict()
    assert row["reply_id"] == "r1"
    assert row["post_id"] is None


def test_description_可选(clean_collections):
    got = report(UID, {
        "postId": "p1", "reportedUserId": "app-bad",
        "reason": "spam", "description": "反复刷屏",
    })
    row = clean_collections.collection(COLLECTIONS["reports"]).document(got["id"]).get().to_dict()
    assert row["description"] == "反复刷屏"


def test_不校验目标是否真实存在(clean_collections):
    """TS 版不查 posts/replies 是否存在 —— 照抄。"""
    got = report(UID, {"postId": "根本不存在的帖子", "reportedUserId": "app-x", "reason": "spam"})
    assert got["status"] == "pending"


def test_重复举报产生多条记录(clean_collections):
    """★ 坑 1：无幂等、无去重，同一人可反复举报。

    本测试是**行为锁定**。若将来产品要求去重，必须同步改这个断言。
    """
    payload = {"postId": "p1", "reportedUserId": "app-bad", "reason": "spam"}
    ids = [report(UID, payload)["id"] for _ in range(3)]
    assert len(set(ids)) == 3, "每次都应是新记录"
    assert len(list(clean_collections.collection(COLLECTIONS["reports"]).stream())) == 3


def test_带幂等键也照样产生新记录(clean_collections):
    """无 with_idempotency 包装，因此 idempotency_key 不起任何作用。"""
    payload = {"postId": "p1", "reportedUserId": "app-bad", "reason": "spam",
               "idempotency_key": "same_key"}
    a = report(UID, payload)
    b = report(UID, payload)
    assert a["id"] != b["id"]
    assert list(clean_collections.collection(COLLECTIONS["idempotency"]).stream()) == [], \
        "不得写幂等记录"
