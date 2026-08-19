import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';
import { withIdempotency } from './idempotency';
import { hashPayload } from './utils';

export const createPost = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const { appUserId } = await resolveAppUserId(uid);
  const { text, allowed_chart_technique_ids, attachments, presentation_mode } = request.data;

  if (!text || typeof text !== 'string' || text.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'text 不能为空');
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const postRef = db.collection(COLLECTIONS.posts).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const mode = presentation_mode === 'oneTimeAnonymous'
      ? 'oneTimeAnonymous'
      : 'stableAlias';
    const postData = {
      id: postRef.id,
      text: text.trim(),
      author_provider_uid: uid,
      author_app_user_id: appUserId,
      presentation_mode: mode,
      presentation_identity_id: mode === 'oneTimeAnonymous'
        ? `post_${postRef.id}`
        : `user_${appUserId}`,
      status: 'active',
      allowed_chart_technique_ids: allowed_chart_technique_ids ?? [],
      attachments: attachments ?? [],
      revisions: [],
      has_outcome_feedback: false,
      idempotency_key: request.data.idempotency_key ?? null,
      created_at: now,
      updated_at: now,
    };

    const profileRef = db.collection(COLLECTIONS.profiles).doc(appUserId);
    await Promise.all([
      postRef.set(postData),
      profileRef.set({
        user_provider_uid: uid,
        public_post_count: admin.firestore.FieldValue.increment(
          mode === 'stableAlias' ? 1 : 0,
        ),
        public_reply_count: admin.firestore.FieldValue.increment(0),
        updated_at: now,
      }, { merge: true }),
    ]);

    return {
      id: postRef.id,
      text: postData.text,
      author_app_user_id: postData.author_app_user_id,
      presentation_mode: postData.presentation_mode,
      presentation_identity_id: postData.presentation_identity_id,
      status: postData.status,
      allowed_chart_technique_ids: postData.allowed_chart_technique_ids,
      attachments: postData.attachments,
      revisions: postData.revisions,
      created_at: new Date().toISOString(),
    };
  });
});

export const editPost = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const { postId, text, allowed_chart_technique_ids, attachments } = request.data;
  if (!postId || typeof postId !== 'string' || !text || typeof text !== 'string' || !text.trim()) {
    throw new HttpsError('invalid-argument', 'postId 和 text 必填');
  }
  const ref = db.collection(COLLECTIONS.posts).doc(postId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', '帖子不存在');
  if (snap.get('author_provider_uid') !== uid) throw new HttpsError('permission-denied', '只能编辑自己的帖子');
  if (snap.get('status') !== 'active') throw new HttpsError('failed-precondition', '帖子已删除');
  const update: Record<string, unknown> = { text: text.trim(), updated_at: admin.firestore.FieldValue.serverTimestamp() };
  if (Array.isArray(allowed_chart_technique_ids)) update.allowed_chart_technique_ids = allowed_chart_technique_ids;
  if (Array.isArray(attachments)) update.attachments = attachments;
  await ref.update(update);
  return { id: postId, ...snap.data(), ...update };
});

export const tombstonePost = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const { postId } = request.data;
  if (!postId || typeof postId !== 'string') throw new HttpsError('invalid-argument', 'postId 必填');
  const ref = db.collection(COLLECTIONS.posts).doc(postId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', '帖子不存在');
  if (snap.get('author_provider_uid') !== uid) throw new HttpsError('permission-denied', '只能删除自己的帖子');
  await ref.update({ status: 'tombstoned', updated_at: admin.firestore.FieldValue.serverTimestamp() });
  return { success: true };
});
