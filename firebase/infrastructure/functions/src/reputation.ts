import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { db, COLLECTIONS } from './index';
import { requireAuthUid } from './identity';

export const recalculateReputation = onCall({ region: 'asia-east1' }, async (request) => {
  requireAuthUid(request.auth?.uid);
  const { appUserId } = request.data;

  if (!appUserId || typeof appUserId !== 'string') {
    throw new HttpsError('invalid-argument', 'appUserId 不能为空');
  }

  const likesSnap = await db
    .collection(COLLECTIONS.likes)
    .where('user_app_user_id', '==', appUserId)
    .get();

  const likeCount = likesSnap.size;

  const verificationsSnap = await db
    .collection(COLLECTIONS.verifications)
    .where('verifier_app_user_id', '==', appUserId)
    .where('revoked_at', '==', null)
    .get();

  const verificationCount = verificationsSnap.size;

  const profileRef = db.collection(COLLECTIONS.profiles).doc(appUserId);
  const snap = await profileRef.get();

  if (snap.exists) {
    await profileRef.update({
      playground_like_count: likeCount,
      playground_verification_count: verificationCount,
    } as any);
  } else {
    await profileRef.set({
      app_user_id: appUserId,
      playground_like_count: likeCount,
      playground_verification_count: verificationCount,
    });
  }

  return {
    app_user_id: appUserId,
    playground_like_count: likeCount,
    playground_verification_count: verificationCount,
  };
});
