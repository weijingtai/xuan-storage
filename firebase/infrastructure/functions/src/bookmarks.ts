import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';

export const setBookmark = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { postId, action } = request.data;

  if (!postId || typeof postId !== 'string') {
    throw new HttpsError('invalid-argument', 'postId 不能为空');
  }
  if (!action || !['bookmark', 'unbookmark'].includes(action)) {
    throw new HttpsError('invalid-argument', 'action 必须是 bookmark 或 unbookmark');
  }

  const postSnap = await db.collection(COLLECTIONS.posts).doc(postId).get();
  if (!postSnap.exists) {
    throw new HttpsError('not-found', '帖子不存在');
  }

  const bookmarkId = `bookmark_${uid}_${postId}`;
  const bookmarkRef = db.collection(COLLECTIONS.bookmarks).doc(bookmarkId);

  if (action === 'bookmark') {
    const now = admin.firestore.FieldValue.serverTimestamp();
    await bookmarkRef.set({
      id: bookmarkId,
      post_id: postId,
      user_provider_uid: uid,
      user_app_user_id: appUserId,
      created_at: now,
    });
    return { bookmarked: true, id: bookmarkId };
  } else {
    await bookmarkRef.delete();
    return { bookmarked: false, id: bookmarkId };
  }
});
