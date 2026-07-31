import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';

export const reportContent = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { postId, replyId, reportedUserId, reason, description } = request.data;

  if (!postId && !replyId) {
    throw new HttpsError('invalid-argument', 'postId 或 replyId 必须提供一个');
  }
  if (!reportedUserId || typeof reportedUserId !== 'string') {
    throw new HttpsError('invalid-argument', 'reportedUserId 不能为空');
  }
  if (!reason || typeof reason !== 'string') {
    throw new HttpsError('invalid-argument', 'reason 不能为空');
  }

  const reportRef = db.collection(COLLECTIONS.reports).doc();
  const now = admin.firestore.FieldValue.serverTimestamp();

  await reportRef.set({
    id: reportRef.id,
    post_id: postId ?? null,
    reply_id: replyId ?? null,
    reporter_provider_uid: uid,
    reporter_app_user_id: appUserId,
    reported_user_id: reportedUserId,
    reason,
    description: description ?? null,
    status: 'pending',
    created_at: now,
  });

  return {
    id: reportRef.id,
    status: 'pending',
    created_at: new Date().toISOString(),
  };
});
