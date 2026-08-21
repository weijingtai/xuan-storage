"""FW2-S: 服务端 REST 写端点 (PUT /playground/likes, PUT /playground/bookmarks) 验收测试集。

判据覆盖：
- S1: REST 端点与现有 callable 逐字段等价
- S2: 幂等性实证（同一 Idempotency-Key 重放 N 次，数据库只落一条，返回体一致）
- S3: 不同 payload 复用同一幂等键 -> 报 409 冲突 (conflict.idempotency)
- S4: 参数校验对齐（postId/replyId 都不给、action 非法值，错误码对齐 invalid-argument）
- S5: 写后立即读，读到新值（缓存失效生效）
- S6: OpenAPI 校验
- S7: pytest 全套通过
"""

import json
from unittest.mock import MagicMock
import pytest

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
    callable_res = _set_bookmark_impl("uid_bm1", {"postId": "p1", "action": "bookmark"})
    clean_collections.collection(COLLECTIONS["bookmarks"]).document("bookmark_uid_bm1_p1").delete()

    status_code, rest_res, headers = _set_playground_bookmark_impl(
        uid="uid_bm1",
        data={"postId": "p1", "action": "bookmark"},
    )
    assert status_code == 200
    assert headers["Content-Type"] == "application/json"
    assert rest_res == callable_res
    assert set(rest_res.keys()) == {"bookmarked", "id"}
    assert rest_res["bookmarked"] is True
    assert rest_res["id"] == "bookmark_uid_bm1_p1"


def test_S1_unbookmark_逐字段等价(clean_collections):
    _seed(clean_collections)
    _set_playground_bookmark_impl(uid="uid_bm1", data={"postId": "p1", "action": "bookmark"})

    status_code, rest_res, headers = _set_playground_bookmark_impl(
        uid="uid_bm1",
        data={"postId": "p1", "action": "unbookmark"},
    )
    assert status_code == 200
    assert rest_res == {"bookmarked": False, "id": "bookmark_uid_bm1_p1"}


# ============================================================================
# S2: 幂等性实证（同一 Idempotency-Key 重放 N 次，数据库只落一条）
# ============================================================================

def test_S2_like_幂等重放_N次计数(clean_collections):
    _seed(clean_collections)
    key = "idem-like-s2-key"
    results = []
    for _ in range(5):
        code, body, _ = _set_playground_like_impl(
            uid="uid_idem",
            data={"postId": "p1", "action": "like"},
            idempotency_key=key,
        )
        assert code == 200
        results.append(body)

    # 5 次返回体完全一致
    assert all(r == results[0] for r in results)

    # 数据库 likes 集合只落 1 条
    likes = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["likes"]).stream() if d.id == "like_post_uid_idem_p1"]
    assert len(likes) == 1

    # 幂等记录状态为 completed
    idem_doc = clean_collections.collection(COLLECTIONS["idempotency"]).document(key).get()
    assert idem_doc.exists
    assert idem_doc.to_dict()["state"] == "completed"


def test_S2_bookmark_幂等重放_N次计数(clean_collections):
    _seed(clean_collections)
    key = "idem-bm-s2-key"
    results = []
    for _ in range(5):
        code, body, _ = _set_playground_bookmark_impl(
            uid="uid_bm_idem",
            data={"postId": "p1", "action": "bookmark"},
            idempotency_key=key,
        )
        assert code == 200
        results.append(body)

    assert all(r == results[0] for r in results)
    bms = [d.to_dict() for d in clean_collections.collection(COLLECTIONS["bookmarks"]).stream() if d.id == "bookmark_uid_bm_idem_p1"]
    assert len(bms) == 1


# ============================================================================
# S3: 异载荷冲突测试
# ============================================================================

def test_S3_同key异载荷报409冲突(clean_collections):
    _seed(clean_collections)
    key = "idem-conflict-key"
    code1, body1, _ = _set_playground_like_impl(
        uid="uid_c",
        data={"postId": "p1", "action": "like"},
        idempotency_key=key,
    )
    assert code1 == 200

    # 相同 key，不同 action (payload 改变)
    code2, body2, _ = _set_playground_like_impl(
        uid="uid_c",
        data={"postId": "p1", "action": "unlike"},
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

def test_S5_写后立即读帖子详情命中失效(clean_collections):
    _seed(clean_collections)
    cache = MemoryCachePort()
    set_global_cache(cache)

    # 1. 预热读缓存
    status1, post1, h1 = _get_playground_post_impl(post_id="p1", cache=cache, db_client=clean_collections)
    assert status1 == 200
    assert cache.get("playground/posts/p1") is not None

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


# ============================================================================
# HTTP 适配器入口 (@https_fn.on_request) 测试
# ============================================================================

def test_HTTP_likes_on_request_header_and_body(clean_collections):
    _seed(clean_collections)
    req = MagicMock()
    req.method = "PUT"
    req.headers = {
        "X-Caller-UID": "uid_http_like",
        "Idempotency-Key": "ik-http-1",
        "Content-Type": "application/json",
    }
    req.get_json.return_value = {"postId": "p1", "action": "like"}

    resp = playground_likes_py(req)
    assert resp.status_code == 200
    data = json.loads(resp.response[0] if isinstance(resp.response, list) else resp.response)
    assert data["liked"] is True
    assert data["id"] == "like_post_uid_http_like_p1"


def test_HTTP_bookmarks_on_request_header_and_body(clean_collections):
    _seed(clean_collections)
    req = MagicMock()
    req.method = "PUT"
    req.headers = {
        "X-Caller-UID": "uid_http_bm",
        "Idempotency-Key": "ik-http-bm-1",
        "Content-Type": "application/json",
    }
    req.get_json.return_value = {"postId": "p1", "action": "bookmark"}

    resp = playground_bookmarks_py(req)
    assert resp.status_code == 200
    data = json.loads(resp.response[0] if isinstance(resp.response, list) else resp.response)
    assert data["bookmarked"] is True
    assert data["id"] == "bookmark_uid_http_bm_p1"
