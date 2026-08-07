/// 组合 Repository：收藏（S2 Phase 4）。
///
/// 实现业务层端口 [PlaygroundBookmarkRepository]。
///
/// 缓存裁定：**不缓存**（契约套件 C5 断言：改远端值后立刻读必须拿到新值）。
/// 本类纯透传 [PlaygroundBookmarkRemoteDataSource]。
library;

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class CachedPlaygroundBookmarkRepository
    implements PlaygroundBookmarkRepository {
  CachedPlaygroundBookmarkRepository({
    required PlaygroundBookmarkRemoteDataSource remote,
  }) : _remote = remote;

  final PlaygroundBookmarkRemoteDataSource _remote;

  @override
  Future<void> setBookmark(SetBookmarkCommand command) =>
      _remote.setBookmark(command);

  @override
  Future<bool> isBookmarked(PlaygroundPostId postId) {
    return _remote.isBookmarked(postId); // 不查缓存
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getBookmarkedPosts({
    PlaygroundCursor? cursor,
    int limit = 20,
  }) {
    return _remote.getBookmarkedPosts(cursor: cursor, limit: limit);
  }
}
