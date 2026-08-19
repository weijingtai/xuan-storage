import { db, COLLECTIONS } from './index';
import { hashPayload } from './utils';

export interface IdempotentCommand {
  operation: string;
  actorId: string;
  idempotencyKey: string | undefined;
  /** Business input only. `idempotency_key` is deliberately excluded. */
  payload: unknown;
}

export interface IdempotentCommandContext {
  commandId: string;
  /** One timestamp created before entering Firestore's retryable callback. */
  timestamp: Date;
  outboxId: string;
}

function canonicalize(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(canonicalize);
  if (value !== null && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value as Record<string, unknown>)
      .filter(([key]) => key !== 'idempotency_key')
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, child]) => [key, canonicalize(child)]));
  }
  return value;
}

/**
 * Atomically commits domain facts, deterministic outbox records, and the
 * completed receipt.  The callback is transaction-only: no Admin writes,
 * random IDs, network calls, or wall-clock reads are allowed inside it.
 */
export async function runIdempotentCommand<T>(
  command: IdempotentCommand,
  execute: (tx: admin.firestore.Transaction, context: IdempotentCommandContext) => Promise<T>,
): Promise<T> {
  if (!command.idempotencyKey || typeof command.idempotencyKey !== 'string') {
    throw new HttpsError('invalid-argument', 'idempotency_key 必填');
  }
  if (!command.operation || !command.actorId) {
    throw new HttpsError('invalid-argument', 'operation 和 actor 必填');
  }

  const payloadHash = hashPayload(canonicalize(command.payload));
  const commandId = hashPayload([command.operation, command.actorId, command.idempotencyKey]);
  const context: IdempotentCommandContext = {
    commandId,
    outboxId: `outbox_${commandId}`,
    timestamp: new Date(),
  };
  const receiptRef = db.collection(COLLECTIONS.idempotency).doc(commandId);

  return db.runTransaction(async (tx) => {
    const existing = await tx.get(receiptRef);
    if (existing.exists) {
      const receipt = existing.data()!;
      if (receipt.operation !== command.operation || receipt.actor_id !== command.actorId || receipt.payload_hash !== payloadHash) {
        throw new HttpsError('aborted', 'idempotency key conflict');
      }
      return receipt.result as T;
    }

    const result = await execute(tx, context);
    tx.set(receiptRef, {
      id: commandId,
      command_id: commandId,
      idempotency_key: command.idempotencyKey,
      operation: command.operation,
      actor_id: command.actorId,
      payload_hash: payloadHash,
      state: 'completed',
      result,
      created_at: context.timestamp,
      completed_at: context.timestamp,
    });
    return result;
  });
}

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
  const decision = await db.runTransaction(async (tx) => {
    const snap = await tx.get(idemDoc);

    if (snap.exists) {
      const data = snap.data()!;
      const expiresAt = data.expires_at?.toDate?.() ?? data.expires_at;

      if (expiresAt && new Date(expiresAt) < new Date()) {
        tx.delete(idemDoc);
      } else if (data.payload_hash === payloadHash) {
        if (data.result) {
          return { kind: 'replay' as const, result: data.result as T };
        }
        // A competing caller has committed its command claim but has not yet
        // published the result.  Do not run the command a second time.
        throw new HttpsError('unavailable', 'idempotency command is in progress');
      } else {
        // 冲突：同一 key 但不同 payload
        throw new HttpsError(
          'aborted',
          `idempotency key conflict: ${idempotencyKey}`,
        );
      }
    }

    const expiresAt = new Date(Date.now() + ttlMinutes * 60 * 1000);
    tx.set(idemDoc, {
      idempotency_key: idempotencyKey,
      payload_hash: payloadHash,
      state: 'running',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      expires_at: expiresAt,
    });

    return { kind: 'execute' as const, expiresAt };
  });

  if (decision.kind === 'replay') return decision.result;

  // Deliberately outside runTransaction: Firestore may retry the callback,
  // while this command body can perform ordinary Admin SDK writes/outbox work.
  // The committed claim above prevents a concurrent invocation from entering it.
  try {
    const result = await fn();
    await idemDoc.set({
      result,
      state: 'completed',
      completed_at: admin.firestore.FieldValue.serverTimestamp(),
      expires_at: decision.expiresAt,
    }, { merge: true });
    return result;
  } catch (error) {
    // A failed command must be retryable; only the claimant may remove this
    // record because another invocation observes `running` and never executes.
    await idemDoc.delete();
    throw error;
  }
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
