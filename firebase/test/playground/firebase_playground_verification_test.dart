import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_verification_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';
import 'package:persistence_firebase/playground/firebase_playground_schema.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebasePlaygroundVerificationRepository', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth mockAuth;
    late FirebasePlaygroundIdentityResolver identityResolver;

    const postAuthorUid = 'post-author-uid';
    const verifierUid = 'verifier-uid';
    const postId = PlaygroundPostId('test-post-1');
    const replyId = PlaygroundReplyId('test-reply-1');

    Future<void> seedPostAndIdentity() async {
      await firestore
          .collection(PlaygroundFirestoreSchema.identityMap)
          .doc(verifierUid)
          .set({'app_user_id': 'app-verifier-1', 'provider_uid': verifierUid});

      await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId.value)
          .set({
        'author_provider_uid': postAuthorUid,
        'author_app_user_id': 'app-post-author',
        'text': '测试帖文',
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('非帖子作者 → 验证成功', () async {
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: verifierUid, isAnonymous: false),
        signedIn: true,
      );
      identityResolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );
      final repo = FirebasePlaygroundVerificationRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      );
      await seedPostAndIdentity();

      final v = await repo.verifyRootReply(
        const VerifyRootReplyCommand(
          postId: postId,
          rootReplyId: replyId,
        ),
      );

      expect(v.postId, equals(postId));
      expect(v.rootReplyId, equals(replyId));
      expect(v.isActive, isTrue);
    });

    test('帖子作者自己验证 → 拒绝', () async {
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: postAuthorUid, isAnonymous: false),
        signedIn: true,
      );
      identityResolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );
      final repo = FirebasePlaygroundVerificationRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      );
      await seedPostAndIdentity();

      expect(
        () async => await repo.verifyRootReply(
          const VerifyRootReplyCommand(
            postId: postId,
            rootReplyId: replyId,
          ),
        ),
        throwsA(
          isA<PlaygroundError>().having(
            (e) => e.code,
            'code',
            PlaygroundErrorCode.forbidden,
          ),
        ),
      );
    });

    test('帖子不存在 → notFound', () async {
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: verifierUid, isAnonymous: false),
        signedIn: true,
      );
      identityResolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );
      final repo = FirebasePlaygroundVerificationRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      );
      await firestore
          .collection(PlaygroundFirestoreSchema.identityMap)
          .doc(verifierUid)
          .set({'app_user_id': 'app-verifier-1', 'provider_uid': verifierUid});

      expect(
        () async => await repo.verifyRootReply(
          const VerifyRootReplyCommand(
            postId: PlaygroundPostId('nonexistent'),
            rootReplyId: replyId,
          ),
        ),
        throwsA(
          isA<PlaygroundError>().having(
            (e) => e.code,
            'code',
            PlaygroundErrorCode.notFound,
          ),
        ),
      );
    });

    test('跨帖验证 → 仅按 postId 匹配', () async {
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: verifierUid, isAnonymous: false),
        signedIn: true,
      );
      identityResolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );
      final repo = FirebasePlaygroundVerificationRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      );

      await firestore
          .collection(PlaygroundFirestoreSchema.identityMap)
          .doc(verifierUid)
          .set({'app_user_id': 'app-verifier-1', 'provider_uid': verifierUid});
      await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc('post-a')
          .set({
        'author_provider_uid': 'other-author',
        'author_app_user_id': 'app-other',
        'text': '帖文A',
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
      });

      final v = await repo.verifyRootReply(
        const VerifyRootReplyCommand(
          postId: PlaygroundPostId('post-a'),
          rootReplyId: replyId,
        ),
      );
      expect(v.postId.value, equals('post-a'));
    });

    test('撤销验证', () async {
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: verifierUid, isAnonymous: false),
        signedIn: true,
      );
      identityResolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );
      final repo = FirebasePlaygroundVerificationRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      );
      await seedPostAndIdentity();

      await repo.verifyRootReply(
        const VerifyRootReplyCommand(
          postId: postId,
          rootReplyId: replyId,
        ),
      );

      final revoked = await repo.revokeVerification(
        const RevokeVerificationCommand(
          postId: postId,
          rootReplyId: replyId,
        ),
      );

      expect(revoked.isActive, isFalse);
      expect(revoked.isRevoked, isTrue);
    });
  });
}
