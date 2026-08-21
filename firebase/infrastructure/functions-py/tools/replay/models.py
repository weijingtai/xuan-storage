"""离线回放比对数据模型。"""
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Set


@dataclass
class ReplaySample:
    """单个样本定义（声明式）。"""

    id: str
    description: str
    ts_function: str
    py_function: str
    data: Dict[str, Any] = field(default_factory=dict)
    auth_email: Optional[str] = None
    auth_uid: Optional[str] = None
    auth_password: str = "password123"
    expected_status: int = 200
    seed_data: Dict[str, Dict[str, Dict[str, Any]]] = field(default_factory=dict)
    # {collection_name: {doc_id: doc_dict}}
    known_static_ids: Set[str] = field(default_factory=set)

    # 触发器专用字段
    is_trigger: bool = False
    trigger_type: Optional[str] = None  # "outbox" 或 "storage"
    trigger_action: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ReplayResult:
    """单样本双跑比对结果。"""

    sample_id: str
    description: str
    equivalent: bool
    differences: List[str]
    ts_status: int
    py_status: int
    ts_response: Any
    py_response: Any
    ts_snapshot: Dict[str, Any]
    py_snapshot: Dict[str, Any]
    ts_normalized: Dict[str, Any]
    py_normalized: Dict[str, Any]
