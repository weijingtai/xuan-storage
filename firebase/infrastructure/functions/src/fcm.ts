import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';

export const registerFcmToken = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { token, platform } = request.data;

  if (!token || typeof token !== 'string') {
    throw new HttpsError('invalid-argument', 'token 不能为空');
  }

  const tokenId = `fcm_${uid}_${token}`;
  const now = admin.firestore.FieldValue.serverTimestamp();

  await db.collection(COLLECTIONS.fcmTokens).doc(tokenId).set({
    id: tokenId,
    provider_uid: uid,
    app_user_id: appUserId,
    token,
    platform: platform ?? 'unknown',
    registered_at: now,
    last_used_at: now,
  });

  return { success: true, token_id: tokenId };
});

export const unregisterFcmToken = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const { token } = request.data;

  if (!token || typeof token !== 'string') {
    throw new HttpsError('invalid-argument', 'token 不能为空');
  }

  const tokenId = `fcm_${uid}_${token}`;
  await db.collection(COLLECTIONS.fcmTokens).doc(tokenId).delete();

  return { success: true };
});
