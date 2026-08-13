/// RED: Firestore 直写应验仓库（Task 5）。
///
/// Design §4.2/§7.1：
/// - 只写独立 `verify_{postId}_{rootReplyId}` 文档，不改 reply；
/// - Poster-only；目标同帖、depth=0、未墓碑、非 Poster 自己的回复；
/// - verify→revoke→reverify 状态机；created_at 保持，revoked_at null↔time；
/// - 零 outbox/notification/callable。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firestore_direct_playground_verification_repository.dart';

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
  const rootReplyId = 'reply-root-1';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late FirestoreDirectPlaygroundVerificationRepository repo;

  Future<void> seedIdentity(String uid, String app, String pres, String alias) {
    return firestore.collection('identity_map').doc(uid).set({
      'app_user_id': app,
      'provider_uid': uid,
      'provider_id': 'firebase',
      'public_presentation_id': pres,
      'public_display_alias': alias,
    });
  }

  /// seed 帖子（poster 拥有）与一条 root 回复（other 发布）。
  Future<void> seedPostAndRootReply({bool tombstoneRoot = false}) async {
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
    await firestore.collection('playground_replies').doc(rootReplyId).set({
      'id': rootReplyId,
      'post_id': postId,
      'depth': 0,
      'body': '根回复',
      'is_tombstoned': tombstoneRoot,
      'presentation_mode': 'stableAlias',
      'presentation_identity_id': otherPresentation,
      'presentation_display_alias': otherAlias,
      'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    await firestore.collection('playground_reply_owners').doc(rootReplyId).set({
      'content_id': rootReplyId,
      'provider_uid': otherUid,
      'app_user_id': otherApp,
      'public_presentation_id': otherPresentation,
      'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
  }

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final mockUser = MockUser(uid: posterUid, isAnonymous: false);
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    repo = FirestoreDirectPlaygroundVerificationRepository(
      firestore: firestore,
      auth: mockAuth,
    );
    await seedIdentity(posterUid, posterApp, posterPresentation, posterAlias);
    await seedIdentity(otherUid, otherApp, otherPresentation, otherAlias);
  });

  group('verifyRootReply（§7.1）', () {
    test('verify 写独立文档 verify_{postId}_{rootReplyId}，不改 reply', () async {
      await seedPostAndRootReply();

      final v = await repo.verifyRootReply(const VerifyRootReplyCommand(
        postId: PlaygroundPostId(postId),
        rootReplyId: PlaygroundReplyId(rootReplyId),
        idempotencyKey: 'verify-key-1',
      ));

      expect(v.postId.value, postId);
      expect(v.rootReplyId.value, rootReplyId);
      expect(v.posterUserId, const PlaygroundUserId(posterApp));
      expect(v.isActive, isTrue);

      final docId = 'verify_${postId}_$rootReplyId';
      final doc = (await firestore
              .collection('playground_verifications')
              .doc(docId)
              .get())
          .data()!;
      expect(doc['post_id'], postId);
      expect(doc['root_reply_id'], rootReplyId);
      expect(doc['revoked_at'], isNull);

      // reply 未被修改。
      final reply = (await firestore
              .collection('playground_replies')
              .doc(rootReplyId)
              .get())
          .data()!;
      expect(reply['body'], '根回复');
      expect(reply.containsKey('verification'), isFalse);
      expect(reply.containsKey('verified'), isFalse);
    });

    test('非 Poster → forbidden', () async {
      await seedPostAndRootReply();
      // 用 other（非 poster）身份。
      final otherAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: otherUid, isAnonymous: false),
        signedIn: true,
      );
      final otherRepo = FirestoreDirectPlaygroundVerificationRepository(
        firestore: firestore,
        auth: otherAuth,
      );

      expect(
        () => otherRepo.verifyRootReply(const VerifyRootReplyCommand(
          postId: PlaygroundPostId(postId),
          rootReplyId: PlaygroundReplyId(rootReplyId),
          idempotencyKey: 'verify-nonposter',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.forbidden)
            .having(
                (e) => e.machineCode, 'machineCode', 'authorization/forbidden')),
      );
    });

    test('应验自己的回复 → forbidden', () async {
      // Poster 自己也发一条 root 回复。
      await seedPostAndRootReply();
      await firestore.collection('playground_replies').doc('own-root').set({
        'id': 'own-root',
        'post_id': postId,
        'depth': 0,
        'body': 'Poster 自己的回复',
        'is_tombstoned': false,
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      await firestore.collection('playground_reply_owners').doc('own-root').set({
        'content_id': 'own-root',
        'provider_uid': posterUid,
        'app_user_id': posterApp,
        'public_presentation_id': posterPresentation,
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      expect(
        () => repo.verifyRootReply(const VerifyRootReplyCommand(
          postId: PlaygroundPostId(postId),
          rootReplyId: PlaygroundReplyId('own-root'),
          idempotencyKey: 'verify-own',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.forbidden)),
      );
    });

    test('tombstone root → 拒绝', () async {
      await seedPostAndRootReply(tombstoneRoot: true);
      expect(
        () => repo.verifyRootReply(const VerifyRootReplyCommand(
          postId: PlaygroundPostId(postId),
          rootReplyId: PlaygroundReplyId(rootReplyId),
          idempotencyKey: 'verify-tb',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.tombstoned)),
      );
    });

    test('跨帖/非 root（depth=1）→ 拒绝', () async {
      await seedPostAndRootReply();
      // seed 另一帖与二级回复。
      await firestore.collection('playground_replies').doc('depth1').set({
        'id': 'depth1',
        'post_id': postId,
        'depth': 1,
        'root_reply_id': rootReplyId,
        'body': '二级',
        'is_tombstoned': false,
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      expect(
        () => repo.verifyRootReply(const VerifyRootReplyCommand(
          postId: PlaygroundPostId(postId),
          rootReplyId: PlaygroundReplyId('depth1'),
          idempotencyKey: 'verify-depth1',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)),
      );
    });
  });

  group('verify→revoke→reverify 状态机（§7.1）', () {
    test('verify → revoke → re-verify，created_at 保持，revoked_at 状态转换',
        () async {
      await seedPostAndRootReply();

      final v1 = await repo.verifyRootReply(const VerifyRootReplyCommand(
        postId: PlaygroundPostId(postId),
        rootReplyId: PlaygroundReplyId(rootReplyId),
        idempotencyKey: 'verify-sm-1',
      ));

      final revoked = await repo.revokeVerification(const RevokeVerificationCommand(
        postId: PlaygroundPostId(postId),
        rootReplyId: PlaygroundReplyId(rootReplyId),
        idempotencyKey: 'revoke-sm-1',
      ));
      expect(revoked.isRevoked, isTrue);

      final reverified = await repo.verifyRootReply(const VerifyRootReplyCommand(
        postId: PlaygroundPostId(postId),
        rootReplyId: PlaygroundReplyId(rootReplyId),
        idempotencyKey: 'reverify-sm-1',
      ));
      expect(reverified.isActive, isTrue);

      final doc = (await firestore
              .collection('playground_verifications')
              .doc('verify_${postId}_$rootReplyId')
              .get())
          .data()!;
      expect(doc['created_at'], isNotNull);
      expect(doc['revoked_at'], isNull);
      // 只有一条事实，不新增第二条。
      final all = await firestore.collection('playground_verifications').get();
      expect(all.docs, hasLength(1));
    });
  });

  group('读取', () {
    test('getVerificationsForPost / isRootReplyVerified', () async {
      await seedPostAndRootReply();
      await repo.verifyRootReply(const VerifyRootReplyCommand(
        postId: PlaygroundPostId(postId),
        rootReplyId: PlaygroundReplyId(rootReplyId),
        idempotencyKey: 'verify-read-1',
      ));

      final list = await repo.getVerificationsForPost(PlaygroundPostId(postId));
      expect(list, hasLength(1));
      expect(list.first.rootReplyId.value, rootReplyId);

      final verified = await repo.isRootReplyVerified(PlaygroundReplyId(rootReplyId));
      expect(verified, isTrue);
    });
  });
}
