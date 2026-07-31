/// Firestore collection/document path constants for Playground。
///
/// 这些常量仅在 adapter 内部使用，不得泄漏到端口接口、DTO 或业务层。
library;

abstract final class PlaygroundFirestoreSchema {
  PlaygroundFirestoreSchema._();

  static const posts = 'playground_posts';
  static const replies = 'playground_replies';
  static const verifications = 'playground_verifications';
  static const outcomeFeedback = 'playground_outcome_feedback';
  static const likes = 'playground_likes';
  static const bookmarks = 'playground_bookmarks';
  static const profiles = 'playground_profiles';
  static const notifications = 'playground_notifications';
  static const conversations = 'playground_conversations';
  static const messages = 'playground_messages';
  static const reports = 'playground_reports';
  static const media = 'playground_media';
  static const idempotency = 'playground_idempotency';
  static const outbox = 'playground_outbox';
  static const identityMap = 'identity_map';

  static const fcmTokens = 'fcm_tokens';
  static const blocks = 'playground_blocks';

  /// 回复表上的 depth 字段最大值。
  static const int maxReplyDepth = 1;
}
