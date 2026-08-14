/// Task 6：ThreadQuery adapter（FirebasePlaygroundThreadQueryRepository）契约测试。
///
/// 断言：
/// 1. `getGuestRepresentativeReplies` 后移（§1）：当前返回明确 `unavailable`，
///    不伪造可信限制；不访问 Functions（构造不依赖 FirebaseFunctions）；
/// 2. `getThreadReplies` 为 v1 直连 Firestore 查询：`post_id==, is_tombstoned==false,
///    order created_at asc`，返回 typed [PlaygroundReplyView]（root/discussion 判别），
///    tombstone 被过滤。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_thread_query_repository.dart';
import 'package:persistence_firebase/playground/firestore_direct_playground_command_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late FirebasePlaygroundThreadQueryRepository repo;
  const viewerUid = 'viewer-uid';

  Future<void> seedReply(String docId, Map<String, dynamic> data) =>
      firestore.collection('playground_replies').doc(docId).set(data);

  Future<void> seedPost(String postId) => firestore
      .collection('playground_posts')
      .doc(postId)
      .set({
        'id': postId,
        'text': '帖子',
        'presentation_mode': 'stableAlias',
        'presentation_identity_id': 'pub_alice_128bit',
        'presentation_display_alias': '玄友0001',
        'presentation_avatar_url': null,
        'public_profile_ref': null,
        'status': 'active',
        'allowed_chart_technique_ids': <String>[],
        'attachments': <dynamic>[],
        'has_chart': false,
        'revision_no': 1,
        'current_revision_id': 'r0000000001',
        'idempotency_key': 'idem-post',
        'payload_hash': 'hash-post',
        'created_at': DateTime.utc(2026, 1, 1),
        'updated_at': DateTime.utc(2026, 1, 1),
      });

  Map<String, dynamic> replyDoc(
    String docId, {
    String postId = 'post-1',
    required int depth,
    String? rootReplyId,
    String? replyToReplyId,
    bool isTombstoned = false,
    DateTime? createdAt,
  }) =>
      {
        'id': docId,
        'post_id': postId,
        'presentation_mode': 'stableAlias',
        'presentation_identity_id': 'pub_anon_$docId',
        'presentation_display_alias': '盘友anon',
        'presentation_avatar_url': null,
        'public_profile_ref': null,
        'depth': depth,
        'body': isTombstoned ? '' : '正文-$docId',
        'is_tombstoned': isTombstoned,
        'root_reply_id': rootReplyId,
        'reply_to_reply_id': replyToReplyId,
        'technique_tags': <String>[],
        'chart_attachment': null,
        'media_attachments': <dynamic>[],
        'revision_no': 1,
        'current_revision_id': 'r0000000001',
        'idempotency_key': 'idem-$docId',
        'payload_hash': 'hash-$docId',
        'created_at': createdAt ?? DateTime.utc(2026, 1, 1, 8),
      };

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = FirebasePlaygroundThreadQueryRepository(
      firestore: firestore,
      auth: MockFirebaseAuth(
        mockUser: MockUser(uid: viewerUid, isAnonymous: false),
        signedIn: true,
      ),
    );
  });

  group('getGuestRepresentativeReplies（§1 后移）', () {
    test('当前返回 unavailable，不伪造可信限制（不访问 Functions）', () async {
      expect(
        () => repo.getGuestRepresentativeReplies(
          const GetGuestRepresentativeRepliesQuery(
            postId: PlaygroundPostId('post-1'),
            limit: 7,
            selectionPolicyVersion: 1,
          ),
        ),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.unavailable)),
      );
    });
  });

  group('getThreadReplies（§10.1 v1 查询）', () {
    test('直连 Firestore：post_id==, is_tombstoned==false, created_at asc，tombstone 过滤',
        () async {
      await seedReply('root-1',
          replyDoc('root-1', depth: 0, createdAt: DateTime.utc(2026, 1, 1, 8)));
      await seedReply('disc-1', replyDoc('disc-1',
          depth: 1,
          rootReplyId: 'root-1',
          replyToReplyId: 'root-1',
          createdAt: DateTime.utc(2026, 1, 1, 9)));
      await seedReply('tomb-1', replyDoc('tomb-1',
          depth: 0, isTombstoned: true, createdAt: DateTime.utc(2026, 1, 1, 10)));

      final page = await repo.getThreadReplies(const GetRepliesQuery(
        postId: PlaygroundPostId('post-1'),
        limit: 20,
      ));

      final ids = page.items.map((v) => v.replyId.value).toList();
      expect(ids, isNot(contains('tomb-1')), reason: 'tombstone 必须被过滤');
      expect(ids, containsAll(['root-1', 'disc-1']));
      expect(page.items.first, isA<PlaygroundRootReplyView>());
      expect(page.items[1], isA<PlaygroundDiscussionReplyView>());
      expect(page.hasMore, isFalse);
    });
  });

  group('R1 P1-6 · 详情 viewer/count（写读端确定性 ID 一致 + 全帖 verified count）', () {
    test('写端 like/bookmark 后详情 viewerState 立即 isLiked/isBookmarked（同 deterministic ID）',
        () async {
      await seedPost('post-1');
      final likeId = deterministicCreateId(
          operation: 'like', authUid: viewerUid, idempotencyKey: 'post-1');
      final bookmarkId = deterministicCreateId(
          operation: 'bookmark', authUid: viewerUid, idempotencyKey: 'post-1');
      await firestore
          .collection('playground_likes')
          .doc(likeId)
          .set({'id': likeId, 'target_type': 'post', 'target_id': 'post-1'});
      await firestore
          .collection('playground_bookmarks')
          .doc(bookmarkId)
          .set({'id': bookmarkId, 'post_id': 'post-1', 'user_provider_uid': viewerUid});

      final detail = await repo.getRegisteredThreadDetail(
        const PlaygroundRegisteredThreadDetailQuery(
            postId: PlaygroundPostId('post-1')),
      );
      expect(detail.viewerState.isLiked, isTrue,
          reason: '读端必须用写端同一 deterministic like ID');
      expect(detail.viewerState.isBookmarked, isTrue,
          reason: '读端必须用写端同一 deterministic bookmark ID');
    });

    test('旧错误 ID 不可匹配：like_post_{uid}_{postId} 形式不被当作 liked', () async {
      await seedPost('post-1');
      // 用旧（错误）ID 写 like → 读端 deterministic ID 读不到 → isLiked false。
      await firestore.collection('playground_likes').doc('like_post_${viewerUid}_post-1').set({
        'id': 'like_post_${viewerUid}_post-1',
        'target_type': 'post',
        'target_id': 'post-1',
      });
      final detail = await repo.getRegisteredThreadDetail(
        const PlaygroundRegisteredThreadDetailQuery(
            postId: PlaygroundPostId('post-1')),
      );
      expect(detail.viewerState.isLiked, isFalse);
    });

    test('verifiedRootReplyCount 使用全帖 verification count，超过 50 条回复仍准确', () async {
      await seedPost('post-1');
      // 60 条根回复（超过当前页 limit 50）+ 65 条非撤销应验 → 全帖应验数 = 65。
      for (var i = 0; i < 60; i++) {
        await seedReply('root-$i',
            replyDoc('root-$i', depth: 0, createdAt: DateTime.utc(2026, 1, 1, i)));
      }
      for (var i = 0; i < 65; i++) {
        await firestore
            .collection('playground_verifications')
            .doc('v-$i')
            .set({
              'id': 'v-$i',
              'post_id': 'post-1',
              'root_reply_id': 'root-${i % 60}',
              'revoked_at': null,
              'created_at': DateTime.utc(2026, 1, 1),
            });
      }
      final detail = await repo.getRegisteredThreadDetail(
        const PlaygroundRegisteredThreadDetailQuery(
            postId: PlaygroundPostId('post-1')),
      );
      expect(detail.counts.verifiedRootReplyCount, 65,
          reason: '必须用全帖 verification aggregation，不是当前页 root 数');
    });
  });
}
