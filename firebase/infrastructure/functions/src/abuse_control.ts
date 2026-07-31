import { HttpsError } from 'firebase-functions/v2/https';
import { db, COLLECTIONS } from './index';

interface RateLimitCheck {
  appUserId: string;
  action: string;
  maxPerMinute: number;
}

const DEFAULT_RATE_LIMIT = 30;

export async function checkRateLimit(params: RateLimitCheck): Promise<void> {
  const { appUserId, action, maxPerMinute = DEFAULT_RATE_LIMIT } = params;

  const windowStart = new Date(Date.now() - 60 * 1000);

  const countSnap = await db
    .collection(COLLECTIONS.idempotency)
    .where('app_user_id', '==', appUserId)
    .where('action', '==', action)
    .where('timestamp', '>=', windowStart)
    .get();

  if (countSnap.size >= maxPerMinute) {
    throw new HttpsError(
      'resource-exhausted',
      `操作频率超过限制 (${maxPerMinute}/分钟)`,
    );
  }
}

export async function recordAction(params: {
  appUserId: string;
  action: string;
  idempotencyKey: string;
}): Promise<void> {
  const { appUserId, action, idempotencyKey } = params;
  const docRef = db.collection(COLLECTIONS.idempotency).doc(`rate_${idempotencyKey}`);
  await docRef.set({
    app_user_id: appUserId,
    action,
    timestamp: new Date(),
    ttl: new Date(Date.now() + 10 * 60 * 1000),
  });
}
