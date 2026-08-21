"""测试夹具。全部跑在 192.168.0.165 的 Emulator 上，不连生产。"""
import os

import pytest

EMULATOR_HOST = os.environ.get("XUAN_EMULATOR_HOST", "192.168.0.165:8080")


@pytest.fixture(scope="session", autouse=True)
def _emulator_env():
    """强制指向 Emulator。缺这一步测试会打到生产库。"""
    os.environ["FIRESTORE_EMULATOR_HOST"] = EMULATOR_HOST
    os.environ.setdefault("GCLOUD_PROJECT", "demo-xuan")
    yield


@pytest.fixture()
def firestore_db(_emulator_env):
    from xuan.config import db
    return db()


@pytest.fixture()
def clean_collections(firestore_db):
    """每个用例前清空本计划涉及的集合。"""
    from xuan.config import COLLECTIONS

    names = [
        COLLECTIONS["idempotency"], COLLECTIONS["bookmarks"],
        COLLECTIONS["likes"], COLLECTIONS["profiles"],
        COLLECTIONS["posts"], COLLECTIONS["replies"],
        COLLECTIONS["outbox"], COLLECTIONS["identity_map"],
        COLLECTIONS["conversations"], COLLECTIONS["messages"],
        COLLECTIONS["blocks"], COLLECTIONS["outcome_feedback"],
        COLLECTIONS["verifications"], COLLECTIONS["fcm_tokens"],
        COLLECTIONS["reports"], COLLECTIONS["notifications"],
        COLLECTIONS["media"],
    ]
    for name in names:
        for doc in firestore_db.collection(name).stream():
            doc.reference.delete()
    yield firestore_db
