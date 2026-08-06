/// playground 缓存层的**内存实现**（S2 Phase 7 测试支持）。
///
/// 仅用于契约套件注入：与 drift 的 `DriftPlaygroundXxxCacheStore` 行为对齐
/// （缓存命中 / 写穿透 / 失效语义），不落盘。
library;

import 'package:persistence_core/model/playground_remote_data_source.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

/// [PlaygroundPostCacheStore] 内存实现。
final class InMemoryPlaygroundPostCacheStore
    implements PlaygroundPostCacheStore {
  final Map<PlaygroundPostId, PlaygroundPost> _posts = {};

  @override
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId) async {
    return _posts[postId];
  }

  @override
  Future<void> upsertPost(PlaygroundPost post) async {
    _posts[post.id] = post;
  }

  @override
  Future<void> deletePost(PlaygroundPostId postId) async {
    _posts.remove(postId);
  }
}

/// [PlaygroundReplyCacheStore] 内存实现。
final class InMemoryPlaygroundReplyCacheStore
    implements PlaygroundReplyCacheStore {
  final Map<PlaygroundPostId, List<Object>> _replies = {};

  @override
  Future<List<Object>> getReplies(PlaygroundPostId postId) async {
    return List<Object>.of(_replies[postId] ?? const []);
  }

  @override
  Future<void> upsertReplies(
      PlaygroundPostId postId, List<Object> replies) async {
    _replies[postId] = List<Object>.of(replies);
  }

  @override
  Future<void> deleteReplies(PlaygroundPostId postId) async {
    _replies.remove(postId);
  }

  @override
  Future<void> removeReply(PlaygroundReplyId replyId) async {
    for (final entry in _replies.entries) {
      entry.value.removeWhere((r) {
        final id = r is PlaygroundRootReply
            ? r.id
            : (r as PlaygroundDiscussionReply).id;
        return id == replyId;
      });
    }
  }
}
