import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS, MAX_REPLY_DEPTH } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';
import { withIdempotency } from './idempotency';
import { hashPayload } from './utils';

export const createRootReply = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { postId, text } = request.data;

  if (!text || typeof text !== 'string' || text.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'text 不能为空');
  }
  if (!postId || typeof postId !== 'string') {
    throw new HttpsError('invalid-argument', 'postId 不能为空');
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const postSnap = await db.collection(COLLECTIONS.posts).doc(postId).get();
    if (!postSnap.exists || postSnap.get('status') !== 'active') {
      throw new HttpsError('not-found', '帖子不存在或已失效');
    }

    const replyRef = db.collection(COLLECTIONS.replies).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const replyData = {
      id: replyRef.id,
      post_id: postId,
      parent_reply_id: null,
      root_reply_id: null,
      depth: 0,
      author_provider_uid: uid,
      author_app_user_id: appUserId,
      text: text.trim(),
      is_tombstoned: false,
      verification: null,
      created_at: now,
    };

    await replyRef.set(replyData);

    return {
      id: replyRef.id,
      post_id: replyData.post_id,
      parent_reply_id: replyData.parent_reply_id,
      root_reply_id: replyData.root_reply_id,
      depth: replyData.depth,
      author_app_user_id: replyData.author_app_user_id,
      text: replyData.text,
      is_tombstoned: replyData.is_tombstoned,
      verification: replyData.verification,
      created_at: new Date().toISOString(),
    };
  });
});

export const createDiscussionReply = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { postId, rootReplyId, text } = request.data;

  if (!text || typeof text !== 'string' || text.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'text 不能为空');
  }
  if (!postId || typeof postId !== 'string') {
    throw new HttpsError('invalid-argument', 'postId 不能为空');
  }
  if (!rootReplyId || typeof rootReplyId !== 'string') {
    throw new HttpsError('invalid-argument', 'rootReplyId 不能为空');
  }

  if (MAX_REPLY_DEPTH <= 0) {
    throw new HttpsError('invalid-argument', `回复深度最大为 ${MAX_REPLY_DEPTH}`);
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const rootReplySnap = await db.collection(COLLECTIONS.replies).doc(rootReplyId).get();
    if (!rootReplySnap.exists) {
      throw new HttpsError('not-found', '根回复不存在');
    }
    const rootReplyData = rootReplySnap.data()!;
    if (rootReplyData.depth !== 0) {
      throw new HttpsError('invalid-argument', '目标回复不是根回复');
    }
    if (rootReplyData.post_id !== postId) {
      throw new HttpsError('invalid-argument', '回复不属于该帖子');
    }
    if (rootReplyData.is_tombstoned) {
      throw new HttpsError('failed-precondition', '根回复已被删除');
    }

    const replyRef = db.collection(COLLECTIONS.replies).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const replyData = {
      id: replyRef.id,
      post_id: postId,
      parent_reply_id: rootReplyId,
      root_reply_id: rootReplyId,
      depth: 1,
      author_provider_uid: uid,
      author_app_user_id: appUserId,
      text: text.trim(),
      is_tombstoned: false,
      verification: null,
      created_at: now,
    };

    await replyRef.set(replyData);

    return {
      id: replyRef.id,
      post_id: replyData.post_id,
      parent_reply_id: replyData.parent_reply_id,
      root_reply_id: replyData.root_reply_id,
      depth: replyData.depth,
      author_app_user_id: replyData.author_app_user_id,
      text: replyData.text,
      is_tombstoned: replyData.is_tombstoned,
      verification: replyData.verification,
      created_at: new Date().toISOString(),
    };
  });
});

export const deleteReply = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const { replyId } = request.data;

  if (!replyId || typeof replyId !== 'string') {
    throw new HttpsError('invalid-argument', 'replyId 不能为空');
  }

  const replyRef = db.collection(COLLECTIONS.replies).doc(replyId);
  const snap = await replyRef.get();

  if (!snap.exists) {
    throw new HttpsError('not-found', '回复不存在');
  }

  const replyData = snap.data()!;
  if (replyData.author_provider_uid !== uid) {
    throw new HttpsError('permission-denied', '只能删除自己的回复');
  }

  await replyRef.update({ is_tombstoned: true } as any);

  return { success: true };
});
