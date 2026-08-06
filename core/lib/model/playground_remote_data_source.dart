/// 云端公开分享（S2）RemoteDataSource 端口定义。
///
/// 与 `repository-interface-playground` 的 `PlaygroundXxxRepository` 端口
/// 保持**签名完全一致**（复用同一批 command / DTO），这样现有 Firebase
/// 实现类只需改 `implements` 声明即可降级为 RemoteDataSource。
///
/// 分层定位（S2 三层架构）：
/// ```
/// 业务层 → CachedPlaygroundXxxRepository（firebase）→ PlaygroundXxxRemoteDataSource
///                                                        （本文件，core 端口）
///                                                          → FirebaseXxxRemoteDS
/// ```
///
/// 缓存裁定（与接口注释对应）：
/// - Post / Feed / Reply 正文走缓存；
/// - Like（点赞数/点赞态）与 Bookmark（收藏态）**不缓存**，必须实时远端查询；
/// - Media 走两阶段上传 + BlobGateway。
library;

import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 帖子正文 RemoteDataSource。
///
/// 缓存裁定：帖子正文**可缓存**（缓存命中断言见契约套件 C3）。
abstract interface class PlaygroundPostRemoteDataSource {
  Future<PlaygroundPost> createPost(CreatePostCommand command);
  Future<PlaygroundPost> editPost(EditPostCommand command);
  Future<PlaygroundPost> deletePost(DeletePostCommand command);
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId);
}

/// Feed 列表 RemoteDataSource。
///
/// 缓存裁定：Feed 列表页本身不缓存，但翻页取到的帖子正文**可回写帖子缓存**
/// （供骨架屏 / 详情页命中）。
abstract interface class PlaygroundFeedRemoteDataSource {
  Future<PlaygroundPage<PlaygroundPost>> getFeed(GetFeedQuery query);
  Future<PlaygroundPage<PlaygroundPost>> getRecommendedFeed(
      GetFeedQuery query);
  Future<PlaygroundPage<PlaygroundPost>> getPendingDivinationFeed(
      GetFeedQuery query);
  Future<PlaygroundPage<PlaygroundPost>> getLatestFeed(GetFeedQuery query);
}

/// 点赞 RemoteDataSource。
///
/// 缓存裁定：**不缓存**。`isLiked` / `getLikeCount` 必须实时远端查询
/// （契约套件 C4 断言：改远端值后立刻读必须拿到新值）。
abstract interface class PlaygroundLikeRemoteDataSource {
  Future<void> setLike(SetLikeCommand command);
  Future<bool> isLiked(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId});
  Future<int> getLikeCount(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId});
}

/// 收藏 RemoteDataSource。
///
/// 缓存裁定：**不缓存**。`isBookmarked` 必须实时远端查询
/// （契约套件 C5 断言：改远端值后立刻读必须拿到新值）。
abstract interface class PlaygroundBookmarkRemoteDataSource {
  Future<void> setBookmark(SetBookmarkCommand command);
  Future<bool> isBookmarked(PlaygroundPostId postId);
  Future<PlaygroundPage<PlaygroundPost>> getBookmarkedPosts(
      {PlaygroundCursor? cursor, int limit = 20});
}

/// 评论（回复）RemoteDataSource。
///
/// 缓存裁定：评论正文**可缓存**（根回复 + 讨论回复均缓存）。
abstract interface class PlaygroundReplyRemoteDataSource {
  Future<PlaygroundRootReply> createRootReply(
      CreateRootReplyCommand command);
  Future<PlaygroundDiscussionReply> createDiscussionReply(
      CreateDiscussionReplyCommand command);
  Future<PlaygroundRootReply> editRootReply(EditReplyCommand command);
  Future<PlaygroundDiscussionReply> editDiscussionReply(
      EditReplyCommand command);
  Future<void> deleteReply(DeleteReplyCommand command);
  Future<PlaygroundPage<Object>> getReplies(GetRepliesQuery query);
}

/// 媒体 RemoteDataSource。
///
/// 上传管线（S2 入口 B）：EXIF 剥离 → 客户端转码 → BlobGateway 两阶段上传。
/// BlobGateway firebase 实现交付前，仅接通接口 + 内存 fake 全绿。
abstract interface class PlaygroundMediaRemoteDataSource {
  Future<PlaygroundMediaInfo> beginUpload({
    required PlaygroundUserId userId,
    required String mimeType,
    required int sizeBytes,
    int? width,
    int? height,
    int? durationSeconds,
  });
  Future<PlaygroundMediaInfo> getMediaInfo(
      PlaygroundAttachmentId mediaObjectId);
  Future<String> getDownloadUrl(PlaygroundAttachmentId mediaObjectId);
  Future<void> deleteMedia(PlaygroundAttachmentId mediaObjectId);
}

/// 帖子正文缓存 Store。
///
/// 由 drift 包实现（`playground_post_cache_store.dart`）；组合仓库
/// `CachedPlaygroundPostRepository` 依赖本接口，不依赖具体存储。
abstract interface class PlaygroundPostCacheStore {
  /// 缓存命中返回帖子，未命中返回 null（调用方再走远端）。
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId);

  /// 写穿透：远端成功写入/读取后回写缓存。
  Future<void> upsertPost(PlaygroundPost post);

  /// 删除缓存条目（帖子删除/下架时失效）。
  Future<void> deletePost(PlaygroundPostId postId);
}

/// 评论（回复）正文缓存 Store。
///
/// 由 drift 包实现（`playground_reply_cache_store.dart`）。返回的列表为
/// 重建的 [PlaygroundRootReply] / [PlaygroundDiscussionReply]（按 depth、
/// created_at 升序），保持与远端 `getReplies` 相同的页面内顺序。
abstract interface class PlaygroundReplyCacheStore {
  /// 某帖子的缓存评论列表；无缓存返回空列表。
  Future<List<Object>> getReplies(PlaygroundPostId postId);

  /// 写穿透：远端拉取成功后整页回写（先清后写）。
  Future<void> upsertReplies(PlaygroundPostId postId, List<Object> replies);

  /// 删除某帖子的全部评论缓存（评论删除/下架时失效）。
  Future<void> deleteReplies(PlaygroundPostId postId);

  /// 按回复 id 从缓存移除单条（`deleteReply` 后失效，防缓存读到已删评论）。
  Future<void> removeReply(PlaygroundReplyId replyId);
}
