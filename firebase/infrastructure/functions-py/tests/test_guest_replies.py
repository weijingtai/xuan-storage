"""getGuestRepresentativeReplies。基准实现：functions/src/guest_replies.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.guest_replies import _get_guest_representative_replies_impl as guest
from xuan.handlers.posts import _create_post_impl
from xuan.handlers.replies import _create_root_reply_impl, _delete_reply_impl

UID = "uid_g1"


def _post() -> str:
    return _create_post_impl(UID, {"text": "宿主帖"})["id"]


def test_postId_必填(clean_collections):
    for bad in [{}, {"postId": ""}, {"postId": "  "}, {"postId": 123}]:
        with pytest.raises(XuanHttpsError) as e:
            guest(bad)
        assert e.value.code == "invalid-argument"


def test_帖子不存在或已删(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        guest({"postId": "无"})
    assert e.value.code == "not-found"


def test_未认证也能调用(clean_collections):
    """★ 本接口存在的理由：游客可读。签名里就没有 uid。"""
    pid = _post()
    got = guest({"postId": pid})
    assert got["postId"] == pid
    assert got["visibleReplies"] == []
    assert got["registrationUnlock"]["requiresRegistration"] is True


def test_limit_被_clamp_到_5_到_10(clean_collections):
    pid = _post()
    for i in range(12):
        _create_root_reply_impl(UID, {"postId": pid, "body": f"回复{i}"})

    assert len(guest({"postId": pid})["visibleReplies"]) == 5, "缺省 5"
    assert len(guest({"postId": pid, "limit": 1})["visibleReplies"]) == 5, "低于下限提到 5"
    assert len(guest({"postId": pid, "limit": 99})["visibleReplies"]) == 10, "高于上限压到 10"
    assert len(guest({"postId": pid, "limit": 7})["visibleReplies"]) == 7


def test_limit_为_bool_必须当作非法而不是_1(clean_collections):
    """★ 坑 1：Python 里 bool 是 int 子类，不排除会被当成 limit=1。"""
    pid = _post()
    for i in range(8):
        _create_root_reply_impl(UID, {"postId": pid, "body": f"r{i}"})
    got = guest({"postId": pid, "limit": True})
    assert len(got["visibleReplies"]) == 5, "bool 应被判为非法 → 回落缺省 5，而不是 clamp(1)"


def test_limit_非整数回落缺省(clean_collections):
    pid = _post()
    for i in range(8):
        _create_root_reply_impl(UID, {"postId": pid, "body": f"r{i}"})
    for bad in [7.5, "8", None, []]:
        assert len(guest({"postId": pid, "limit": bad})["visibleReplies"]) == 5


def test_policy_version(clean_collections):
    pid = _post()
    assert guest({"postId": pid})["selectionPolicyVersion"] == 1
    assert guest({"postId": pid, "selectionPolicyVersion": None})["selectionPolicyVersion"] == 1
    for bad in [2, 0, "1", True]:
        with pytest.raises(XuanHttpsError) as e:
            guest({"postId": pid, "selectionPolicyVersion": bad})
        assert e.value.code == "invalid-argument"


def test_额外参数被忽略(clean_collections):
    """入参白名单：cursor/page/offset/sort 一律忽略，不报错也不生效。"""
    pid = _post()
    for i in range(8):
        _create_root_reply_impl(UID, {"postId": pid, "body": f"r{i}"})
    got = guest({"postId": pid, "cursor": "x", "page": 3, "offset": 5, "sort": "desc"})
    assert len(got["visibleReplies"]) == 5


def test_tombstone_不计入_total_与_visible(clean_collections):
    pid = _post()
    ids = [_create_root_reply_impl(UID, {"postId": pid, "body": f"r{i}"})["id"] for i in range(3)]
    _delete_reply_impl(UID, {"replyId": ids[0]})
    got = guest({"postId": pid})
    assert got["totalReplyCount"] == 2
    assert len(got["visibleReplies"]) == 2
    assert all(r["publicReplyId"] != ids[0] for r in got["visibleReplies"])


def test_depth1_不参与选择(clean_collections):
    from xuan.handlers.replies import _create_discussion_reply_impl
    pid = _post()
    rid = _create_root_reply_impl(UID, {"postId": pid, "body": "根"})["id"]
    _create_discussion_reply_impl(UID, {"postId": pid, "rootReplyId": rid, "body": "子"})
    got = guest({"postId": pid})
    assert got["totalReplyCount"] == 1, "只统计 depth==0"


def test_hidden_计数(clean_collections):
    pid = _post()
    for i in range(9):
        _create_root_reply_impl(UID, {"postId": pid, "body": f"r{i}"})
    got = guest({"postId": pid, "limit": 5})
    assert got["totalReplyCount"] == 9
    assert got["hiddenReplyCount"] == 4


def test_排序_已应验优先(clean_collections):
    """★ 坑 3：四键排序方向。"""
    pid = _post()
    plain = _create_root_reply_impl(UID, {"postId": pid, "body": "普通"})["id"]
    verified = _create_root_reply_impl(UID, {"postId": pid, "body": "已验"})["id"]
    clean_collections.collection(COLLECTIONS["replies"]).document(verified).update(
        {"verification": {"by": "someone"}})
    got = guest({"postId": pid})
    assert got["visibleReplies"][0]["publicReplyId"] == verified
    assert got["visibleReplies"][0]["isVerified"] is True


def test_排序_赞数降序(clean_collections):
    pid = _post()
    a = _create_root_reply_impl(UID, {"postId": pid, "body": "少赞"})["id"]
    b = _create_root_reply_impl(UID, {"postId": pid, "body": "多赞"})["id"]
    for i in range(3):
        clean_collections.collection(COLLECTIONS["likes"]).document(f"lk{i}").set({"reply_id": b})
    clean_collections.collection(COLLECTIONS["likes"]).document("lk_a").set({"reply_id": a})
    got = guest({"postId": pid})
    assert [r["publicReplyId"] for r in got["visibleReplies"]][:2] == [b, a]


def test_结果确定性(clean_collections):
    """同一快照 + 同一参数 → 完全相同的 ID 顺序。"""
    pid = _post()
    for i in range(8):
        _create_root_reply_impl(UID, {"postId": pid, "body": f"r{i}"})
    runs = [[r["publicReplyId"] for r in guest({"postId": pid, "limit": 6})["visibleReplies"]]
            for _ in range(3)]
    assert runs[0] == runs[1] == runs[2]


def test_不泄漏敏感字段(clean_collections):
    pid = _post()
    _create_root_reply_impl(UID, {"postId": pid, "body": "x"})
    got = guest({"postId": pid})
    s = str(got)
    assert UID not in s, "provider uid 不得出网"
    assert "author_app_user_id" not in s


def test_outcome_feedback_无则_none(clean_collections):
    pid = _post()
    assert guest({"postId": pid})["outcomeFeedback"] is None


def test_outcome_feedback_取最新且忽略已删(clean_collections):
    pid = _post()
    col = clean_collections.collection(COLLECTIONS["outcome_feedback"])
    col.document("of1").set({"post_id": pid, "outcome_description": "旧",
                             "created_at": "2026-01-01T00:00:00Z", "deleted_at": None})
    col.document("of2").set({"post_id": pid, "outcome_description": "新",
                             "created_at": "2026-06-01T00:00:00Z", "deleted_at": None})
    col.document("of3").set({"post_id": pid, "outcome_description": "已删",
                             "created_at": "2026-12-01T00:00:00Z", "deleted_at": "2026-12-02T00:00:00Z"})
    got = guest({"postId": pid})["outcomeFeedback"]
    assert got["body"] == "新", "取最新的未删项"
    assert got["isEdited"] is False


def test_guest_replies_likes_批量查询次数(clean_collections, monkeypatch):
    """L-3 验证：候选回复点赞数批量查询，35 条回复仅需 2 次 Firestore likes 查询（ceil(35/30)=2）。"""
    from xuan import config
    from xuan.config import COLLECTIONS

    pid = _post()
    rids = []
    for i in range(35):
        rid = _create_root_reply_impl(UID, {"postId": pid, "body": f"r{i:02d}"})["id"]
        rids.append(rid)

    # 给第 0 条加 2 个赞，第 34 条加 1 个赞，其余 0 赞
    clean_collections.collection(COLLECTIONS["likes"]).document("lk0_1").set({"reply_id": rids[0]})
    clean_collections.collection(COLLECTIONS["likes"]).document("lk0_2").set({"reply_id": rids[0]})
    clean_collections.collection(COLLECTIONS["likes"]).document("lk34").set({"reply_id": rids[34]})

    client = config.db()
    likes_col = client.collection(COLLECTIONS["likes"])
    orig_where = likes_col.__class__.where

    likes_query_count = 0

    def counting_where(self, field_path=None, op_string=None, value=None, **kwargs):
        nonlocal likes_query_count
        if field_path == "reply_id" or kwargs.get("field_path") == "reply_id":
            likes_query_count += 1
        return orig_where(self, *([field_path, op_string, value] if field_path is not None else []), **kwargs)

    monkeypatch.setattr(likes_col.__class__, "where", counting_where)

    got = guest({"postId": pid, "limit": 10})
    assert got["totalReplyCount"] == 35

    # 验证点赞排序与统计正确性：第 0 条赞最多，排在最前
    assert got["visibleReplies"][0]["publicReplyId"] == rids[0]

    # 验证 35 条回复时，likes 集合查询次数应为 2 (ceil(35/30))，而不是 35
    assert likes_query_count == 2, f"Expected 2 batch queries on likes, got {likes_query_count}"


