"""写入类 callable 的统一前置守卫。

设计目标：接线只占**一行**，且开关关闭时**零副作用**
（不查询、不写记录），这样影子比对期内行为与 TS 完全等价。
"""

from typing import Optional

from xuan.rate_limit import check_rate_limit, rate_limit_enabled, record_action


def guard_rate_limit(app_user_id: str, action: str,
                     idempotency_key: Optional[str] = None) -> None:
    """限流守卫。开关关闭时**立即返回，不产生任何 IO**。"""
    if not rate_limit_enabled():
        return
    check_rate_limit(app_user_id, action)
    if idempotency_key:
        record_action(app_user_id, action, idempotency_key)
