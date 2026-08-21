"""FW1-S: 服务端 REST 端点与无状态 ETag 验收测试集。

验收判据覆盖：
- S1: 端点形状与 openapi.yaml 逐项吻合（路径、查询参数、响应字段、状态码、ProblemDetails）
- S2: If-None-Match 命中回 304 且响应体为空，计数器证明数据层 0 调用
- S3: ETag 稳定性双向验证（同数据 ETag 恒定不变，数据变化 ETag 改变）
- S4: 多 Tab 排序与过滤正确（recommended/pendingDivination/latest，技法过滤边界测试）
- S5: 游标分页连续无重复遗漏，非法/陈旧游标返回 400 ProblemDetails
- S6: 缓存故障平稳降级
- S7: 全套 pytest 退出码 0
"""

import base64
import json
from unittest.mock import MagicMock
import pytest

from xuan.cache import (
    CachePort,
    CachedEntry,
    MemoryCachePort,
    get_global_cache,
    set_global_cache,
)
from xuan.handlers.playground_rest import (
    _list_playground_feed_impl,
    _get_playground_post_impl,
    compute_feed_etag,
    compute_post_etag,
    encode_cursor,
    decode_cursor,
    to_playground_post_dto,
    playground_feed_py,
    playground_posts_py,
)


class MockFirestoreDb:
    """可精确定位并统计读操作次数的 Firestore Mock 客户端。"""

    def __init__(self, posts=None):
        self.read_count = 0
        self.posts = posts or []

    def collection(self, name: str):
        assert name == "playground_posts"
        mock_col = MagicMock()
        client = self

        def doc_fn(doc_id: str):
            doc_mock = MagicMock()
            def get_fn():
                client.read_count += 1
                found = next((p for p in client.posts if p["id"] == doc_id), None)
                snap = MagicMock()
                if found:
                    snap.exists = True
                    snap.id = doc_id
                    snap.to_dict.return_value = found
                else:
                    snap.exists = False
                    snap.id = doc_id
                    snap.to_dict.return_value = None
                return snap
            doc_mock.get.side_effect = get_fn
            return doc_mock

        def where_fn(field_path, op_string, value):
            return QueryBuilder(client, client.posts).where(field_path, op_string, value)

        mock_col.document.side_effect = doc_fn
        mock_col.where.side_effect = where_fn
        return mock_col


class QueryBuilder:
    """模拟 Firestore 链式查询构建器。"""

    def __init__(self, client: MockFirestoreDb, items: list[dict]):
        self.client = client
        self.items = list(items)
        self._limit = None
        self._order_by = None
        self._descending = False
        self._start_after_doc_id = None

    def where(self, field_path, op_string, value):
        if op_string == "==":
            self.items = [x for x in self.items if x.get(field_path) == value]
        elif op_string == "array_contains_any" or op_string == "array-contains-any":
            target_set = set(value)
            self.items = [
                x for x in self.items
                if bool(set(x.get(field_path) or []) & target_set)
            ]
        return self

    def order_by(self, field_path, direction="ASCENDING"):
        desc = direction in ("DESCENDING", "desc", True)
        self._order_by = field_path
        self._descending = desc
        return self

    def limit(self, count: int):
        self._limit = count
        return self

    def start_after(self, doc_snap_or_val):
        if hasattr(doc_snap_or_val, "id"):
            self._start_after_doc_id = doc_snap_or_val.id
        elif isinstance(doc_snap_or_val, dict) and "id" in doc_snap_or_val:
            self._start_after_doc_id = doc_snap_or_val["id"]
        elif isinstance(doc_snap_or_val, (list, tuple)) and len(doc_snap_or_val) >= 2:
            self._start_after_doc_id = doc_snap_or_val[-1]
        elif isinstance(doc_snap_or_val, str):
            self._start_after_doc_id = doc_snap_or_val
        return self

    def get(self):
        self.client.read_count += 1
        res = list(self.items)

        # 排序
        if self._order_by:
            def sort_key(x):
                val = x.get(self._order_by)
                if val is None:
                    val = 0 if self._descending else float("inf")
                # tie-breaker by id
                return (val, x.get("id", ""))

            res.sort(key=sort_key, reverse=self._descending)

        # 游标定位
        if self._start_after_doc_id:
            idx = -1
            for i, it in enumerate(res):
                if it.get("id") == self._start_after_doc_id:
                    idx = i
                    break
            if idx >= 0:
                res = res[idx + 1:]

        # limit 截断
        if self._limit is not None:
            res = res[:self._limit]

        snaps = []
        for it in res:
            s = MagicMock()
            s.id = it.get("id")
            s.exists = True
            s.to_dict.return_value = it
            snaps.append(s)
        return snaps


class FaultyCachePort(CachePort):
    """全抛异常的故障缓存，用于 S6 降级测试。"""

    def _do_get(self, key: str):
        raise ConnectionResetError("Cache connection lost")

    def _do_set(self, key: str, entry: CachedEntry, ttl=None):
        raise TimeoutError("Cache write timed out")

    def _do_invalidate_by_prefix(self, prefix: str):
        raise RuntimeError("Cache cluster down")


@pytest.fixture(autouse=True)
def reset_global_cache_for_test():
    set_global_cache(MemoryCachePort())
    yield
    set_global_cache(MemoryCachePort())


def _make_sample_posts(count=5):
    posts = []
    for i in range(count):
        posts.append({
            "id": f"post_{i:02d}",
            "text": f"帖子内容 {i}",
            "author_provider_uid": f"uid_{i}",
            "author_app_user_id": f"user_app_{i}",
            "status": "active",
            "allowed_chart_technique_ids": ["bazi", "meihua"] if i % 2 == 0 else ["liuren"],
            "attachments": [
                {
                    "type": "image",
                    "media_object_id": f"media_{i}",
                    "mime_type": "image/jpeg",
                    "width": 1080,
                    "height": 1920,
                    "moderation_state": "approved",
                }
            ],
            "revisions": [],
            "created_at": f"2026-08-21T10:{i:02d}:00Z",
            "updated_at": f"2026-08-21T10:{i:02d}:00Z",
            "recommendation_score": (count - i) * 10,
            "reply_status": "pending" if i % 2 == 0 else "resolved",
            "feedback_status": "unverified",
            "content_type": "divination",
            "has_outcome_feedback": False,
        })
    return posts


# ============================================================================
# S1: 端点形状与 openapi.yaml 契约吻合
# ============================================================================

def test_s1_feed_dto_shape_conformance():
    """S1: 验证 Feed 响应体包含 items、nextCursor、hasMore，且每个 item 包含规范定义的全部字段。"""
    raw_posts = _make_sample_posts(2)
    db = MockFirestoreDb(raw_posts)

    status, body, headers = _list_playground_feed_impl(
        params={"tab": "recommended"},
        db_client=db,
    )

    assert status == 200
    assert "items" in body
    assert "nextCursor" in body
    assert "hasMore" in body
    assert "ETag" in headers

    item = body["items"][0]
    required_keys = [
        "id", "text", "author_user_id", "status",
        "allowed_chart_technique_ids", "attachments", "revisions",
        "created_at", "has_outcome_feedback", "rev"
    ]
    for key in required_keys:
        assert key in item, f"PlaygroundPost missing required schema field: {key}"

    # 验证 author_user_id 脱敏
    assert item["author_user_id"] == "user_app_0"


def test_s1_post_detail_dto_shape_conformance():
    """S1: 验证单帖详情响应结构吻合 OpenAPI PlaygroundPost 契约。"""
    raw_posts = _make_sample_posts(1)
    db = MockFirestoreDb(raw_posts)

    status, body, headers = _get_playground_post_impl(
        post_id="post_00",
        db_client=db,
    )

    assert status == 200
    assert "ETag" in headers
    assert body["id"] == "post_00"
    assert body["text"] == "帖子内容 0"
    assert body["status"] == "active"
    assert len(body["attachments"]) == 1
    assert body["attachments"][0]["type"] == "image"
    assert body["attachments"][0]["media_object_id"] == "media_0"


def test_s1_rfc9457_problem_details_on_404():
    """S1: 验证资源不存在时返回 RFC 9457 Problem Details。"""
    db = MockFirestoreDb([])
    status, body, headers = _get_playground_post_impl(
        post_id="non_existent",
        db_client=db,
    )

    assert status == 404
    assert body["type"] == "not_found"
    assert body["status"] == 404
    assert "title" in body
    assert "detail" in body


# ============================================================================
# S2: If-None-Match 命中回 304，响应体空，证明数据层 0 调用
# ============================================================================

def test_s2_feed_if_none_match_304_zero_db_calls():
    """S2: Feed 端点 If-None-Match 命中返回 304，且 Firestore 读次数增量为 0。"""
    raw_posts = _make_sample_posts(3)
    db = MockFirestoreDb(raw_posts)

    # 1. 首次查询（冷启动）：下探 Firestore 并计算 ETag
    status1, body1, headers1 = _list_playground_feed_impl(
        params={"tab": "recommended"},
        db_client=db,
    )
    assert status1 == 200
    etag = headers1.get("ETag")
    assert etag is not None
    reads_after_cold = db.read_count
    assert reads_after_cold > 0, "首次查询必须访问数据层"

    # 2. 带 If-None-Match 再次请求（命中 304）
    status2, body2, headers2 = _list_playground_feed_impl(
        params={"tab": "recommended"},
        if_none_match=etag,
        db_client=db,
    )
    assert status2 == 304
    assert body2 is None or body2 == {}
    assert headers2.get("ETag") == etag
    assert db.read_count == reads_after_cold, "304 短路必须 0 次访问数据层！"


def test_s2_post_detail_if_none_match_304_zero_db_calls():
    """S2: 帖子详情 If-None-Match 命中返回 304 且 0 次数据层读。"""
    raw_posts = _make_sample_posts(1)
    db = MockFirestoreDb(raw_posts)

    # 1. 首次读取
    status1, body1, headers1 = _get_playground_post_impl(
        post_id="post_00",
        db_client=db,
    )
    assert status1 == 200
    etag = headers1.get("ETag")
    reads_after_first = db.read_count

    # 2. 304 短路
    status2, body2, headers2 = _get_playground_post_impl(
        post_id="post_00",
        if_none_match=etag,
        db_client=db,
    )
    assert status2 == 304
    assert body2 is None or body2 == {}
    assert headers2.get("ETag") == etag
    assert db.read_count == reads_after_first, "帖子 304 短路必须 0 次访问数据层！"


# ============================================================================
# S3: ETag 稳定性双向验证
# ============================================================================

def test_s3_feed_etag_stability_and_mutation():
    """S3: 同数据 ETag 恒定不变；数据修改后 ETag 必定改变。"""
    posts = _make_sample_posts(3)

    # 方向 1：同一数据集反复计算 ETag 恒定
    etag_runs = [compute_feed_etag(posts) for _ in range(5)]
    assert all(e == etag_runs[0] for e in etag_runs), "同一数据集 ETag 必须恒定"

    # 方向 2：数据变化后 ETag 必定改变
    modified_posts = json.loads(json.dumps(posts))
    modified_posts[0]["updated_at"] = "2026-08-21T11:00:00Z"
    etag_modified = compute_feed_etag(modified_posts)
    assert etag_modified != etag_runs[0], "数据更新后 ETag 必须变化"

    # 增删条目后 ETag 必定改变
    etag_subset = compute_feed_etag(posts[:2])
    assert etag_subset != etag_runs[0], "列表条目数量变化后 ETag 必须变化"


def test_s3_post_etag_stability_and_mutation():
    """S3: 单帖 ETag 稳定性与变更敏感性。"""
    post = _make_sample_posts(1)[0]
    etag1 = compute_post_etag(post)
    etag2 = compute_post_etag(post)
    assert etag1 == etag2

    post_updated = dict(post)
    post_updated["updated_at"] = "2026-08-21T12:00:00Z"
    etag_updated = compute_post_etag(post_updated)
    assert etag_updated != etag1


# ============================================================================
# S4: 多 Tab 排序与过滤正确性
# ============================================================================

def test_s4_tab_recommended_ordering():
    """S4: recommended Tab 按 recommendation_score DESC 排序。"""
    posts = _make_sample_posts(4)
    # 给定分数: 40, 30, 20, 10
    db = MockFirestoreDb(posts)

    status, body, _ = _list_playground_feed_impl(
        params={"tab": "recommended"},
        db_client=db,
    )
    assert status == 200
    ids = [it["id"] for it in body["items"]]
    assert ids == ["post_00", "post_01", "post_02", "post_03"]


def test_s4_tab_pending_divination_ordering_and_filter():
    """S4: pendingDivination Tab 过滤 reply_status == 'pending' 并按 created_at ASC 排序。"""
    posts = _make_sample_posts(4)
    # post_00 (pending, 10:00), post_01 (resolved, 10:01), post_02 (pending, 10:02), post_03 (resolved, 10:03)
    db = MockFirestoreDb(posts)

    status, body, _ = _list_playground_feed_impl(
        params={"tab": "pendingDivination"},
        db_client=db,
    )
    assert status == 200
    ids = [it["id"] for it in body["items"]]
    assert ids == ["post_00", "post_02"]


def test_s4_tab_latest_ordering():
    """S4: latest Tab 按 created_at DESC 排序。"""
    posts = _make_sample_posts(4)
    db = MockFirestoreDb(posts)

    status, body, _ = _list_playground_feed_impl(
        params={"tab": "latest"},
        db_client=db,
    )
    assert status == 200
    ids = [it["id"] for it in body["items"]]
    assert ids == ["post_03", "post_02", "post_01", "post_00"]


def test_s4_technique_ids_filtering_boundaries():
    """S4: techniqueIds 数组包含过滤（边界测试：0个、1个、上限10个、超限>10个被拒）。"""
    posts = _make_sample_posts(4)
    db = MockFirestoreDb(posts)

    # 1. 过滤 bazi
    status, body, _ = _list_playground_feed_impl(
        params={"tab": "recommended", "techniqueIds": ["bazi"]},
        db_client=db,
    )
    assert status == 200
    assert all("bazi" in it["allowed_chart_technique_ids"] for it in body["items"])

    # 2. 上限 10 个有效
    ten_techniques = [f"tech_{i}" for i in range(10)]
    status, body, _ = _list_playground_feed_impl(
        params={"tab": "recommended", "techniqueIds": ten_techniques},
        db_client=db,
    )
    assert status == 200

    # 3. 超过 10 个抛出 400 invalid_argument
    eleven_techniques = [f"tech_{i}" for i in range(11)]
    status, body, _ = _list_playground_feed_impl(
        params={"tab": "recommended", "techniqueIds": eleven_techniques},
        db_client=db,
    )
    assert status == 400
    assert body["type"] == "invalid_argument"


# ============================================================================
# S5: 游标分页连续无重复遗漏
# ============================================================================

def test_s5_cursor_pagination_continuity():
    """S5: 游标分页连续翻页无重复、无遗漏。"""
    posts = _make_sample_posts(7)
    db = MockFirestoreDb(posts)

    # 第 1 页：limit=3
    status1, page1, _ = _list_playground_feed_impl(
        params={"tab": "latest", "limit": 3},
        db_client=db,
    )
    assert status1 == 200
    assert len(page1["items"]) == 3
    assert page1["hasMore"] is True
    cursor1 = page1["nextCursor"]
    assert cursor1 is not None

    # 第 2 页：使用 cursor1
    status2, page2, _ = _list_playground_feed_impl(
        params={"tab": "latest", "limit": 3, "cursor": cursor1},
        db_client=db,
    )
    assert status2 == 200
    assert len(page2["items"]) == 3
    assert page2["hasMore"] is True
    cursor2 = page2["nextCursor"]
    assert cursor2 is not None

    # 第 3 页：使用 cursor2
    status3, page3, _ = _list_playground_feed_impl(
        params={"tab": "latest", "limit": 3, "cursor": cursor2},
        db_client=db,
    )
    assert status3 == 200
    assert len(page3["items"]) == 1
    assert page3["hasMore"] is False
    assert page3["nextCursor"] is None

    # 聚合验证：无重复无遗漏
    all_fetched_ids = [
        it["id"] for it in (page1["items"] + page2["items"] + page3["items"])
    ]
    expected_ids = [f"post_{6-i:02d}" for i in range(7)]
    assert all_fetched_ids == expected_ids
    assert len(set(all_fetched_ids)) == 7


def test_s5_stale_or_invalid_cursor_returns_400():
    """S5: 无效或跨 Tab 错用的游标返回 400 ProblemDetails。"""
    db = MockFirestoreDb(_make_sample_posts(2))

    # 1. 语法错误的非法游标
    status, body, _ = _list_playground_feed_impl(
        params={"tab": "recommended", "cursor": "not-valid-base64"},
        db_client=db,
    )
    assert status == 400
    assert body["type"] == "invalid_argument"
    assert body["reason"] == "CURSOR_INVALID_OR_STALE"

    # 2. 针对 recommended 生成的游标用在 latest 上
    cur_recommended = encode_cursor("recommended", "post_00", 100)
    status2, body2, _ = _list_playground_feed_impl(
        params={"tab": "latest", "cursor": cur_recommended},
        db_client=db,
    )
    assert status2 == 400
    assert body2["type"] == "invalid_argument"
    assert body2["reason"] == "CURSOR_INVALID_OR_STALE"


# ============================================================================
# S6: 缓存故障平稳降级
# ============================================================================

def test_s6_faulty_cache_graceful_degradation():
    """S6: 缓存后端全部抛出异常时，端点平稳降级正常返回正确结果。"""
    faulty_cache = FaultyCachePort()
    set_global_cache(faulty_cache)

    posts = _make_sample_posts(2)
    db = MockFirestoreDb(posts)

    # 1. Feed 读降级
    status, body, headers = _list_playground_feed_impl(
        params={"tab": "recommended"},
        db_client=db,
        cache=faulty_cache,
    )
    assert status == 200
    assert len(body["items"]) == 2
    assert "ETag" in headers

    # 2. 帖子详情读降级
    status_p, body_p, headers_p = _get_playground_post_impl(
        post_id="post_00",
        db_client=db,
        cache=faulty_cache,
    )
    assert status_p == 200
    assert body_p["id"] == "post_00"
    assert "ETag" in headers_p

    # 缓存记录了错误，但业务 100% 成功
    assert faulty_cache.stats.errors > 0


# ============================================================================
# HTTP Request 适配器测试 (@https_fn.on_request)
# ============================================================================

def test_http_feed_request_wrapper(monkeypatch):
    """测试 playground_feed_py HTTP 请求封装。"""
    posts = _make_sample_posts(2)
    db = MockFirestoreDb(posts)
    monkeypatch.setattr("xuan.handlers.playground_rest.db", lambda: db)

    # 模拟 Werkzeug/Flask 请求
    req = MagicMock()
    req.args = {"tab": "recommended", "limit": "2"}
    req.headers = {}

    resp = playground_feed_py(req)
    assert resp.status_code == 200
    assert "ETag" in resp.headers
    data = json.loads(resp.get_data(as_text=True))
    assert len(data["items"]) == 2

    # 模拟 304 短路请求
    etag = resp.headers["ETag"]
    req_304 = MagicMock()
    req_304.args = {"tab": "recommended", "limit": "2"}
    req_304.headers = {"If-None-Match": etag}

    resp_304 = playground_feed_py(req_304)
    assert resp_304.status_code == 304
    assert resp_304.get_data(as_text=True) == ""


def test_http_posts_request_wrapper(monkeypatch):
    """测试 playground_posts_py HTTP 请求封装。"""
    posts = _make_sample_posts(1)
    db = MockFirestoreDb(posts)
    monkeypatch.setattr("xuan.handlers.playground_rest.db", lambda: db)

    req = MagicMock()
    req.path = "/playground/posts/post_00"
    req.args = {"id": "post_00"}
    req.headers = {}

    resp = playground_posts_py(req)
    assert resp.status_code == 200
    data = json.loads(resp.get_data(as_text=True))
    assert data["id"] == "post_00"
