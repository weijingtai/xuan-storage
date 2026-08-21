"""outcome_feedback。基准实现：functions/src/outcome_feedback.ts"""
import pytest

from xuan.config import COLLECTIONS
from xuan.errors import XuanHttpsError
from xuan.handlers.outcome_feedback import _set_outcome_feedback_impl as set_fb
from xuan.handlers.posts import _create_post_impl, _tombstone_post_impl

AUTHOR = "uid_of_author"
OTHER = "uid_of_other"


def _post() -> str:
    return _create_post_impl(AUTHOR, {"text": "求测"})["id"]


def test_必填校验(clean_collections):
    pid = _post()
    for bad in [
        {}, {"postId": pid}, {"outcome_description": "结果"},
        {"postId": pid, "outcome_description": "   "},
        {"postId": 1, "outcome_description": "x"},
    ]:
        with pytest.raises(XuanHttpsError) as e:
            set_fb(AUTHOR, bad)
        assert e.value.code == "invalid-argument"


def test_帖子不存在或已删(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        set_fb(AUTHOR, {"postId": "无", "outcome_description": "x"})
    assert e.value.code == "not-found"

    pid = _post()
    _tombstone_post_impl(AUTHOR, {"postId": pid})
    with pytest.raises(XuanHttpsError) as e:
        set_fb(AUTHOR, {"postId": pid, "outcome_description": "x"})
    assert e.value.code == "not-found"


def test_只有帖子作者可设置(clean_collections):
    pid = _post()
    with pytest.raises(XuanHttpsError) as e:
        set_fb(OTHER, {"postId": pid, "outcome_description": "x"})
    assert e.value.code == "permission-denied"


def test_设置成功并回写帖子标志(clean_collections):
    pid = _post()
    got = set_fb(AUTHOR, {"postId": pid, "outcome_description": "  应验了  "})
    assert got["outcome_description"] == "应验了", "必须 trim"
    assert got["post_id"] == pid

    fb = clean_collections.collection(COLLECTIONS["outcome_feedback"]).document(got["id"]).get().to_dict()
    assert fb["deleted_at"] is None, "★ 必须显式写 null，否则后续查询漏掉"

    post = clean_collections.collection(COLLECTIONS["posts"]).document(pid).get().to_dict()
    assert post["has_outcome_feedback"] is True, "必须回写帖子标志"


def test_重复设置报_already_exists(clean_collections):
    pid = _post()
    set_fb(AUTHOR, {"postId": pid, "outcome_description": "第一次"})
    with pytest.raises(XuanHttpsError) as e:
        set_fb(AUTHOR, {"postId": pid, "outcome_description": "第二次"})
    assert e.value.code == "already-exists"


def test_设置后游客视图可见(clean_collections):
    from xuan.handlers.guest_replies import _get_guest_representative_replies_impl as guest
    pid = _post()
    set_fb(AUTHOR, {"postId": pid, "outcome_description": "最终结果"})
    got = guest({"postId": pid})["outcomeFeedback"]
    assert got["body"] == "最终结果"
    assert got["isEdited"] is False


from xuan.handlers.outcome_feedback import _revoke_outcome_feedback_impl as revoke_fb


def test_撤销_必填校验(clean_collections):
    with pytest.raises(XuanHttpsError) as e:
        revoke_fb(AUTHOR, {})
    assert e.value.code == "invalid-argument"


def test_撤销_无有效反馈(clean_collections):
    pid = _post()
    with pytest.raises(XuanHttpsError) as e:
        revoke_fb(AUTHOR, {"postId": pid})
    assert e.value.code == "not-found"


def test_撤销_成功并回写帖子标志(clean_collections):
    pid = _post()
    got = set_fb(AUTHOR, {"postId": pid, "outcome_description": "结果"})
    assert revoke_fb(AUTHOR, {"postId": pid}) == {"success": True}

    fb = clean_collections.collection(COLLECTIONS["outcome_feedback"]).document(got["id"]).get().to_dict()
    assert fb["deleted_at"] is not None

    post = clean_collections.collection(COLLECTIONS["posts"]).document(pid).get().to_dict()
    assert post["has_outcome_feedback"] is False


def test_撤销_非作者查不到(clean_collections):
    """★ 坑 5：用 author_app_user_id 匹配。"""
    pid = _post()
    set_fb(AUTHOR, {"postId": pid, "outcome_description": "结果"})
    with pytest.raises(XuanHttpsError) as e:
        revoke_fb(OTHER, {"postId": pid})
    assert e.value.code == "not-found"


def test_撤销后可重新设置(clean_collections):
    pid = _post()
    set_fb(AUTHOR, {"postId": pid, "outcome_description": "第一次"})
    revoke_fb(AUTHOR, {"postId": pid})
    again = set_fb(AUTHOR, {"postId": pid, "outcome_description": "第二次", "idempotency_key": "k2"})
    assert again["outcome_description"] == "第二次"


def test_撤销后游客视图不再显示(clean_collections):
    from xuan.handlers.guest_replies import _get_guest_representative_replies_impl as guest
    pid = _post()
    set_fb(AUTHOR, {"postId": pid, "outcome_description": "结果"})
    revoke_fb(AUTHOR, {"postId": pid})
    assert guest({"postId": pid})["outcomeFeedback"] is None

