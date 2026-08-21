"""CS2-W 缓存接入读路径与失效钩子量化测试集。

验收判据对照：
- A1: 接入 2 个读路径 handler (guest_replies, resolve_app_user_id)
- A2: Firestore 读次数下降一个数量级以上（真实计数器量化对比）
- A3: CacheStats 命中率可观测与实测
- A4: 写操作触发失效钩子后，下一次读立即获取最新数据（不依赖 TTL）
- A5: 缓存后端全抛异常时，业务路径正常返回正确数据（平稳降级）
- A6: pytest 全套通过
"""

import json
from unittest.mock import MagicMock
import pytest

from xuan.cache import (
    CachePort,
    CachedEntry,
    MemoryCachePort,
    NoOpCache,
    get_global_cache,
    set_global_cache,
    get_global_single_flight,
    invalidate_guest_replies_cache,
    invalidate_identity_cache,
)
from xuan.handlers.guest_replies import _get_guest_representative_replies_impl
from xuan.identity import resolve_app_user_id


class MockFirestoreClient:
    """可精确统计读写调用次数的 Mock Firestore 客户端。"""

    def __init__(self, post_data=None, replies_data=None, likes_data=None, feedback_data=None, identity_data=None):
        self.read_count = 0
        self.write_count = 0
        self.post_data = post_data or {"id": "p_test", "status": "active"}
        self.replies_data = replies_data if replies_data is not None else [
            {"id": "r1", "post_id": "p_test", "depth": 0, "body": "回复1", "created_at": "2026-01-01T00:00:00Z"},
            {"id": "r2", "post_id": "p_test", "depth": 0, "body": "回复2", "created_at": "2026-01-02T00:00:00Z"},
            {"id": "r3", "post_id": "p_test", "depth": 0, "body": "回复3", "created_at": "2026-01-03T00:00:00Z"},
        ]
        self.likes_data = likes_data or []
        self.feedback_data = feedback_data or []
        self.identity_data = identity_data or {
            "app_user_id": "app-user-123",
            "public_presentation_id": "pres-123",
            "public_display_alias": "玄友1234",
        }

    def collection(self, name: str):
        mock_col = MagicMock()
        client = self

        if name == "playground_posts":
            def doc_fn(doc_id="p_test"):
                doc_mock = MagicMock()
                def get_fn():
                    client.read_count += 1
                    snap = MagicMock()
                    snap.exists = True
                    snap.id = doc_id
                    snap.to_dict.return_value = client.post_data
                    return snap
                doc_mock.get.side_effect = get_fn
                return doc_mock
            mock_col.document.side_effect = doc_fn

        elif name == "playground_replies":
            def where_fn(field_path, op_string, value):
                q_mock = MagicMock()
                def chained_where(f, op, val):
                    return q_mock
                q_mock.where.side_effect = chained_where
                def get_fn():
                    client.read_count += 1
                    snaps = []
                    for r in client.replies_data:
                        s = MagicMock()
                        s.id = r["id"]
                        s.to_dict.return_value = r
                        snaps.append(s)
                    return snaps
                q_mock.get.side_effect = get_fn
                return q_mock
            mock_col.where.side_effect = where_fn

        elif name == "playground_likes":
            def where_fn(field_path, op_string, value):
                q_mock = MagicMock()
                def get_fn():
                    client.read_count += 1
                    snaps = []
                    for lk in client.likes_data:
                        if lk.get("reply_id") in value:
                            s = MagicMock()
                            s.id = lk.get("id", "lk1")
                            s.to_dict.return_value = lk
                            snaps.append(s)
                    return snaps
                q_mock.get.side_effect = get_fn
                return q_mock
            mock_col.where.side_effect = where_fn

        elif name == "playground_outcome_feedback":
            def where_fn(field_path, op_string, value):
                q_mock = MagicMock()
                def get_fn():
                    client.read_count += 1
                    snaps = []
                    for fb in client.feedback_data:
                        s = MagicMock()
                        s.id = fb.get("id", "fb1")
                        s.to_dict.return_value = fb
                        snaps.append(s)
                    return snaps
                q_mock.get.side_effect = get_fn
                return q_mock
            mock_col.where.side_effect = where_fn

        elif name == "identity_map":
            def doc_fn(uid="uid_1"):
                doc_mock = MagicMock()
                def get_fn(transaction=None):
                    client.read_count += 1
                    snap = MagicMock()
                    snap.exists = True
                    snap.id = uid
                    snap.to_dict.return_value = client.identity_data
                    return snap
                doc_mock.get.side_effect = get_fn
                return doc_mock
            mock_col.document.side_effect = doc_fn

        return mock_col

    def transaction(self):
        tx_mock = MagicMock()
        return tx_mock


class BrokenKVBackend(CachePort):
    """故意全抛异常的故障缓存后端。"""

    def _do_get(self, key: str) -> CachedEntry | None:
        raise ConnectionResetError("Redis connection reset by peer")

    def _do_set(self, key: str, entry: CachedEntry, ttl=None) -> None:
        raise TimeoutError("Redis SET timed out")

    def _do_invalidate_by_prefix(self, prefix: str) -> None:
        raise RuntimeError("Redis CLUSTERDOWN")


@pytest.fixture(autouse=True)
def _reset_cache_fixture():
    """每个测试用例前重置全局缓存。"""
    cache = MemoryCachePort()
    set_global_cache(cache)
    yield
    set_global_cache(MemoryCachePort())


def test_a1_handler_selection_and_wiring_verification():
    """A1 判据：验证选定的 2 个读路径已正确接入 CachePort 且返回合法结构。"""
    cache = get_global_cache()
    assert isinstance(cache, CachePort)

    # 1. 验证 identity 查询
    mock_client = MockFirestoreClient()
    with pytest.MonkeyPatch.context() as mp:
        mp.setattr("xuan.identity.db", lambda: mock_client)
        mp.setattr("google.cloud.firestore.transactional", lambda fn: fn)

        ident = resolve_app_user_id("uid_test_a1")
        assert ident["appUserId"] == "app-user-123"
        assert ident["publicPresentationId"] == "pres-123"

    # 2. 验证 guest_replies 查询
    with pytest.MonkeyPatch.context() as mp:
        mp.setattr("xuan.handlers.guest_replies.db", lambda: mock_client)
        resp = _get_guest_representative_replies_impl({"postId": "p_test"})
        assert resp["postId"] == "p_test"
        assert len(resp["visibleReplies"]) == 3
        assert resp["totalReplyCount"] == 3


def test_a2_firestore_read_reduction_quantified():
    """A2 判据：机械度量 Firestore 读次数下降一个数量级以上（>10x 降幅）。"""
    mock_client = MockFirestoreClient()

    with pytest.MonkeyPatch.context() as mp:
        mp.setattr("xuan.handlers.guest_replies.db", lambda: mock_client)

        # 场景：20 次并发/连续请求相同的 guest_replies 端点
        request_count = 20

        # 第 1 次请求：冷启动未命中缓存，下探 Firestore
        r1 = _get_guest_representative_replies_impl({"postId": "p_test"})
        reads_after_cold = mock_client.read_count
        assert reads_after_cold > 0, "冷启动必须真实读取 Firestore"

        # 连续发起余下 19 次请求
        for _ in range(request_count - 1):
            rx = _get_guest_representative_replies_impl({"postId": "p_test"})
            assert rx["postId"] == "p_test"

        reads_after_warm = mock_client.read_count
        # 无缓存时 20 次请求的预期读次数 = reads_after_cold * 20
        unmitigated_reads = reads_after_cold * request_count
        actual_reads = reads_after_warm

        reduction_factor = unmitigated_reads / actual_reads
        reduction_percentage = (1 - actual_reads / unmitigated_reads) * 100

        print(f"\n[A2 度量] 无缓存读次数: {unmitigated_reads}, 接入缓存读次数: {actual_reads}")
        print(f"[A2 度量] 读次数下降倍数: {reduction_factor:.2f}x, 降低率: {reduction_percentage:.2f}%")

        assert actual_reads == reads_after_cold, "命中缓存后后续 19 次读必须 0 次 Firestore 下探"
        assert reduction_factor >= 10.0, f"读次数降幅必须在一个数量级以上 (>=10x)，实测为 {reduction_factor}x"


def test_a3_cache_stats_observability_and_hit_rate():
    """A3 判据：CacheStats 命中率可观测与实测。"""
    cache = MemoryCachePort()
    set_global_cache(cache)
    mock_client = MockFirestoreClient()

    with pytest.MonkeyPatch.context() as mp:
        mp.setattr("xuan.handlers.guest_replies.db", lambda: mock_client)

        # 构造 10 个不同 postId 的初次读（10 次 miss）
        for i in range(10):
            mock_client.post_data = {"id": f"p_{i}", "status": "active"}
            _get_guest_representative_replies_impl({"postId": f"p_{i}"})

        # 构造 40 次命中读（40 次 hit）
        for _ in range(4):
            for i in range(10):
                _get_guest_representative_replies_impl({"postId": f"p_{i}"})

        stats = cache.stats
        assert stats.misses == 10
        assert stats.hits == 40
        assert stats.errors == 0
        assert abs(stats.hit_rate - 0.80) < 1e-6, f"预期命中率 80.0%, 实测: {stats.hit_rate * 100:.2f}%"


def test_a4_write_invalidates_cache_immediately():
    """A4 判据：写操作触发失效钩子后，下一次读立即获取最新数据（不依赖 TTL）。"""
    cache = get_global_cache()
    mock_client = MockFirestoreClient()

    with pytest.MonkeyPatch.context() as mp:
        mp.setattr("xuan.handlers.guest_replies.db", lambda: mock_client)

        # 1. 读初始状态（3 条回复）
        res1 = _get_guest_representative_replies_impl({"postId": "p_test"})
        assert res1["totalReplyCount"] == 3

        # 2. 模拟写入第 4 条回复
        mock_client.replies_data.append({
            "id": "r4", "post_id": "p_test", "depth": 0, "body": "最新回复4", "created_at": "2026-01-04T00:00:00Z"
        })

        # 若未触发失效钩子，读缓存仍会是 3
        res_cached = _get_guest_representative_replies_impl({"postId": "p_test"})
        assert res_cached["totalReplyCount"] == 3, "未失效前应读到缓存旧值"

        # 3. 触发失效钩子（模拟 create_root_reply / delete_reply / verify 写入完成）
        invalidate_guest_replies_cache("p_test")

        # 4. 再次读取：必须立即反映 4 条回复，不需要等待 TTL 到期
        res2 = _get_guest_representative_replies_impl({"postId": "p_test"})
        assert res2["totalReplyCount"] == 4
        assert any(r["publicReplyId"] == "r4" for r in res2["visibleReplies"])


def test_a5_faulty_cache_graceful_degradation():
    """A5 判据：缓存后端全程抛异常时，业务路径平稳降级直查 Firestore，不破坏响应。"""
    broken_cache = BrokenKVBackend()
    set_global_cache(broken_cache)

    mock_client = MockFirestoreClient()

    with pytest.MonkeyPatch.context() as mp:
        mp.setattr("xuan.handlers.guest_replies.db", lambda: mock_client)
        mp.setattr("xuan.identity.db", lambda: mock_client)
        mp.setattr("google.cloud.firestore.transactional", lambda fn: fn)

        # 1. 读 guest_replies
        resp = _get_guest_representative_replies_impl({"postId": "p_test"})
        assert resp["postId"] == "p_test"
        assert len(resp["visibleReplies"]) == 3

        # 2. 读 identity
        ident = resolve_app_user_id("uid_broken_test")
        assert ident["appUserId"] == "app-user-123"

        # 3. 触发失效钩子（必须静默捕获，不抛出）
        invalidate_guest_replies_cache("p_test")
        invalidate_identity_cache("uid_broken_test")

        # 4. 统计错误数有增加，但业务返回完全正常
        assert broken_cache.stats.errors > 0


def test_etag_304_short_circuit():
    """验证 ETag 304 短路机制：带匹配 If-None-Match 时短路返回 304 且 0 次 Firestore 读。"""
    mock_client = MockFirestoreClient()

    with pytest.MonkeyPatch.context() as mp:
        mp.setattr("xuan.handlers.guest_replies.db", lambda: mock_client)

        # 首次读取获取 ETag
        first_resp = _get_guest_representative_replies_impl({"postId": "p_test"})
        etag = first_resp.get("_etag")
        assert etag is not None and etag.startswith('"')
        reads_after_first = mock_client.read_count

        # 携带 If-None-Match 再次请求
        short_circuit_resp = _get_guest_representative_replies_impl(
            {"postId": "p_test", "ifNoneMatch": etag}
        )
        assert short_circuit_resp.get("_status_code") == 304
        assert short_circuit_resp.get("_etag") == etag
        assert mock_client.read_count == reads_after_first, "304 短路必须 0 次 Firestore 读"
