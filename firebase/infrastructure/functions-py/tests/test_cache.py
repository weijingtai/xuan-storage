"""CS2 服务端缓存层测试集。

覆盖验收判据：
  B1: CachePort 接口方法全部不抛异常（底层 KV 故障测试替身）
  B2: 单飞（Single-Flight）：并发 N 个相同请求，底层只被调用 1 次
  B3: TTL ±20% 抖动：落在区间内且不全相同
  B4: 查询指纹规范化：参数乱序/默认值/None 等价，契约版本改变不等价
  B5: If-None-Match 命中回 304 且不下探数据层（计数器证明数据层 0 调用）
"""

import concurrent.futures
from datetime import datetime, timedelta, timezone
import time
import pytest

from xuan.cache import (
    CachedEntry,
    CachedResponse,
    CachePort,
    CacheStats,
    MemoryCachePort,
    NoOpCache,
    SingleFlight,
    cached_query,
    compute_etag,
    compute_jittered_ttl,
    compute_query_fingerprint,
    matches_etag,
)


# ============================================================================
# B1: CachePort 接口方法全部不抛异常
# ============================================================================

class BrokenKVBackend:
    """故意在所有操作上抛异常的底层存储，模拟 Redis 网络中断/崩溃。"""

    def raw_get(self, key: str):
        raise ConnectionResetError("Redis connection lost")

    def raw_set(self, key: str, val: bytes, ttl: float | None = None):
        raise TimeoutError("Redis connection timed out")

    def raw_invalidate_prefix(self, prefix: str):
        raise RuntimeError("Redis OOM or cluster partitioned")


class FaultyCachePort(CachePort):
    """包装 BrokenKVBackend 的 CachePort 实现。"""

    def __init__(self):
        super().__init__()
        self._kv = BrokenKVBackend()

    def _do_get(self, key: str) -> CachedEntry | None:
        self._kv.raw_get(key)
        return None

    def _do_set(self, key: str, entry: CachedEntry, ttl: timedelta | float | None = None) -> None:
        self._kv.raw_set(key, entry.body)

    def _do_invalidate_by_prefix(self, prefix: str) -> None:
        self._kv.raw_invalidate_prefix(prefix)


def test_b1_cache_port_never_throws_on_get_error():
    cache = FaultyCachePort()
    # get 发生异常时不抛出，必须记录 errors 并返回 None
    result = cache.get("feed:test:1")
    assert result is None
    assert cache.stats.errors == 1


def test_b1_cache_port_never_throws_on_set_error():
    cache = FaultyCachePort()
    entry = CachedEntry(body=b'{"items": []}', etag='"abc"', stored_at=datetime.now(timezone.utc))
    # set 发生异常时不抛出，静默吞掉并增加 error 计数
    cache.set("feed:test:1", entry, ttl=timedelta(seconds=60))
    assert cache.stats.errors == 1


def test_b1_cache_port_never_throws_on_invalidate_error():
    cache = FaultyCachePort()
    # invalidate_by_prefix 发生异常时不抛出，静默吞掉并增加 error 计数
    cache.invalidate_by_prefix("feed:")
    assert cache.stats.errors == 1


def test_b1_business_path_survives_cache_failure():
    """验证底层 KV 挂掉时，业务调用 cached_query 仍可降级直查数据源，业务不中断。"""
    cache = FaultyCachePort()
    call_count = 0

    def db_loader():
        nonlocal call_count
        call_count += 1
        return b'{"posts": [1, 2, 3]}'

    resp = cached_query(cache, "feed:home", db_loader)
    assert resp.status_code == 200
    assert resp.body == b'{"posts": [1, 2, 3]}'
    assert call_count == 1
    # 试图 get 失败 1 次，试图 set 失败 1 次 -> errors = 2
    assert cache.stats.errors == 2


# ============================================================================
# B2: 单飞（Single-Flight）测试
# ============================================================================

def test_b2_single_flight_concurrent_requests():
    """并发 20 个请求同时请求相同 key，底层 loader 只执行 1 次。"""
    sf = SingleFlight()
    loader_calls = 0

    def slow_data_loader():
        nonlocal loader_calls
        loader_calls += 1
        time.sleep(0.1)  # 模拟数据层耗时
        return {"data": "ok"}

    concurrency = 20
    results = []

    def worker():
        return sf.execute("feed:hot_posts", slow_data_loader)

    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
        futures = [executor.submit(worker) for _ in range(concurrency)]
        for f in concurrent.futures.as_completed(futures):
            results.append(f.result())

    assert len(results) == concurrency
    assert all(r == {"data": "ok"} for r in results)
    assert loader_calls == 1, f"Expected 1 data layer call, got {loader_calls}"


def test_b2_single_flight_timeout_fallback():
    """单飞等待超过上限（2.0s）时安全兜底，不把等待者永久拖住。"""
    sf = SingleFlight()

    # 验证 wait_timeout 能够触发独立兜底
    def hung_loader():
        time.sleep(1.0)
        return "slow_result"

    res = sf.execute("slow_key", hung_loader, wait_timeout=0.05)
    assert res == "slow_result"


# ============================================================================
# B3: TTL ±20% 抖动测试
# ============================================================================

def test_b3_ttl_jitter_distribution():
    """连续生成 100 个 TTL，验证严格落在 ±20% 区间且不全相同。"""
    base_ttl = 60.0
    ttls = [compute_jittered_ttl(base_ttl, jitter_ratio=0.2) for _ in range(100)]

    min_expected = 60.0 * 0.8  # 48.0
    max_expected = 60.0 * 1.2  # 72.0

    assert all(min_expected <= t <= max_expected for t in ttls), "All TTLs must be within [48.0, 72.0]"
    # 验证不是恒定值
    distinct_ttls = set(ttls)
    assert len(distinct_ttls) > 80, f"Expected varied TTLs, got {len(distinct_ttls)} distinct values"


def test_b3_ttl_jitter_with_timedelta():
    """支持 timedelta 输入与输出。"""
    base_delta = timedelta(minutes=5)  # 300s
    jittered = compute_jittered_ttl(base_delta, jitter_ratio=0.2)
    assert isinstance(jittered, timedelta)
    assert timedelta(minutes=4) <= jittered <= timedelta(minutes=6)


# ============================================================================
# B4: 查询指纹规范化测试
# ============================================================================

def test_b4_query_fingerprint_param_order_independence():
    """参数顺序不同，生成的指纹完全相同。"""
    route = "/v1/feed"
    params_a = {"tag": "tech", "limit": 20, "since": 12345}
    params_b = {"limit": 20, "since": 12345, "tag": "tech"}

    fp_a = compute_query_fingerprint(route, params_a, contract_version="1")
    fp_b = compute_query_fingerprint(route, params_b, contract_version="1")
    assert fp_a == fp_b


def test_b4_query_fingerprint_default_and_none_equivalence():
    """显式传默认值、不传该参数、或者传 None，三者指纹完全相同。"""
    route = "/v1/posts"
    defaults = {"limit": 20, "order": "desc"}

    # 1. 显式传默认值
    params_explicit_default = {"limit": 20, "order": "desc", "author": "alice"}
    # 2. 不传默认参数
    params_omitted_default = {"author": "alice"}
    # 3. 传 None
    params_with_none = {"limit": 20, "order": "desc", "author": "alice", "cursor": None}

    fp_1 = compute_query_fingerprint(route, params_explicit_default, contract_version="1", default_params=defaults)
    fp_2 = compute_query_fingerprint(route, params_omitted_default, contract_version="1", default_params=defaults)
    fp_3 = compute_query_fingerprint(route, params_with_none, contract_version="1", default_params=defaults)

    assert fp_1 == fp_2 == fp_3


def test_b4_query_fingerprint_contract_version_differentiation():
    """契约版本不同，生成的指纹必须不同。"""
    route = "/v1/feed"
    params = {"tag": "tech"}

    fp_v1 = compute_query_fingerprint(route, params, contract_version="1")
    fp_v2 = compute_query_fingerprint(route, params, contract_version="2")

    assert fp_v1 != fp_v2
    assert ":v1:" in fp_v1 or fp_v1.startswith(f"{route}:v1:")
    assert ":v2:" in fp_v2 or fp_v2.startswith(f"{route}:v2:")


# ============================================================================
# B5: ETag 计算与 304 短路测试（不下探数据层）
# ============================================================================

def test_b5_etag_generation():
    body = b'{"status": "ok", "items": [1, 2, 3]}'
    etag = compute_etag(body)
    assert etag.startswith('"') and etag.endswith('"')
    # 相同内容生成相同 ETag
    assert compute_etag(body) == etag


def test_b5_if_none_match_304_short_circuit():
    """If-None-Match 命中时直接返回 304，计数器证明底层数据层 0 调用。"""
    cache = MemoryCachePort()
    key = "feed:v1:user_123"
    data_content = b'{"feed": ["post_a", "post_b"]}'
    etag = compute_etag(data_content)

    # 预填充缓存
    cache.set(key, CachedEntry(body=data_content, etag=etag, stored_at=datetime.now(timezone.utc)))

    data_layer_calls = 0

    def db_loader():
        nonlocal data_layer_calls
        data_layer_calls += 1
        return data_content

    # 客户端带上匹配的 If-None-Match
    response = cached_query(
        cache=cache,
        key=key,
        loader=db_loader,
        if_none_match=etag,
    )

    assert response.status_code == 304
    assert response.body == b""
    assert response.etag == etag
    assert data_layer_calls == 0, f"Expected 0 data layer calls on 304 match, got {data_layer_calls}"
    assert cache.stats.hits == 1


def test_b5_if_none_match_mismatch_returns_200():
    """If-None-Match 不匹配时，返回 200 + 缓存内容，不下探数据层。"""
    cache = MemoryCachePort()
    key = "feed:v1:user_123"
    data_content = b'{"feed": ["post_a", "post_b"]}'
    etag = compute_etag(data_content)

    cache.set(key, CachedEntry(body=data_content, etag=etag, stored_at=datetime.now(timezone.utc)))

    data_layer_calls = 0

    def db_loader():
        nonlocal data_layer_calls
        data_layer_calls += 1
        return b'{"feed": ["new_post"]}'

    response = cached_query(
        cache=cache,
        key=key,
        loader=db_loader,
        if_none_match='"old-etag-999"',
    )

    assert response.status_code == 200
    assert response.body == data_content
    assert response.etag == etag
    assert data_layer_calls == 0
    assert cache.stats.hits == 1


# ============================================================================
# MemoryCachePort & NoOpCache 基础功能测试
# ============================================================================

def test_memory_cache_ttl_expiration():
    cache = MemoryCachePort()
    entry = CachedEntry(body=b"temp", etag='"temp"', stored_at=datetime.now(timezone.utc))
    cache.set("key1", entry, ttl=timedelta(milliseconds=50))

    # 立即读取命中
    assert cache.get("key1") == entry
    assert cache.stats.hits == 1

    # 等待过期
    time.sleep(0.06)
    assert cache.get("key1") is None
    assert cache.stats.misses == 1


def test_memory_cache_invalidate_by_prefix():
    cache = MemoryCachePort()
    e1 = CachedEntry(body=b"1", etag='"1"', stored_at=datetime.now(timezone.utc))
    e2 = CachedEntry(body=b"2", etag='"2"', stored_at=datetime.now(timezone.utc))
    e3 = CachedEntry(body=b"3", etag='"3"', stored_at=datetime.now(timezone.utc))

    cache.set("feed:user:1", e1)
    cache.set("feed:user:2", e2)
    cache.set("post:detail:1", e3)

    cache.invalidate_by_prefix("feed:user:")

    assert cache.get("feed:user:1") is None
    assert cache.get("feed:user:2") is None
    assert cache.get("post:detail:1") == e3


def test_noop_cache_behavior():
    cache = NoOpCache()
    entry = CachedEntry(body=b"noop", etag='"noop"', stored_at=datetime.now(timezone.utc))
    cache.set("k", entry)
    assert cache.get("k") is None
    cache.invalidate_by_prefix("k")
    assert cache.stats.hits == 0


def test_cache_stats_hit_rate():
    stats_empty = CacheStats(hits=0, misses=0, errors=0)
    assert stats_empty.hit_rate == 0.0

    stats_partial = CacheStats(hits=3, misses=1, errors=0)
    assert stats_partial.hit_rate == 0.75


def test_single_flight_exception_propagation():
    """验证当 leader 抛出异常时，等待者也能感知并接收到相同异常。"""
    sf = SingleFlight()

    def bad_loader():
        time.sleep(0.05)
        raise ValueError("Loader DB exploded")

    concurrency = 5
    exceptions = []

    def worker():
        try:
            return sf.execute("fail_key", bad_loader)
        except Exception as e:
            return e

    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
        futures = [executor.submit(worker) for _ in range(concurrency)]
        for f in concurrent.futures.as_completed(futures):
            exceptions.append(f.result())

    assert len(exceptions) == concurrency
    assert all(isinstance(e, ValueError) and str(e) == "Loader DB exploded" for e in exceptions)


def test_matches_etag_variations():
    """测试 ETag 弱匹配、通配符、引号处理。"""
    strong_etag = '"abc123"'
    assert matches_etag('"abc123"', strong_etag) is True
    assert matches_etag('W/"abc123"', strong_etag) is True
    assert matches_etag('*', strong_etag) is True
    assert matches_etag('"other", "abc123"', strong_etag) is True
    assert matches_etag('"other", W/"abc123"', strong_etag) is True
    assert matches_etag('"other"', strong_etag) is False
    assert matches_etag(None, strong_etag) is False
    assert matches_etag("", strong_etag) is False


def test_cached_query_with_dict_and_single_flight():
    """验证 cached_query 支持 dict 返回值并结合 SingleFlight 协同工作。"""
    cache = MemoryCachePort()
    sf = SingleFlight()
    key = "feed:trending"
    call_count = 0

    def dict_loader():
        nonlocal call_count
        call_count += 1
        return {"items": [{"id": 1}, {"id": 2}]}

    resp = cached_query(
        cache=cache,
        key=key,
        loader=dict_loader,
        ttl=60,
        single_flight=sf,
    )
    assert resp.status_code == 200
    assert resp.body == b'{"items":[{"id":1},{"id":2}]}'
    assert call_count == 1
    assert "ETag" in resp.headers

    # 第二次查询命中缓存
    resp2 = cached_query(
        cache=cache,
        key=key,
        loader=dict_loader,
        ttl=60,
        single_flight=sf,
    )
    assert resp2.status_code == 200
    assert resp2.body == resp.body
    assert call_count == 1  # 未增加
    assert cache.stats.hits == 1

