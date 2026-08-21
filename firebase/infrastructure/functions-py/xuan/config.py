"""全局配置。集合名必须与 TS 侧 src/index.ts 保持逐字一致。"""

import os
import firebase_admin
from firebase_admin import credentials, firestore, initialize_app
import google.auth.credentials

# 部署区域。与 TS 版一致，改动会导致客户端调用不到。
REGION = "asia-east1"

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
