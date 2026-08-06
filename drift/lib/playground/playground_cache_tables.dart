/// playground 缓存层的 drift 表定义（S2，设计稿 §4.3.2）。
///
/// 两张表分工：
/// - [PlaygroundPostCaches]：帖子正文缓存（Feed 翻页/详情页骨架屏回写）。
/// - [PlaygroundReplyCaches]：评论（回复）正文缓存。
///
/// 缓存裁定（与 S2-development-plan.md Phase 3 一致）：
/// - 点赞数 / 点赞态 / 收藏态 **不缓存**，必须实时远端查询；
/// - `like_count` / `reply_count` 仅用于缓存内帖子展示，不用于读取裁定。
///
/// 时间列一律 epoch millis（UTC）。
library;

import 'package:drift/drift.dart';

/// 帖子正文缓存表。
@DataClassName('PlaygroundPostCacheRow')
class PlaygroundPostCaches extends Table {
  @override
  String get tableName => 't_playground_post_cache';

  /// 帖子 id。
  TextColumn get postId => text().named('post_id')();

  /// 作者 app 用户 id。
  TextColumn get authorUserId => text().named('author_user_id')();

  /// 帖子正文。
  TextColumn get textContent => text().named('text_content')();

  /// 允许的术数技法 id，JSON array。
  TextColumn get allowedChartTechniqueIds =>
      text().named('allowed_chart_technique_ids')();

  /// 附件元数据，JSON（[PlaygroundAttachment] 列表的序列化）。
  TextColumn get attachmentJson => text().named('attachment_json').nullable()();

  /// 修订历史，JSON（[PlaygroundRevision] 列表的序列化）。
  TextColumn get revisionJson => text().named('revision_json').nullable()();

  /// 帖子状态（active / quarantined / tombstoned）。
  TextColumn get status => text().named('status')();

  /// 创建时间（epoch millis）。
  IntColumn get createdAt => integer().named('created_at')();

  /// 更新时间（epoch millis），可空。
  IntColumn get updatedAt => integer().named('updated_at').nullable()();

  /// 缓存写入时间（epoch millis）。
  IntColumn get cachedAt => integer().named('cached_at')();

  /// 回复数（仅用于缓存内帖子展示，不用于读取裁定）。
  IntColumn get replyCount => integer().named('reply_count')
      .withDefault(const Constant(0))();

  /// 点赞数（仅用于缓存内帖子展示，不用于读取裁定）。
  IntColumn get likeCount => integer().named('like_count')
      .withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {postId};
}

/// 评论（回复）正文缓存表。
///
/// 根回复与讨论回复共用一表，以 [isRoot] 区分。
@DataClassName('PlaygroundReplyCacheRow')
class PlaygroundReplyCaches extends Table {
  @override
  String get tableName => 't_playground_reply_cache';

  /// 回复 id。
  TextColumn get replyId => text().named('reply_id')();

  /// 所属帖子 id。
  TextColumn get postId => text().named('post_id')();

  /// 作者 app 用户 id。
  TextColumn get authorUserId => text().named('author_user_id')();

  /// 回复正文。
  TextColumn get body => text().named('body')();

  /// 回复深度（根回复 = 0）。
  IntColumn get depth => integer().named('depth')();

  /// 是否根回复（1 = 根回复）。
  IntColumn get isRoot => integer().named('is_root')();

  /// 根回复 id（讨论回复非空）。
  TextColumn get rootReplyId => text().named('root_reply_id').nullable()();

  /// 所回复的回复 id（讨论回复可空）。
  TextColumn get replyToReplyId =>
      text().named('reply_to_reply_id').nullable()();

  /// 术数技法标签，JSON array（根回复用）。
  TextColumn get techniqueTagsJson =>
      text().named('technique_tags_json').nullable()();

  /// 图盘附件，JSON（根回复用）。
  TextColumn get chartAttachmentJson =>
      text().named('chart_attachment_json').nullable()();

  /// 媒体附件列表，JSON。
  TextColumn get mediaAttachmentsJson =>
      text().named('media_attachments_json').nullable()();

  /// 修订历史，JSON。
  TextColumn get revisionJson => text().named('revision_json').nullable()();

  /// 回复状态（active / tombstoned）。
  TextColumn get status => text().named('status')();

  /// 创建时间（epoch millis）。
  IntColumn get createdAt => integer().named('created_at')();

  /// 更新时间（epoch millis），可空。
  IntColumn get updatedAt => integer().named('updated_at').nullable()();

  /// 缓存写入时间（epoch millis）。
  IntColumn get cachedAt => integer().named('cached_at')();

  @override
  Set<Column> get primaryKey => {replyId};
}
