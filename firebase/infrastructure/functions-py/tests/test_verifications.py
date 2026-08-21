"""verifications。基准实现：functions/src/verifications.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.posts import _create_post_impl, _tombstone_post_impl
from xuan.handlers.replies import _create_discussion_reply_impl, _create_root_reply_impl
from xuan.handlers.verifications import _verify_root_reply_impl as verify

AUTHOR = "uid_author"
REPLIER = "uid_replier"


def _post_and_reply():
    pid = _create_post_impl(AUTHOR, {"text": "求解"})["id"]
    rid = _create_root_reply_impl(REPLIER, {"postId": pid, "body": "我的解答"})["id"]
    return pid, rid


def test_必填校验(clean_collections):
    pid, rid = _post_and_reply()
    for bad in [{}, {"postId": pid}, {"rootReplyId": rid}, {"postId": 1, "rootReplyId": rid}]:
        with pytest.raises(XuanHttpsError) as e:
            verify(AUTHOR, bad)
        assert e.value.code == "invalid-argument"


def test_帖子不存在或已删(clean_collections):
    pid, rid = _post_and_reply()
    with pytest.raises(XuanHttpsError) as e:
        verify(AUTHOR, {"postId": "无", "rootReplyId": rid})
    assert e.value.code == "not-found"

    _tombstone_post_impl(AUTHOR, {"postId": pid})
    with pytest.raises(XuanHttpsError) as e:
        verify(AUTHOR, {"postId": pid, "rootReplyId": rid})
    assert e.value.code == "not-found"


def test_只有帖子作者能应验(clean_collections):
    pid, rid = _post_and_reply()
    with pytest.raises(XuanHttpsError) as e:
        verify(REPLIER, {"postId": pid, "rootReplyId": rid})
    assert e.value.code == "permission-denied"


def test_不能应验自己的回复(clean_collections):
    pid = _create_post_impl(AUTHOR, {"text": "自问"})["id"]
    own = _create_root_reply_impl(AUTHOR, {"postId": pid, "body": "自答"})["id"]
    with pytest.raises(XuanHttpsError) as e:
        verify(AUTHOR, {"postId": pid, "rootReplyId": own})
    assert e.value.code == "permission-denied"


def test_只能应验根回复(clean_collections):
    pid, rid = _post_and_reply()
    child = _create_discussion_reply_impl(REPLIER, {"postId": pid, "rootReplyId": rid, "body": "子"})["id"]
    with pytest.raises(XuanHttpsError) as e:
        verify(AUTHOR, {"postId": pid, "rootReplyId": child})
    assert e.value.code == "invalid-argument"


def test_回复不属于该帖子(clean_collections):
    pid, rid = _post_and_reply()
    other = _create_post_impl(AUTHOR, {"text": "另一帖"})["id"]
    with pytest.raises(XuanHttpsError) as e:
        verify(AUTHOR, {"postId": other, "rootReplyId": rid})
    assert e.value.code == "invalid-argument"


def test_应验成功_三处联动写入(clean_collections):
    """★ 坑 3：verifications + replies.verification + outbox，缺一不可。"""
    pid, rid = _post_and_reply()
    got = verify(AUTHOR, {"postId": pid, "rootReplyId": rid})
    assert got["post_id"] == pid and got["root_reply_id"] == rid
    assert "existing" not in got, "首次应验不带 existing"

    # 1) verifications 记录，revoked_at 必须显式为 None（坑 2）
    v = clean_collections.collection(COLLECTIONS["verifications"]).document(got["id"]).get().to_dict()
    assert v["revoked_at"] is None
    assert "revoked_at" in v, "必须显式写 null，否则后续 == None 查询漏掉它"

    # 2) replies.verification 字段 —— 游客视图排序的第一顺位键
    r = clean_collections.collection(COLLECTIONS["replies"]).document(rid).get().to_dict()
    assert isinstance(r["verification"], dict)
    assert r["verification"]["verifier_app_user_id"] == got["verifier_app_user_id"]

    # 3) outbox 事件
    events = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["outbox"]).stream()]
    assert [e["event_type"] for e in events] == ["reply_verified"]


def test_重复应验返回既有记录且带_existing(clean_collections):
    """★ 坑 4：不报错、不新增、返回体多一个 existing。"""
    pid, rid = _post_and_reply()
    first = verify(AUTHOR, {"postId": pid, "rootReplyId": rid})
    second = verify(AUTHOR, {"postId": pid, "rootReplyId": rid, "idempotency_key": "另一个key"})

    assert second["existing"] is True
    assert second["id"] == first["id"]
    assert len(list(clean_collections.collection(COLLECTIONS["verifications"]).stream())) == 1
    events = list(clean_collections.collection(COLLECTIONS["outbox"]).stream())
    assert len(events) == 1, "重复应验不得再发一次通知"


def test_应验后游客视图置顶(clean_collections):
    """联动验证：应验直接影响 P3 的排序结果。"""
    from xuan.handlers.guest_replies import _get_guest_representative_replies_impl as guest
    pid = _create_post_impl(AUTHOR, {"text": "帖"})["id"]
    plain = _create_root_reply_impl(REPLIER, {"postId": pid, "body": "普通"})["id"]
    target = _create_root_reply_impl(REPLIER, {"postId": pid, "body": "会被应验"})["id"]
    verify(AUTHOR, {"postId": pid, "rootReplyId": target})
    got = guest({"postId": pid})
    assert got["visibleReplies"][0]["publicReplyId"] == target
    assert got["visibleReplies"][0]["isVerified"] is True


from xuan.handlers.verifications import _revoke_verification_impl as revoke


def test_撤销_必填校验(clean_collections):
    for bad in [{}, {"postId": "p"}, {"rootReplyId": "r"}]:
        with pytest.raises(XuanHttpsError) as e:
            revoke(AUTHOR, bad)
        assert e.value.code == "invalid-argument"


def test_撤销_无有效记录(clean_collections):
    pid, rid = _post_and_reply()
    with pytest.raises(XuanHttpsError) as e:
        revoke(AUTHOR, {"postId": pid, "rootReplyId": rid})
    assert e.value.code == "not-found"


def test_撤销_三处联动(clean_collections):
    pid, rid = _post_and_reply()
    v = verify(AUTHOR, {"postId": pid, "rootReplyId": rid})
    assert revoke(AUTHOR, {"postId": pid, "rootReplyId": rid}) == {"success": True}

    # 1) revoked_at 被置上
    row = clean_collections.collection(COLLECTIONS["verifications"]).document(v["id"]).get().to_dict()
    assert row["revoked_at"] is not None

    # 2) replies.verification 被清为 None
    r = clean_collections.collection(COLLECTIONS["replies"]).document(rid).get().to_dict()
    assert r["verification"] is None

    # 3) outbox 两条事件
    types = sorted(d.to_dict()["event_type"]
                   for d in clean_collections.collection(COLLECTIONS["outbox"]).stream())
    assert types == ["reply_verified", "verification_revoked"]


def test_撤销_非应验人查不到记录(clean_collections):
    """★ 坑 5：用 verifier_app_user_id 匹配，别人撤不了我的应验。"""
    pid, rid = _post_and_reply()
    verify(AUTHOR, {"postId": pid, "rootReplyId": rid})
    with pytest.raises(XuanHttpsError) as e:
        revoke("uid_第三方", {"postId": pid, "rootReplyId": rid})
    assert e.value.code == "not-found"


def test_撤销后可重新应验(clean_collections):
    pid, rid = _post_and_reply()
    first = verify(AUTHOR, {"postId": pid, "rootReplyId": rid})
    revoke(AUTHOR, {"postId": pid, "rootReplyId": rid})
    again = verify(AUTHOR, {"postId": pid, "rootReplyId": rid, "idempotency_key": "k2"})
    assert "existing" not in again, "撤销后应能重新应验，产生新记录"
    assert again["id"] != first["id"]


def test_撤销后游客视图不再置顶(clean_collections):
    from xuan.handlers.guest_replies import _get_guest_representative_replies_impl as guest
    pid = _create_post_impl(AUTHOR, {"text": "帖"})["id"]
    rid = _create_root_reply_impl(REPLIER, {"postId": pid, "body": "答"})["id"]
    verify(AUTHOR, {"postId": pid, "rootReplyId": rid})
    revoke(AUTHOR, {"postId": pid, "rootReplyId": rid})
    got = guest({"postId": pid})
    assert got["visibleReplies"][0]["isVerified"] is False


def test_撤销影响信誉计数(clean_collections):
    from xuan.handlers.reputation import _recalculate_reputation_impl as recalc
    pid, rid = _post_and_reply()
    v = verify(AUTHOR, {"postId": pid, "rootReplyId": rid})
    aid = v["verifier_app_user_id"]
    assert recalc(AUTHOR, {"appUserId": aid})["playground_verification_count"] == 1
    revoke(AUTHOR, {"postId": pid, "rootReplyId": rid})
    assert recalc(AUTHOR, {"appUserId": aid})["playground_verification_count"] == 0

