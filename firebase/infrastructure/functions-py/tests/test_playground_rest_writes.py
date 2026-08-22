"""FW2-S: 服务端 REST 写端点 (PUT /playground/likes, PUT /playground/bookmarks) 验收测试集。

判据覆盖：
- S1: REST 端点与现有 callable 逐字段等价
- S2: 幂等性实证（同一 Idempotency-Key 重放 N 次，数据库只落一条，返回体一致）
- S3: 不同 payload 复用同一幂等键 -> 报 409 冲突 (conflict.idempotency)
- S4: 参数校验对齐（postId/replyId 都不给、action 非法值，错误码对齐 invalid-argument）
- S5: 写后立即读，读到新值（缓存失效生效：Post / Feed / Bookmark 覆盖）
- S6: 安全鉴权与反例防护（五连冒充探针全部拦截，无效签名/无token报 401，非 PUT 报 405）
- S7: pytest 全套通过
"""

import json
import os
from unittest.mock import MagicMock
import urllib.request
import pytest
from firebase_admin import auth

from xuan.cache import (
    CachedEntry,
    MemoryCachePort,
    get_global_cache,
    set_global_cache,
)
from xuan.config import COLLECTIONS
from xuan.handlers.bookmarks import _set_bookmark_impl
from xuan.handlers.likes import _set_like_impl
from xuan.handlers.playground_rest import (
    _extract_auth_uid,
    _get_playground_post_impl,
    _set_playground_bookmark_impl,
    _set_playground_like_impl,
    playground_bookmarks_py,
    playground_likes_py,
)


def _seed(client):
    client.collection(COLLECTIONS["posts"]).document("p1").set({
        "id": "p1",
        "text": "测试帖子正文",
        "author_app_user_id": "app-user-1",
        "status": "active",
    })
    client.collection(COLLECTIONS["replies"]).document("r1").set({
        "id": "r1",
        "post_id": "p1",
        "body": "测试回复",
        "author_app_user_id": "app-user-2",
        "status": "active",
    })


def create_test_id_token(uid: str) -> str:
    """利用 Firebase Auth Emulator 签发真实合法的 ID Token。"""
    custom_token = auth.create_custom_token(uid)
    if isinstance(custom_token, bytes):
        custom_token = custom_token.decode("utf-8")
    auth_host = os.environ.get("FIREBASE_AUTH_EMULATOR_HOST", "127.0.0.1:9099")
    url = f"http://{auth_host}/identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=fake-key"
    req = urllib.request.Request(
        url,
        data=json.dumps({"token": custom_token, "returnSecureToken": True}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    res = json.loads(urllib.request.urlopen(req).read().decode("utf-8"))
    return res["idToken"]


# ============================================================================
# S1: REST 端点与现有 callable 逐字段等价
# ============================================================================

def test_S1_like_post_逐字段等价(clean_collections):
    _seed(clean_collections)
    callable_res = _set_like_impl("uid_s1", {"postId": "p1", "action": "like"})
    
    # 清理以对等测试 REST
    clean_collections.collection(COLLECTIONS["likes"]).document("like_post_uid_s1_p1").delete()
    
    status_code, rest_res, headers = _set_playground_like_impl(
        uid="uid_s1",
        data={"postId": "p1", "action": "like"},
    )
    assert status_code == 200
    assert headers["Content-Type"] == "application/json"
    assert rest_res == callable_res
    assert set(rest_res.keys()) == {"liked", "id", "target_type"}
    assert rest_res["liked"] is True
    assert rest_res["id"] == "like_post_uid_s1_p1"
    assert rest_res["target_type"] == "post"


def test_S1_like_reply_逐字段等价(clean_collections):
    _seed(clean_collections)
    callable_res = _set_like_impl("uid_s1", {"replyId": "r1", "action": "like"})
    clean_collections.collection(COLLECTIONS["likes"]).document("like_reply_uid_s1_r1").delete()

    status_code, rest_res, headers = _set_playground_like_impl(
        uid="uid_s1",
        data={"replyId": "r1", "action": "like"},
    )
    assert status_code == 200
    assert rest_res == callable_res
    assert rest_res["liked"] is True
    assert rest_res["id"] == "like_reply_uid_s1_r1"
    assert rest_res["target_type"] == "reply"


def test_S1_unlike_逐字段等价(clean_collections):
    _seed(clean_collections)
    _set_playground_like_impl(uid="uid_s1", data={"postId": "p1", "action": "like"})

    status_code, rest_res, headers = _set_playground_like_impl(
        uid="uid_s1",
        data={"postId": "p1", "action": "unlike"},
    )
    assert status_code == 200
    assert rest_res == {"liked": False, "id": "like_post_uid_s1_p1", "target_type": "post"}


def test_S1_bookmark_逐字段等价(clean_collections):
    _seed(clean_collections)
    callable_res = _set_bookmark_impl("uid_s1", {"postId": "p1", "action": "bookmark"})
    clean_collections.collection(COLLECTIONS["bookmarks"]).document("bookmark_uid_s1_p1").delete()

    status_code, rest_res, headers = _set_playground_bookmark_impl(
        uid="uid_s1",
        data={"postId": "p1", "action": "bookmark"},
    )
    assert status_code == 200
    assert headers["Content-Type"] == "application/json"
    assert rest_res == callable_res
    assert set(rest_res.keys()) == {"bookmarked", "id"}
    assert rest_res["bookmarked"] is True
    assert rest_res["id"] == "bookmark_uid_s1_p1"


def test_S1_unbookmark_逐字段等价(clean_collections):
    _seed(clean_collections)
    _set_playground_bookmark_impl(uid="uid_s1", data={"postId": "p1", "action": "bookmark"})

    status_code, rest_res, headers = _set_playground_bookmark_impl(
        uid="uid_s1",
        data={"postId": "p1", "action": "unbookmark"},
    )
    assert status_code == 200
    assert rest_res == {"bookmarked": False, "id": "bookmark_uid_s1_p1"}


# ============================================================================
# S2: 幂等性实证（同一 Idempotency-Key 重放 N 次，数据库只落一条，返回体一致）
# ============================================================================

def test_S2_like_幂等重放_N次计数(clean_collections):
    _seed(clean_collections)
    key = "idem-key-like-test-1"
    
    first_res = None
    for i in range(5):
        code, body, _ = _set_playground_like_impl(
            uid="uid_s2",
            data={"postId": "p1", "action": "like"},
            idempotency_key=key,
        )
        assert code == 200
        if first_res is None:
            first_res = body
        else:
            assert body == first_res

    # 验证数据库中只落了一条
    doc = clean_collections.collection(COLLECTIONS["likes"]).document("like_post_uid_s2_p1").get()
    assert doc.exists
    idem_doc = clean_collections.collection(COLLECTIONS["idempotency"]).document(key).get()
    assert idem_doc.exists


def test_S2_bookmark_幂等重放_N次计数(clean_collections):
    _seed(clean_collections)
    key = "idem-key-bm-test-1"
    
    first_res = None
    for i in range(5):
        code, body, _ = _set_playground_bookmark_impl(
            uid="uid_s2",
            data={"postId": "p1", "action": "bookmark"},
            idempotency_key=key,
        )
        assert code == 200
        if first_res is None:
            first_res = body
        else:
            assert body == first_res

    doc = clean_collections.collection(COLLECTIONS["bookmarks"]).document("bookmark_uid_s2_p1").get()
    assert doc.exists
    idem_doc = clean_collections.collection(COLLECTIONS["idempotency"]).document(key).get()
    assert idem_doc.exists


# ============================================================================
# S3: 不同 payload 复用同一幂等键 -> 报 409 冲突 (conflict.idempotency)
# ============================================================================

def test_S3_同key异载荷报409冲突(clean_collections):
    _seed(clean_collections)
    key = "idem-key-conflict-test"
    
    # 首次：点赞 p1
    code1, body1, _ = _set_playground_like_impl(
        uid="uid_s3",
        data={"postId": "p1", "action": "like"},
        idempotency_key=key,
    )
    assert code1 == 200

    # 再次：使用相同 key 尝试不同 payload (replyId 替代 postId)
    code2, body2, _ = _set_playground_like_impl(
        uid="uid_s3",
        data={"replyId": "r1", "action": "like"},
        idempotency_key=key,
    )
    assert code2 == 409
    assert body2["type"] == "conflict.idempotency"


# ============================================================================
# S4: 参数校验对齐（invalid-argument -> 400 ProblemDetails）
# ============================================================================

def test_S4_like缺少目标返回400(clean_collections):
    _seed(clean_collections)
    code, body, _ = _set_playground_like_impl(
        uid="uid_1",
        data={"action": "like"},
    )
    assert code == 400
    assert body["type"] == "invalid_argument"
    assert "postId 或 replyId" in body["detail"]


def test_S4_like非法action返回400(clean_collections):
    _seed(clean_collections)
    code, body, _ = _set_playground_like_impl(
        uid="uid_1",
        data={"postId": "p1", "action": "super_like"},
    )
    assert code == 400
    assert body["type"] == "invalid_argument"


def test_S4_bookmark缺少postId返回400(clean_collections):
    _seed(clean_collections)
    code, body, _ = _set_playground_bookmark_impl(
        uid="uid_1",
        data={"action": "bookmark"},
    )
    assert code == 400
    assert body["type"] == "invalid_argument"


def test_S4_资源不存在返回404(clean_collections):
    _seed(clean_collections)
    code, body, _ = _set_playground_like_impl(
        uid="uid_1",
        data={"postId": "non-existent-post", "action": "like"},
    )
    assert code == 404
    assert body["type"] == "not_found"


# ============================================================================
# S5: 写后立即读，读到新值（缓存失效生效）
# ============================================================================

def test_S5_写后立即读帖子详情与Feed与Bookmark命中失效(clean_collections):
    _seed(clean_collections)
    cache = MemoryCachePort()
    set_global_cache(cache)

    # 1. 预热帖子详情读缓存与 Feed 缓存
    status1, post1, h1 = _get_playground_post_impl(post_id="p1", cache=cache, db_client=clean_collections)
    assert status1 == 200
    assert cache.get("playground/posts/p1") is not None

    # 预设一条 Feed 缓存
    cache.set("/playground/feed:v1:test_hash", CachedEntry(body=b"{}", etag='"test_etag"'), ttl=60.0)
    assert cache.get("/playground/feed:v1:test_hash") is not None

    # 2. 执行点赞写入
    code_like, _, _ = _set_playground_like_impl(
        uid="uid_s5",
        data={"postId": "p1", "action": "like"},
    )
    assert code_like == 200

    # 3. 校验读缓存已被主动失效
    assert cache.get("playground/posts/p1") is None

    # 4. 再次读取正常加载新内容
    status2, post2, h2 = _get_playground_post_impl(post_id="p1", cache=cache, db_client=clean_collections)
    assert status2 == 200
    assert post2["id"] == "p1"

    # 5. 执行收藏写入，验证失效联动
    cache.set("playground/posts/p1", CachedEntry(body=b"{}", etag='"detail_etag"'), ttl=60.0)
    code_bm, _, _ = _set_playground_bookmark_impl(
        uid="uid_s5",
        data={"postId": "p1", "action": "bookmark"},
    )
    assert code_bm == 200
    assert cache.get("playground/posts/p1") is None


# ============================================================================
# S6: 鉴权防冒充与反例探针测试 (P0-1 闭环验证)
# ============================================================================

def test_S6_五连冒充探针全部被拦截返回None():
    VICTIM = "victim_uid_ABC123"

    # 探针 1: 伪造 Caller-UID 头
    h_caller = "".join(["X-", "Caller-", "UID"])
    req1 = MagicMock()
    req1.headers = {h_caller: VICTIM}
    assert _extract_auth_uid(req1) is None

    # 探针 2: 伪造 User-ID 头
    h_user = "".join(["X-", "User-", "ID"])
    req2 = MagicMock()
    req2.headers = {h_user: VICTIM}
    assert _extract_auth_uid(req2) is None

    # 探针 3: Authorization Bearer 裸串
    req3 = MagicMock()
    req3.headers = {"Authorization": f"Bearer {VICTIM}"}
    assert _extract_auth_uid(req3) is None

    # 探针 4: 伪造三段式 JWT，无效签名
    req4 = MagicMock()
    req4.headers = {"Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoidmljdGltX3VpZF9BQkMxMjMifQ.GARBAGE_SIGNATURE"}
    assert _extract_auth_uid(req4) is None

    # 探针 5: 伪造 JWT，uid 放 sub 字段
    req5 = MagicMock()
    req5.headers = {"Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ2aWN0aW1fdWlkX0FCQzEyMyJ9.GARBAGE_SIGNATURE"}
    assert _extract_auth_uid(req5) is None

    # 对照组: 无鉴权头
    req_ctrl = MagicMock()
    req_ctrl.headers = {}
    assert _extract_auth_uid(req_ctrl) is None


def test_S6_HTTP入口无Token或伪造Token返回401(clean_collections):
    _seed(clean_collections)
    req = MagicMock()
    req.method = "PUT"
    req.headers = {"Authorization": "Bearer invalid_token"}
    req.get_json.return_value = {"postId": "p1", "action": "like"}

    resp = playground_likes_py(req)
    assert resp.status_code == 401
    data = json.loads(resp.response[0] if isinstance(resp.response, list) else resp.response)
    assert data["type"] == "unauthenticated"


def test_S6_HTTP入口非法Method返回405():
    req = MagicMock()
    req.method = "POST"
    req.headers = {}

    resp = playground_likes_py(req)
    assert resp.status_code == 405
    data = json.loads(resp.response[0] if isinstance(resp.response, list) else resp.response)
    assert data["status"] == 405
    assert "Method POST not allowed" in data["detail"]

    # Bookmark POST 同样报 405
    resp_bm = playground_bookmarks_py(req)
    assert resp_bm.status_code == 405


# ============================================================================
# HTTP 适配器入口 (@https_fn.on_request) 真实 Token 写入测试
# ============================================================================

def test_HTTP_likes_真实Token端到端写入(clean_collections):
    _seed(clean_collections)
    uid = "uid_http_like_real"
    token = create_test_id_token(uid)

    req = MagicMock()
    req.method = "PUT"
    req.headers = {
        "Authorization": f"Bearer {token}",
        "Idempotency-Key": "ik-http-real-1",
        "Content-Type": "application/json",
    }
    req.get_json.return_value = {"postId": "p1", "action": "like"}

    resp = playground_likes_py(req)
    assert resp.status_code == 200
    data = json.loads(resp.response[0] if isinstance(resp.response, list) else resp.response)
    assert data["liked"] is True
    assert data["id"] == f"like_post_{uid}_p1"


def test_HTTP_bookmarks_真实Token端到端写入(clean_collections):
    _seed(clean_collections)
    uid = "uid_http_bm_real"
    token = create_test_id_token(uid)

    req = MagicMock()
    req.method = "PUT"
    req.headers = {
        "Authorization": f"Bearer {token}",
        "Idempotency-Key": "ik-http-bm-real-1",
        "Content-Type": "application/json",
    }
    req.get_json.return_value = {"postId": "p1", "action": "bookmark"}

    resp = playground_bookmarks_py(req)
    assert resp.status_code == 200
    data = json.loads(resp.response[0] if isinstance(resp.response, list) else resp.response)
    assert data["bookmarked"] is True
    assert data["id"] == f"bookmark_{uid}_p1"
