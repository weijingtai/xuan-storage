import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';
import { withIdempotency } from './idempotency';
import { hashPayload } from './utils';

export const createPost = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { text, allowed_chart_technique_ids, attachments } = request.data;

  if (!text || typeof text !== 'string' || text.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'text 不能为空');
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const postRef = db.collection(COLLECTIONS.posts).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const postData = {
      id: postRef.id,
      text: text.trim(),
      author_provider_uid: uid,
      author_app_user_id: appUserId,
      status: 'active',
      allowed_chart_technique_ids: allowed_chart_technique_ids ?? [],
      attachments: attachments ?? [],
      revisions: [],
      has_outcome_feedback: false,
      created_at: now,
    };

    await postRef.set(postData);

    return {
      id: postRef.id,
      text: postData.text,
      author_app_user_id: postData.author_app_user_id,
      status: postData.status,
      allowed_chart_technique_ids: postData.allowed_chart_technique_ids,
      attachments: postData.attachments,
      revisions: postData.revisions,
      created_at: new Date().toISOString(),
    };
  });
});
