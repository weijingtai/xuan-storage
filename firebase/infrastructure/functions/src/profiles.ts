import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { COLLECTIONS, db } from './index';
import { requireAuthUid, resolveAppUserId } from './identity';
import { hashPayload } from './utils';
import { withIdempotency } from './idempotency';

/// Updates only the authenticated actor's profile.  The profile document ID and
/// provider UID are server-derived; neither can be selected by the caller.
export const updateMyProfile = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const { appUserId } = await resolveAppUserId(uid);
  const input = request.data ?? {};
  const update: Record<string, unknown> = { updated_at: admin.firestore.FieldValue.serverTimestamp() };
  if (input.displayName !== undefined) {
    if (typeof input.displayName !== 'string') throw new HttpsError('invalid-argument', 'displayName 必须为字符串');
    update.display_name = input.displayName;
  }
  if (input.avatarUrl !== undefined) {
    if (typeof input.avatarUrl !== 'string') throw new HttpsError('invalid-argument', 'avatarUrl 必须为字符串');
    update.avatar_url = input.avatarUrl;
  }
  if (input.bio !== undefined) {
    if (typeof input.bio !== 'string') throw new HttpsError('invalid-argument', 'bio 必须为字符串');
    update.bio = input.bio;
  }
  if (input.commonTechniques !== undefined) {
    if (!Array.isArray(input.commonTechniques) || input.commonTechniques.some((x: unknown) => typeof x !== 'string')) {
      throw new HttpsError('invalid-argument', 'commonTechniques 必须为字符串数组');
    }
    update.common_techniques = input.commonTechniques;
  }
  if (Object.keys(update).length === 1) throw new HttpsError('invalid-argument', '至少更新一个资料字段');

  return withIdempotency(input.idempotency_key, hashPayload(input), async () => {
    await db.collection(COLLECTIONS.profiles).doc(appUserId).set({
      ...update,
      user_provider_uid: uid,
    }, { merge: true });
    return { appUserId, success: true };
  });
});
