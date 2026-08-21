"""错误码必须与 TS 侧 HttpsError 的 code 字符串一致，
否则客户端按 code 分支的逻辑会全部失效。"""
import pytest

from xuan.errors import (
    XuanHttpsError, invalid_argument, not_found,
    unauthenticated, conflict, unavailable,
)


@pytest.mark.parametrize("factory,expected_code", [
    (lambda: invalid_argument("x"), "invalid-argument"),
    (lambda: not_found("x"), "not-found"),
    (lambda: unauthenticated("x"), "unauthenticated"),
    (lambda: conflict("x"), "aborted"),
    (lambda: unavailable("x"), "unavailable"),
])
def test_错误码字符串与_ts_一致(factory, expected_code):
    err = factory()
    assert isinstance(err, XuanHttpsError)
    assert err.code == expected_code


def test_映射到_L0_契约错误码():
    """服务端错误码 → 契约内核 10 码的映射，供 REST 层生成 RFC 9457 响应体。"""
    assert conflict("x").l0_code == "conflict.idempotency"
    assert not_found("x").l0_code == "not_found"
    assert unavailable("x").l0_code == "unavailable"
    assert invalid_argument("x").l0_code == "invalid_argument"
    assert unauthenticated("x").l0_code == "unauthenticated"


def test_新增两个错误码():
    from xuan.errors import failed_precondition, already_exists

    fp = failed_precondition("帖子已删除")
    assert fp.code == "failed-precondition"
    assert fp.l0_code == "invalid_argument", "契约内核无对应码，归入 invalid_argument"

    ae = already_exists("对话已存在")
    assert ae.code == "already-exists"
    assert ae.l0_code == "conflict.unique"


def test_限流错误码():
    from xuan.errors import resource_exhausted

    e = resource_exhausted("操作频率超过限制 (30/分钟)")
    assert e.code == "resource-exhausted"
    assert e.l0_code == "unavailable", "契约内核无对应码；限流可重试，归入 unavailable"
    assert e.retryable_hint is True if hasattr(e, "retryable_hint") else True

