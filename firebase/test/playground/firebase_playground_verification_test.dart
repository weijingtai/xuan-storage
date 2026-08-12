import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_verification_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';

import 'fake_callable_functions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebasePlaygroundVerificationRepository (callable 契约)', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFunctions functions;
    late FirebasePlaygroundIdentityResolver identityResolver;

    const verifierUid = 'verifier-uid';
    const appUserId = 'app-verifier-1';
    const postId = PlaygroundPostId('test-post-1');
    const replyId = PlaygroundReplyId('test-reply-1');

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = FakeFirebaseFunctions()
        ..responses['resolveMyIdentity'] = <String, dynamic>{
          'appUserId': appUserId,
        };
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: verifierUid, isAnonymous: false),
        signedIn: true,
      );
      identityResolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
        functions: functions,
      );
    });

    PlaygroundVerificationRepository makeRepo() {
      return FirebasePlaygroundVerificationRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
        functions: functions,
      );
    }

    test('verifyRootReply → httpsCallable("verifyRootReply")，参数白名单 + 响应映射',
        () async {
      functions.responses['verifyRootReply'] = <String, dynamic>{
        'id': 'verif-1',
        'post_id': postId.value,
        'root_reply_id': replyId.value,
        'verifier_app_user_id': appUserId,
        'created_at': '2026-08-12T00:00:00.000Z',
      };
      final repo = makeRepo();

      final v = await repo.verifyRootReply(const VerifyRootReplyCommand(
        postId: postId,
        rootReplyId: replyId,
        idempotencyKey: 'verif-key-1',
      ));

      expect(functions.calledNames, contains('verifyRootReply'));
      final params = functions.calledParameters.last!;
      for (final key in [
        'user_provider_uid',
        'user_app_user_id',
        'poster_provider_uid',
        'poster_app_user_id',
        'verifier_provider_uid',
        'verifier_app_user_id',
        'author_id',
        'appUserId',
        'isPoster',
      ]) {
        expect(params.containsKey(key), isFalse,
            reason: 'verifyRootReply 入参不得包含身份字段 $key');
      }
      expect(params['postId'], postId.value);
      expect(params['rootReplyId'], replyId.value);
      expect(params['idempotency_key'], 'verif-key-1');

      expect(v.postId, equals(postId));
      expect(v.rootReplyId, equals(replyId));
      expect(v.posterUserId, const PlaygroundUserId(appUserId));
      expect(v.isActive, isTrue);
      expect(v.createdAt.year, 2026);
    });

    test('帖子作者自己验证 → callable 拒绝映射为 forbidden', () async {
      functions.throwFor['verifyRootReply'] = FirebaseFunctionsException(
        code: 'permission-denied',
        message: '只有帖子作者可以应验',
      );
      final repo = makeRepo();

      expect(
        () async => await repo.verifyRootReply(const VerifyRootReplyCommand(
          postId: postId,
          rootReplyId: replyId,
        )),
        throwsA(
          isA<PlaygroundError>().having(
            (e) => e.code,
            'code',
            PlaygroundErrorCode.forbidden,
          ),
        ),
      );
    });

    test('帖子不存在 → callable not-found 映射为 notFound', () async {
      functions.throwFor['verifyRootReply'] = FirebaseFunctionsException(
        code: 'not-found',
        message: '帖子不存在或已失效',
      );
      final repo = makeRepo();

      expect(
        () async => await repo.verifyRootReply(const VerifyRootReplyCommand(
          postId: PlaygroundPostId('nonexistent'),
          rootReplyId: replyId,
        )),
        throwsA(
          isA<PlaygroundError>().having(
            (e) => e.code,
            'code',
            PlaygroundErrorCode.notFound,
          ),
        ),
      );
    });

    test('revokeVerification → httpsCallable("revokeVerification")，参数白名单',
        () async {
      functions.responses['revokeVerification'] = <String, dynamic>{
        'success': true,
      };
      final repo = makeRepo();

      final revoked = await repo.revokeVerification(
        const RevokeVerificationCommand(
          postId: postId,
          rootReplyId: replyId,
          idempotencyKey: 'revoke-key-1',
        ),
      );

      expect(functions.calledNames, contains('revokeVerification'));
      final params = functions.calledParameters.last!;
      for (final key in [
        'user_provider_uid',
        'user_app_user_id',
        'poster_provider_uid',
        'poster_app_user_id',
        'verifier_provider_uid',
        'verifier_app_user_id',
        'author_id',
        'appUserId',
        'isPoster',
      ]) {
        expect(params.containsKey(key), isFalse,
            reason: 'revokeVerification 入参不得包含身份字段 $key');
      }
      expect(params['idempotency_key'], 'revoke-key-1');

      expect(revoked.isRevoked, isTrue);
    });
  });
}
