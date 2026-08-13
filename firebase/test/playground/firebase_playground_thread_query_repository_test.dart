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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late FirebasePlaygroundThreadQueryRepository repo;

  Future<void> seedReply(String docId, Map<String, dynamic> data) =>
      firestore.collection('playground_replies').doc(docId).set(data);

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
      auth: MockFirebaseAuth(),
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
}
