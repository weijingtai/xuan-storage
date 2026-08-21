"""身份解析。对应 TS 侧 src/identity.ts 的两个导出函数。

注意 TS 版读取字段时做了双写兼容（`app_user_id` 或 `appUserId`），
说明线上存在两种历史格式，Python 版必须照样兼容，否则老用户会解析失败。
生成规则与 TS 完全一致：
  - app_user_id: app-${Date.now().toString(36)}-${Math.floor(Math.random() * 0x7fffffff).toString(36)}
  - public_presentation_id: 16 字节随机 hex (32 字符)
  - public_display_alias: 玄友 + 4位零补齐随机数
"""

import json
import logging
import random
import secrets
import time
from typing import Optional

from google.cloud import firestore as gcf

from xuan.cache import (
    cached_query,
    compute_query_fingerprint,
    get_global_cache,
    get_global_single_flight,
)
from xuan.config import COLLECTIONS, db
from xuan.errors import unauthenticated

logger = logging.getLogger(__name__)


def _to_base36(num: int) -> str:
    """将非负整数转换为 base36 字符串（与 JS Number.prototype.toString(36) 一致）。"""
    if num <= 0:
        return "0"
    chars = "0123456789abcdefghijklmnopqrstuvwxyz"
    digits = []
    while num > 0:
        digits.append(chars[num % 36])
        num //= 36
    return "".join(reversed(digits))


def _generate_presentation_id() -> str:
    """128-bit 随机 hex，与 TS 的 crypto.randomBytes(16).toString('hex') 等价。"""
    return secrets.token_hex(16)


def _generate_display_alias() -> str:
    """默认公开别名，格式「玄友XXXX」，与 TS 版一致。"""
    return f"玄友{random.randint(0, 9999):04d}"


def require_auth_uid(uid: Optional[str]) -> str:
    """校验已登录。空 uid 抛 unauthenticated。"""
    if not uid:
        raise unauthenticated("未登录")
    return uid


def resolve_app_user_id(uid: Optional[str]) -> dict:
    """把 Firebase Auth uid 解析为应用内身份，不存在则原子创建。

    已接入 CachePort 读缓存网关，支持单飞防击穿与 TTL 抖动。
    返回 {appUserId, publicPresentationId, publicDisplayAlias}。
    键名保持 camelCase，与 TS 版返回结构一致。
    """
    if not uid:
        raise unauthenticated("未登录")

    cache_key = compute_query_fingerprint(
        route=f"identity/{uid}",
        contract_version="1",
    )

    def _loader() -> dict:
        client = db()
        id_map_doc = client.collection(COLLECTIONS["identity_map"]).document(uid)

        @gcf.transactional
        def _resolve(tx):
            snap = id_map_doc.get(transaction=tx)
            if snap.exists:
                data = snap.to_dict() or {}
                # 双写兼容：线上存在 snake_case 与 camelCase 两种历史格式
                return {
                    "appUserId": data.get("app_user_id") or data.get("appUserId") or "",
                    "publicPresentationId": (
                        data.get("public_presentation_id") or data.get("publicPresentationId") or ""
                    ),
                    "publicDisplayAlias": (
                        data.get("public_display_alias") or data.get("publicDisplayAlias") or ""
                    ),
                }

            # 与 TS 保持完全一致的 ID 生成规则：
            # `app-${Date.now().toString(36)}-${Math.floor(Math.random() * 0x7fffffff).toString(36)}`
            ts_ms = int(time.time() * 1000)
            rand_val = random.randint(0, 0x7ffffffe)
            new_app_user_id = f"app-{_to_base36(ts_ms)}-{_to_base36(rand_val)}"
            presentation_id = _generate_presentation_id()
            alias = _generate_display_alias()

            tx.set(id_map_doc, {
                "app_user_id": new_app_user_id,
                "provider_uid": uid,
                "provider_id": "firebase",
                "public_presentation_id": presentation_id,
                "public_display_alias": alias,
                "created_at": gcf.SERVER_TIMESTAMP,
            })
            return {
                "appUserId": new_app_user_id,
                "publicPresentationId": presentation_id,
                "publicDisplayAlias": alias,
            }

        return _resolve(client.transaction())

    cached_resp = cached_query(
        cache=get_global_cache(),
        key=cache_key,
        loader=_loader,
        ttl=300.0,
        single_flight=get_global_single_flight(),
    )

    if isinstance(cached_resp.body, (bytes, bytearray)):
        return json.loads(cached_resp.body.decode("utf-8"))
    if isinstance(cached_resp.body, str):
        return json.loads(cached_resp.body)
    return cached_resp.body
