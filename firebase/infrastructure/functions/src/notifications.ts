import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { db, COLLECTIONS } from './index';

export const onOutboxCreated = onDocumentCreated(
  { document: `${COLLECTIONS.outbox}/{docId}`, region: 'asia-east1' },
  async (event) => {
    const outboxData = event.data?.data();
    if (!outboxData) return;

    const eventType = outboxData.event_type as string;
    const notificationEventId = event.params.docId;

    switch (eventType) {
      case 'reply_verified': {
        const postId = outboxData.post_id as string;
        const replyId = outboxData.reply_id as string;
        const verifierAppUserId = outboxData.verifier_app_user_id as string;

        const replySnap = await db.collection(COLLECTIONS.replies).doc(replyId).get();
        if (!replySnap.exists) return;
        const replyData = replySnap.data()!;
        const recipientAppUserId = replyData.author_app_user_id as string;

        const existingQuery = await db
          .collection(COLLECTIONS.notifications)
          .where('notification_event_id', '==', notificationEventId)
          .get();

        if (!existingQuery.empty) return;

        const notifRef = db.collection(COLLECTIONS.notifications).doc();
        const now = admin.firestore.FieldValue.serverTimestamp();

        await notifRef.set({
          id: notifRef.id,
          notification_event_id: notificationEventId,
          recipient_app_user_id: recipientAppUserId,
          type: 'reply_verified',
          post_id: postId,
          reply_id: replyId,
          actor_app_user_id: verifierAppUserId,
          is_read: false,
          created_at: now,
        });

        await sendPushNotification(recipientAppUserId, {
          title: '你的回复被应验了',
          body: '有人应验了你的占卜回复',
          data: { type: 'reply_verified', post_id: postId, reply_id: replyId },
        });
        break;
      }

      case 'verification_revoked': {
        const postId = outboxData.post_id as string;
        const replyId = outboxData.reply_id as string;
        const verifierAppUserId = outboxData.verifier_app_user_id as string;

        const replySnap = await db.collection(COLLECTIONS.replies).doc(replyId).get();
        if (!replySnap.exists) return;
        const replyData = replySnap.data()!;
        const recipientAppUserId = replyData.author_app_user_id as string;

        const existingQuery = await db
          .collection(COLLECTIONS.notifications)
          .where('notification_event_id', '==', notificationEventId)
          .get();

        if (!existingQuery.empty) return;

        const notifRef = db.collection(COLLECTIONS.notifications).doc();
        const now = admin.firestore.FieldValue.serverTimestamp();

        await notifRef.set({
          id: notifRef.id,
          notification_event_id: notificationEventId,
          recipient_app_user_id: recipientAppUserId,
          type: 'verification_revoked',
          post_id: postId,
          reply_id: replyId,
          actor_app_user_id: verifierAppUserId,
          is_read: false,
          created_at: now,
        });
        break;
      }

      case 'like_added': {
        const postId = outboxData.post_id as string | null;
        const replyId = outboxData.reply_id as string | null;
        const likerAppUserId = outboxData.user_app_user_id as string;

        let recipientAppUserId: string | null = null;

        if (postId) {
          const postSnap = await db.collection(COLLECTIONS.posts).doc(postId).get();
          if (postSnap.exists) {
            recipientAppUserId = postSnap.get('author_app_user_id') as string;
          }
        } else if (replyId) {
          const replySnap = await db.collection(COLLECTIONS.replies).doc(replyId).get();
          if (replySnap.exists) {
            recipientAppUserId = replySnap.get('author_app_user_id') as string;
          }
        }

        if (!recipientAppUserId || recipientAppUserId === likerAppUserId) return;

        const existingQuery = await db
          .collection(COLLECTIONS.notifications)
          .where('notification_event_id', '==', notificationEventId)
          .get();

        if (!existingQuery.empty) return;

        const notifRef = db.collection(COLLECTIONS.notifications).doc();
        const now = admin.firestore.FieldValue.serverTimestamp();

        await notifRef.set({
          id: notifRef.id,
          notification_event_id: notificationEventId,
          recipient_app_user_id: recipientAppUserId,
          type: 'like_added',
          post_id: postId ?? null,
          reply_id: replyId ?? null,
          actor_app_user_id: likerAppUserId,
          is_read: false,
          created_at: now,
        });

        await sendPushNotification(recipientAppUserId, {
          title: '有人赞了你',
          body: postId ? '有人赞了你的帖子' : '有人赞了你的回复',
          data: { type: 'like_added', post_id: postId ?? '', reply_id: replyId ?? '' },
        });
        break;
      }

      case 'dm_message': {
        const conversationId = outboxData.conversation_id as string;
        const senderAppUserId = outboxData.sender_app_user_id as string;
        const recipientAppUserId = outboxData.recipient_app_user_id as string;
        const messageId = outboxData.message_id as string;

        if (!recipientAppUserId) return;

        const existingQuery = await db
          .collection(COLLECTIONS.notifications)
          .where('notification_event_id', '==', notificationEventId)
          .get();

        if (!existingQuery.empty) return;

        const notifRef = db.collection(COLLECTIONS.notifications).doc();
        const now = admin.firestore.FieldValue.serverTimestamp();

        await notifRef.set({
          id: notifRef.id,
          notification_event_id: notificationEventId,
          recipient_app_user_id: recipientAppUserId,
          type: 'dm_message',
          conversation_id: conversationId,
          message_id: messageId,
          actor_app_user_id: senderAppUserId,
          is_read: false,
          created_at: now,
        });

        await sendPushNotification(recipientAppUserId, {
          title: '新消息',
          body: '你收到了一条私信',
          data: { type: 'dm_message', conversation_id: conversationId },
        });
        break;
      }

      case 'dm_accepted': {
        const conversationId = outboxData.conversation_id as string;
        const acceptorAppUserId = outboxData.user_app_user_id as string;

        const convSnap = await db.collection(COLLECTIONS.conversations).doc(conversationId).get();
        if (!convSnap.exists) return;
        const convData = convSnap.data()!;
        const recipientAppUserId = convData.initiated_by as string;

        if (!recipientAppUserId || recipientAppUserId === acceptorAppUserId) return;

        const existingQuery = await db
          .collection(COLLECTIONS.notifications)
          .where('notification_event_id', '==', notificationEventId)
          .get();

        if (!existingQuery.empty) return;

        const notifRef = db.collection(COLLECTIONS.notifications).doc();
        const now = admin.firestore.FieldValue.serverTimestamp();

        await notifRef.set({
          id: notifRef.id,
          notification_event_id: notificationEventId,
          recipient_app_user_id: recipientAppUserId,
          type: 'dm_accepted',
          conversation_id: conversationId,
          actor_app_user_id: acceptorAppUserId,
          is_read: false,
          created_at: now,
        });

        await sendPushNotification(recipientAppUserId, {
          title: '私信请求被接受',
          body: '对方接受了你的私信请求',
          data: { type: 'dm_accepted', conversation_id: conversationId },
        });
        break;
      }
    }
  },
);

async function sendPushNotification(
  recipientAppUserId: string,
  notification: { title: string; body: string; data: Record<string, string> },
): Promise<void> {
  try {
    const tokensSnap = await db
      .collection(COLLECTIONS.fcmTokens)
      .where('app_user_id', '==', recipientAppUserId)
      .get();

    if (tokensSnap.empty) return;

    const tokens: string[] = [];
    tokensSnap.forEach((doc) => {
      const t = doc.get('token') as string;
      if (t) tokens.push(t);
    });

    if (tokens.length === 0) return;

    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data,
      android: {
        priority: 'high',
        notification: {
          channelId: 'playground_notifications',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    await admin.messaging().sendEachForMulticast(message);
  } catch (err) {
    console.error('FCM push failed:', err);
  }
}
