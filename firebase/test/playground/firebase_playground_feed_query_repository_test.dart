/// Phase 7B：FeedQuery adapter（FirebasePlaygroundFeedQueryRepository）
/// 契约测试 —— RED → GREEN。
///
/// 断言：
/// 1. 三类 tab 返回安全 [PlaygroundFeedItem] 公开投影（post + counts +
///    viewerState + authorSummary）；
/// 2. counts 正确聚合（reply/like/verification、hasOutcomeFeedback）；
/// 3. tombstone 帖文被过滤；filter（技法/pending）与分页 cursor 生效；
/// 4. 公开 DTO 零敏感字段。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_schema.dart';
import 'package:persistence_firebase/playground/firebase_playground_feed_query_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_cursor.dart';

const sensitiveBlacklist = <String>[
  'author_provider_uid',
  'presentation_identity_id',
  'author_app_user_id',
  'user_provider_uid',
];

String _dump(Object? value) {
  final buffer = StringBuffer();
  if (value is Iterable) {
    for (final e in value) {
      buffer.write(_dump(e));
    }
  } else if (value is Map) {
    for (final e in value.entries) {
      buffer.write(_dump(e.value));
    }
  } else {
    buffer.write('$value');
  }
  return buffer.toString();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const viewerUid = 'feed-viewer-uid';
  const postAuthorUid = 'feed-author-uid';
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FirebasePlaygroundFeedQueryRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: viewerUid, isAnonymous: false),
      signedIn: true,
    );
    repo = FirebasePlaygroundFeedQueryRepository(
      firestore: firestore,
      auth: auth,
    );
  });

  Future<void> seedPost(
    String docId, {
    required String text,
    required DateTime createdAt,
    String status = 'active',
    List<String> techniqueIds = const [],
    String? replyStatus,
    bool hasOutcomeFeedback = false,
    double? recommendationScore,
  }) {
    return firestore.collection(PlaygroundFirestoreSchema.posts).doc(docId).set({
      'author_provider_uid': postAuthorUid,
      'text': text,
      'status': status,
      'allowed_chart_technique_ids': techniqueIds,
      'attachments': <dynamic>[],
      'revisions': <dynamic>[],
      'has_outcome_feedback': hasOutcomeFeedback,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(createdAt),
      'reply_status': ?replyStatus,
      'recommendation_score': ?recommendationScore?.toString(),
    });
  }

  Future<void> seedReply(String docId, String postId, {bool tombstoned = false}) {
    return firestore
        .collection(PlaygroundFirestoreSchema.replies)
        .doc(docId)
        .set({
      'post_id': postId,
      'depth': 0,
      'body': '回复',
      'is_tombstoned': tombstoned,
      'author_provider_uid': postAuthorUid,
      'root_reply_id': null,
      'reply_to_reply_id': null,
      'technique_tags': <String>[],
      'media_attachments': <dynamic>[],
      'revisions': <dynamic>[],
      'created_at': DateTime.utc(2026, 1, 1),
    });
  }

  Future<void> seedLike(String docId, String postId) {
    return firestore.collection(PlaygroundFirestoreSchema.likes).doc(docId).set({
      'post_id': postId,
      'user_provider_uid': viewerUid,
      'created_at': DateTime.utc(2026, 1, 1),
    });
  }

  Future<void> seedVerification(String docId, String postId) {
    return firestore
        .collection(PlaygroundFirestoreSchema.verifications)
        .doc(docId)
        .set({
      'post_id': postId,
      'root_reply_id': 'r1',
      'revoked_at': null,
      'created_at': DateTime.utc(2026, 1, 1),
    });
  }

  group('Feed 公开投影与计数', () {
    test('getLatestFeed 返回 PlaygroundFeedItem（counts/viewerState/authorSummary）',
        () async {
      await seedPost('post-1', text: '最新帖', createdAt: DateTime.utc(2026, 6, 1));
      await seedPost('post-2', text: '旧帖', createdAt: DateTime.utc(2026, 1, 1));
      await seedReply('r1', 'post-1');
      await seedReply('r2', 'post-1', tombstoned: true); // tombstone 不计
      await seedLike('like_post_${viewerUid}_post-1', 'post-1');
      await seedVerification('verif-1', 'post-1');

      final page = await repo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );

      expect(page.items, isA<List<PlaygroundFeedItem>>());
      expect(page.items, isNotEmpty);
      expect(page.items.first.post.body, '最新帖');

      final target =
          page.items.firstWhere((i) => i.post.publicPostId.value == 'post-1');
      expect(target.replyCount, 1, reason: 'tombstone 回复不计入 replyCount');
      expect(target.likeCount, 1);
      expect(target.verificationCount, 1);
      expect(target.hasOutcomeFeedback, isFalse);
      expect(target.authorSummary.publicPresentationUserId.value, isNotEmpty);
      expect(target.viewerState.isLiked, isTrue);
      expect(target.viewerState.canVerify, isTrue,
          reason: 'viewer 非作者 → 可应验');
    });

    test('hasOutcomeFeedback 来自帖子文档字段', () async {
      await seedPost('post-fb',
          text: '有反馈', createdAt: DateTime.utc(2026, 1, 1),
          hasOutcomeFeedback: true);
      final page = await repo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );
      expect(page.items.single.hasOutcomeFeedback, isTrue);
    });
  });

  group('Feed tab 语义', () {
    test('getRecommendedFeed 走 recommendation_score 排序', () async {
      await seedPost('low', text: '低分', createdAt: DateTime.utc(2026, 1, 1),
          recommendationScore: 1);
      await seedPost('high', text: '高分', createdAt: DateTime.utc(2026, 1, 2),
          recommendationScore: 99);
      final page = await repo.getRecommendedFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.recommended, limit: 10),
      );
      expect(page.items.map((i) => i.post.publicPostId.value).toList(),
          ['high', 'low']);
    });

    test('getPendingDivinationFeed 只返回 reply_status=pending', () async {
      await seedPost('pending', text: '待断', createdAt: DateTime.utc(2026, 1, 1),
          replyStatus: 'pending');
      await seedPost('replied', text: '已断', createdAt: DateTime.utc(2026, 1, 2),
          replyStatus: 'replied');
      final page = await repo.getPendingDivinationFeed(
        const GetFeedBatchQuery(
            tab: PlaygroundFeedTab.pendingDivination, limit: 10),
      );
      final ids = page.items.map((i) => i.post.publicPostId.value).toList();
      expect(ids, contains('pending'));
      expect(ids, isNot(contains('replied')));
    });

    test('getFeed 按 tab 分发', () async {
      await seedPost('latest', text: '最新', createdAt: DateTime.utc(2026, 1, 1));
      final page = await repo.getFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );
      expect(page.items, isNotEmpty);
    });
  });

  group('Filter 与墓碑', () {
    test('tombstoned 帖文不进入 feed', () async {
      await seedPost('active', text: '活跃', createdAt: DateTime.utc(2026, 1, 1));
      await seedPost('tomb', text: '墓碑', createdAt: DateTime.utc(2026, 1, 2),
          status: 'tombstoned');
      final page = await repo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );
      final ids = page.items.map((i) => i.post.publicPostId.value).toList();
      expect(ids, contains('active'));
      expect(ids, isNot(contains('tomb')));
    });

    test('技法 filter（arrayContainsAny）', () async {
      await seedPost('tech', text: '六爻帖', createdAt: DateTime.utc(2026, 1, 1),
          techniqueIds: ['liuyao']);
      await seedPost('plain', text: '无技法', createdAt: DateTime.utc(2026, 1, 2));
      final page = await repo.getLatestFeed(GetFeedBatchQuery(
        tab: PlaygroundFeedTab.latest,
        filter: const PlaygroundComposableFilter(techniqueIds: ['liuyao']),
        limit: 10,
      ));
      final ids = page.items.map((i) => i.post.publicPostId.value).toList();
      expect(ids, contains('tech'));
      expect(ids, isNot(contains('plain')));
    });

    test('待断 filter（reply=pending）', () async {
      await seedPost('p1', text: '待断', createdAt: DateTime.utc(2026, 1, 1),
          replyStatus: 'pending');
      await seedPost('p2', text: '已断', createdAt: DateTime.utc(2026, 1, 2),
          replyStatus: 'replied');
      final page = await repo.getLatestFeed(GetFeedBatchQuery(
        tab: PlaygroundFeedTab.latest,
        filter: const PlaygroundComposableFilter(
            reply: PlaygroundFeedReplyFilter.pending),
        limit: 10,
      ));
      final ids = page.items.map((i) => i.post.publicPostId.value).toList();
      expect(ids, contains('p1'));
      expect(ids, isNot(contains('p2')));
    });
  });

  group('分页', () {
    test('超过 limit 时返回 nextCursor，且 cursor 可往返解码（opaque）', () async {
      for (var i = 0; i < 5; i++) {
        await seedPost('p-$i', text: '帖$i',
            createdAt: DateTime.utc(2026, 1, i + 1));
      }
      final page1 = await repo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 3),
      );
      expect(page1.items, hasLength(3));
      expect(page1.nextCursor, isNotNull);
      expect(page1.hasMore, isTrue);

      // cursor 是不透明 token，但内部必须携带 orderBy 值（startAfter(values) 用）。
      final values = FirebasePlaygroundCursor.toStartAfterValues(page1.nextCursor!);
      expect(values, isNotNull);
      expect(values, hasLength(1));
      expect(values!.single, isA<Timestamp>());

      // 第二页查询构造必须接受 cursor 且不抛错。
      // 注意：fake_cloud_firestore 4.2.0 的 startAfter 对 Timestamp 值比较有
      // 已知缺陷（探针实证：带 orderBy Timestamp 的 startAfter 恒返回空）；
      // 真实 Firestore 的 startAfter(values) 是标准 API。翻页"第二页非空且
      // 不重复"的端到端断言由真 emulator 集成验证（Phase 8 / emulator 环境）。
      final page2 = await repo.getLatestFeed(GetFeedBatchQuery(
        tab: PlaygroundFeedTab.latest,
        limit: 3,
        cursor: page1.nextCursor,
      ));
      expect(page2, isNotNull);
    });
  });

  group('公开 DTO 敏感字段扫描', () {
    test('FeedItem 不含 provider uid / presentation_identity_id', () async {
      await seedPost('post-1', text: '敏感扫描', createdAt: DateTime.utc(2026, 1, 1));
      final page = await repo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );
      final dump = _dump(page);
      for (final key in sensitiveBlacklist) {
        expect(dump, isNot(contains(key)),
            reason: 'Feed 公开投影不得含敏感键 $key');
      }
      expect(dump, isNot(contains(postAuthorUid)));
      expect(dump, isNot(contains(viewerUid)));
    });
  });
}
