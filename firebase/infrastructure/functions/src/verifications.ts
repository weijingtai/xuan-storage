import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';
import { withIdempotency } from './idempotency';
import { hashPayload } from './utils';

export const verifyRootReply = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { postId, rootReplyId } = request.data;

  if (!postId || typeof postId !== 'string') {
    throw new HttpsError('invalid-argument', 'postId 不能为空');
  }
  if (!rootReplyId || typeof rootReplyId !== 'string') {
    throw new HttpsError('invalid-argument', 'rootReplyId 不能为空');
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const postSnap = await db.collection(COLLECTIONS.posts).doc(postId).get();
    if (!postSnap.exists || postSnap.get('status') !== 'active') {
      throw new HttpsError('not-found', '帖子不存在或已失效');
    }
    const postData = postSnap.data()!;

    if (postData.author_provider_uid !== uid) {
      throw new HttpsError('permission-denied', '只有帖子作者可以应验');
    }

    const replySnap = await db.collection(COLLECTIONS.replies).doc(rootReplyId).get();
    if (!replySnap.exists) {
      throw new HttpsError('not-found', '回复不存在');
    }
    const replyData = replySnap.data()!;

    if (replyData.author_provider_uid === uid) {
      throw new HttpsError('permission-denied', '不能应验自己的回复');
    }

    if (replyData.depth !== 0) {
      throw new HttpsError('invalid-argument', '只能应验根回复');
    }
    if (replyData.post_id !== postId) {
      throw new HttpsError('invalid-argument', '回复不属于该帖子');
    }

    const existingQuery = await db
      .collection(COLLECTIONS.verifications)
      .where('post_id', '==', postId)
      .where('root_reply_id', '==', rootReplyId)
      .where('revoked_at', '==', null)
      .get();

    if (!existingQuery.empty) {
      return {
        id: existingQuery.docs[0].id,
        post_id: postId,
        root_reply_id: rootReplyId,
        verifier_app_user_id: appUserId,
        created_at: existingQuery.docs[0].get('created_at')?.toDate?.()?.toISOString?.() ?? existingQuery.docs[0].get('created_at'),
        existing: true,
      };
    }

    const verificationRef = db.collection(COLLECTIONS.verifications).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const verificationData = {
      id: verificationRef.id,
      post_id: postId,
      root_reply_id: rootReplyId,
      verifier_provider_uid: uid,
      verifier_app_user_id: appUserId,
      revoked_at: null,
      created_at: now,
    };

    await verificationRef.set(verificationData);

    const outboxRef = db.collection(COLLECTIONS.outbox).doc();
    await outboxRef.set({
      id: outboxRef.id,
      event_type: 'reply_verified',
      post_id: postId,
      reply_id: rootReplyId,
      verifier_app_user_id: appUserId,
      created_at: now,
    });

    await db.collection(COLLECTIONS.replies).doc(rootReplyId).update({
      verification: {
        verifier_app_user_id: appUserId,
        verified_at: now,
      },
    } as any);

    return {
      id: verificationRef.id,
      post_id: postId,
      root_reply_id: rootReplyId,
      verifier_app_user_id: appUserId,
      created_at: new Date().toISOString(),
    };
  });
});

export const revokeVerification = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { postId, rootReplyId } = request.data;

  if (!postId || typeof postId !== 'string') {
    throw new HttpsError('invalid-argument', 'postId 不能为空');
  }
  if (!rootReplyId || typeof rootReplyId !== 'string') {
    throw new HttpsError('invalid-argument', 'rootReplyId 不能为空');
  }

  const verificationQuery = await db
    .collection(COLLECTIONS.verifications)
    .where('post_id', '==', postId)
    .where('root_reply_id', '==', rootReplyId)
    .where('verifier_app_user_id', '==', appUserId)
    .where('revoked_at', '==', null)
    .limit(1)
    .get();

  if (verificationQuery.empty) {
    throw new HttpsError('not-found', '没有有效的应验记录');
  }

  const verificationDoc = verificationQuery.docs[0];
  const now = admin.firestore.FieldValue.serverTimestamp();

  await verificationDoc.ref.update({ revoked_at: now } as any);

  await db.collection(COLLECTIONS.replies).doc(rootReplyId).update({
    verification: null,
  } as any);

  const outboxRef = db.collection(COLLECTIONS.outbox).doc();
  await outboxRef.set({
    id: outboxRef.id,
    event_type: 'verification_revoked',
    post_id: postId,
    reply_id: rootReplyId,
    verifier_app_user_id: appUserId,
    created_at: now,
  });

  return { success: true };
});
