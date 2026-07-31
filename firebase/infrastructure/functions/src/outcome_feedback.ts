import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';
import { hashPayload } from './utils';

export const setOutcomeFeedback = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { postId, outcome_description } = request.data;

  if (!postId || typeof postId !== 'string') {
    throw new HttpsError('invalid-argument', 'postId 不能为空');
  }
  if (!outcome_description || typeof outcome_description !== 'string' || outcome_description.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'outcome_description 不能为空');
  }

  const postSnap = await db.collection(COLLECTIONS.posts).doc(postId).get();
  if (!postSnap.exists || postSnap.get('status') !== 'active') {
    throw new HttpsError('not-found', '帖子不存在或已失效');
  }
  const postData = postSnap.data()!;
  if (postData.author_provider_uid !== uid) {
    throw new HttpsError('permission-denied', '只有帖子作者可以设置最终反馈');
  }

  const existingQuery = await db
    .collection(COLLECTIONS.outcomeFeedback)
    .where('post_id', '==', postId)
    .where('deleted_at', '==', null)
    .get();

  if (!existingQuery.empty) {
    throw new HttpsError('already-exists', '已有有效的最终反馈');
  }

  const feedbackRef = db.collection(COLLECTIONS.outcomeFeedback).doc();
  const now = admin.firestore.FieldValue.serverTimestamp();

  const feedbackData = {
    id: feedbackRef.id,
    post_id: postId,
    author_provider_uid: uid,
    author_app_user_id: appUserId,
    outcome_description: outcome_description.trim(),
    deleted_at: null,
    created_at: now,
  };

  await feedbackRef.set(feedbackData);
  await db.collection(COLLECTIONS.posts).doc(postId).update({
    has_outcome_feedback: true,
  } as any);

  return {
    id: feedbackRef.id,
    post_id: postId,
    author_app_user_id: appUserId,
    outcome_description: feedbackData.outcome_description,
    created_at: new Date().toISOString(),
  };
});

export const revokeOutcomeFeedback = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { postId } = request.data;

  if (!postId || typeof postId !== 'string') {
    throw new HttpsError('invalid-argument', 'postId 不能为空');
  }

  const feedbackQuery = await db
    .collection(COLLECTIONS.outcomeFeedback)
    .where('post_id', '==', postId)
    .where('author_app_user_id', '==', appUserId)
    .where('deleted_at', '==', null)
    .limit(1)
    .get();

  if (feedbackQuery.empty) {
    throw new HttpsError('not-found', '没有有效的最终反馈');
  }

  const now = admin.firestore.FieldValue.serverTimestamp();

  await feedbackQuery.docs[0].ref.update({ deleted_at: now } as any);
  await db.collection(COLLECTIONS.posts).doc(postId).update({
    has_outcome_feedback: false,
  } as any);

  return { success: true };
});
