"""影子比对判定器。

用途：FW2 影子比对期内，同一请求分别打到 TS 版与 Python 版，
把两个返回喂给 compare()，不一致即上报。

占位符归一化：将时间戳替换为 <TS>，将动态生成 ID（Firestore ID、app-* 标识）按首次出现次序
替换为 <ID:1>, <ID:2> 等占位符，保留跨集合引用拓扑关系。
"""

from dataclasses import dataclass, field
import datetime
import re
from typing import Any, Dict, List, Set, Tuple

# 天然不可能相同、且不代表行为差异的字段名
IGNORED_KEYS = {
    "created_at", "updated_at", "completed_at", "expires_at",
    "timestamp", "server_time",
}

TIMESTAMP_KEYS = {
    "created_at", "updated_at", "completed_at", "expires_at",
    "timestamp", "server_time", "verified_at", "revoked_at",
    "deleted_at", "last_active_at", "read_at", "expires_after",
}

RE_FIRESTORE_ID = re.compile(r"^[A-Za-z0-9]{20}$")
RE_APP_USER_ID = re.compile(r"^app-[a-z0-9]+(-[a-z0-9]+)*$")
RE_UUID = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", re.I)
RE_ISO_TIMESTAMP = re.compile(r"^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:?\d{2})?$")
RE_DEFAULT_ALIAS = re.compile(r"^玄友\d{4}$")


@dataclass
class ShadowDiff:
    """一次比对的结果。"""

    equivalent: bool
    differences: list = field(default_factory=list)


def _walk(ts: Any, py: Any, path: str, out: list, ignore_keys: bool = True) -> None:
    if isinstance(ts, dict) and isinstance(py, dict):
        for key in sorted(set(ts) | set(py)):
            if ignore_keys and key in IGNORED_KEYS:
                continue
            sub = f"{path}.{key}" if path else key
            if key not in ts:
                out.append(f"{sub}: 仅 Python 侧存在（值={py[key]!r}）")
            elif key not in py:
                out.append(f"{sub}: 仅 TS 侧存在（值={ts[key]!r}）")
            else:
                _walk(ts[key], py[key], sub, out, ignore_keys=ignore_keys)
        return

    if isinstance(ts, list) and isinstance(py, list):
        if len(ts) != len(py):
            out.append(f"{path}: 列表长度不同 TS={len(ts)} PY={len(py)}")
            return
        for i, (a, b) in enumerate(zip(ts, py)):
            _walk(a, b, f"{path}[{i}]", out, ignore_keys=ignore_keys)
        return

    if ts != py:
        out.append(f"{path}: TS={ts!r} PY={py!r}")


def compare(ts_result: Any, py_result: Any) -> ShadowDiff:
    """比对两个返回值。忽略 IGNORED_KEYS 中的字段。"""
    diffs: list = []
    _walk(ts_result, py_result, "", diffs, ignore_keys=True)
    return ShadowDiff(equivalent=not diffs, differences=diffs)


def compare_normalized(ts_result: Any, py_result: Any) -> ShadowDiff:
    """比对已经归一化后的完整结构（不忽略任何字段）。"""
    diffs: list = []
    _walk(ts_result, py_result, "", diffs, ignore_keys=False)
    return ShadowDiff(equivalent=not diffs, differences=diffs)


class Normalizer:
    """对单次执行结果及全库快照进行占位符归一化。

    保持实体间的引用拓扑关系：
    - 字典键（字段名与集合名）一律不归一化，保持原样以便发现字段/集合改名类差异
    - 快照第 2 层（文档 ID 键）按首次出现映射为 <ID:1>, <ID:2> 等
    - 字段值中的动态生成 ID 映射为对应占位符编号
    - 所有时间戳形态归一化为 <TS>
    """

    def __init__(self, known_static_ids: Set[str] | None = None):
        self.known_static_ids = set(known_static_ids or set())
        self.id_map: Dict[str, str] = {}
        self.id_counter = 0

    def _get_or_create_placeholder(self, raw_id: str) -> str:
        if raw_id in self.known_static_ids:
            return raw_id
        if raw_id not in self.id_map:
            self.id_counter += 1
            self.id_map[raw_id] = f"<ID:{self.id_counter}>"
        return self.id_map[raw_id]

    def is_dynamic_id(self, val: str, key_context: str = "") -> bool:
        if not isinstance(val, str):
            return False
        if val in self.known_static_ids:
            return False
        if val in self.id_map:
            return True
        if RE_APP_USER_ID.match(val):
            return True
        if RE_FIRESTORE_ID.match(val):
            return True
        if RE_UUID.match(val):
            return True
        if RE_DEFAULT_ALIAS.match(val):
            return True
        if key_context.endswith(("_id", "Id", "id")) and len(val) >= 16 and re.match(r"^[A-Za-z0-9_-]+$", val):
            return True
        return False

    def is_timestamp_value(self, val: Any, key_context: str = "") -> bool:
        if isinstance(val, (datetime.datetime, datetime.date)):
            return True
        if isinstance(val, dict):
            keys = set(val.keys())
            if keys in ({"_seconds", "_nanoseconds"}, {"seconds", "nanoseconds"}, {"_method_name"}):
                return True
        if isinstance(val, str) and RE_ISO_TIMESTAMP.match(val):
            return True
        if key_context in TIMESTAMP_KEYS:
            if isinstance(val, (int, float)) and val > 1_000_000_000:
                return True
            if isinstance(val, dict) and not val:
                return True
        return False

    def normalize_value(self, data: Any, key_context: str = "") -> Any:
        """递归归一化任意值（字典键一律保持原样，仅对值进行处理）。"""
        if self.is_timestamp_value(data, key_context):
            return "<TS>"

        if isinstance(data, str):
            if self.is_dynamic_id(data, key_context):
                return self._get_or_create_placeholder(data)
            return data

        if isinstance(data, dict):
            return {k: self.normalize_value(data[k], key_context=k) for k in sorted(data.keys())}

        if isinstance(data, (list, tuple)):
            return [self.normalize_value(item, key_context=key_context) for item in data]

        return data

    def normalize_response(self, response: Any) -> Any:
        """归一化 callable 返回值。"""
        return self.normalize_value(response)

    def normalize_snapshot(self, snapshot: Dict[str, Dict[str, Any]]) -> Dict[str, Dict[str, Any]]:
        """归一化 Firestore 全库快照：
        - 第 1 层（集合名）：保持原样，不得归一化
        - 第 2 层（文档 ID）：归一化为占位符
        - 第 3 层起（文档内容）：键为字段名保持原样，值为内容递归归一化
        """
        if not isinstance(snapshot, dict):
            return snapshot

        norm_snap = {}
        for col_name in sorted(snapshot.keys()):
            docs = snapshot[col_name]
            if not isinstance(docs, dict):
                norm_snap[col_name] = self.normalize_value(docs, key_context=col_name)
                continue

            norm_docs = {}
            for doc_id in sorted(docs.keys()):
                doc_data = docs[doc_id]
                # 文档 ID 属于真正的动态 ID，映射占位符
                norm_doc_id = self._get_or_create_placeholder(doc_id)
                # 文档内部字段：键保持原样，值递归归一化
                norm_docs[norm_doc_id] = self.normalize_value(doc_data, key_context="doc")
            norm_snap[col_name] = norm_docs
        return norm_snap


def compare_replay(
    ts_response: Any,
    py_response: Any,
    ts_snapshot: Dict[str, Any],
    py_snapshot: Dict[str, Any],
    ts_status: int = 200,
    py_status: int = 200,
    known_static_ids: Set[str] | None = None,
) -> Tuple[ShadowDiff, Any, Any]:
    """比对单次回放的完整结果（HTTP 状态码 + 返回值 + 数据库快照）。"""
    ts_normalizer = Normalizer(known_static_ids=known_static_ids)
    py_normalizer = Normalizer(known_static_ids=known_static_ids)

    ts_norm = {
        "http_status": ts_status,
        "response": ts_normalizer.normalize_response(ts_response),
        "snapshot": ts_normalizer.normalize_snapshot(ts_snapshot),
    }
    py_norm = {
        "http_status": py_status,
        "response": py_normalizer.normalize_response(py_response),
        "snapshot": py_normalizer.normalize_snapshot(py_snapshot),
    }

    diff = compare_normalized(ts_norm, py_norm)
    return diff, ts_norm, py_norm
