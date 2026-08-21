"""错误封装。

两层含义：
  - `code`：Firebase callable 的错误码字符串，**必须与 TS 版一致**，
    客户端现有的分支逻辑依赖它。
  - `l0_code`：契约内核（REPOSITORY-CONTRACT-KERNEL-DESIGN §3.1）的 10 个闭合错误码，
    供将来 REST 层生成 RFC 9457 Problem Details 使用。
"""

from typing import Any
from firebase_functions import https_fn

# Firebase code → L0 闭合错误码
_L0_MAP = {
    "invalid-argument": "invalid_argument",
    "not-found": "not_found",
    "unauthenticated": "unauthenticated",
    "permission-denied": "permission_denied",
    "aborted": "conflict.idempotency",
    "already-exists": "conflict.unique",
    "failed-precondition": "invalid_argument",
    "resource-exhausted": "unavailable",
    "unavailable": "unavailable",
    "deadline-exceeded": "deadline_exceeded",
    "internal": "internal",
}

_CODE_ENUM = {
    "invalid-argument": https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
    "not-found": https_fn.FunctionsErrorCode.NOT_FOUND,
    "unauthenticated": https_fn.FunctionsErrorCode.UNAUTHENTICATED,
    "permission-denied": https_fn.FunctionsErrorCode.PERMISSION_DENIED,
    "aborted": https_fn.FunctionsErrorCode.ABORTED,
    "already-exists": https_fn.FunctionsErrorCode.ALREADY_EXISTS,
    "failed-precondition": https_fn.FunctionsErrorCode.FAILED_PRECONDITION,
    "resource-exhausted": https_fn.FunctionsErrorCode.RESOURCE_EXHAUSTED,
    "unavailable": https_fn.FunctionsErrorCode.UNAVAILABLE,
    "deadline-exceeded": https_fn.FunctionsErrorCode.DEADLINE_EXCEEDED,
    "internal": https_fn.FunctionsErrorCode.INTERNAL,
}


class XuanHttpsError(https_fn.HttpsError):
    """带 L0 映射的 HttpsError。"""

    def __init__(self, code: str, message: str):
        self.code_str = code
        super().__init__(code=_CODE_ENUM[code], message=message)

    @property
    def code(self) -> str:  # type: ignore[override]
        return self.code_str

    @code.setter
    def code(self, value: Any) -> None:
        if isinstance(value, https_fn.FunctionsErrorCode):
            self.code_str = value.value
        elif isinstance(value, str):
            self.code_str = value

    @property
    def l0_code(self) -> str:
        """对应的契约内核错误码。"""
        return _L0_MAP[self.code_str]

    def __str__(self) -> str:
        return f"[{self.code_str}] {self.message}"


def invalid_argument(message: str) -> XuanHttpsError:
    """入参非法。"""
    return XuanHttpsError("invalid-argument", message)


def not_found(message: str) -> XuanHttpsError:
    """资源不存在。"""
    return XuanHttpsError("not-found", message)


def unauthenticated(message: str) -> XuanHttpsError:
    """未登录。"""
    return XuanHttpsError("unauthenticated", message)


def conflict(message: str) -> XuanHttpsError:
    """幂等键冲突。TS 版用的是 'aborted'，此处保持一致。"""
    return XuanHttpsError("aborted", message)


def unavailable(message: str) -> XuanHttpsError:
    """暂不可用（可重试）。"""
    return XuanHttpsError("unavailable", message)


def failed_precondition(message: str) -> XuanHttpsError:
    """状态不满足前置条件（如帖子已删除、对话未激活）。

    契约内核的 10 个闭合错误码中没有精确对应项，映射到 invalid_argument——
    从调用方视角，「对已删除的帖子发起编辑」确实属于请求本身不合法。
    """
    return XuanHttpsError("failed-precondition", message)


def already_exists(message: str) -> XuanHttpsError:
    """目标已存在。映射到契约内核的 conflict.unique。"""
    return XuanHttpsError("already-exists", message)


def resource_exhausted(message: str) -> XuanHttpsError:
    """超出频率限制。

    映射到契约内核的 unavailable —— 限流是**暂时性**拒绝，
    调用方退避后重试即可成功，语义上属于「后端暂不可用」而非「请求非法」。
    """
    return XuanHttpsError("resource-exhausted", message)

