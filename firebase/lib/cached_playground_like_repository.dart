/// 组合 Repository：点赞（S2 Phase 4）。
///
/// 实现业务层端口 [PlaygroundLikeRepository]。
///
/// 缓存裁定：**不缓存**（契约套件 C4 断言：改远端值后立刻读必须拿到新值）。
/// 本类纯透传 [PlaygroundLikeRemoteDataSource]。
library;

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class CachedPlaygroundLikeRepository
    implements PlaygroundLikeRepository {
  CachedPlaygroundLikeRepository({required PlaygroundLikeRemoteDataSource remote})
      : _remote = remote;

  final PlaygroundLikeRemoteDataSource _remote;

  @override
  Future<void> setLike(SetLikeCommand command) => _remote.setLike(command);

  @override
  Future<bool> isLiked(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId}) {
    return _remote.isLiked(postId: postId, replyId: replyId); // 不查缓存
  }

  @override
  Future<int> getLikeCount(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId}) {
    return _remote.getLikeCount(postId: postId, replyId: replyId); // 不查缓存
  }
}
