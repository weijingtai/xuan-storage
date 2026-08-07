/// S2 契约套件的 drift 拓扑（REVIEW-S2 §9-7，P1-7 返工）。
///
/// 【为什么存在】firebase 拓扑已跑全套契约（13+ 条），但 drift 的
/// `DriftPlaygroundPostCacheStore` 只被 6 条自写 store 测试覆盖，从未过
/// 契约套件的缓存断言 —— 两套缓存实现互不交叉验证。本文件用
/// **结构迥异的拓扑**（内联内存 remote + 内联组合 + 真实 drift 缓存）
/// 跑 `runPlaygroundPostContractSuite`（含 C3 两条缓存断言 + C1 CRUD）。
library;

import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_core/test_support/playground_contract_suite.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/playground/playground_post_cache_store.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 内联内存 remote（契约拓扑注入用，故意与 firebase 实现无关）。
final class _MemoryPostRemote implements PlaygroundPostRemoteDataSource {
  final Map<PlaygroundPostId, PlaygroundPost> _posts = {};

  @override
  Future<PlaygroundPost> createPost(CreatePostCommand command) async {
    final id = PlaygroundPostId('mem-${_posts.length}');
    final post = PlaygroundPost(
      id: id,
      text: command.text,
      authorUserId: const PlaygroundUserId('mem-user'),
      allowedChartTechniqueIds: command.allowedChartTechniqueIds,
      attachments: command.attachments,
      createdAt: DateTime.now(),
    );
    _posts[id] = post;
    return post;
  }

  @override
  Future<PlaygroundPost> editPost(EditPostCommand command) async {
    final existing = _posts[command.postId]!;
    final edited = existing.copyWith(text: command.text);
    _posts[command.postId] = edited;
    return edited;
  }

  @override
  Future<PlaygroundPost> deletePost(DeletePostCommand command) async {
    final existing = _posts[command.postId]!;
    final deleted = existing.copyWith(status: PlaygroundPostStatus.tombstoned);
    _posts[command.postId] = deleted;
    return deleted;
  }

  @override
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId) async {
    return _posts[postId];
  }
}

/// 内联组合仓库（与 firebase `CachedPlaygroundPostRepository` 同构）。
final class _CachedPostRepository implements PlaygroundPostRepository {
  _CachedPostRepository(this._remote, this._cache);

  final _MemoryPostRemote _remote;
  final PlaygroundPostCacheStore _cache;

  @override
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId) async {
    final cached = await _cache.getPost(postId);
    if (cached != null) return cached;
    final remote = await _remote.getPost(postId);
    if (remote == null) return null;
    await _cache.upsertPost(remote);
    return remote;
  }

  @override
  Future<PlaygroundPost> createPost(CreatePostCommand command) async {
    final post = await _remote.createPost(command);
    await _cache.upsertPost(post);
    return post;
  }

  @override
  Future<PlaygroundPost> editPost(EditPostCommand command) async {
    final post = await _remote.editPost(command);
    await _cache.upsertPost(post);
    return post;
  }

  @override
  Future<PlaygroundPost> deletePost(DeletePostCommand command) async {
    final post = await _remote.deletePost(command);
    await _cache.deletePost(command.postId);
    return post;
  }
}

void main() {
  late PersistenceDriftDatabase db;
  late DriftPlaygroundPostCacheStore cache;
  late _MemoryPostRemote remote;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    cache = DriftPlaygroundPostCacheStore(db);
    remote = _MemoryPostRemote();
  });

  tearDown(() async {
    await db.close();
  });

  runPlaygroundPostContractSuite(
    topologyName: 'drift（内联 remote + Drift 缓存）',
    makeRepository: () => _CachedPostRepository(remote, cache),
    makeRemote: () => remote,
    makeCacheStore: () => cache,
  );
}
