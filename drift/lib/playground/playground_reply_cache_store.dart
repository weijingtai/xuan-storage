/// 评论（回复）正文缓存 Store（drift 实现，S2 Phase 3）。
///
/// 实现 [PlaygroundReplyCacheStore]（core 端口）。根回复与讨论回复共表，
/// 以 `is_root` 区分；`getReplies` 命中时按 depth、created_at 升序重建。
library;

import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'playground_cache_codec.dart';
import 'playground_cache_tables.dart';

part 'playground_reply_cache_store.g.dart';

@DriftAccessor(tables: [PlaygroundReplyCaches])
class DriftPlaygroundReplyCacheStore
    extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$DriftPlaygroundReplyCacheStoreMixin
    implements PlaygroundReplyCacheStore {
  DriftPlaygroundReplyCacheStore(super.db);

  @override
  Future<List<Object>> getReplies(PlaygroundPostId postId) async {
    final rows = await (select(playgroundReplyCaches)
          ..where((t) => t.postId.equals(postId.value))
          ..orderBy([
            (t) => OrderingTerm.asc(t.depth),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
    return rows.map(rowToReply).toList();
  }

  @override
  Future<void> upsertReplies(
      PlaygroundPostId postId, List<Object> replies) async {
    // 先清后写：整页回写，避免旧页残留。
    await deleteReplies(postId);
    if (replies.isEmpty) return;
    await batch((b) {
      b.insertAll(
        playgroundReplyCaches,
        replies.map(replyToCompanion).toList(),
      );
    });
  }

  @override
  Future<void> deleteReplies(PlaygroundPostId postId) async {
    await (delete(playgroundReplyCaches)
          ..where((t) => t.postId.equals(postId.value)))
        .go();
  }

  @override
  Future<void> removeReply(PlaygroundReplyId replyId) async {
    await (delete(playgroundReplyCaches)
          ..where((t) => t.replyId.equals(replyId.value)))
        .go();
  }

  /// [PlaygroundRootReply] / [PlaygroundDiscussionReply] → 行写入。
  PlaygroundReplyCachesCompanion replyToCompanion(Object reply) {
    if (reply is PlaygroundRootReply) {
      return PlaygroundReplyCachesCompanion.insert(
        replyId: reply.id.value,
        postId: reply.postId.value,
        authorUserId: reply.authorUserId.value,
        body: reply.body,
        depth: 0,
        isRoot: 1,
        rootReplyId: const Value(null),
        replyToReplyId: const Value(null),
        techniqueTagsJson: Value(reply.techniqueTags.isEmpty
            ? null
            : encodeStringList(reply.techniqueTags)),
        chartAttachmentJson:
            Value(encodeAttachment(reply.chartAttachment)),
        mediaAttachmentsJson: Value(reply.mediaAttachments.isEmpty
            ? null
            : encodeAttachments(reply.mediaAttachments)),
        revisionJson: Value(
            reply.revisions.isEmpty ? null : encodeRevisions(reply.revisions)),
        status: reply.isTombstoned ? 'tombstoned' : 'active',
        createdAt: reply.createdAt.millisecondsSinceEpoch,
        updatedAt: Value(reply.updatedAt?.millisecondsSinceEpoch),
        cachedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }
    if (reply is PlaygroundDiscussionReply) {
      return PlaygroundReplyCachesCompanion.insert(
        replyId: reply.id.value,
        postId: reply.postId.value,
        authorUserId: reply.authorUserId.value,
        body: reply.body,
        depth: 1,
        isRoot: 0,
        rootReplyId: Value(reply.rootReplyId.value),
        replyToReplyId: Value(reply.replyToReplyId?.value),
        techniqueTagsJson: const Value(null),
        chartAttachmentJson: const Value(null),
        mediaAttachmentsJson: Value(reply.mediaAttachments.isEmpty
            ? null
            : encodeAttachments(reply.mediaAttachments)),
        revisionJson: Value(
            reply.revisions.isEmpty ? null : encodeRevisions(reply.revisions)),
        status: reply.isTombstoned ? 'tombstoned' : 'active',
        createdAt: reply.createdAt.millisecondsSinceEpoch,
        updatedAt: Value(reply.updatedAt?.millisecondsSinceEpoch),
        cachedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }
    throw ArgumentError('未知回复类型: ${reply.runtimeType}');
  }

  /// 行 → [PlaygroundRootReply] / [PlaygroundDiscussionReply]。
  Object rowToReply(PlaygroundReplyCacheRow row) {
    final isTombstoned = row.status == 'tombstoned';
    if (row.isRoot == 1) {
      return PlaygroundRootReply(
        id: PlaygroundReplyId(row.replyId),
        postId: PlaygroundPostId(row.postId),
        authorUserId: PlaygroundUserId(row.authorUserId),
        body: row.body,
        techniqueTags: decodeStringList(row.techniqueTagsJson),
        chartAttachment: decodeAttachment(row.chartAttachmentJson),
        mediaAttachments: decodeAttachments(row.mediaAttachmentsJson),
        revisions: decodeRevisions(row.revisionJson),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
        updatedAt: row.updatedAt != null
            ? DateTime.fromMillisecondsSinceEpoch(row.updatedAt!)
            : null,
        isTombstoned: isTombstoned,
      );
    }
    return PlaygroundDiscussionReply(
      id: PlaygroundReplyId(row.replyId),
      postId: PlaygroundPostId(row.postId),
      rootReplyId: PlaygroundReplyId(row.rootReplyId ?? ''),
      replyToReplyId: row.replyToReplyId != null
          ? PlaygroundReplyId(row.replyToReplyId!)
          : null,
      authorUserId: PlaygroundUserId(row.authorUserId),
      body: row.body,
      mediaAttachments: decodeAttachments(row.mediaAttachmentsJson),
      revisions: decodeRevisions(row.revisionJson),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: row.updatedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(row.updatedAt!)
          : null,
      isTombstoned: isTombstoned,
    );
  }
}
