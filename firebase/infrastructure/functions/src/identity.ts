import { HttpsError } from 'firebase-functions/v2/https';
import { db, COLLECTIONS } from './index';

/**
 * 从 Firebase Auth context 解析 appUserId。
 *
 * 流程：
 * 1. 取 auth.uid (providerUserId)
 * 2. 查 identity_map/{providerUserId} → appUserId
 * 3. 不存在则原子创建
 *
 * @param uid - Firebase Auth UID
 * @returns appUserId 字符串
 * @throws HttpsError('unauthenticated') 若 uid 为空
 */
export async function resolveAppUserId(uid: string | undefined): Promise<string> {
  if (!uid) {
    throw new HttpsError('unauthenticated', '未登录');
  }

  const idMapDoc = db.collection(COLLECTIONS.identityMap).doc(uid);

  const appUserId = await db.runTransaction(async (tx) => {
    const snap = await tx.get(idMapDoc);
    if (snap.exists) {
      return snap.get('app_user_id') as string;
    }
    const newAppUserId = `app-${Date.now().toString(36)}-${Math.floor(Math.random() * 0x7fffffff).toString(36)}`;
    tx.set(idMapDoc, {
      app_user_id: newAppUserId,
      provider_uid: uid,
      provider_id: 'firebase',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    return newAppUserId;
  });

  return appUserId;
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

import * as admin from 'firebase-admin';
