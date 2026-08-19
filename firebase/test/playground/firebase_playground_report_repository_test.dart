/// Phase 7B：Report adapter（FirebasePlaygroundReportRepository）
/// 契约测试 —— RED → GREEN。
///
/// 断言：
/// 1. submitReport 直写 `playground_reports`（Rules 允许客户端创建）：
///    字段含 reporter_provider_uid（来自 Auth session）、严格单目标
///    target_type/target_id、reason、state=pending；**零可伪造身份字段**；
/// 2. 六类 target（post/reply/profile/conversation/message/media）均可举报；
/// 3. getMyReportState 读单文档返回 pending。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_schema.dart';
import 'package:persistence_firebase/playground/firebase_playground_report_repository.dart';

const forbiddenSpoofableKeys = <String>[
  'author_provider_uid',
  'author_app_user_id',
  'user_app_user_id',
  'reported_user_id',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const reporterUid = 'report-uid';
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FirebasePlaygroundReportRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: reporterUid, isAnonymous: false),
      signedIn: true,
    );
    repo = FirebasePlaygroundReportRepository(
      firestore: firestore,
      auth: auth,
    );
  });

  Future<List<Map<String, dynamic>>> allReportDocs() async {
    final snaps =
        await firestore.collection(PlaygroundFirestoreSchema.reports).get();
    return snaps.docs.map((d) => d.data()).toList();
  }

  group('submitReport（直写 playground_reports）', () {
    test('post target：写入 target_type/target_id/reason/state=pending/reporter_provider_uid',
        () async {
      final receipt = await repo.submitReport(PlaygroundReportCommand(
        target: const PostTarget(PlaygroundPostId('post-1')),
        reason: PlaygroundReportReason.spam,
        description: '垃圾内容',
        idempotencyKey: 'report-key-1',
      ));

      expect(receipt.reportId.value, isNotEmpty);
      expect(receipt.target, const PostTarget(PlaygroundPostId('post-1')));
      expect(receipt.state, PlaygroundReportState.pending);

      final docs = await allReportDocs();
      expect(docs, hasLength(1));
      final doc = docs.single;
      expect(doc['target_type'], 'post');
      expect(doc['target_id'], 'post-1');
      expect(doc['reason'], PlaygroundReportReason.spam.name);
      expect(doc['state'], PlaygroundReportState.pending.name);
      expect(doc['description'], '垃圾内容');
      expect(doc['idempotency_key'], 'report-key-1');
      expect(doc['reporter_provider_uid'], reporterUid,
          reason: 'reporter 必须来自 Auth session');
      for (final key in forbiddenSpoofableKeys) {
        expect(doc.containsKey(key), isFalse,
            reason: 'report 写 payload 不得含可伪造身份键 $key');
      }
    });

    test('六类 target 全部可举报，target_type 正确', () async {
      final targets = <(PlaygroundContentTarget, String)>[
        (const PostTarget(PlaygroundPostId('p1')), 'post'),
        (const ReplyTarget(PlaygroundReplyId('r1')), 'reply'),
        (const ProfileTarget(PlaygroundUserId('u2')), 'profile'),
        (const ConversationTarget(PlaygroundConversationId('c1')),
            'conversation'),
        (const MessageTarget(PlaygroundMessageId('m1')), 'message'),
        (const MediaTarget(PlaygroundAttachmentId('a1')), 'media'),
      ];

      for (final entry in targets) {
        final target = entry.$1;
        final receipt = await repo.submitReport(PlaygroundReportCommand(
          target: target,
          reason: PlaygroundReportReason.inappropriateContent,
        ));
        expect(receipt.reportId.value, isNotEmpty);
        expect(receipt.target, target);
      }

      final docs = await allReportDocs();
      expect(docs, hasLength(targets.length));
      final types = docs.map((d) => d['target_type']).toSet();
      expect(types, containsAll(['post', 'reply', 'profile', 'conversation',
          'message', 'media']));
    });
  });

  group('getMyReportState', () {
    test('读单文档返回 pending', () async {
      final receipt = await repo.submitReport(PlaygroundReportCommand(
        target: const PostTarget(PlaygroundPostId('p1')),
        reason: PlaygroundReportReason.misinformation,
      ));
      final state = await repo.getMyReportState(receipt.reportId);
      expect(state, PlaygroundReportState.pending);
    });

    test('未举报过的 reportId 回退 pending（幂等重放证据可复用）', () async {
      final state =
          await repo.getMyReportState(const PlaygroundReportId('missing'));
      expect(state, PlaygroundReportState.pending);
    });
  });
}
