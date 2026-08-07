/// 组合 Repository：帖子正文（S2 Phase 4）。
///
/// 实现业务层端口 [PlaygroundPostRepository]，内部按三层架构接线：
/// 远端 [PlaygroundPostRemoteDataSource] + 缓存 [PlaygroundPostCacheStore]。
///
/// 缓存裁定：帖子正文**可缓存**（契约套件 C3）。
/// 失效策略：写穿透（远端成功即回写缓存），编辑频率低不做失效标记。
library;

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class CachedPlaygroundPostRepository
    implements PlaygroundPostRepository {
  CachedPlaygroundPostRepository({
    required PlaygroundPostRemoteDataSource remote,
    required PlaygroundPostCacheStore cache,
  })  : _remote = remote,
        _cache = cache;

  final PlaygroundPostRemoteDataSource _remote;
  final PlaygroundPostCacheStore _cache;

  @override
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId) async {
    // 1. 先查缓存（命中直接返回）。
    final cached = await _cache.getPost(postId);
    if (cached != null) return cached;

    // 2. 未命中走远端。
    final remote = await _remote.getPost(postId);
    if (remote == null) return null;

    // 3. 回写缓存。
    await _cache.upsertPost(remote);
    return remote;
  }

  @override
  Future<PlaygroundPost> createPost(CreatePostCommand command) async {
    final post = await _remote.createPost(command);
    await _cache.upsertPost(post); // 写穿透
    return post;
  }

  @override
  Future<PlaygroundPost> editPost(EditPostCommand command) async {
    final post = await _remote.editPost(command);
    await _cache.upsertPost(post); // 写穿透
    return post;
  }

  @override
  Future<PlaygroundPost> deletePost(DeletePostCommand command) async {
    final post = await _remote.deletePost(command);
    // 帖子删除（tombstone）后失效缓存，避免读到旧正文。
    await _cache.deletePost(command.postId);
    return post;
  }
}
