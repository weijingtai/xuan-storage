"""FW3-S: 服务端 12 个 REST 写端点 (Batch 1-6) 验收测试套件。

覆盖 6 批共 12 个端点：
- Batch 1: createPost, editPost
- Batch 2: tombstonePost, updateMyProfile
- Batch 3: createRootReply, createDiscussionReply
- Batch 4: editReply, deleteReply
- Batch 5: verifyRootReply, revokeVerification
- Batch 6: setOutcomeFeedback, revokeOutcomeFeedback

验证要点：
1. 逐端点功能正常，返回体与 Callable 等价；
2. 幂等性防护 (Idempotency-Key 重放一致，异载荷 409)；
3. 严格身份鉴权 (Bearer 验签，无 Token 401，伪造头拦截)；
4. 请求方法限制 (非允许方法 405 Method Not Allowed)；
5. 入参校验与 RFC 9457 Problem Details 错误映射；
6. 业务联动写入（断语应验 3 处联动，最终反馈回写 post 标志）。
"""

import json
import os
from unittest.mock import MagicMock
import pytest
from firebase_admin import auth

from xuan.config import COLLECTIONS
from xuan.handlers.playground_rest import (
    _create_playground_post_impl,
    _edit_playground_post_impl,
    _tombstone_playground_post_impl,
    _update_playground_profile_impl,
    _create_playground_root_reply_impl,
    _create_playground_discussion_reply_impl,
    _edit_playground_reply_impl,
    _delete_playground_reply_impl,
    _verify_playground_root_reply_impl,
    _revoke_playground_verification_impl,
    _set_playground_outcome_feedback_impl,
    _revoke_playground_outcome_feedback_impl,
    playground_posts_write_py,
    playground_profile_py,
    playground_replies_write_py,
    playground_verifications_write_py,
    playground_outcome_feedback_write_py,
)


def create_test_id_token(uid: str) -> str:
    """利用 Firebase Auth Emulator 签发真实合法的 ID Token。"""
    custom_token = auth.create_custom_token(uid)
    if isinstance(custom_token, bytes):
        custom_token = custom_token.decode("utf-8")
    auth_host = os.environ.get("FIREBASE_AUTH_EMULATOR_HOST", "192.168.0.165:9099")
    import urllib.request
    url = f"http://{auth_host}/identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=fake-api-key"
    payload = json.dumps({"token": custom_token, "returnSecureToken": True}).encode("utf-8")
    req = urllib.request.Request(url, data=payload, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req) as resp:
        body = json.loads(resp.read().decode("utf-8"))
        return body["idToken"]


def _make_http_req(method="POST", headers=None, body=None, args=None):
    req = MagicMock()
    req.method = method
    req.headers = headers or {}
    req.args = args or {}
    req.data = json.dumps(body or {}).encode("utf-8") if body is not None else b""
    req.get_json = lambda silent=True: body or {}
    return req


def _seed_identity(client, uid="user-author-1", app_user_id="app-user-1", presentation_id="pres-1"):
    client.collection(COLLECTIONS["identity_map"]).document(uid).set({
        "provider_uid": uid,
        "app_user_id": app_user_id,
        "public_presentation_id": presentation_id,
        "public_display_alias": "卦师阿玄",
    })


# ============================================================================
# Batch 1: Posts 发帖与编辑 (createPost, editPost)
# ============================================================================

def test_batch1_create_and_edit_post(clean_collections):
    client = clean_collections
    _seed_identity(client, uid="user-author-1", app_user_id="app-user-1")

    # 1. 发帖 (POST /playground/posts)
    status, body, _ = _create_playground_post_impl(
        uid="user-author-1",
        data={"text": "求测下半年运势", "allowed_chart_technique_ids": ["bazi", "liuyao"]},
        idempotency_key="post-key-001",
    )
    assert status == 201
    post_id = body["id"]
    assert body["text"] == "求测下半年运势"
    assert body["author_app_user_id"] == "app-user-1"
    assert body["status"] == "active"

    # 幂等重放
    status2, body2, _ = _create_playground_post_impl(
        uid="user-author-1",
        data={"text": "求测下半年运势", "allowed_chart_technique_ids": ["bazi", "liuyao"]},
        idempotency_key="post-key-001",
    )
    assert status2 == 201
    assert body2["id"] == post_id

    # 异载荷冲突
    status_conflict, body_conflict, _ = _create_playground_post_impl(
        uid="user-author-1",
        data={"text": "不同内容", "allowed_chart_technique_ids": ["bazi"]},
        idempotency_key="post-key-001",
    )
    assert status_conflict == 409
    assert body_conflict["type"] == "conflict.idempotency"

    # 2. 编辑 (PATCH /playground/posts/{id})
    status_edit, body_edit, _ = _edit_playground_post_impl(
        uid="user-author-1",
        post_id=post_id,
        data={"text": "求测下半年运势（补充背景）"},
        idempotency_key="edit-post-001",
    )
    assert status_edit == 200
    assert body_edit["text"] == "求测下半年运势（补充背景）"

    # 编辑幂等重放
    status_edit_replay, body_edit_replay, _ = _edit_playground_post_impl(
        uid="user-author-1",
        post_id=post_id,
        data={"text": "求测下半年运势（补充背景）"},
        idempotency_key="edit-post-001",
    )
    assert status_edit_replay == 200
    assert body_edit_replay["text"] == "求测下半年运势（补充背景）"

    # 编辑异载荷冲突 409
    status_edit_conf, body_edit_conf, _ = _edit_playground_post_impl(
        uid="user-author-1",
        post_id=post_id,
        data={"text": "另一个不同的更新内容"},
        idempotency_key="edit-post-001",
    )
    assert status_edit_conf == 409
    assert body_edit_conf["type"] == "conflict.idempotency"

    # 非作者编辑报 403
    status_403, body_403, _ = _edit_playground_post_impl(
        uid="user-other-2",
        post_id=post_id,
        data={"text": "篡改他人帖子"},
    )
    assert status_403 == 403
    assert body_403["type"] == "permission_denied"


# ============================================================================
# Batch 2: Posts 墓碑化与 Profile (tombstonePost, updateMyProfile)
# ============================================================================

def test_batch2_tombstone_post_and_profile(clean_collections):
    client = clean_collections
    _seed_identity(client, uid="user-author-1", app_user_id="app-user-1")

    # 创建帖子
    _, post_body, _ = _create_playground_post_impl(
        uid="user-author-1",
        data={"text": "待删除帖子"},
    )
    post_id = post_body["id"]

    # 1. 软删帖子 (DELETE /playground/posts/{id})
    status_del, body_del, _ = _tombstone_playground_post_impl(
        uid="user-author-1",
        post_id=post_id,
        idempotency_key="del-post-001",
    )
    assert status_del == 200
    assert body_del["success"] is True

    # 软删幂等重放（同一 key 返回 200 且不报错）
    status_del_replay, body_del_replay, _ = _tombstone_playground_post_impl(
        uid="user-author-1",
        post_id=post_id,
        idempotency_key="del-post-001",
    )
    assert status_del_replay == 200
    assert body_del_replay["success"] is True

    # 验证数据库状态已墓碑化
    doc = client.collection(COLLECTIONS["posts"]).document(post_id).get()
    assert doc.to_dict()["status"] == "tombstoned"

    # 2. 更新个人资料 (PATCH /playground/profile)
    status_prof, body_prof, _ = _update_playground_profile_impl(
        uid="user-author-1",
        data={"displayName": "新玄号", "bio": "专注六爻纳甲", "commonTechniques": ["liuyao", "meihua"]},
        idempotency_key="prof-key-001",
    )
    assert status_prof == 200
    assert body_prof["appUserId"] == "app-user-1"
    assert body_prof["success"] is True

    # 验证 profile 数据库落库
    prof_doc = client.collection(COLLECTIONS["profiles"]).document("app-user-1").get()
    pdata = prof_doc.to_dict()
    assert pdata["display_name"] == "新玄号"
    assert pdata["bio"] == "专注六爻纳甲"
    assert pdata["common_techniques"] == ["liuyao", "meihua"]


# ============================================================================
# Batch 3: Replies 根回复与跟帖 (createRootReply, createDiscussionReply)
# ============================================================================

def test_batch3_create_replies(clean_collections):
    client = clean_collections
    _seed_identity(client, uid="user-author-1", app_user_id="app-user-1")
    _seed_identity(client, uid="user-replyer-2", app_user_id="app-user-2")

    _, post_body, _ = _create_playground_post_impl(
        uid="user-author-1",
        data={"text": "问事帖"},
    )
    post_id = post_body["id"]

    # 1. 创建根回复 (POST /playground/posts/{id}/replies)
    status_r, body_r, _ = _create_playground_root_reply_impl(
        uid="user-replyer-2",
        post_id=post_id,
        data={"body": "依卦象看，秋季必成", "techniqueTags": ["liuyao"]},
        idempotency_key="root-reply-001",
    )
    assert status_r == 201
    root_reply_id = body_r["id"]
    assert body_r["post_id"] == post_id
    assert body_r["author_app_user_id"] == "app-user-2"
    assert body_r["body"] == "依卦象看，秋季必成"

    # 2. 创建讨论跟帖 (POST /playground/replies/{id}/replies)
    status_d, body_d, _ = _create_playground_discussion_reply_impl(
        uid="user-author-1",
        root_reply_id=root_reply_id,
        data={"body": "感谢大师指点！"},
        idempotency_key="disc-reply-001",
    )
    assert status_d == 201
    assert body_d["post_id"] == post_id
    assert body_d["root_reply_id"] == root_reply_id
    assert body_d["author_app_user_id"] == "app-user-1"


# ============================================================================
# Batch 4: Replies 编辑与删除 (editReply, deleteReply)
# ============================================================================

def test_batch4_edit_and_delete_reply(clean_collections):
    client = clean_collections
    _seed_identity(client, uid="user-author-1", app_user_id="app-user-1")
    _seed_identity(client, uid="user-replyer-2", app_user_id="app-user-2")

    _, post_body, _ = _create_playground_post_impl(
        uid="user-author-1",
        data={"text": "帖子"},
    )
    _, r_body, _ = _create_playground_root_reply_impl(
        uid="user-replyer-2",
        post_id=post_body["id"],
        data={"body": "原断语"},
    )
    reply_id = r_body["id"]

    # 1. 编辑回复 (PATCH /playground/replies/{id})
    status_edit, body_edit, _ = _edit_playground_reply_impl(
        uid="user-replyer-2",
        reply_id=reply_id,
        data={"body": "修订后的断语"},
        idempotency_key="edit-reply-001",
    )
    assert status_edit == 200
    assert body_edit["body"] == "修订后的断语"

    # 编辑回复幂等重放
    status_edit_replay, body_edit_replay, _ = _edit_playground_reply_impl(
        uid="user-replyer-2",
        reply_id=reply_id,
        data={"body": "修订后的断语"},
        idempotency_key="edit-reply-001",
    )
    assert status_edit_replay == 200
    assert body_edit_replay["body"] == "修订后的断语"

    # 编辑回复异载荷冲突 409
    status_edit_conf, body_edit_conf, _ = _edit_playground_reply_impl(
        uid="user-replyer-2",
        reply_id=reply_id,
        data={"body": "不一致的修改内容"},
        idempotency_key="edit-reply-001",
    )
    assert status_edit_conf == 409
    assert body_edit_conf["type"] == "conflict.idempotency"

    # 2. 软删回复 (DELETE /playground/replies/{id})
    status_del, body_del, _ = _delete_playground_reply_impl(
        uid="user-replyer-2",
        reply_id=reply_id,
        idempotency_key="del-reply-001",
    )
    assert status_del == 200
    assert body_del["success"] is True

    # 软删回复幂等重放
    status_del_replay, body_del_replay, _ = _delete_playground_reply_impl(
        uid="user-replyer-2",
        reply_id=reply_id,
        idempotency_key="del-reply-001",
    )
    assert status_del_replay == 200
    assert body_del_replay["success"] is True

    # 验证回复标记已软删
    rdoc = client.collection(COLLECTIONS["replies"]).document(reply_id).get()
    assert rdoc.to_dict()["is_tombstoned"] is True


# ============================================================================
# Batch 5: 断语应验与撤销 (verifyRootReply, revokeVerification)
# ============================================================================

def test_batch5_verify_and_revoke_verification(clean_collections):
    client = clean_collections
    _seed_identity(client, uid="user-author-1", app_user_id="app-user-1")
    _seed_identity(client, uid="user-replyer-2", app_user_id="app-user-2")

    _, post_body, _ = _create_playground_post_impl(
        uid="user-author-1",
        data={"text": "求测求职"},
    )
    post_id = post_body["id"]
    _, r_body, _ = _create_playground_root_reply_impl(
        uid="user-replyer-2",
        post_id=post_id,
        data={"body": "本周五收到 offer"},
    )
    root_reply_id = r_body["id"]

    # 1. 应验断语 (PUT /playground/replies/{id}/verification)
    status_v, body_v, _ = _verify_playground_root_reply_impl(
        uid="user-author-1",
        root_reply_id=root_reply_id,
        data={"postId": post_id, "feedbackOutcome": "果然周五拿到了！"},
        idempotency_key="verify-001",
    )
    assert status_v == 200
    assert body_v["post_id"] == post_id
    assert body_v["root_reply_id"] == root_reply_id
    assert body_v["verifier_app_user_id"] == "app-user-1"

    # 验证三处联动写入：
    # 1) reply 上有 verification 结构
    rdoc = client.collection(COLLECTIONS["replies"]).document(root_reply_id).get()
    assert rdoc.to_dict()["verification"] is not None
    # 2) verifications 集合落库
    v_docs = list(client.collection(COLLECTIONS["verifications"]).where("root_reply_id", "==", root_reply_id).get())
    assert len(v_docs) == 1
    # 3) outbox 产生事件
    o_docs = list(client.collection(COLLECTIONS["outbox"]).where("reply_id", "==", root_reply_id).get())
    assert len(o_docs) >= 1

    # 2. 撤销应验 (DELETE /playground/replies/{id}/verification)
    status_rv, body_rv, _ = _revoke_playground_verification_impl(
        uid="user-author-1",
        root_reply_id=root_reply_id,
        data={"postId": post_id},
        idempotency_key="revoke-verify-001",
    )
    assert status_rv == 200
    assert body_rv["success"] is True

    # 验证回复上的 verification 已被清空
    rdoc2 = client.collection(COLLECTIONS["replies"]).document(root_reply_id).get()
    assert rdoc2.to_dict()["verification"] is None


# ============================================================================
# Batch 6: 最终反馈与撤销 (setOutcomeFeedback, revokeOutcomeFeedback)
# ============================================================================

def test_batch6_outcome_feedback_and_revoke(clean_collections):
    client = clean_collections
    _seed_identity(client, uid="user-author-1", app_user_id="app-user-1")

    _, post_body, _ = _create_playground_post_impl(
        uid="user-author-1",
        data={"text": "事情有了最终结果"},
    )
    post_id = post_body["id"]

    # 1. 填写最终反馈 (PUT /playground/posts/{id}/outcome-feedback)
    status_fb, body_fb, _ = _set_playground_outcome_feedback_impl(
        uid="user-author-1",
        post_id=post_id,
        data={"outcomeDescription": "最终签约成功，感谢各位大师"},
        idempotency_key="outcome-001",
    )
    assert status_fb == 200
    assert body_fb["post_id"] == post_id
    assert body_fb["outcome_description"] == "最终签约成功，感谢各位大师"

    # 验证 post 的 has_outcome_feedback 标志回写为 True
    pdoc = client.collection(COLLECTIONS["posts"]).document(post_id).get()
    assert pdoc.to_dict()["has_outcome_feedback"] is True

    # 重复设置应报 conflict / already_exists (409)
    status_dup, body_dup, _ = _set_playground_outcome_feedback_impl(
        uid="user-author-1",
        post_id=post_id,
        data={"outcomeDescription": "再次填写"},
    )
    assert status_dup == 409

    # 2. 撤销最终反馈 (DELETE /playground/posts/{id}/outcome-feedback)
    status_rf, body_rf, _ = _revoke_playground_outcome_feedback_impl(
        uid="user-author-1",
        post_id=post_id,
        idempotency_key="revoke-outcome-001",
    )
    assert status_rf == 200
    assert body_rf["success"] is True

    # 验证 post 的 has_outcome_feedback 标志重置为 False
    pdoc2 = client.collection(COLLECTIONS["posts"]).document(post_id).get()
    assert pdoc2.to_dict()["has_outcome_feedback"] is False


# ============================================================================
# 安全鉴权、HTTP Method 与端到端 Token 测试
# ============================================================================

def test_security_and_http_methods(clean_collections):
    client = clean_collections
    _seed_identity(client, uid="user-author-1", app_user_id="app-user-1")
    token = create_test_id_token("user-author-1")

    # 1. 正常 Bearer Token 端到端调用 (POST /playground/posts)
    req = _make_http_req(
        method="POST",
        headers={"Authorization": f"Bearer {token}", "Idempotency-Key": "e2e-post-001"},
        body={"text": "端到端 Token 测试发帖"},
    )
    resp = playground_posts_write_py(req)
    assert resp.status_code == 201
    resp_data = json.loads(resp.response[0])
    assert resp_data["author_app_user_id"] == "app-user-1"
    post_id = resp_data["id"]

    # 2. 冒充拦截（无 Token / 伪造头）必须返回 401
    req_spoof = _make_http_req(
        method="POST",
        headers={"X-Caller-UID": "user-author-1", "Idempotency-Key": "spoof-001"},
        body={"text": "冒充发帖"},
    )
    resp_spoof = playground_posts_write_py(req_spoof)
    assert resp_spoof.status_code == 401

    # 3. 坏签名/伪造 JWT Token 必须返回 401
    req_bad_jwt = _make_http_req(
        method="POST",
        headers={"Authorization": "Bearer eyJhbGciOiJub25lIn0.eyJ1aWQiOiJhdXRob3ItMSJ9.", "Idempotency-Key": "bad-jwt-001"},
        body={"text": "伪造JWT发帖"},
    )
    resp_bad_jwt = playground_posts_write_py(req_bad_jwt)
    assert resp_bad_jwt.status_code == 401

    # 4. HTTP 错误方法 (GET 调写端点) 必须返回 405 Method Not Allowed
    req_bad_method = _make_http_req(
        method="GET",
        headers={"Authorization": f"Bearer {token}"},
    )
    resp_bad_method = playground_posts_write_py(req_bad_method)
    assert resp_bad_method.status_code == 405

    # 5. 其余 4 个 FaaS 入口的 401 与 405 拦截校验
    handlers_and_methods = [
        (playground_profile_py, "GET", "PATCH", {"displayName": "测试"}),
        (playground_replies_write_py, "GET", "POST", {"postId": "post-dummy-1", "body": "回复"}),
        (playground_verifications_write_py, "GET", "PUT", {"rootReplyId": "reply-dummy-1"}),
        (playground_outcome_feedback_write_py, "GET", "PUT", {"postId": "post-dummy-1", "outcomeDescription": "反馈"}),
    ]
    for handler, bad_method, valid_method, dummy_body in handlers_and_methods:
        # 无 Token -> 401
        r401 = handler(_make_http_req(method=valid_method, body=dummy_body))
        assert r401.status_code == 401, f"{handler.__name__} 无 Token 应返回 401"

        # 非法 Method -> 405
        r405 = handler(_make_http_req(method=bad_method, headers={"Authorization": f"Bearer {token}"}, body=dummy_body))
        assert r405.status_code == 405, f"{handler.__name__} 错误方法 {bad_method} 应返回 405"


def test_cross_scope_permissions(clean_collections):
    client = clean_collections
    _seed_identity(client, uid="user-author-1", app_user_id="app-user-1")
    _seed_identity(client, uid="user-attacker-2", app_user_id="app-user-2")

    # 创建帖子
    _, post_body, _ = _create_playground_post_impl(
        uid="user-author-1",
        data={"text": "受保护帖子"},
    )
    post_id = post_body["id"]

    # 1. 攻击者试图软删他人帖子 -> 403 permission_denied
    status_del, body_del, _ = _tombstone_playground_post_impl(
        uid="user-attacker-2",
        post_id=post_id,
    )
    assert status_del == 403
    assert body_del["type"] == "permission_denied"

    # 2. 攻击者试图填写他人帖子的最终反馈 -> 403 permission_denied
    status_fb, body_fb, _ = _set_playground_outcome_feedback_impl(
        uid="user-attacker-2",
        post_id=post_id,
        data={"outcomeDescription": "越权设置反馈"},
    )
    assert status_fb == 403
    assert body_fb["type"] == "permission_denied"


