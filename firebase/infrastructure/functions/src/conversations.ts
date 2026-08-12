import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';
import { resolveAppUserId, requireAuthUid } from './identity';
import { withIdempotency } from './idempotency';
import { hashPayload, nowISO } from './utils';

export const sendDmRequest = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { targetAppUserId, initialMessage } = request.data;

  if (!targetAppUserId || typeof targetAppUserId !== 'string') {
    throw new HttpsError('invalid-argument', 'targetAppUserId 不能为空');
  }
  if (!initialMessage || typeof initialMessage !== 'string' || initialMessage.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'initialMessage 不能为空');
  }
  if (targetAppUserId === appUserId) {
    throw new HttpsError('invalid-argument', '不能给自己发私聊申请');
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const existingQuery = await db
      .collection(COLLECTIONS.conversations)
      .where('participants', 'array-contains', appUserId)
      .get();

    const hasExisting = existingQuery.docs.some((doc) => {
      const p = doc.get('participants') as string[];
      return p.includes(targetAppUserId);
    });

    if (hasExisting) {
      throw new HttpsError('already-exists', '对话已存在');
    }

    const convRef = db.collection(COLLECTIONS.conversations).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    await convRef.set({
      id: convRef.id,
      participants: [appUserId, targetAppUserId],
      status: 'pending',
      initiated_by: appUserId,
      created_at: now,
    });

    const msgRef = db.collection(COLLECTIONS.messages).doc();
    await msgRef.set({
      id: msgRef.id,
      conversation_id: convRef.id,
      sender_app_user_id: appUserId,
      text: initialMessage.trim(),
      type: 'dm_request',
      created_at: now,
    });

    return {
      conversation_id: convRef.id,
      status: 'pending',
      participants: [appUserId, targetAppUserId],
      initiated_by: appUserId,
      created_at: nowISO(),
    };
  });
});

export const respondDmRequest = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { conversationId, accept } = request.data;

  if (!conversationId || typeof conversationId !== 'string') {
    throw new HttpsError('invalid-argument', 'conversationId 不能为空');
  }
  if (typeof accept !== 'boolean') {
    throw new HttpsError('invalid-argument', 'accept 必须是布尔值');
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const convSnap = await db.collection(COLLECTIONS.conversations).doc(conversationId).get();
    if (!convSnap.exists) {
      throw new HttpsError('not-found', '对话不存在');
    }

    const convData = convSnap.data()!;
    if (!convData.participants.includes(appUserId)) {
      throw new HttpsError('permission-denied', '不是对话参与者');
    }
    if (convData.initiated_by === appUserId) {
      throw new HttpsError('permission-denied', '不能响应自己发起的请求');
    }

    if (accept) {
      await convSnap.ref.update({ status: 'active' } as any);

      const outboxRef = db.collection(COLLECTIONS.outbox).doc();
      await outboxRef.set({
        id: outboxRef.id,
        event_type: 'dm_accepted',
        conversation_id: conversationId,
        user_app_user_id: appUserId,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      await convSnap.ref.update({ status: 'declined' } as any);
    }

    return {
      success: true,
      conversation_id: conversationId,
      status: accept ? 'active' : 'declined',
      participants: convData.participants,
      initiated_by: convData.initiated_by,
      created_at: nowISO(),
    };
  });
});

export const sendMessage = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { conversationId, text } = request.data;

  if (!conversationId || typeof conversationId !== 'string') {
    throw new HttpsError('invalid-argument', 'conversationId 不能为空');
  }
  if (!text || typeof text !== 'string' || text.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'text 不能为空');
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const convSnap = await db.collection(COLLECTIONS.conversations).doc(conversationId).get();
    if (!convSnap.exists) {
      throw new HttpsError('not-found', '对话不存在');
    }
    const convData = convSnap.data()!;
    if (convData.status !== 'active') {
      throw new HttpsError('failed-precondition', '对话未激活');
    }
    if (!convData.participants.includes(appUserId)) {
      throw new HttpsError('permission-denied', '不是对话参与者');
    }

    const otherParticipant = convData.participants.find((p: string) => p !== appUserId);

    const blockQuery = await db
      .collection(COLLECTIONS.blocks)
      .where('blocker_app_user_id', '==', otherParticipant)
      .where('blocked_app_user_id', '==', appUserId)
      .get();

    if (!blockQuery.empty) {
      throw new HttpsError('permission-denied', '对方已将你拉黑');
    }

    const msgRef = db.collection(COLLECTIONS.messages).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    await msgRef.set({
      id: msgRef.id,
      conversation_id: conversationId,
      sender_app_user_id: appUserId,
      text: text.trim(),
      type: 'message',
      created_at: now,
    });

    const outboxRef = db.collection(COLLECTIONS.outbox).doc();
    await outboxRef.set({
      id: outboxRef.id,
      event_type: 'dm_message',
      conversation_id: conversationId,
      sender_app_user_id: appUserId,
      recipient_app_user_id: otherParticipant,
      message_id: msgRef.id,
      created_at: now,
    });

    return {
      message_id: msgRef.id,
      conversation_id: conversationId,
      sender_app_user_id: appUserId,
      text: text.trim(),
      created_at: nowISO(),
    };
  });
});

export const blockUser = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { targetAppUserId } = request.data;

  if (!targetAppUserId || typeof targetAppUserId !== 'string') {
    throw new HttpsError('invalid-argument', 'targetAppUserId 不能为空');
  }
  if (targetAppUserId === appUserId) {
    throw new HttpsError('invalid-argument', '不能拉黑自己');
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const existingQuery = await db
      .collection(COLLECTIONS.blocks)
      .where('blocker_app_user_id', '==', appUserId)
      .where('blocked_app_user_id', '==', targetAppUserId)
      .get();

    if (!existingQuery.empty) {
      return { blocked: true, already_blocked: true };
    }

    const blockRef = db.collection(COLLECTIONS.blocks).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    await blockRef.set({
      id: blockRef.id,
      blocker_app_user_id: appUserId,
      blocked_app_user_id: targetAppUserId,
      created_at: now,
    });

    return { blocked: true };
  });
});

export const unblockUser = onCall({ region: 'asia-east1' }, async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const appUserId = await resolveAppUserId(uid);
  const { targetAppUserId } = request.data;

  if (!targetAppUserId || typeof targetAppUserId !== 'string') {
    throw new HttpsError('invalid-argument', 'targetAppUserId 不能为空');
  }

  const payloadHash = hashPayload(request.data);

  return withIdempotency(request.data.idempotency_key, payloadHash, async () => {
    const blockQuery = await db
      .collection(COLLECTIONS.blocks)
      .where('blocker_app_user_id', '==', appUserId)
      .where('blocked_app_user_id', '==', targetAppUserId)
      .get();

    for (const doc of blockQuery.docs) {
      await doc.ref.delete();
    }

    return { unblocked: true, removed: blockQuery.size };
  });
});
