import { db, COLLECTIONS } from './index';

/**
 * 幂等执行包装器。
 *
 * 流程：
 * 1. 检查 idempotency_key 是否已存在
 * 2. 若存在且 payload_hash 相同 → 返回缓存结果（重放）
 * 3. 若存在但 payload_hash 不同 → 返回 CONFLICT
 * 4. 若不存在 → 执行 fn，记录 idempotency doc，返回结果
 *
 * @param idempotencyKey - 客户端生成的 UUID
 * @param payloadHash - 命令内容的 SHA-256 哈希（由客户端或本层计算）
 * @param fn - 要执行的业务逻辑
 * @param ttlMinutes - 幂等记录保留时间（默认 60 分钟）
 */
export async function withIdempotency<T>(
  idempotencyKey: string | undefined,
  payloadHash: string,
  fn: () => Promise<T>,
  ttlMinutes: number = 60,
): Promise<T> {
  if (!idempotencyKey) {
    return fn();
  }

  const idemDoc = db.collection(COLLECTIONS.idempotency).doc(idempotencyKey);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(idemDoc);

    if (snap.exists) {
      const data = snap.data()!;
      const expiresAt = data.expires_at?.toDate?.() ?? data.expires_at;

      if (expiresAt && new Date(expiresAt) < new Date()) {
        // 幂等记录已过期，允许新建
        tx.delete(idemDoc);
      } else if (data.payload_hash === payloadHash) {
        // 重复请求，返回缓存结果
        if (data.result) {
          return data.result as T;
        }
        throw new Error('idempotency record exists but result is missing');
      } else {
        // 冲突：同一 key 但不同 payload
        throw new HttpsError(
          'aborted',
          `idempotency key conflict: ${idempotencyKey}`,
        );
      }
    }

    // 执行
    const result = await fn();

    const expiresAt = new Date(Date.now() + ttlMinutes * 60 * 1000);
    tx.set(idemDoc, {
      idempotency_key: idempotencyKey,
      payload_hash: payloadHash,
      result: result,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      expires_at: expiresAt,
    });

    return result;
  });
}

/**
 * Firestore transaction 重试包装器。
 * 最多重试 maxRetries 次，每次退避 delayMs * attempt。
 */
export async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  delayMs: number = 200,
): Promise<T> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (err: any) {
      if (attempt === maxRetries) throw err;
      if (err.code === 10 /* ABORTED */) {
        await new Promise((r) => setTimeout(r, delayMs * attempt));
        continue;
      }
      throw err;
    }
  }
  throw new Error('unreachable');
}

import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
