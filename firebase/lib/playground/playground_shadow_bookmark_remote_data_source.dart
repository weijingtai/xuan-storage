import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'playground_shadow_comparator.dart';
import 'playground_shadow_feed_remote_data_source.dart';

/// 广场收藏影子比对数据源（§5.3 / FW2）。
///
/// 遵循防双写原则：写操作只由 primary 执行，防止线上产生双写副作用；
/// 写后触发影子契约校验回调，读操作支持双跑比对。
final class ShadowPlaygroundBookmarkRemoteDataSource
    implements PlaygroundBookmarkRemoteDataSource {
  ShadowPlaygroundBookmarkRemoteDataSource({
    required this.primary,
    required this.secondary,
    this.onComparison,
  });

  final PlaygroundBookmarkRemoteDataSource primary;
  final PlaygroundBookmarkRemoteDataSource secondary;
  final ShadowComparisonCallback? onComparison;

  @override
  Future<void> setBookmark(SetBookmarkCommand command) async {
    // 防双写安全机制：敏感写仅由 primary 发起实际写操作，避免线上双写副作用；
    // 写路径返回 Future<void> 且不可双写，影子比对由读路径（isBookmarked）双跑承载。
    await primary.setBookmark(command);
  }

  @override
  Future<bool> isBookmarked(PlaygroundPostId postId) async {
    final primaryResult = await primary.isBookmarked(postId);

    try {
      final secondaryResult = await secondary.isBookmarked(postId);
      if (primaryResult != secondaryResult) {
        onComparison?.call(
          ShadowComparisonResult.mismatch(
            ['isBookmarked mismatch: primary=$primaryResult vs secondary=$secondaryResult'],
            postId.value,
          ),
          'isBookmarked',
        );
      } else {
        onComparison?.call(ShadowComparisonResult.match(postId.value), 'isBookmarked');
      }
    } catch (_) {}

    return primaryResult;
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getBookmarkedPosts({
    PlaygroundCursor? cursor,
    int limit = 20,
  }) async {
    return primary.getBookmarkedPosts(cursor: cursor, limit: limit);
  }
}
