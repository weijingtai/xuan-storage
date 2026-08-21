r"""与 JS `JSON.stringify` 逐字节一致的哈希。

TS 侧实现（src/utils.ts）：
    crypto.createHash('sha256').update(JSON.stringify(data)).digest('hex')

Python 的 json.dumps 默认行为与 JS 有三处不同，必须全部关掉：
  1. 默认在 `, ` 和 `: ` 后加空格  → separators=(",", ":")
  2. 默认把非 ASCII 转义成 \uXXXX  → ensure_ascii=False
  3. 默认不排序键（与 JS 一致，故 sort_keys 保持 False）
"""

import hashlib
import json
from typing import Any


def _js_json_dumps(data: Any) -> str:
    """模拟 JS 的 JSON.stringify 输出。"""
    return json.dumps(
        data,
        ensure_ascii=False,      # JS 不转义非 ASCII
        separators=(",", ":"),   # JS 不加空格
        sort_keys=False,         # JS 保持插入顺序
        allow_nan=False,         # JS 的 JSON.stringify 会把 NaN 变成 null，此处直接拒绝
    )


def hash_payload(data: Any) -> str:
    """与 TS 侧 hashPayload 完全等价。"""
    return hashlib.sha256(_js_json_dumps(data).encode("utf-8")).hexdigest()


def canonicalize(value: Any) -> Any:
    """与 TS 侧 idempotency.ts 的 canonicalize 等价。

    对 dict：剔除 idempotency_key，按键名排序，递归处理。
    对 list：逐项递归。
    其余原样返回。
    """
    if isinstance(value, list):
        return [canonicalize(v) for v in value]
    if isinstance(value, dict):
        return {
            k: canonicalize(v)
            for k, v in sorted(value.items(), key=lambda kv: kv[0])
            if k != "idempotency_key"
        }
    return value
