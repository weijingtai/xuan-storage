"""跨语言哈希一致性。这是整个 Python 重写里最容易静默出错的一处。

哈希对不上的后果不是报错，而是同一个幂等键被判为「异载荷」，
轻则冲突报错，重则同一操作被执行两次。
"""
import json
from pathlib import Path

import pytest

from xuan.hashing import hash_payload

VECTORS = json.loads(
    (Path(__file__).parent / "fixtures" / "js_hash_vectors.json").read_text(encoding="utf-8")
)


@pytest.mark.parametrize("case", VECTORS, ids=lambda c: c["name"])
def test_与_js_哈希逐位一致(case):
    got = hash_payload(case["data"])
    assert got == case["hash"], (
        f'用例 {case["name"]} 哈希不一致\n'
        f'  Python: {got}\n'
        f'  JS    : {case["hash"]}\n'
        f"  数据  : {case['data']}"
    )


def test_canonicalize_剔除幂等键并排序():
    from xuan.hashing import canonicalize

    got = canonicalize({"b": 1, "idempotency_key": "k", "a": 2})
    assert list(got.keys()) == ["a", "b"], "必须剔除 idempotency_key 并按键排序"


def test_canonicalize_递归处理嵌套():
    from xuan.hashing import canonicalize

    got = canonicalize({"outer": {"z": 1, "idempotency_key": "k", "a": 2}})
    assert list(got["outer"].keys()) == ["a", "z"]
