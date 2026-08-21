"""操作频率限制。基准实现：functions/src/abuse_control.ts

⚠ **TS 侧这两个函数从未接线**（index.ts 未导出、生产代码零调用），
因此启用限流是一个**行为变更**，不是等价迁移。

为此本模块提供开关 `XUAN_RATE_LIMIT_ENABLED`，**缺省关闭**：
  - 影子比对期：关闭 → 行为与 TS 完全等价，比对可正常进行
  - 切换完成后：置 true → 限流生效

见 REALTIME-AND-FAAS-MIGRATION-PLAN.md §11.6。
"""

import os
from datetime import datetime, timedelta, timezone

from xuan.config import COLLECTIONS, db
from xuan.errors import resource_exhausted

DEFAULT_RATE_LIMIT = 30
_WINDOW = timedelta(minutes=1)
_TTL = timedelta(minutes=10)

_TRUTHY = {"true", "1", "yes", "on"}


def rate_limit_enabled() -> bool:
    """限流总开关。**缺省关闭** —— 影子比对期内必须保持关闭。"""
    return os.environ.get("XUAN_RATE_LIMIT_ENABLED", "").strip().lower() in _TRUTHY


def check_rate_limit(app_user_id: str, action: str,
                     max_per_minute: int = DEFAULT_RATE_LIMIT) -> None:
    """超过窗口内上限则抛 resource-exhausted。未超限静默返回。"""
    window_start = datetime.now(timezone.utc) - _WINDOW

    rows = list(db().collection(COLLECTIONS["idempotency"])
                .where("app_user_id", "==", app_user_id)
                .where("action", "==", action)
                .where("timestamp", ">=", window_start).get())

    if len(rows) >= max_per_minute:
        raise resource_exhausted(f"操作频率超过限制 ({max_per_minute}/分钟)")


def record_action(app_user_id: str, action: str, idempotency_key: str) -> None:
    """记录一次操作，供 check_rate_limit 统计。"""
    now = datetime.now(timezone.utc)
    db().collection(COLLECTIONS["idempotency"]).document(f"rate_{idempotency_key}").set({
        "app_user_id": app_user_id,
        "action": action,
        "timestamp": now,
        "ttl": now + _TTL,
    })
