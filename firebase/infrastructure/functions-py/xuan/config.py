"""全局配置。集合名必须与 TS 侧 src/index.ts 保持逐字一致。"""

import os
import firebase_admin
from firebase_admin import credentials, firestore, initialize_app
import google.auth.credentials

# 部署区域。与 TS 版一致，改动会导致客户端调用不到。
REGION = "asia-east1"

# Storage 触发器的区域必须与被监听的桶同区，否则部署直接报
# "A function in region X cannot listen to a bucket in region Y"。
# 各环境的默认桶未必都在 REGION：xuan-staging 的默认桶建在 us-east1。
#
# ⚠ 这个值不能用 .env.<projectId> 配置。firebase-tools 的顺序是
#   「先分析源码 → 后加载 .env」，装饰器求值时环境变量还不存在，
#   只会静默回落到默认值。凡是装饰器参数需要的值都有这个限制。
#   FIREBASE_CONFIG 则在分析阶段就已注入，所以按项目 id 查表是可行的。
_STORAGE_TRIGGER_REGION_BY_PROJECT = {
    "xuan-staging": "us-east1",  # 默认桶建在 us-east1，与函数主区域不一致
}


def _current_project_id() -> str:
    """解析当前部署目标的项目 id。分析阶段与运行期都可用。"""
    import json

    cfg = os.environ.get("FIREBASE_CONFIG")
    if cfg:
        try:
            parsed = json.loads(cfg)
            if parsed.get("projectId"):
                return parsed["projectId"]
        except (ValueError, TypeError):
            pass
    return os.environ.get("GCLOUD_PROJECT") or ""


STORAGE_TRIGGER_REGION = (
    os.environ.get("XUAN_STORAGE_TRIGGER_REGION")
    or _STORAGE_TRIGGER_REGION_BY_PROJECT.get(_current_project_id())
    or REGION
)

# 集合名。键为 snake_case，值必须与 TS 侧 COLLECTIONS 的值完全相同。
COLLECTIONS = {
    "posts": "playground_posts",
    "replies": "playground_replies",
    "verifications": "playground_verifications",
    "outcome_feedback": "playground_outcome_feedback",
    "likes": "playground_likes",
    "bookmarks": "playground_bookmarks",
    "profiles": "playground_profiles",
    "notifications": "playground_notifications",
    "conversations": "playground_conversations",
    "messages": "playground_messages",
    "reports": "playground_reports",
    "media": "playground_media",
    "idempotency": "playground_idempotency",
    "outbox": "playground_outbox",
    "identity_map": "identity_map",
    "fcm_tokens": "fcm_tokens",
    "blocks": "playground_blocks",
}

MAX_REPLY_DEPTH = 1

_app = None


class _EmulatorCredential(credentials.Base):
    """Emulator 专用匿名凭据，避免在无 ADC 环境下抛 DefaultCredentialsError。"""

    def __init__(self, project_id: str = "demo-xuan"):
        self._project_id = project_id

    def get_credential(self):
        return google.auth.credentials.AnonymousCredentials()

    @property
    def project_id(self):
        return self._project_id


if os.environ.get("FIRESTORE_EMULATOR_HOST") and not firebase_admin._apps:
    _project_id = os.environ.get("GCLOUD_PROJECT") or "demo-xuan"
    _app = initialize_app(credential=_EmulatorCredential(_project_id))


def db():
    """惰性初始化 Firestore 客户端。Emulator 由 FIRESTORE_EMULATOR_HOST 环境变量接管。"""
    global _app
    if _app is None:
        if not firebase_admin._apps:
            if os.environ.get("FIRESTORE_EMULATOR_HOST"):
                project_id = os.environ.get("GCLOUD_PROJECT") or "demo-xuan"
                _app = initialize_app(credential=_EmulatorCredential(project_id))
            else:
                _app = initialize_app()
        else:
            _app = firebase_admin.get_app()
    return firestore.client()
