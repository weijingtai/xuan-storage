"""媒体处理。基准实现：functions/src/media.ts"""
from datetime import datetime, timedelta, timezone

import pytest

from xuan.config import COLLECTIONS
from xuan.handlers.media import cleanup_orphan_media, handle_media_uploaded


def _pending(client, doc_id, owner="u1", session="s1", created=None, bucket_path=None):
    row = {
        "id": doc_id, "owner_user_id": owner, "upload_session_id": session,
        "status": "pending",
        "created_at": created or datetime.now(timezone.utc),
    }
    if bucket_path:
        row["bucket_path"] = bucket_path
    client.collection(COLLECTIONS["media"]).document(doc_id).set(row)
    return doc_id


# ---- onMediaUploaded ----

def test_路径不匹配则忽略(clean_collections):
    _pending(clean_collections, "m1")
    assert handle_media_uploaded("别的目录/x.png", 100, "image/png") is False
    row = clean_collections.collection(COLLECTIONS["media"]).document("m1").get().to_dict()
    assert row["status"] == "pending", "不匹配的路径不得改动任何记录"


def test_空路径不崩(clean_collections):
    assert handle_media_uploaded(None, 0, None) is False
    assert handle_media_uploaded("", 0, None) is False


def test_找不到媒体记录则忽略(clean_collections):
    assert handle_media_uploaded("playground_media/u1/没有这个会话/a.png", 1, "image/png") is False


def test_匹配成功置为_ready(clean_collections):
    _pending(clean_collections, "m1", owner="u1", session="s1")
    ok = handle_media_uploaded("playground_media/u1/s1/photo.png", 2048, "image/png")
    assert ok is True
    row = clean_collections.collection(COLLECTIONS["media"]).document("m1").get().to_dict()
    assert row["status"] == "ready"
    assert row["bucket_path"] == "playground_media/u1/s1/photo.png"
    assert row["file_size"] == 2048
    assert row["content_type"] == "image/png"
    assert "finalized_at" in row


def test_owner_与_session_双重匹配(clean_collections):
    """两个条件都要对上，只对一个不行。"""
    _pending(clean_collections, "m1", owner="u1", session="s1")
    assert handle_media_uploaded("playground_media/别人/s1/a.png", 1, "image/png") is False
    assert handle_media_uploaded("playground_media/u1/别的会话/a.png", 1, "image/png") is False
    row = clean_collections.collection(COLLECTIONS["media"]).document("m1").get().to_dict()
    assert row["status"] == "pending"


# ---- cleanupOrphanMedia ----

def test_清理_只处理超过_24_小时的_pending(clean_collections, monkeypatch):
    monkeypatch.setattr("xuan.handlers.media._delete_bucket_file", lambda p: None)
    old = datetime.now(timezone.utc) - timedelta(hours=25)
    fresh = datetime.now(timezone.utc) - timedelta(hours=1)
    _pending(clean_collections, "old", created=old)
    _pending(clean_collections, "fresh", created=fresh)

    assert cleanup_orphan_media() == 1
    rows = {d.id: d.to_dict() for d in clean_collections.collection(COLLECTIONS["media"]).stream()}
    assert rows["old"]["status"] == "orphan"
    assert rows["fresh"]["status"] == "pending", "未满 24 小时的不动"


def test_清理_不碰非_pending(clean_collections, monkeypatch):
    monkeypatch.setattr("xuan.handlers.media._delete_bucket_file", lambda p: None)
    old = datetime.now(timezone.utc) - timedelta(hours=25)
    _pending(clean_collections, "ready_one", created=old)
    clean_collections.collection(COLLECTIONS["media"]).document("ready_one").update({"status": "ready"})
    assert cleanup_orphan_media() == 0


def test_清理_先落状态再删文件(clean_collections, monkeypatch):
    """★ 坑 5：顺序不能反。"""
    order = []

    def fake_delete(path):
        # 删文件时状态必须已经是 orphan
        row = clean_collections.collection(COLLECTIONS["media"]).document("old").get().to_dict()
        order.append(("delete", row["status"]))

    monkeypatch.setattr("xuan.handlers.media._delete_bucket_file", fake_delete)
    _pending(clean_collections, "old",
             created=datetime.now(timezone.utc) - timedelta(hours=25),
             bucket_path="playground_media/u1/s1/a.png")

    cleanup_orphan_media()
    assert order == [("delete", "orphan")], "删文件时状态必须已落为 orphan"


def test_清理_删文件失败不中断(clean_collections, monkeypatch):
    def boom(path):
        raise RuntimeError("存储挂了")

    monkeypatch.setattr("xuan.handlers.media._delete_bucket_file", boom)
    old = datetime.now(timezone.utc) - timedelta(hours=25)
    _pending(clean_collections, "a", created=old, bucket_path="p/a.png")
    _pending(clean_collections, "b", created=old, session="s2", bucket_path="p/b.png")

    assert cleanup_orphan_media() == 2, "单个文件删除失败不得中断整轮"
    rows = {d.id: d.to_dict() for d in clean_collections.collection(COLLECTIONS["media"]).stream()}
    assert rows["a"]["status"] == "orphan" and rows["b"]["status"] == "orphan"


def test_清理_无_bucket_path_跳过删除(clean_collections, monkeypatch):
    called = []
    monkeypatch.setattr("xuan.handlers.media._delete_bucket_file", lambda p: called.append(p))
    _pending(clean_collections, "nopath",
             created=datetime.now(timezone.utc) - timedelta(hours=25))
    cleanup_orphan_media()
    assert called == [], "没有 bucket_path 就不该尝试删文件"


def test_两个_trigger_壳可导入():
    from xuan.handlers.media import cleanup_orphan_media_py, on_media_uploaded_py
    assert on_media_uploaded_py is not None and cleanup_orphan_media_py is not None
