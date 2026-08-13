import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS, MAX_REPLY_DEPTH } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';
import { withIdempotency } from './idempotency';
import { hashPayload } from './utils';

export const createRootReply = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const { appUserId } = await resolveAppUserId(uid);
  const { postId, body } = request.data;

  if (!body || typeof body !== 'string' || body.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'body 不能为空');
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
      root_reply_id: null,
      reply_to_reply_id: null,
      depth: 0,
      author_provider_uid: uid,
      author_app_user_id: appUserId,
      body: body.trim(),
      is_tombstoned: false,
      verification: null,
      created_at: now,
      updated_at: now,
      technique_tags: request.data.techniqueTags ?? [],
      chart_attachment: request.data.chartAttachment ?? null,
      media_attachments: request.data.mediaAttachments ?? [],
      presentation_identity_id: `user_${appUserId}`,
      revisions: [],
      idempotency_key: request.data.idempotency_key ?? null,
    };

    await replyRef.set(replyData);

    return {
      id: replyRef.id,
      post_id: replyData.post_id,
      root_reply_id: replyData.root_reply_id,
      reply_to_reply_id: replyData.reply_to_reply_id,
      depth: replyData.depth,
      author_app_user_id: replyData.author_app_user_id,
      body: replyData.body,
      is_tombstoned: replyData.is_tombstoned,
      verification: replyData.verification,
      created_at: new Date().toISOString(),
    };
  });
});

export const createDiscussionReply = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const { appUserId } = await resolveAppUserId(uid);
  const { postId, rootReplyId, replyToReplyId, body } = request.data;

  if (!body || typeof body !== 'string' || body.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'body 不能为空');
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
    if (replyToReplyId != null) {
      if (typeof replyToReplyId !== 'string') throw new HttpsError('invalid-argument', 'replyToReplyId 必须为字符串');
      const target = await db.collection(COLLECTIONS.replies).doc(replyToReplyId).get();
      if (!target.exists || target.get('post_id') !== postId || target.get('root_reply_id') !== rootReplyId && replyToReplyId !== rootReplyId) {
        throw new HttpsError('invalid-argument', '被回复对象不属于该讨论树');
      }
    }

    const replyRef = db.collection(COLLECTIONS.replies).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const replyData = {
      id: replyRef.id,
      post_id: postId,
      root_reply_id: rootReplyId,
      reply_to_reply_id: replyToReplyId ?? rootReplyId,
      depth: 1,
      author_provider_uid: uid,
      author_app_user_id: appUserId,
      body: body.trim(),
      is_tombstoned: false,
      verification: null,
      created_at: now,
      updated_at: now,
      technique_tags: [],
      chart_attachment: null,
      media_attachments: request.data.mediaAttachments ?? [],
      presentation_identity_id: `user_${appUserId}`,
      revisions: [],
      idempotency_key: request.data.idempotency_key ?? null,
    };

    await replyRef.set(replyData);

    return {
      id: replyRef.id,
      post_id: replyData.post_id,
      root_reply_id: replyData.root_reply_id,
      reply_to_reply_id: replyData.reply_to_reply_id,
      depth: replyData.depth,
      author_app_user_id: replyData.author_app_user_id,
      body: replyData.body,
      is_tombstoned: replyData.is_tombstoned,
      verification: replyData.verification,
      created_at: new Date().toISOString(),
    };
  });
});

export const editReply = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const { replyId, body, techniqueTags, chartAttachment, mediaAttachments } = request.data;
  if (!replyId || typeof replyId !== 'string' || !body || typeof body !== 'string' || !body.trim()) throw new HttpsError('invalid-argument', 'replyId 和 body 必填');
  const ref = db.collection(COLLECTIONS.replies).doc(replyId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', '回复不存在');
  if (snap.get('author_provider_uid') !== uid) throw new HttpsError('permission-denied', '只能编辑自己的回复');
  if (snap.get('is_tombstoned') === true) throw new HttpsError('failed-precondition', '回复已删除');
  const update: Record<string, unknown> = { body: body.trim(), updated_at: admin.firestore.FieldValue.serverTimestamp() };
  if (Array.isArray(techniqueTags)) update.technique_tags = techniqueTags;
  if (chartAttachment !== undefined) update.chart_attachment = chartAttachment;
  if (Array.isArray(mediaAttachments)) update.media_attachments = mediaAttachments;
  await ref.update(update);
  return { id: replyId, ...snap.data(), ...update };
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

  await replyRef.update({ is_tombstoned: true, updated_at: admin.firestore.FieldValue.serverTimestamp() } as any);

  return { success: true };
});
