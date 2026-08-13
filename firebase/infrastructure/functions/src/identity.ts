import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';
import { db, COLLECTIONS } from './index';

/**
 * 生成随机 128-bit public_presentation_id（hex）。
 */
function generatePresentationId(): string {
  return crypto.randomBytes(16).toString('hex');
}

/**
 * 生成公开显示别名，默认格式 "玄友XXXX"。
 */
function generateDisplayAlias(): string {
  const suffix = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
  return `玄友${suffix}`;
}

/**
 * 从 Firebase Auth context 解析 appUserId。
 *
 * 流程：
 * 1. 取 auth.uid (providerUserId)
 * 2. 查 identity_map/{providerUserId} → appUserId
 * 3. 不存在则原子创建（含 public_presentation_id、public_display_alias）
 *
 * @param uid - Firebase Auth UID
 * @returns { appUserId, publicPresentationId, publicDisplayAlias }
 * @throws HttpsError('unauthenticated') 若 uid 为空
 */
export async function resolveAppUserId(uid: string | undefined): Promise<{
  appUserId: string;
  publicPresentationId: string;
  publicDisplayAlias: string;
}> {
  if (!uid) {
    throw new HttpsError('unauthenticated', '未登录');
  }

  const idMapDoc = db.collection(COLLECTIONS.identityMap).doc(uid);

  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(idMapDoc);
    if (snap.exists) {
      const data = snap.data();
      if (data) {
        const appUserId = (data.app_user_id || data.appUserId) as string;
        const publicPresentationId = (data.public_presentation_id || data.publicPresentationId) as string;
        const publicDisplayAlias = (data.public_display_alias || data.publicDisplayAlias) as string;
        return {
          appUserId: appUserId ?? '',
          publicPresentationId: publicPresentationId ?? '',
          publicDisplayAlias: publicDisplayAlias ?? '',
        };
      }
    }

    // 不存在则原子创建
    const newAppUserId = `app-${Date.now().toString(36)}-${Math.floor(Math.random() * 0x7fffffff).toString(36)}`;
    const newPresentationId = generatePresentationId();
    const newDisplayAlias = generateDisplayAlias();

    tx.set(idMapDoc, {
      app_user_id: newAppUserId,
      provider_uid: uid,
      provider_id: 'firebase',
      public_presentation_id: newPresentationId,
      public_display_alias: newDisplayAlias,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {
      appUserId: newAppUserId,
      publicPresentationId: newPresentationId,
      publicDisplayAlias: newDisplayAlias,
    };
  });

  return result;
}

/**
 * 获取当前认证用户的 provider UID，若未登录则抛出。
 */
export function requireAuthUid(uid: string | undefined): string {
  if (!uid) {
    throw new HttpsError('unauthenticated', '未登录');
  }
  return uid;
}

/**
 * resolveMyIdentity：基于 Firebase Auth context 返回当前用户的身份信息。
 *
 * 返回 { appUserId, publicPresentationId, publicDisplayAlias }，
 * 不接受任何客户端身份值。
 */
export const resolveMyIdentity = onCall(
  { region: 'asia-east1' },
  async (request) => {
    const uid = requireAuthUid(request.auth?.uid);
    const identity = await resolveAppUserId(uid);
    return {
      appUserId: identity.appUserId,
      publicPresentationId: identity.publicPresentationId,
      publicDisplayAlias: identity.publicDisplayAlias,
    };
  },
);
