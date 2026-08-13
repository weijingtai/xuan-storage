/// RED: Firestore 直写最终反馈仓库（Task 5）。
///
/// Design §4.2/§4.3/§7.2：
/// - 只写独立 `feedback_{postId}` 及其 append-only revision，不改 post；
/// - Poster-only；发布→编辑→撤回→再发布状态机；
/// - 撤回把 outcome_description='' 并设置 deleted_at；再发布清空 deleted_at 追加 revision；
/// - 零 outbox/notification/callable。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firestore_direct_playground_outcome_feedback_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const posterUid = 'poster-uid';
  const posterApp = 'app-poster';
  const posterPresentation = 'pub_poster_pres_128bit';
  const posterAlias = '玄友0001';

  const otherUid = 'other-uid';
  const otherApp = 'app-other';
  const otherPresentation = 'pub_other_pres_128bit';
  const otherAlias = '玄友0002';

  const postId = 'post-1';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late FirestoreDirectPlaygroundOutcomeFeedbackRepository repo;

  Future<void> seedIdentity(String uid, String app, String pres, String alias) {
    return firestore.collection('identity_map').doc(uid).set({
      'app_user_id': app,
      'provider_uid': uid,
      'provider_id': 'firebase',
      'public_presentation_id': pres,
      'public_display_alias': alias,
    });
  }

  Future<void> seedPost() async {
    await firestore.collection('playground_posts').doc(postId).set({
      'id': postId,
      'text': '母帖',
      'status': 'active',
      'presentation_mode': 'stableAlias',
      'presentation_identity_id': posterPresentation,
      'presentation_display_alias': posterAlias,
      'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    await firestore.collection('playground_post_owners').doc(postId).set({
      'content_id': postId,
      'provider_uid': posterUid,
      'app_user_id': posterApp,
      'public_presentation_id': posterPresentation,
      'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
  }

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final mockUser = MockUser(uid: posterUid, isAnonymous: false);
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    repo = FirestoreDirectPlaygroundOutcomeFeedbackRepository(
      firestore: firestore,
      auth: mockAuth,
    );
    await seedIdentity(posterUid, posterApp, posterPresentation, posterAlias);
    await seedIdentity(otherUid, otherApp, otherPresentation, otherAlias);
  });

  group('setOutcomeFeedback（§7.2）', () {
    test('发布写 feedback_{postId} + revision 1，不改 post', () async {
      await seedPost();

      final f = await repo.setOutcomeFeedback(const SetOutcomeFeedbackCommand(
        postId: PlaygroundPostId(postId),
        body: '应验了！',
        idempotencyKey: 'fb-key-1',
      ));

      expect(f.postId.value, postId);
      expect(f.body, '应验了！');
      expect(f.isActive, isTrue);

      final doc = (await firestore
              .collection('playground_outcome_feedback')
              .doc('feedback_$postId')
              .get())
          .data()!;
      expect(doc['post_id'], postId);
      expect(doc['outcome_description'], '应验了！');
      expect(doc['revision_no'], 1);
      expect(doc['current_revision_id'], 'r0000000001');
      expect(doc['deleted_at'], isNull);

      // revision 1。
      final rev = (await firestore
              .collection('playground_outcome_feedback')
              .doc('feedback_$postId')
              .collection('revisions')
              .doc('r0000000001')
              .get())
          .data()!;
      expect(rev['revision_no'], 1);
      expect(rev['body'], '应验了！');

      // post 未被修改。
      final post = (await firestore
              .collection('playground_posts')
              .doc(postId)
              .get())
          .data()!;
      expect(post['text'], '母帖');
      expect(post.containsKey('has_outcome_feedback'), isFalse);
    });

    test('非 Poster → forbidden', () async {
      await seedPost();
      final otherAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: otherUid, isAnonymous: false),
        signedIn: true,
      );
      final otherRepo = FirestoreDirectPlaygroundOutcomeFeedbackRepository(
        firestore: firestore,
        auth: otherAuth,
      );

      expect(
        () => otherRepo.setOutcomeFeedback(const SetOutcomeFeedbackCommand(
          postId: PlaygroundPostId(postId),
          body: '越权反馈',
          idempotencyKey: 'fb-nonposter',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.forbidden)
            .having(
                (e) => e.machineCode, 'machineCode', 'authorization/forbidden')),
      );
    });
  });

  group('publish→edit→revoke→republish（§7.2）', () {
    test('编辑追加 revision；撤回清空并置 deleted_at；再发布追加 revision',
        () async {
      await seedPost();

      // 发布。
      await repo.setOutcomeFeedback(const SetOutcomeFeedbackCommand(
        postId: PlaygroundPostId(postId),
        body: '初版',
        idempotencyKey: 'fb-sm-1',
      ));

      // 编辑（新逻辑提交 → 新 key）。
      final edited = await repo.setOutcomeFeedback(const SetOutcomeFeedbackCommand(
        postId: PlaygroundPostId(postId),
        body: '编辑版',
        idempotencyKey: 'fb-sm-2',
      ));
      expect(edited.body, '编辑版');
      expect(edited.isEdited, isTrue);

      var doc = (await firestore
              .collection('playground_outcome_feedback')
              .doc('feedback_$postId')
              .get())
          .data()!;
      expect(doc['revision_no'], 2);
      expect(doc['current_revision_id'], 'r0000000002');

      // 撤回。
      await repo.revokeOutcomeFeedback(const RevokeOutcomeFeedbackCommand(
        postId: PlaygroundPostId(postId),
        idempotencyKey: 'fb-sm-3',
      ));
      doc = (await firestore
              .collection('playground_outcome_feedback')
              .doc('feedback_$postId')
              .get())
          .data()!;
      expect(doc['outcome_description'], '');
      expect(doc['deleted_at'], isNotNull);
      expect(doc['revision_no'], 3);

      final revoked = await repo.getOutcomeFeedback(PlaygroundPostId(postId));
      expect(revoked, isNotNull);
      expect(revoked!.isDeleted, isTrue);

      // 再发布。
      final republished = await repo.setOutcomeFeedback(
          const SetOutcomeFeedbackCommand(
        postId: PlaygroundPostId(postId),
        body: '再发布',
        idempotencyKey: 'fb-sm-4',
      ));
      expect(republished.isActive, isTrue);
      expect(republished.body, '再发布');

      doc = (await firestore
              .collection('playground_outcome_feedback')
              .doc('feedback_$postId')
              .get())
          .data()!;
      expect(doc['deleted_at'], isNull);
      expect(doc['revision_no'], 4);

      final all = await firestore
          .collection('playground_outcome_feedback')
          .get();
      expect(all.docs, hasLength(1), reason: '每帖只有一份当前事实');
    });

    test('零 outbox/notification/callable', () async {
      await seedPost();
      await repo.setOutcomeFeedback(const SetOutcomeFeedbackCommand(
        postId: PlaygroundPostId(postId),
        body: '反馈',
        idempotencyKey: 'fb-zero-1',
      ));
      expect(
          (await firestore.collection('playground_outbox').get()).docs, isEmpty);
      expect(
          (await firestore.collection('playground_notifications').get()).docs,
          isEmpty);
    });
  });
}
