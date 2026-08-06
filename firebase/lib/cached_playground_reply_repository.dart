/// 组合 Repository：评论（回复）（S2 Phase 4）。
///
/// 实现业务层端口 [PlaygroundReplyRepository]。
///
/// 缓存裁定：评论正文**可缓存**。`getReplies` 命中缓存直接返回（整页回写）；
/// 写操作（创建/编辑/删除）走远端后**失效**该帖的评论缓存
/// （下次读取重新拉取整页），避免页内顺序与分页游标漂移。
library;

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class CachedPlaygroundReplyRepository
    implements PlaygroundReplyRepository {
  CachedPlaygroundReplyRepository({
    required PlaygroundReplyRemoteDataSource remote,
    required PlaygroundReplyCacheStore cache,
  })  : _remote = remote,
        _cache = cache;

  final PlaygroundReplyRemoteDataSource _remote;
  final PlaygroundReplyCacheStore _cache;

  @override
  Future<PlaygroundPage<Object>> getReplies(GetRepliesQuery query) async {
    // 1. 先查缓存（命中返回缓存页，无游标续页能力）。
    final cached = await _cache.getReplies(query.postId);
    if (cached.isNotEmpty) {
      return PlaygroundPage(
        items: cached,
        nextCursor: null,
        hasMore: false,
      );
    }

    // 2. 未命中走远端，整页回写。
    final page = await _remote.getReplies(query);
    await _cache.upsertReplies(query.postId, page.items);
    return page;
  }

  @override
  Future<PlaygroundRootReply> createRootReply(
      CreateRootReplyCommand command) async {
    final reply = await _remote.createRootReply(command);
    await _cache.deleteReplies(command.postId); // 失效，防页序漂移
    return reply;
  }

  @override
  Future<PlaygroundDiscussionReply> createDiscussionReply(
      CreateDiscussionReplyCommand command) async {
    final reply = await _remote.createDiscussionReply(command);
    await _cache.deleteReplies(command.postId); // 失效
    return reply;
  }

  @override
  Future<PlaygroundRootReply> editRootReply(EditReplyCommand command) async {
    final reply = await _remote.editRootReply(command);
    await _cache.deleteReplies(reply.postId); // 失效
    return reply;
  }

  @override
  Future<PlaygroundDiscussionReply> editDiscussionReply(
      EditReplyCommand command) async {
    final reply = await _remote.editDiscussionReply(command);
    await _cache.deleteReplies(reply.postId); // 失效
    return reply;
  }

  @override
  Future<void> deleteReply(DeleteReplyCommand command) async {
    await _remote.deleteReply(command);
    // 删除后无法从远端确定所属帖子，按 replyId 精确失效缓存条目，
    // 防 getReplies 命中旧缓存读到已删评论（契约 C9）。
    await _cache.removeReply(command.replyId);
  }
}
