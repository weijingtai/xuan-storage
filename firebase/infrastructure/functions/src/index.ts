import * as admin from 'firebase-admin';

// 初始化 Firebase Admin（冷启动时执行一次）。
// Emulator 环境自动连接 localhost，生产环境使用默认凭据。
if (admin.apps.length === 0) {
  admin.initializeApp();
}

export const db = admin.firestore();
export const auth = admin.auth();

// ----- 集合名常量（与 Dart 侧 firebase_playground_schema.dart 一致）-----

export const COLLECTIONS = {
  posts: 'playground_posts',
  replies: 'playground_replies',
  verifications: 'playground_verifications',
  outcomeFeedback: 'playground_outcome_feedback',
  likes: 'playground_likes',
  bookmarks: 'playground_bookmarks',
  profiles: 'playground_profiles',
  notifications: 'playground_notifications',
  conversations: 'playground_conversations',
  messages: 'playground_messages',
  reports: 'playground_reports',
  media: 'playground_media',
  idempotency: 'playground_idempotency',
  outbox: 'playground_outbox',
  identityMap: 'identity_map',
  fcmTokens: 'fcm_tokens',
  blocks: 'playground_blocks',
} as const;

export const MAX_REPLY_DEPTH = 1;

// ----- 导出所有 callable Functions -----

export { createPost } from './posts';
export { createRootReply, createDiscussionReply, deleteReply } from './replies';
export { verifyRootReply, revokeVerification } from './verifications';
export { setOutcomeFeedback, revokeOutcomeFeedback } from './outcome_feedback';
export { setLike } from './likes';
export { setBookmark } from './bookmarks';
export { sendDmRequest, respondDmRequest, sendMessage, blockUser } from './conversations';
export { reportContent } from './moderation';
export { registerFcmToken, unregisterFcmToken } from './fcm';
export { onOutboxCreated } from './notifications';
export { recalculateReputation } from './reputation';
export { onMediaUploaded, cleanupOrphanMedia } from './media';
