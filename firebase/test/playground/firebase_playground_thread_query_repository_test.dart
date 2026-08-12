/// RED-B：BLOCK-03 Dart adapter（FirebasePlaygroundThreadQueryRepository）契约测试。
///
/// 断言：
/// 1. `getGuestRepresentativeReplies` 走 `FirebaseFunctions.httpsCallable(
///    'getGuestRepresentativeReplies')`，入参对象仅含 postId/limit/
///    selectionPolicyVersion（游客 callable，无身份字段）；
/// 2. Functions JSON → DTO 完整映射（visibleReplies/total/hidden/
///    selectionPolicyVersion/registrationUnlock/outcomeFeedback）；
/// 3. `getThreadReplies` 为直连 Firestore 查询，含 where('is_tombstoned',==,false)，
///    返回 typed [PlaygroundReplyView]（root/discussion 判别），tombstone 被过滤。
///
/// 生产路径不得使用 FakeFirebaseFunctions——双证据走真 emulator。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_thread_query_repository.dart';

import 'fake_callable_functions.dart';

/// 与 Functions guest_replies.ts 返回一致的 JSON fixture（键名 = Dart 字段约定）。
Map<String, dynamic> fullGuestResponse() {
  return <String, dynamic>{
    'postId': 'post-1',
    'visibleReplies': <dynamic>[
      <String, dynamic>{
        'publicReplyId': 'root-1',
        'postId': 'post-1',
        'body': '正文 root-1',
        'techniqueTags': <dynamic>['六爻'],
        'chart': <String, dynamic>{
          'techniqueId': '六爻',
          'schoolId': null,
          'publicChartSnapshot': 'chart-snapshot-1',
          'rendererSchemaVersion': 1,
          'source': 'createdInPlayground',
        },
        'mediaAttachments': <dynamic>[
          <String, dynamic>{
            'type': 'image',
            'mediaObjectId': 'media-1',
            'mimeType': 'image/png',
            'width': 100,
            'height': 200,
            'durationSeconds': null,
            'secureUrl': '/public/media/media-1',
          },
        ],
        'author': <String, dynamic>{
          'publicPresentationUserId': 'anon-abc',
          'displayAlias': '盘友abc',
          'avatarUrl': null,
          'publicProfileRef': null,
        },
        'depth': 0,
        'rootReplyId': null,
        'replyToReplyId': null,
        'isVerified': true,
        'isTombstoned': false,
        'presentationMode': 'stableAlias',
        'createdAt': '2026-01-01T08:00:00.000Z',
        'updatedAt': null,
        'latestRevision': null,
      },
      <String, dynamic>{
        'publicReplyId': 'root-2',
        'postId': 'post-1',
        'body': '正文 root-2',
        'techniqueTags': <dynamic>[],
        'chart': null,
        'mediaAttachments': <dynamic>[],
        'author': <String, dynamic>{
          'publicPresentationUserId': 'anon-def',
          'displayAlias': '盘友def',
          'avatarUrl': null,
          'publicProfileRef': null,
        },
        'depth': 0,
        'rootReplyId': null,
        'replyToReplyId': null,
        'isVerified': false,
        'isTombstoned': false,
        'presentationMode': 'stableAlias',
        'createdAt': '2026-01-01T09:00:00.000Z',
        'updatedAt': null,
        'latestRevision': null,
      },
    ],
    'totalReplyCount': 12,
    'hiddenReplyCount': 7,
    'selectionPolicyVersion': 1,
    'registrationUnlock': <String, dynamic>{
      'requiresRegistration': true,
      'ctaMessageKey': 'register_to_unlock_replies',
      'unlockRoute': '/register',
    },
    'outcomeFeedback': <String, dynamic>{
      'body': '占测已应验',
      'isEdited': false,
      'publishedAt': '2026-01-05T00:00:00.000Z',
      'updatedAt': null,
    },
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late FakeFirebaseFunctions functions;
  late FirebasePlaygroundThreadQueryRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = FakeFirebaseFunctions();
    repo = FirebasePlaygroundThreadQueryRepository(
      firestore: firestore,
      auth: MockFirebaseAuth(),
      functions: functions,
    );
  });

  group('getGuestRepresentativeReplies（BLOCK-03 RED-B）', () {
    test('调用 httpsCallable("getGuestRepresentativeReplies")，入参仅 postId/limit/selectionPolicyVersion',
        () async {
      functions.responses['getGuestRepresentativeReplies'] = <String, dynamic>{
        'postId': 'post-1',
        'visibleReplies': <dynamic>[],
        'totalReplyCount': 0,
        'hiddenReplyCount': 0,
        'selectionPolicyVersion': 1,
        'registrationUnlock': <String, dynamic>{
          'requiresRegistration': true,
          'ctaMessageKey': 'register_to_unlock_replies',
          'unlockRoute': '/register',
        },
        'outcomeFeedback': null,
      };

      await repo.getGuestRepresentativeReplies(
        const GetGuestRepresentativeRepliesQuery(
          postId: PlaygroundPostId('post-1'),
          limit: 7,
          selectionPolicyVersion: 1,
        ),
      );

      expect(functions.calledNames, contains('getGuestRepresentativeReplies'));
      final params = functions.calledParameters.last!;
      expect(params.keys.toSet(),
          {'postId', 'limit', 'selectionPolicyVersion'});
      expect(params['postId'], 'post-1');
      expect(params['limit'], 7);
      expect(params['selectionPolicyVersion'], 1);
    });

    test('JSON→DTO 完整映射（visible/total/hidden/policy/registrationUnlock/outcomeFeedback）',
        () async {
      functions.responses['getGuestRepresentativeReplies'] = fullGuestResponse();

      final result = await repo.getGuestRepresentativeReplies(
        const GetGuestRepresentativeRepliesQuery(
          postId: PlaygroundPostId('post-1'),
        ),
      );

      expect(result.postId.value, 'post-1');
      expect(result.totalReplyCount, 12);
      expect(result.hiddenReplyCount, 7);
      expect(result.selectionPolicyVersion, 1);
      expect(result.registrationUnlock.requiresRegistration, isTrue);
      expect(result.registrationUnlock.ctaMessageKey,
          'register_to_unlock_replies');
      expect(result.registrationUnlock.unlockRoute, '/register');

      final v = result.visibleReplies.first;
      expect(v.publicReplyId.value, 'root-1');
      expect(v.postId.value, 'post-1');
      expect(v.body, '正文 root-1');
      expect(v.techniqueTags, ['六爻']);
      expect(v.depth, 0);
      expect(v.isVerified, isTrue);
      expect(v.isTombstoned, isFalse);
      expect(v.rootReplyId, isNull);
      expect(v.replyToReplyId, isNull);
      expect(v.presentationMode, PlaygroundPresentationMode.stableAlias);
      expect(v.createdAt, DateTime.utc(2026, 1, 1, 8));
      expect(v.updatedAt, isNull);

      // author 公开投影（无敏感字段）。
      expect(v.author.publicPresentationUserId.value, 'anon-abc');
      expect(v.author.displayAlias, '盘友abc');
      expect(v.author.avatarUrl, isNull);
      expect(v.author.publicProfileRef, isNull);

      // chart + media 公开附件。
      expect(v.chart, isA<PublicXuanChartAttachment>());
      final chart = v.chart as PublicXuanChartAttachment;
      expect(chart.techniqueId, '六爻');
      expect(chart.publicChartSnapshot, 'chart-snapshot-1');
      expect(chart.source, PlaygroundChartSource.createdInPlayground);
      expect(v.mediaAttachments.single, isA<PublicMediaAttachment>());
      final media = v.mediaAttachments.single as PublicMediaAttachment;
      expect(media.mediaObjectId.value, 'media-1');
      expect(media.secureUrl, '/public/media/media-1');

      // outcome feedback 对游客可见。
      expect(result.outcomeFeedback, isNotNull);
      expect(result.outcomeFeedback!.body, '占测已应验');
      expect(result.outcomeFeedback!.isEdited, isFalse);
      expect(result.outcomeFeedback!.publishedAt,
          DateTime.utc(2026, 1, 5));

      // 第二条未应验。
      final v2 = result.visibleReplies[1];
      expect(v2.isVerified, isFalse);
      expect(v2.chart, isNull);
    });
  });

  group('getThreadReplies（BLOCK-03 RED-B）', () {
    test('直连 Firestore 查询：where(is_tombstoned == false) 过滤墓碑，返回 typed view',
        () async {
      Future<void> seed(String id, Map<String, dynamic> data) =>
          firestore.collection('playground_replies').doc(id).set(data);

      await seed('root-1', {
        'post_id': 'post-1',
        'depth': 0,
        'body': '根回复',
        'is_tombstoned': false,
        'root_reply_id': null,
        'reply_to_reply_id': null,
        'technique_tags': <String>[],
        'chart_attachment': null,
        'media_attachments': <dynamic>[],
        'author_provider_uid': 'alice-uid',
        'presentation_identity_id': null,
        'verification': null,
        'revisions': <dynamic>[],
        'created_at': DateTime.utc(2026, 1, 1, 8),
      });
      await seed('disc-1', {
        'post_id': 'post-1',
        'depth': 1,
        'body': '讨论回复',
        'is_tombstoned': false,
        'root_reply_id': 'root-1',
        'reply_to_reply_id': 'root-1',
        'technique_tags': <String>[],
        'chart_attachment': null,
        'media_attachments': <dynamic>[],
        'author_provider_uid': 'bob-uid',
        'presentation_identity_id': null,
        'verification': null,
        'revisions': <dynamic>[],
        'created_at': DateTime.utc(2026, 1, 1, 9),
      });
      // 墓碑回复：必须被 where(is_tombstoned == false) 过滤。
      await seed('tomb-1', {
        'post_id': 'post-1',
        'depth': 0,
        'body': '',
        'is_tombstoned': true,
        'root_reply_id': null,
        'reply_to_reply_id': null,
        'technique_tags': <String>[],
        'chart_attachment': null,
        'media_attachments': <dynamic>[],
        'author_provider_uid': 'alice-uid',
        'presentation_identity_id': null,
        'verification': null,
        'revisions': <dynamic>[],
        'created_at': DateTime.utc(2026, 1, 1, 10),
      });

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

    test('游客场景不产生任何 callable 调用（纯直连）', () async {
      await firestore.collection('playground_replies').doc('r-1').set({
        'post_id': 'post-1',
        'depth': 0,
        'body': '正文',
        'is_tombstoned': false,
        'root_reply_id': null,
        'reply_to_reply_id': null,
        'technique_tags': <String>[],
        'chart_attachment': null,
        'media_attachments': <dynamic>[],
        'author_provider_uid': 'alice-uid',
        'presentation_identity_id': null,
        'verification': null,
        'revisions': <dynamic>[],
        'created_at': DateTime.utc(2026, 1, 1, 8),
      });
      await repo.getThreadReplies(const GetRepliesQuery(
        postId: PlaygroundPostId('post-1'),
      ));
      expect(functions.calledNames, isEmpty);
    });
  });
}
