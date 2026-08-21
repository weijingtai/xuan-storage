"""Firebase Emulator 交互客户端。

支持清空 Firestore 与 Auth、生成固定 UID 的 Auth ID Token、数据灌入、Callable 调用、Storage 触发以及全库快照。
"""
import os
from typing import Any, Dict, Optional, Tuple
import requests

from xuan.config import COLLECTIONS, db


class ReplayClient:
    """与本地 Firebase Emulator 进行 HTTP / SDK 交互的客户端。"""

    def __init__(
        self,
        host: str = "127.0.0.1",
        project: str = "demo-xuan",
        region: str = "us-central1",
        firestore_port: int = 8080,
        auth_port: int = 9099,
        functions_port: int = 5001,
        storage_port: int = 9199,
    ):
        self.host = host
        self.project = project
        self.region = region
        self.firestore_port = firestore_port
        self.auth_port = auth_port
        self.functions_port = functions_port
        self.storage_port = storage_port

        self.firestore_url = f"http://{host}:{firestore_port}"
        self.auth_url = f"http://{host}:{auth_port}"
        self.functions_url = f"http://{host}:{functions_port}/{project}/{region}"
        self.storage_url = f"http://{host}:{storage_port}"

        # 确保 Python SDK 环境变量一致
        os.environ["FIRESTORE_EMULATOR_HOST"] = f"{host}:{firestore_port}"
        os.environ["GCLOUD_PROJECT"] = project

    def clear_firestore(self) -> None:
        """调用 Firestore Emulator REST 端点快速清空全库。"""
        url = f"{self.firestore_url}/emulator/v1/projects/{self.project}/databases/(default)/documents"
        resp = requests.delete(url, timeout=10)
        resp.raise_for_status()

    def clear_auth(self) -> None:
        """调用 Auth Emulator REST 端点清空全部用户账户。"""
        url = f"{self.auth_url}/emulator/v1/projects/{self.project}/accounts"
        try:
            requests.delete(url, timeout=10)
        except Exception:
            pass

    def get_auth_token(
        self,
        email: str,
        password: str = "password123",
        fixed_uid: Optional[str] = None,
    ) -> Tuple[str, str]:
        """通过 Auth Emulator 接口签发用户的 ID Token 与 localId。
        
        如果指定了 fixed_uid，则通过 Emulator 管理端点创建/更新并显式指定 localId。
        """
        if fixed_uid:
            target_email = f"{fixed_uid}@example.com"
            admin_url = f"{self.auth_url}/identitytoolkit.googleapis.com/v1/projects/{self.project}/accounts"
            admin_headers = {"Authorization": "Bearer owner", "Content-Type": "application/json"}
            requests.post(
                admin_url,
                headers=admin_headers,
                json={
                    "localId": fixed_uid,
                    "email": target_email,
                    "password": password,
                    "emailVerified": True,
                },
                timeout=10,
            )
            # 密码登录获取带指定 localId 的 idToken
            sign_in_url = f"{self.auth_url}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-key"
            resp2 = requests.post(
                sign_in_url,
                json={"email": target_email, "password": password, "returnSecureToken": True},
                timeout=10,
            )
            resp2.raise_for_status()
            data2 = resp2.json()
            return data2["idToken"], fixed_uid

        # 默认注册
        url = f"{self.auth_url}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-key"
        resp = requests.post(
            url,
            json={"email": email, "password": password, "returnSecureToken": True},
            timeout=10,
        )
        if resp.status_code == 200:
            data = resp.json()
            return data["idToken"], data["localId"]

        # 用户已存在时通过密码登录
        sign_in_url = f"{self.auth_url}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-key"
        resp2 = requests.post(
            sign_in_url,
            json={"email": email, "password": password, "returnSecureToken": True},
            timeout=10,
        )
        resp2.raise_for_status()
        data2 = resp2.json()
        return data2["idToken"], data2["localId"]

    def seed_firestore(self, seed_data: Dict[str, Dict[str, Dict[str, Any]]]) -> None:
        """向 Firestore 灌入前置数据。
        
        结构: {collection_name: {doc_id: doc_fields}}
        """
        if not seed_data:
            return
        client = db()
        for col_name, docs in seed_data.items():
            for doc_id, fields in docs.items():
                client.collection(col_name).document(doc_id).set(fields)

    def write_document(self, collection_name: str, doc_id: str, data: Dict[str, Any]) -> None:
        """向指定集合写入单个文档（用于触发 onOutboxCreated 等 Firestore Trigger）。"""
        client = db()
        client.collection(collection_name).document(doc_id).set(data)

    def upload_storage_file(
        self,
        file_path: str,
        content: bytes = b"fake binary content",
        content_type: str = "image/jpeg",
        id_token: Optional[str] = None,
    ) -> Tuple[int, Any]:
        """上传文件到 Storage Emulator（用于触发 onMediaUploaded 等 Storage Trigger）。"""
        import urllib.parse
        encoded_name = urllib.parse.quote(file_path, safe="")
        bucket = f"{self.project}.appspot.com"
        url = f"{self.storage_url}/v0/b/{bucket}/o?name={encoded_name}"
        headers = {"Content-Type": content_type}
        if id_token:
            headers["Authorization"] = f"Bearer {id_token}"
        resp = requests.post(url, data=content, headers=headers, timeout=10)
        try:
            return resp.status_code, resp.json()
        except Exception:
            return resp.status_code, {"text": resp.text}

    def call_callable(
        self,
        func_name: str,
        data: Any,
        id_token: Optional[str] = None,
    ) -> Tuple[int, Any]:
        """调用指定 Callable 函数，返回 (status_code, json_body)。"""
        url = f"{self.functions_url}/{func_name}"
        headers = {"Content-Type": "application/json"}
        if id_token:
            headers["Authorization"] = f"Bearer {id_token}"

        body = {"data": data}
        try:
            resp = requests.post(url, json=body, headers=headers, timeout=15)
            try:
                payload = resp.json()
            except Exception:
                payload = {"text": resp.text}
            return resp.status_code, payload
        except requests.RequestException as e:
            return 599, {"error": {"message": str(e), "status": "REQUEST_FAILED"}}

    def snapshot_all_collections(self) -> Dict[str, Dict[str, Any]]:
        """抓取全部 17 个已知集合的完整快照。
        
        返回: {collection_name: {doc_id: doc_dict}}
        """
        client = db()
        snapshot = {}
        for key, col_name in COLLECTIONS.items():
            docs_dict = {}
            for doc in client.collection(col_name).stream():
                docs_dict[doc.id] = doc.to_dict()
            if docs_dict:
                snapshot[col_name] = docs_dict
        return snapshot
