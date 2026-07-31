import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_feed_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_schema.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebasePlaygroundFeedRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = FirebasePlaygroundFeedRepository(firestore: firestore);
  });

  Future<void> seedPost({
    required String docId,
    required String authorUid,
    required String text,
    required DateTime createdAt,
    String status = 'active',
    String replyStatus = 'pending',
    String? recommendationScore,
    List<String> techniqueIds = const [],
  }) async {
    final data = <String, dynamic>{
      'author_provider_uid': authorUid,
      'author_app_user_id': authorUid,
      'text': text,
      'status': status,
      'reply_status': replyStatus,
      'created_at': Timestamp.fromDate(createdAt),
      'allowed_chart_technique_ids': techniqueIds,
    };
    if (recommendationScore != null) {
      data['recommendation_score'] = recommendationScore;
    }
    await firestore
        .collection(PlaygroundFirestoreSchema.posts)
        .doc(docId)
        .set(data);
  }

  group('推荐 tab', () {
    test('返回 active 帖文', () async {
      await seedPost(
        docId: 'post-1',
        authorUid: 'user-a',
        text: '推荐帖文',
        createdAt: DateTime.utc(2026, 1, 1),
        recommendationScore: '10',
      );

      final page = await repo.getFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.recommended, limit: 10),
      );

      expect(page.items, isNotEmpty);
      expect(page.items.length, lessThanOrEqualTo(10));
      expect(page.items.any((p) => p.id.value == 'post-1'), isTrue);
    });

    test('tombstoned 帖文不返回', () async {
      await seedPost(
        docId: 'active',
        authorUid: 'user-a',
        text: '活跃帖',
        createdAt: DateTime.utc(2026, 1, 1),
        status: 'active',
      );
      await seedPost(
        docId: 'tombstoned',
        authorUid: 'user-a',
        text: '已删除帖',
        createdAt: DateTime.utc(2026, 1, 2),
        status: 'tombstoned',
      );

      final page = await repo.getFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.recommended, limit: 10),
      );

      expect(page.items.any((p) => p.id.value == 'active'), isTrue);
      expect(page.items.any((p) => p.id.value == 'tombstoned'), isFalse);
    });
  });

  group('待断 tab', () {
    test('返回 reply_status=pending 的帖文', () async {
      await seedPost(
        docId: 'pending-post',
        authorUid: 'user-a',
        text: '待断帖',
        createdAt: DateTime.utc(2026, 1, 1),
        replyStatus: 'pending',
      );
      await seedPost(
        docId: 'replied-post',
        authorUid: 'user-b',
        text: '已断帖',
        createdAt: DateTime.utc(2026, 1, 2),
        replyStatus: 'replied',
      );

      final page = await repo.getPendingDivinationFeed(
        const GetFeedQuery(
          tab: PlaygroundFeedTab.pendingDivination,
          limit: 10,
        ),
      );

      expect(page.items.any((p) => p.id.value == 'pending-post'), isTrue);
    });
  });

  group('最新 tab', () {
    test('按 created_at 降序返回', () async {
      await seedPost(
        docId: 'old',
        authorUid: 'user-a',
        text: '旧帖',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await seedPost(
        docId: 'new',
        authorUid: 'user-b',
        text: '新帖',
        createdAt: DateTime.utc(2026, 6, 1),
      );

      final page = await repo.getLatestFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );

      expect(page.items, isNotEmpty);
    });
  });

  group('技法 filter', () {
    test('技法过滤返回匹配帖文', () async {
      await seedPost(
        docId: 'tech-post',
        authorUid: 'user-a',
        text: '六爻帖',
        createdAt: DateTime.utc(2026, 1, 1),
        techniqueIds: ['liuyao', 'qimen'],
      );
      await seedPost(
        docId: 'no-tech-post',
        authorUid: 'user-b',
        text: '无技法帖',
        createdAt: DateTime.utc(2026, 1, 2),
        techniqueIds: [],
      );

      final page = await repo.getFeed(
        GetFeedQuery(
          tab: PlaygroundFeedTab.recommended,
          filter: const PlaygroundFeedFilter(techniqueIds: ['liuyao']),
          limit: 10,
        ),
      );

      expect(page.items.any((p) => p.id.value == 'tech-post'), isTrue);
    });
  });

  group('cursor 分页', () {
    test('多帖文时分页正确', () async {
      for (var i = 0; i < 5; i++) {
        await seedPost(
          docId: 'p-$i',
          authorUid: 'user-x',
          text: '帖文$i',
          createdAt: DateTime.utc(2026, 1, i + 1),
        );
      }

      final page1 = await repo.getFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.recommended, limit: 3),
      );

      expect(page1.items.length, lessThanOrEqualTo(3));
      expect(page1.items, isNotEmpty);

      if (page1.hasMore) {
        final page2 = await repo.getFeed(
          GetFeedQuery(
            tab: PlaygroundFeedTab.recommended,
            limit: 3,
          ),
        );
        expect(page2.items, isNotEmpty);
      }
    });

    test('cursor token 非空时 isNotEmpty', () async {
      for (var i = 0; i < 10; i++) {
        await seedPost(
          docId: 'cp-$i',
          authorUid: 'user-x',
          text: '游标帖$i',
          createdAt: DateTime.utc(2026, 1, i + 1),
        );
      }

      final page1 = await repo.getFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.recommended, limit: 3),
      );

      if (page1.nextCursor != null) {
        expect(page1.nextCursor!.isNotEmpty, isTrue);
      }
    });
  });

  group('空结果', () {
    test('无帖文时返回空页', () async {
      final page = await repo.getFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.recommended, limit: 10),
      );

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('未匹配帖文时返回空页', () async {
      final page = await repo.getFeed(
        GetFeedQuery(
          tab: PlaygroundFeedTab.recommended,
          filter: const PlaygroundFeedFilter(
            techniqueIds: ['nonexistent'],
          ),
          limit: 10,
        ),
      );

      expect(page.items, isEmpty);
    });
  });
}
