import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';
import { withIdempotency } from './idempotency';
import { hashPayload } from './utils';

export const setLike = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { postId, replyId, action } = request.data;

  if (!postId && !replyId) {
    throw new HttpsError('invalid-argument', 'postId 或 replyId 必须提供一个');
  }
  if (!action || !['like', 'unlike'].includes(action)) {
    throw new HttpsError('invalid-argument', 'action 必须是 like 或 unlike');
  }

  if (postId && typeof postId !== 'string') {
    throw new HttpsError('invalid-argument', 'postId 格式无效');
  }
  if (replyId && typeof replyId !== 'string') {
    throw new HttpsError('invalid-argument', 'replyId 格式无效');
  }

  if (postId) {
    const postSnap = await db.collection(COLLECTIONS.posts).doc(postId).get();
    if (!postSnap.exists) {
      throw new HttpsError('not-found', '帖子不存在');
    }
  }
  if (replyId) {
    const replySnap = await db.collection(COLLECTIONS.replies).doc(replyId).get();
    if (!replySnap.exists) {
      throw new HttpsError('not-found', '回复不存在');
    }
  }

  const likeId = postId
    ? `like_post_${uid}_${postId}`
    : `like_reply_${uid}_${replyId}`;

  const likeRef = db.collection(COLLECTIONS.likes).doc(likeId);

  if (action === 'like') {
    const now = admin.firestore.FieldValue.serverTimestamp();
    const likeData: Record<string, any> = {
      id: likeId,
      user_provider_uid: uid,
      user_app_user_id: appUserId,
      created_at: now,
    };
    if (postId) likeData.post_id = postId;
    if (replyId) likeData.reply_id = replyId;

    await likeRef.set(likeData);

    const outboxRef = db.collection(COLLECTIONS.outbox).doc();
    await outboxRef.set({
      id: outboxRef.id,
      event_type: 'like_added',
      post_id: postId ?? null,
      reply_id: replyId ?? null,
      user_app_user_id: appUserId,
      created_at: now,
    });

    return { liked: true, id: likeId, target_type: postId ? 'post' : 'reply' };
  } else {
    const snap = await likeRef.get();
    if (snap.exists) {
      await likeRef.delete();

      const now = admin.firestore.FieldValue.serverTimestamp();
      const outboxRef = db.collection(COLLECTIONS.outbox).doc();
      await outboxRef.set({
        id: outboxRef.id,
        event_type: 'like_removed',
        post_id: postId ?? null,
        reply_id: replyId ?? null,
        user_app_user_id: appUserId,
        created_at: now,
      });
    }

    return { liked: false, id: likeId, target_type: postId ? 'post' : 'reply' };
  }
});
