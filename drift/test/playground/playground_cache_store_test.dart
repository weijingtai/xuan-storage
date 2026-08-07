/// 缓存 store 运行时测试（S2 Phase 3 交付验证）。
///
/// 用内存 SQLite 验证：
/// - schema v10 建表（onCreate）与迁移可跑
/// - Post 缓存 upsert/get/delete roundtrip（含附件/修订 JSON 序列化）
/// - Reply 缓存整页回写 / 按 replyId 移除 / 按帖子清空
library;

import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/playground/playground_post_cache_store.dart';
import 'package:persistence_drift/playground/playground_reply_cache_store.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

void main() {
  late PersistenceDriftDatabase db;
  late DriftPlaygroundPostCacheStore postStore;
  late DriftPlaygroundReplyCacheStore replyStore;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    postStore = DriftPlaygroundPostCacheStore(db);
    replyStore = DriftPlaygroundReplyCacheStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PlaygroundPostCacheStore', () {
    test('upsert → get roundtrip（含附件与修订 JSON）', () async {
      final post = PlaygroundPost(
        id: PlaygroundPostId('p-1'),
        text: '正文内容',
        authorUserId: const PlaygroundUserId('u-1'),
        status: PlaygroundPostStatus.active,
        allowedChartTechniqueIds: const ['t1', 't2'],
        attachments: [
          PlaygroundAttachment.image(
            mediaObjectId: const PlaygroundAttachmentId('m-1'),
            mimeType: 'image/png',
            width: 100,
            height: 200,
          ),
        ],
        revisions: [
          PlaygroundRevision(
            body: 'v1',
            editedBy: 'u-1',
            editedAt: DateTime.utc(2026, 8, 6),
          ),
        ],
        createdAt: DateTime.utc(2026, 8, 6, 10),
        updatedAt: DateTime.utc(2026, 8, 6, 11),
      );

      await postStore.upsertPost(post);
      final got = await postStore.getPost(post.id);

      expect(got, isNotNull);
      expect(got!.text, equals('正文内容'));
      expect(got.status, PlaygroundPostStatus.active);
      expect(got.allowedChartTechniqueIds, ['t1', 't2']);
      expect(got.attachments, hasLength(1));
      expect(got.attachments.first.mediaObjectId?.value, 'm-1');
      expect(got.attachments.first.width, 100);
      expect(got.attachments.first.height, 200);
      expect(got.revisions, hasLength(1));
      expect(got.revisions.first.body, 'v1');
      expect(got.updatedAt!.toUtc(), DateTime.utc(2026, 8, 6, 11));
    });

    test('写穿透覆盖旧值', () async {
      final a = PlaygroundPost(
        id: PlaygroundPostId('p-2'),
        text: '旧正文',
        authorUserId: const PlaygroundUserId('u-1'),
        createdAt: DateTime.utc(2026, 8, 6),
      );
      final b = PlaygroundPost(
        id: PlaygroundPostId('p-2'),
        text: '新正文',
        authorUserId: const PlaygroundUserId('u-1'),
        createdAt: DateTime.utc(2026, 8, 6),
      );
      await postStore.upsertPost(a);
      await postStore.upsertPost(b);
      final got = await postStore.getPost(a.id);
      expect(got!.text, '新正文');
    });

    test('delete 后命中为空', () async {
      final post = PlaygroundPost(
        id: PlaygroundPostId('p-3'),
        text: 'x',
        authorUserId: const PlaygroundUserId('u-1'),
        createdAt: DateTime.utc(2026, 8, 6),
      );
      await postStore.upsertPost(post);
      await postStore.deletePost(post.id);
      expect(await postStore.getPost(post.id), isNull);
    });
  });

  group('PlaygroundReplyCacheStore', () {
    test('整页回写 + 读取（根回复与讨论回复混合）', () async {
      const postId = PlaygroundPostId('post-reply-1');
      final root = PlaygroundRootReply(
        id: PlaygroundReplyId('r-root'),
        postId: postId,
        authorUserId: const PlaygroundUserId('u-1'),
        body: '根回复',
        techniqueTags: const ['t1'],
        createdAt: DateTime.utc(2026, 8, 6, 10),
      );
      final discussion = PlaygroundDiscussionReply(
        id: PlaygroundReplyId('r-disc'),
        postId: postId,
        rootReplyId: root.id,
        authorUserId: const PlaygroundUserId('u-2'),
        body: '讨论回复',
        createdAt: DateTime.utc(2026, 8, 6, 11),
      );

      await replyStore.upsertReplies(postId, [root, discussion]);
      final got = await replyStore.getReplies(postId);

      expect(got, hasLength(2));
      expect(got[0], isA<PlaygroundRootReply>());
      expect((got[0] as PlaygroundRootReply).body, '根回复');
      expect((got[0] as PlaygroundRootReply).techniqueTags, ['t1']);
      expect(got[1], isA<PlaygroundDiscussionReply>());
      expect((got[1] as PlaygroundDiscussionReply).body, '讨论回复');
      expect(
        (got[1] as PlaygroundDiscussionReply).rootReplyId,
        root.id,
      );
    });

    test('removeReply 只删目标条', () async {
      const postId = PlaygroundPostId('post-reply-2');
      final root = PlaygroundRootReply(
        id: PlaygroundReplyId('r-root-2'),
        postId: postId,
        authorUserId: const PlaygroundUserId('u-1'),
        body: '根',
        createdAt: DateTime.utc(2026, 8, 6),
      );
      final discussion = PlaygroundDiscussionReply(
        id: PlaygroundReplyId('r-disc-2'),
        postId: postId,
        rootReplyId: root.id,
        authorUserId: const PlaygroundUserId('u-2'),
        body: '讨论',
        createdAt: DateTime.utc(2026, 8, 6),
      );
      await replyStore.upsertReplies(postId, [root, discussion]);

      await replyStore.removeReply(discussion.id);
      final got = await replyStore.getReplies(postId);
      expect(got, hasLength(1));
      expect((got.single as PlaygroundRootReply).body, '根');
    });

    test('deleteReplies 清空某帖', () async {
      const postId = PlaygroundPostId('post-reply-3');
      await replyStore.upsertReplies(
        postId,
        [
          PlaygroundRootReply(
            id: PlaygroundReplyId('r-1'),
            postId: postId,
            authorUserId: const PlaygroundUserId('u-1'),
            body: 'x',
            createdAt: DateTime.utc(2026, 8, 6),
          ),
        ],
      );
      await replyStore.deleteReplies(postId);
      expect(await replyStore.getReplies(postId), isEmpty);
    });
  });
}
