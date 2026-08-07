/// 帖子正文缓存 Store（drift 实现，S2 Phase 3）。
///
/// 实现 [PlaygroundPostCacheStore]（core 端口）。缓存裁定见
/// `playground_cache_tables.dart`：点赞数/收藏态不缓存。
library;

import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'playground_cache_codec.dart';
import 'playground_cache_tables.dart';

part 'playground_post_cache_store.g.dart';

@DriftAccessor(tables: [PlaygroundPostCaches])
class DriftPlaygroundPostCacheStore
    extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$DriftPlaygroundPostCacheStoreMixin
    implements PlaygroundPostCacheStore {
  DriftPlaygroundPostCacheStore(super.db);

  @override
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId) async {
    final row = await (select(playgroundPostCaches)
          ..where((t) => t.postId.equals(postId.value)))
        .getSingleOrNull();
    if (row == null) return null;
    return rowToPost(row);
  }

  @override
  Future<void> upsertPost(PlaygroundPost post) async {
    await into(playgroundPostCaches).insertOnConflictUpdate(
      postToCompanion(post),
    );
  }

  @override
  Future<void> deletePost(PlaygroundPostId postId) async {
    await (delete(playgroundPostCaches)
          ..where((t) => t.postId.equals(postId.value)))
        .go();
  }

  /// [PlaygroundPost] → 行写入。
  PlaygroundPostCachesCompanion postToCompanion(PlaygroundPost post) {
    return PlaygroundPostCachesCompanion.insert(
      postId: post.id.value,
      authorUserId: post.authorUserId.value,
      textContent: post.text,
      allowedChartTechniqueIds: encodeStringList(
          post.allowedChartTechniqueIds),
      attachmentJson: Value(
          post.attachments.isEmpty ? null : encodeAttachments(post.attachments)),
      revisionJson: Value(
          post.revisions.isEmpty ? null : encodeRevisions(post.revisions)),
      status: post.status.name,
      createdAt: post.createdAt.millisecondsSinceEpoch,
      updatedAt: Value(post.updatedAt?.millisecondsSinceEpoch),
      cachedAt: DateTime.now().millisecondsSinceEpoch,
      replyCount: const Value(0),
      likeCount: const Value(0),
    );
  }

  /// 行 → [PlaygroundPost]（缓存重建，`hasOutcomeFeedback` 恒 false）。
  PlaygroundPost rowToPost(PlaygroundPostCacheRow row) {
    return PlaygroundPost(
      id: PlaygroundPostId(row.postId),
      text: row.textContent,
      authorUserId: PlaygroundUserId(row.authorUserId),
      status: PlaygroundPostStatus.values.byName(row.status),
      allowedChartTechniqueIds: decodeStringList(row.allowedChartTechniqueIds),
      attachments: decodeAttachments(row.attachmentJson),
      revisions: decodeRevisions(row.revisionJson),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: row.updatedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(row.updatedAt!)
          : null,
    );
  }
}
