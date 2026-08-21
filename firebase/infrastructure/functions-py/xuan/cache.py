"""服务端缓存层（Provider 无关部分）。

对应架构设计：REALTIME-AND-FAAS-MIGRATION-PLAN.md §9
包含模块：
  1. CachePort 窄接口与数据结构 (CachedEntry, CacheStats, NoOpCache, MemoryCachePort)
  2. 单飞 (SingleFlight) 与 TTL ±20% 抖动 (compute_jittered_ttl)
  3. 查询指纹规范化 (compute_query_fingerprint)
  4. ETag 计算、比对与 304 短路 (compute_etag, matches_etag, cached_query)

铁律：CachePort 的所有方法都不抛异常。底层异常全部捕获、记录日志并计入 stats.errors。
"""

from __future__ import annotations

import abc
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
import hashlib
import json
import logging
import random
import threading
import time
from typing import Any, Callable, TypeVar

logger = logging.getLogger(__name__)

T = TypeVar("T")


# ============================================================================
# 1. 核心数据结构与 CachePort 窄接口
# ============================================================================

@dataclass(frozen=True)
class CachedEntry:
    """缓存条目：响应体 bytes、ETag 与写入时间。"""
    body: bytes
    etag: str
    stored_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))


@dataclass
class CacheStats:
    """缓存统计指标。"""
    hits: int = 0
    misses: int = 0
    errors: int = 0

    @property
    def hit_rate(self) -> float:
        total = self.hits + self.misses
        return 0.0 if total == 0 else self.hits / total


class CachePort(abc.ABC):
    """缓存端口抽象基类。

    铁律：CachePort 的所有方法都不抛异常。
    底层 KV 故障必须被捕获并记录日志、增加 stats.errors，
    get 返回 None，set/invalidate 静默吞掉，保证业务不因缓存故障而阻断。
    """

    def __init__(self) -> None:
        self._hits = 0
        self._misses = 0
        self._errors = 0
        self._stats_lock = threading.Lock()

    @property
    def stats(self) -> CacheStats:
        with self._stats_lock:
            return CacheStats(
                hits=self._hits,
                misses=self._misses,
                errors=self._errors,
            )

    def _record_hit(self) -> None:
        with self._stats_lock:
            self._hits += 1

    def _record_miss(self) -> None:
        with self._stats_lock:
            self._misses += 1

    def _record_error(self) -> None:
        with self._stats_lock:
            self._errors += 1

    def get(self, key: str) -> CachedEntry | None:
        """获取缓存条目。未命中或底层故障返回 None，绝不抛异常。"""
        try:
            entry = self._do_get(key)
            if entry is not None:
                self._record_hit()
                return entry
            else:
                self._record_miss()
                return None
        except Exception:
            logger.exception("CachePort.get failed for key '%s'", key)
            self._record_error()
            return None

    def set(
        self,
        key: str,
        entry: CachedEntry,
        ttl: timedelta | float | int | None = None,
    ) -> None:
        """设置缓存条目。ttl 为 None 时按默认策略。写失败静默记录日志，绝不抛异常。"""
        try:
            self._do_set(key, entry, ttl)
        except Exception:
            logger.exception("CachePort.set failed for key '%s'", key)
            self._record_error()

    def invalidate_by_prefix(self, prefix: str) -> None:
        """按前缀批量失效。失败静默记录日志，绝不抛异常。"""
        try:
            self._do_invalidate_by_prefix(prefix)
        except Exception:
            logger.exception("CachePort.invalidate_by_prefix failed for prefix '%s'", prefix)
            self._record_error()

    @abc.abstractmethod
    def _do_get(self, key: str) -> CachedEntry | None:
        """子类实现的具体读取逻辑。"""
        raise NotImplementedError

    @abc.abstractmethod
    def _do_set(
        self,
        key: str,
        entry: CachedEntry,
        ttl: timedelta | float | int | None = None,
    ) -> None:
        """子类实现的具体写入逻辑。"""
        raise NotImplementedError

    @abc.abstractmethod
    def _do_invalidate_by_prefix(self, prefix: str) -> None:
        """子类实现的具体前缀失效逻辑。"""
        raise NotImplementedError


class NoOpCache(CachePort):
    """空缓存实现（兜底与无缓存模式）。"""

    def _do_get(self, key: str) -> CachedEntry | None:
        return None

    def _do_set(
        self,
        key: str,
        entry: CachedEntry,
        ttl: timedelta | float | int | None = None,
    ) -> None:
        pass

    def _do_invalidate_by_prefix(self, prefix: str) -> None:
        pass


class MemoryCachePort(CachePort):
    """基于内存字典的线程安全缓存实现（仅供单测与本地降级调试）。"""

    def __init__(self) -> None:
        super().__init__()
        self._store: dict[str, tuple[CachedEntry, float | None]] = {}
        self._lock = threading.Lock()

    def _do_get(self, key: str) -> CachedEntry | None:
        now = time.time()
        with self._lock:
            if key not in self._store:
                return None
            entry, expires_at = self._store[key]
            if expires_at is not None and now >= expires_at:
                del self._store[key]
                return None
            return entry

    def _do_set(
        self,
        key: str,
        entry: CachedEntry,
        ttl: timedelta | float | int | None = None,
    ) -> None:
        expires_at: float | None = None
        if ttl is not None:
            if isinstance(ttl, timedelta):
                secs = ttl.total_seconds()
            else:
                secs = float(ttl)
            expires_at = time.time() + secs

        with self._lock:
            self._store[key] = (entry, expires_at)

    def _do_invalidate_by_prefix(self, prefix: str) -> None:
        with self._lock:
            keys_to_remove = [k for k in self._store if k.startswith(prefix)]
            for k in keys_to_remove:
                del self._store[k]


# ============================================================================
# 2. 单飞（Single-Flight）与 TTL ±20% 抖动
# ============================================================================

class _FlightCall:
    def __init__(self) -> None:
        self.event = threading.Event()
        self.result: Any = None
        self.exception: BaseException | None = None


class SingleFlight:
    """防击穿单飞控制：同一 key 的并发请求，底层计算只执行 1 次，所有等待者共享结果。

    支持 wait_timeout 兜底（建议 2.0s），避免慢请求拖死所有并发等待者。
    """

    def __init__(self) -> None:
        self._calls: dict[str, _FlightCall] = {}
        self._lock = threading.Lock()

    def execute(
        self,
        key: str,
        fn: Callable[[], T],
        wait_timeout: float = 2.0,
    ) -> T:
        with self._lock:
            if key in self._calls:
                call = self._calls[key]
                is_leader = False
            else:
                call = _FlightCall()
                self._calls[key] = call
                is_leader = True

        if not is_leader:
            # 等待 leader 完成
            signaled = call.event.wait(timeout=wait_timeout)
            if not signaled:
                logger.warning(
                    "SingleFlight wait timed out for key '%s' (%.2fs), falling back to direct execution",
                    key,
                    wait_timeout,
                )
                return fn()
            if call.exception is not None:
                raise call.exception
            return call.result  # type: ignore[no-any-return]

        # Leader 执行
        try:
            res = fn()
            call.result = res
            return res
        except BaseException as exc:
            call.exception = exc
            raise
        finally:
            with self._lock:
                self._calls.pop(key, None)
            call.event.set()


def compute_jittered_ttl(
    base_ttl: float | int | timedelta,
    jitter_ratio: float = 0.2,
) -> float | timedelta:
    """计算带有 ±20% 随机浮动的 TTL，防止大量缓存同一时刻失效引发雪崩。"""
    factor = random.uniform(1.0 - jitter_ratio, 1.0 + jitter_ratio)
    if isinstance(base_ttl, timedelta):
        return timedelta(seconds=base_ttl.total_seconds() * factor)
    return float(base_ttl) * factor


# ============================================================================
# 3. 查询指纹规范化
# ============================================================================

def compute_query_fingerprint(
    route: str,
    params: dict[str, Any] | None = None,
    contract_version: str | int = "1",
    default_params: dict[str, Any] | None = None,
) -> str:
    """计算规范化的查询指纹。

    规则：
      1. 去除值为 None 或与契约默认值 (default_params) 相同的参数；
      2. 参数名按字典序排序，确保与调用方传参顺序无关；
      3. 包含显式契约版本号 (contract_version)；
      4. 生成确定性哈希，形式如 `<route>:v<contract_version>:<sha256_digest>`。
    """
    params = params or {}
    default_params = default_params or {}

    filtered: dict[str, Any] = {}
    for k, v in params.items():
        if v is None:
            continue
        if k in default_params and default_params[k] == v:
            continue
        filtered[k] = v

    # 规范化 JSON 序列化：键按字母排序，无多余空格
    canonical_json = json.dumps(
        filtered,
        sort_keys=True,
        ensure_ascii=False,
        separators=(",", ":"),
    )
    param_hash = hashlib.sha256(canonical_json.encode("utf-8")).hexdigest()
    clean_route = route.rstrip("/")
    return f"{clean_route}:v{contract_version}:{param_hash}"


# ============================================================================
# 4. ETag 计算、比对与 304 短路处理
# ============================================================================

def compute_etag(body: bytes | str) -> str:
    """根据响应体内容计算强 ETag（SHA-256 hex 字符串并加双引号）。"""
    if isinstance(body, str):
        raw = body.encode("utf-8")
    else:
        raw = bytes(body)
    digest = hashlib.sha256(raw).hexdigest()
    return f'"{digest}"'


def matches_etag(if_none_match: str | None, current_etag: str) -> bool:
    """校验客户端 If-None-Match 请求头是否与缓存的 ETag 匹配。

    支持弱 ETag (W/)、引号包裹、逗号分隔的多 ETag 以及通配符 '*'。
    """
    if not if_none_match:
        return False

    client_header = if_none_match.strip()
    if client_header == "*":
        return True

    target_norm = current_etag.strip().lstrip("W/").strip('"')

    for part in client_header.split(","):
        norm_part = part.strip().lstrip("W/").strip('"')
        if norm_part == "*" or norm_part == target_norm:
            return True

    return False


@dataclass(frozen=True)
class CachedResponse:
    """缓存响应对象。"""
    status_code: int
    body: bytes
    etag: str
    headers: dict[str, str] = field(default_factory=dict)


def cached_query(
    cache: CachePort,
    key: str,
    loader: Callable[[], bytes | str | dict[str, Any] | list[Any] | Any],
    if_none_match: str | None = None,
    ttl: timedelta | float | int | None = None,
    single_flight: SingleFlight | None = None,
) -> CachedResponse:
    """服务层通用查询缓存网关。

    执行流程：
      1. 查询 cache.get(key)；
      2. 若命中且 If-None-Match 匹配 -> 直接返回 304 Not Modified，不下探 loader；
      3. 若命中但 If-None-Match 不匹配 -> 直接返回 200 + CachedEntry.body，不下探 loader；
      4. 若未命中 -> 执行 loader()（可受 single_flight 保护），计算 ETag，写入缓存（带 TTL 抖动），
         若与 If-None-Match 匹配则回 304，否则回 200。
    """
    cached_entry = cache.get(key)
    if cached_entry is not None:
        headers = {"ETag": cached_entry.etag}
        if matches_etag(if_none_match, cached_entry.etag):
            return CachedResponse(
                status_code=304,
                body=b"",
                etag=cached_entry.etag,
                headers=headers,
            )
        return CachedResponse(
            status_code=200,
            body=cached_entry.body,
            etag=cached_entry.etag,
            headers=headers,
        )

    # 未命中，执行 loader
    def _do_load_and_serialize() -> bytes:
        val = loader()
        if isinstance(val, bytes):
            return val
        if isinstance(val, str):
            return val.encode("utf-8")
        return json.dumps(val, ensure_ascii=False, separators=(",", ":")).encode("utf-8")

    if single_flight is not None:
        body_bytes = single_flight.execute(key, _do_load_and_serialize)
    else:
        body_bytes = _do_load_and_serialize()

    etag = compute_etag(body_bytes)
    jittered_ttl = compute_jittered_ttl(ttl) if ttl is not None else None
    new_entry = CachedEntry(
        body=body_bytes,
        etag=etag,
        stored_at=datetime.now(timezone.utc),
    )
    cache.set(key, new_entry, ttl=jittered_ttl)

    headers = {"ETag": etag}
    if matches_etag(if_none_match, etag):
        return CachedResponse(
            status_code=304,
            body=b"",
            etag=etag,
            headers=headers,
        )

    return CachedResponse(
        status_code=200,
        body=body_bytes,
        etag=etag,
        headers=headers,
    )


# ============================================================================
# 5. 全局单例与主动失效钩子（Invalidation Hooks）
# ============================================================================

_global_cache_lock = threading.Lock()
_global_cache: CachePort = MemoryCachePort()
_global_single_flight: SingleFlight = SingleFlight()


def get_global_cache() -> CachePort:
    """获取全局缓存实例。"""
    with _global_cache_lock:
        return _global_cache


def set_global_cache(cache: CachePort) -> None:
    """设置全局缓存实例（供单测与配置初始化使用）。"""
    global _global_cache
    with _global_cache_lock:
        _global_cache = cache


def get_global_single_flight() -> SingleFlight:
    """获取全局防击穿 SingleFlight 实例。"""
    return _global_single_flight


def set_global_single_flight(sf: SingleFlight) -> None:
    """设置全局 SingleFlight 实例。"""
    global _global_single_flight
    _global_single_flight = sf


def invalidate_guest_replies_cache(post_id: str) -> None:
    """主动失效指定帖子的游客代表性回复缓存。

    铁律：绝不抛异常。
    """
    if not post_id:
        return
    try:
        cache = get_global_cache()
        cache.invalidate_by_prefix(f"guest_replies/{post_id}")
    except Exception:
        logger.exception("invalidate_guest_replies_cache failed for post_id '%s'", post_id)


def invalidate_identity_cache(uid: str) -> None:
    """主动失效指定用户 uid 的身份映射缓存。

    铁律：绝不抛异常。
    """
    if not uid:
        return
    try:
        cache = get_global_cache()
        cache.invalidate_by_prefix(f"identity/{uid}")
    except Exception:
        logger.exception("invalidate_identity_cache failed for uid '%s'", uid)


def invalidate_playground_post_cache(post_id: str) -> None:
    """主动失效广场帖子详情与 Feed 列表缓存。

    铁律：绝不抛异常。
    """
    if not post_id:
        return
    try:
        cache = get_global_cache()
        cache.invalidate_by_prefix(f"playground/posts/{post_id}")
        cache.invalidate_by_prefix("/playground/feed")
    except Exception:
        logger.exception("invalidate_playground_post_cache failed for post_id '%s'", post_id)


