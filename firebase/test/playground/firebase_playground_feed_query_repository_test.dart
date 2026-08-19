/// Task 6：FeedQuery adapter（FirebasePlaygroundFeedQueryRepository）契约测试。
///
/// 断言：
/// 1. 三类 tab 返回安全 [PlaygroundFeedItem] 公开投影（post + 占位 counts +
///    viewerState + authorSummary）；
/// 2. Feed 占位策略：三 count=0、hasOutcomeFeedback=false（单 query，无逐帖聚合）；
/// 3. getPendingDivinationFeed 不访问 Firestore → invalidArgument +
///    filter/not-supported-in-direct-phase；推荐降级为最新；
/// 4. tombstone 帖文被过滤；技法 arrayContains 与分页 cursor 生效；
/// 5. 公开 DTO 零敏感字段。
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
    bool hasChart = false,
  }) {
    return firestore.collection(PlaygroundFirestoreSchema.posts).doc(docId).set({
      'id': docId,
      'text': text,
      'presentation_mode': 'stableAlias',
      'presentation_identity_id': 'pub_${docId}_128bit',
      'presentation_display_alias': '玄友0001',
      'presentation_avatar_url': null,
      'public_profile_ref': null,
      'status': status,
      'allowed_chart_technique_ids': techniqueIds,
      'attachments': <dynamic>[],
      'has_chart': hasChart,
      'revision_no': 1,
      'current_revision_id': 'r0000000001',
      'idempotency_key': 'idem-$docId',
      'payload_hash': 'hash-$docId',
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(createdAt),
    });
  }

  Future<void> seedReply(String docId, String postId, {bool tombstoned = false}) {
    return firestore
        .collection(PlaygroundFirestoreSchema.replies)
        .doc(docId)
        .set({
      'id': docId,
      'post_id': postId,
      'presentation_mode': 'stableAlias',
      'presentation_identity_id': 'pub_anon_$docId',
      'presentation_display_alias': '盘友anon',
      'presentation_avatar_url': null,
      'public_profile_ref': null,
      'depth': 0,
      'body': '回复',
      'is_tombstoned': tombstoned,
      'root_reply_id': null,
      'reply_to_reply_id': null,
      'technique_tags': <String>[],
      'chart_attachment': null,
      'media_attachments': <dynamic>[],
      'revision_no': 1,
      'current_revision_id': 'r0000000001',
      'idempotency_key': 'idem-$docId',
      'payload_hash': 'hash-$docId',
      'created_at': DateTime.utc(2026, 1, 1),
    });
  }

  Future<void> seedLike(String docId, String postId) {
    return firestore.collection(PlaygroundFirestoreSchema.likes).doc(docId).set({
      'id': docId,
      'target_type': 'post',
      'target_id': postId,
      'created_at': DateTime.utc(2026, 1, 1),
    });
  }

  Future<void> seedVerification(String docId, String postId) {
    return firestore
        .collection(PlaygroundFirestoreSchema.verifications)
        .doc(docId)
        .set({
      'id': docId,
      'post_id': postId,
      'root_reply_id': 'r1',
      'revoked_at': null,
      'created_at': DateTime.utc(2026, 1, 1),
    });
  }

  group('Feed 公开投影与占位计数（§10.3）', () {
    test('getLatestFeed 返回 PlaygroundFeedItem（占位 0 + viewerState + authorSummary）',
        () async {
      await seedPost('post-1', text: '最新帖', createdAt: DateTime.utc(2026, 6, 1));
      await seedPost('post-2', text: '旧帖', createdAt: DateTime.utc(2026, 1, 1));
      await seedReply('r1', 'post-1');
      await seedReply('r2', 'post-1', tombstoned: true);
      await seedLike('like-1', 'post-1');
      await seedVerification('verif-1', 'post-1');

      final page = await repo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );

      expect(page.items, isA<List<PlaygroundFeedItem>>());
      expect(page.items, isNotEmpty);
      expect(page.items.first.post.body, '最新帖');

      final target =
          page.items.firstWhere((i) => i.post.publicPostId.value == 'post-1');
      expect(target.replyCount, 0, reason: 'Feed 占位恒 0，不逐帖聚合');
      expect(target.likeCount, 0);
      expect(target.verificationCount, 0);
      expect(target.hasOutcomeFeedback, isFalse);
      expect(target.post.replyCount, 0);
      expect(target.post.likeCount, 0);
      expect(target.post.verificationCount, 0);
      expect(target.authorSummary.publicPresentationUserId.value, isNotEmpty);
      expect(target.viewerState.isLiked, isFalse);
    });
  });

  group('Feed tab 语义', () {
    test('getRecommendedFeed 与最新同序（降级为最新，不读 recommendation_score）', () async {
      await seedPost('low', text: '低分', createdAt: DateTime.utc(2026, 1, 1));
      await seedPost('high', text: '高分', createdAt: DateTime.utc(2026, 1, 2));
      final page = await repo.getRecommendedFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.recommended, limit: 10),
      );
      expect(page.items.map((i) => i.post.publicPostId.value).toList(),
          ['high', 'low'], reason: '降级为 created_at desc');
    });

    test('getPendingDivinationFeed 不访问 Firestore → invalidArgument + filter/not-supported-in-direct-phase',
        () async {
      await seedPost('pending', text: '待断', createdAt: DateTime.utc(2026, 1, 1));
      expect(
        () => repo.getPendingDivinationFeed(
          const GetFeedBatchQuery(
              tab: PlaygroundFeedTab.pendingDivination, limit: 10),
        ),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)
            .having((e) => e.machineCode, 'machineCode',
                'filter/not-supported-in-direct-phase')),
      );
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

    test('reply/feedback 状态 filter → invalidArgument + filter/not-supported-in-direct-phase',
        () async {
      await seedPost('p1', text: '待断', createdAt: DateTime.utc(2026, 1, 1));
      expect(
        () => repo.getLatestFeed(GetFeedBatchQuery(
          tab: PlaygroundFeedTab.latest,
          filter: const PlaygroundComposableFilter(
              reply: PlaygroundFeedReplyFilter.pending),
          limit: 10,
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)
            .having((e) => e.machineCode, 'machineCode',
                'filter/not-supported-in-direct-phase')),
      );
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

      final values = FirebasePlaygroundCursor.toStartAfterValues(page1.nextCursor!);
      expect(values, isNotNull);
      expect(values, hasLength(1));
      expect(values!.single, isA<Timestamp>());

      final page2 = await repo.getLatestFeed(GetFeedBatchQuery(
        tab: PlaygroundFeedTab.latest,
        limit: 3,
        cursor: page1.nextCursor,
      ));
      expect(page2, isNotNull);
    });
  });

  group('R1 P1-5 · content/time 扫描后过滤与 cursor 绑定（§10.1）', () {
    test('content: withChart 只返回 has_chart==true', () async {
      await seedPost('chart', text: '带图', createdAt: DateTime.utc(2026, 1, 1),
          hasChart: true);
      await seedPost('text', text: '纯文', createdAt: DateTime.utc(2026, 1, 2),
          hasChart: false);
      final page = await repo.getLatestFeed(GetFeedBatchQuery(
        tab: PlaygroundFeedTab.latest,
        filter: const PlaygroundComposableFilter(
            content: PlaygroundFeedContentType.withChart),
        limit: 10,
      ));
      final ids = page.items.map((i) => i.post.publicPostId.value).toList();
      expect(ids, contains('chart'));
      expect(ids, isNot(contains('text')));
    });

    test('content: textOnly 只返回 has_chart!=true', () async {
      await seedPost('chart', text: '带图', createdAt: DateTime.utc(2026, 1, 1),
          hasChart: true);
      await seedPost('text', text: '纯文', createdAt: DateTime.utc(2026, 1, 2),
          hasChart: false);
      final page = await repo.getLatestFeed(GetFeedBatchQuery(
        tab: PlaygroundFeedTab.latest,
        filter: const PlaygroundComposableFilter(
            content: PlaygroundFeedContentType.textOnly),
        limit: 10,
      ));
      final ids = page.items.map((i) => i.post.publicPostId.value).toList();
      expect(ids, contains('text'));
      expect(ids, isNot(contains('chart')));
    });

    test('timeRange: today 过滤掉更早的帖子', () async {
      final now = DateTime.now();
      await seedPost('recent', text: '今天', createdAt: now.subtract(const Duration(hours: 1)),
          hasChart: false);
      await seedPost('old', text: '一年前', createdAt: now.subtract(const Duration(days: 400)),
          hasChart: false);
      final page = await repo.getLatestFeed(GetFeedBatchQuery(
        tab: PlaygroundFeedTab.latest,
        filter: const PlaygroundComposableFilter(
            timeRange: PlaygroundFeedTimeRange.today),
        limit: 10,
      ));
      final ids = page.items.map((i) => i.post.publicPostId.value).toList();
      expect(ids, contains('recent'));
      expect(ids, isNot(contains('old')));
    });

    test('技法超过 10 项 → invalidArgument + filter/technique-count-exceeded', () async {
      final ids = List.generate(11, (i) => 't$i');
      expect(
        () => repo.getLatestFeed(GetFeedBatchQuery(
          tab: PlaygroundFeedTab.latest,
          filter: PlaygroundComposableFilter(techniqueIds: ids),
          limit: 10,
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)
            .having((e) => e.machineCode, 'machineCode',
                'filter/technique-count-exceeded')),
      );
    });

    test('cursor 绑定相同 filter：换 filter 复用 cursor → invalidArgument + cursor-filter-mismatch',
        () async {
      for (var i = 0; i < 5; i++) {
        await seedPost('p-$i', text: '帖$i',
            createdAt: DateTime.utc(2026, 1, i + 1));
      }
      final page1 = await repo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 3),
      );
      expect(page1.nextCursor, isNotNull);

      // 用内容 filter 复用同一 cursor → 拒绝。
      expect(
        () => repo.getLatestFeed(GetFeedBatchQuery(
          tab: PlaygroundFeedTab.latest,
          filter: const PlaygroundComposableFilter(
              content: PlaygroundFeedContentType.withChart),
          cursor: page1.nextCursor,
          limit: 3,
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)
            .having((e) => e.machineCode, 'machineCode',
                'filter/cursor-filter-mismatch')),
      );
    });

    test('相同 filter 复用 cursor 正常翻页（无漏/重）', () async {
      for (var i = 0; i < 6; i++) {
        await seedPost('p-$i', text: '帖$i',
            createdAt: DateTime.utc(2026, 1, i + 1),
            hasChart: i.isEven);
      }
      const filter = PlaygroundComposableFilter(
          content: PlaygroundFeedContentType.withChart);
      final page1 = await repo.getLatestFeed(GetFeedBatchQuery(
        tab: PlaygroundFeedTab.latest,
        filter: filter,
        limit: 2,
      ));
      expect(page1.items.map((i) => i.post.publicPostId.value).toList(),
          ['p-4', 'p-2']);

      final page2 = await repo.getLatestFeed(GetFeedBatchQuery(
        tab: PlaygroundFeedTab.latest,
        filter: filter,
        cursor: page1.nextCursor,
        limit: 2,
      ));
      final ids2 = page2.items.map((i) => i.post.publicPostId.value).toList();
      expect(ids2, contains('p-0'));
      expect(ids2, isNot(contains('p-4')));
      expect(ids2, isNot(contains('p-2')));
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
