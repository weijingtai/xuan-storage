"""媒体处理。基准实现：functions/src/media.ts

两个 trigger 同样采用「纯函数 + 薄壳」结构，便于测试。
"""

import logging
import os
import re
from datetime import datetime, timedelta, timezone
from typing import Optional

import firebase_admin
from firebase_functions import scheduler_fn, storage_fn
from google.cloud import firestore as gcf

from xuan.config import COLLECTIONS, REGION, STORAGE_TRIGGER_REGION, db

_log = logging.getLogger(__name__)

# 与 TS 一致：playground_media/{userId}/{uploadSessionId}/...
_PATH_RE = re.compile(r"^playground_media/([^/]+)/([^/]+)/")

# 超过该时长仍为 pending 的媒体视为孤儿
_ORPHAN_AFTER = timedelta(hours=24)


def _resolve_storage_bucket() -> str:
    """解析 bucket 名。与 TS 的 resolveStorageBucket 等价。"""
    import json

    cfg = os.environ.get("FIREBASE_CONFIG")
    if cfg:
        try:
            parsed = json.loads(cfg)
            if parsed.get("storageBucket"):
                return parsed["storageBucket"]
        except (ValueError, TypeError):
            pass  # 配置格式不对就走下面的回退
    return os.environ.get("STORAGE_BUCKET") or "demo-xuan.appspot.com"


def _delete_bucket_file(path: str) -> None:
    """删除存储对象。独立成函数便于测试 monkeypatch。"""
    from firebase_admin import storage
    storage.bucket().blob(path).delete()


def handle_media_uploaded(
    file_path: Optional[str],
    size: Optional[int],
    content_type: Optional[str],
) -> bool:
    """媒体上传完成后把对应记录置为 ready。返回是否有记录被更新。"""
    if not file_path:
        return False
    match = _PATH_RE.match(file_path)
    if not match:
        return False

    user_id, upload_session_id = match.group(1), match.group(2)

    snaps = list(db().collection(COLLECTIONS["media"])
                 .where("upload_session_id", "==", upload_session_id)
                 .where("owner_user_id", "==", user_id).get())
    if not snaps:
        return False

    snaps[0].reference.update({
        "status": "ready",
        "bucket_path": file_path,
        "file_size": size,
        "content_type": content_type,
        "finalized_at": gcf.SERVER_TIMESTAMP,
    })
    return True


def cleanup_orphan_media() -> int:
    """把超过 24 小时仍为 pending 的媒体标为 orphan 并删除其存储对象。

    ★ 坑 5：**先批量落状态，再逐个删文件**。顺序反了会导致下一轮重复尝试删除。
    单个文件删除失败只记日志，不中断整轮。
    """
    cutoff = datetime.now(timezone.utc) - _ORPHAN_AFTER
    client = db()

    pending = list(client.collection(COLLECTIONS["media"])
                   .where("status", "==", "pending")
                   .where("created_at", "<", cutoff).get())
    if not pending:
        return 0

    batch = client.batch()
    for doc in pending:
        batch.update(doc.reference, {"status": "orphan"})
    batch.commit()

    for doc in pending:
        bucket_path = (doc.to_dict() or {}).get("bucket_path")
        if not bucket_path:
            continue
        try:
            _delete_bucket_file(bucket_path)
        except Exception as err:  # noqa: BLE001 —— 单个失败不中断整轮
            _log.error("Failed to delete orphan media file: %s (%s)", bucket_path, err)

    _log.info("Orphan media cleanup: marked %d as orphan", len(pending))
    return len(pending)


@storage_fn.on_object_finalized(bucket=_resolve_storage_bucket(), region=STORAGE_TRIGGER_REGION)
def on_media_uploaded_py(event: storage_fn.CloudEvent[storage_fn.StorageObjectData]) -> None:
    """存储对象写入完成时的薄壳。"""
    handle_media_uploaded(event.data.name, event.data.size, event.data.content_type)


@scheduler_fn.on_schedule(schedule="every 60 minutes", region=REGION)
def cleanup_orphan_media_py(event: scheduler_fn.ScheduledEvent) -> None:
    """定时清理孤儿媒体的薄壳。"""
    cleanup_orphan_media()
