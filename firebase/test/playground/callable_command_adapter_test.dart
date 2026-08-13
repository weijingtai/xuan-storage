/// RED-A：BLOCK-01 客户端 callable adapter 契约测试。
///
/// 断言：
/// 1. 5 类敏感命令（like/verification/outcome_feedback/conversation/identity）
///    通过 `FirebaseFunctions.httpsCallable('<name>')` 调用 Functions；
/// 2. 入参对象只含业务参数 + `idempotency_key`，**不含任何可伪造身份字段**；
/// 3. `idempotency_key` 正确透传；
/// 4. 不再对 `playground_likes/verifications/outcome_feedback/conversations/
///    messages/identity_map` 集合做客户端直写。
///
/// 生产路径不得使用 FakeFirebaseFunctions——双证据走真 emulator（RED-B）。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_like_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_verification_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_outcome_feedback_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_conversation_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';

import 'fake_callable_functions.dart';

/// 可伪造身份字段黑名单：callable 入参绝不能出现这些键。
const forbiddenIdentityKeys = <String>[
  'user_provider_uid',
  'user_app_user_id',
  'author_provider_uid',
  'author_app_user_id',
  'author_id',
  'appUserId',
  'isPoster',
  'poster_provider_uid',
  'poster_app_user_id',
  'sender_provider_uid',
  'sender_app_user_id',
  'participant_a_provider_uid',
  'participant_a_app_user_id',
  'participant_b_provider_uid',
  'participant_b_app_user_id',
  'blocker_provider_uid',
  'blocker_app_user_id',
  'blocked_provider_uid',
  'blocked_app_user_id',
  'verifier_provider_uid',
  'verifier_app_user_id',
  'recipient_provider_uid',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = 'test-uid';
  const appUserId = 'app-test-user';

  late FakeFirebaseFirestore firestore;
  late FakeFirebaseFunctions functions;
  late FirebasePlaygroundIdentityResolver identityResolver;
  late MockFirebaseAuth auth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    functions = FakeFirebaseFunctions()
      ..responses['resolveMyIdentity'] = <String, dynamic>{
        'appUserId': appUserId,
      };
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: uid, isAnonymous: false),
      signedIn: true,
    );
    await firestore.collection('identity_map').doc(uid).set({
      'app_user_id': appUserId,
      'provider_uid': uid,
      'provider_id': 'firebase',
      'public_presentation_id': 'pub_callable_test',
      'public_display_alias': 'callable测试',
    });
    identityResolver = FirebasePlaygroundIdentityResolver(
      firestore: firestore,
      auth: auth,
    );
  });

  group('BLOCK-01 callable adapter 契约（RED-A）', () {
    test('like.setLike → httpsCallable("setLike")，参数白名单 + idempotency_key',
        () async {
      final repo = FirebasePlaygroundLikeRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );

      await repo.setLike(const SetLikeCommand(
        postId: PlaygroundPostId('post-1'),
        liked: true,
        idempotencyKey: 'like-key-1',
      ));

      expect(functions.calledNames, contains('setLike'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'setLike 入参不得包含身份字段 $key');
      }
      expect(params['postId'], 'post-1');
      expect(params['action'], 'like');
      expect(params['idempotency_key'], 'like-key-1');
    });

    test('like.setLike(unlike) → action=unlike', () async {
      final repo = FirebasePlaygroundLikeRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );

      await repo.setLike(const SetLikeCommand(
        replyId: PlaygroundReplyId('reply-1'),
        liked: false,
        idempotencyKey: 'like-key-2',
      ));

      final params = functions.calledParameters.last!;
      expect(params['replyId'], 'reply-1');
      expect(params['action'], 'unlike');
      expect(params.containsKey('postId'), isFalse);
    });

    test('verification.verifyRootReply → httpsCallable("verifyRootReply")',
        () async {
      final repo = FirebasePlaygroundVerificationRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );
      functions.responses['verifyRootReply'] = <String, dynamic>{
        'id': 'verif-1',
        'post_id': 'post-1',
        'root_reply_id': 'reply-1',
        'verifier_app_user_id': appUserId,
        'created_at': DateTime.now().toIso8601String(),
      };

      await repo.verifyRootReply(const VerifyRootReplyCommand(
        postId: PlaygroundPostId('post-1'),
        rootReplyId: PlaygroundReplyId('reply-1'),
        idempotencyKey: 'verif-key-1',
      ));

      expect(functions.calledNames, contains('verifyRootReply'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'verifyRootReply 入参不得包含身份字段 $key');
      }
      expect(params['postId'], 'post-1');
      expect(params['rootReplyId'], 'reply-1');
      expect(params['idempotency_key'], 'verif-key-1');
    });

    test('verification.revokeVerification → httpsCallable("revokeVerification")',
        () async {
      final repo = FirebasePlaygroundVerificationRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );
      functions.responses['revokeVerification'] = <String, dynamic>{
        'success': true,
      };

      await repo.revokeVerification(const RevokeVerificationCommand(
        postId: PlaygroundPostId('post-1'),
        rootReplyId: PlaygroundReplyId('reply-1'),
        idempotencyKey: 'revoke-key-1',
      ));

      expect(functions.calledNames, contains('revokeVerification'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'revokeVerification 入参不得包含身份字段 $key');
      }
      expect(params['idempotency_key'], 'revoke-key-1');
    });

    test('outcome_feedback.setOutcomeFeedback → httpsCallable("setOutcomeFeedback")',
        () async {
      final repo = FirebasePlaygroundOutcomeFeedbackRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );
      functions.responses['setOutcomeFeedback'] = <String, dynamic>{
        'id': 'fb-1',
        'post_id': 'post-1',
        'author_app_user_id': appUserId,
        'outcome_description': '应验了',
        'created_at': DateTime.now().toIso8601String(),
      };

      await repo.setOutcomeFeedback(const SetOutcomeFeedbackCommand(
        postId: PlaygroundPostId('post-1'),
        body: '应验了',
        idempotencyKey: 'fb-key-1',
      ));

      expect(functions.calledNames, contains('setOutcomeFeedback'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'setOutcomeFeedback 入参不得包含身份字段 $key');
      }
      expect(params['postId'], 'post-1');
      expect(params['outcome_description'], '应验了');
      expect(params['idempotency_key'], 'fb-key-1');
    });

    test('outcome_feedback.revokeOutcomeFeedback → httpsCallable("revokeOutcomeFeedback")',
        () async {
      final repo = FirebasePlaygroundOutcomeFeedbackRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );

      await repo.revokeOutcomeFeedback(const RevokeOutcomeFeedbackCommand(
        postId: PlaygroundPostId('post-1'),
        idempotencyKey: 'fb-revoke-1',
      ));

      expect(functions.calledNames, contains('revokeOutcomeFeedback'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'revokeOutcomeFeedback 入参不得包含身份字段 $key');
      }
      expect(params['postId'], 'post-1');
      expect(params['idempotency_key'], 'fb-revoke-1');
    });

    test('conversation.sendDmRequest → httpsCallable("sendDmRequest")',
        () async {
      final repo = FirebasePlaygroundConversationRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );
      functions.responses['sendDmRequest'] = <String, dynamic>{
        'conversation_id': 'conv-1',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await repo.sendDmRequest(const SendDmRequestCommand(
        recipientUserId: PlaygroundUserId('app-recipient'),
        initialMessage: '你好',
        idempotencyKey: 'dm-key-1',
      ));

      expect(functions.calledNames, contains('sendDmRequest'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'sendDmRequest 入参不得包含身份字段 $key');
      }
      expect(params['targetAppUserId'], 'app-recipient');
      expect(params['initialMessage'], '你好');
      expect(params['idempotency_key'], 'dm-key-1');
    });

    test('conversation.respondDmRequest → httpsCallable("respondDmRequest")',
        () async {
      final repo = FirebasePlaygroundConversationRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );
      functions.responses['respondDmRequest'] = <String, dynamic>{
        'success': true,
        'status': 'active',
      };

      await repo.respondDmRequest(const RespondDmRequestCommand(
        conversationId: PlaygroundConversationId('conv-1'),
        accept: true,
        idempotencyKey: 'dm-respond-1',
      ));

      expect(functions.calledNames, contains('respondDmRequest'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'respondDmRequest 入参不得包含身份字段 $key');
      }
      expect(params['conversationId'], 'conv-1');
      expect(params['accept'], isTrue);
      expect(params['idempotency_key'], 'dm-respond-1');
    });

    test('conversation.sendMessage → httpsCallable("sendMessage")', () async {
      final repo = FirebasePlaygroundConversationRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );
      functions.responses['sendMessage'] = <String, dynamic>{
        'message_id': 'msg-1',
        'conversation_id': 'conv-1',
        'text': '你好',
        'created_at': DateTime.now().toIso8601String(),
      };

      await repo.sendMessage(const SendMessageCommand(
        conversationId: PlaygroundConversationId('conv-1'),
        text: '你好',
        idempotencyKey: 'msg-key-1',
      ));

      expect(functions.calledNames, contains('sendMessage'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'sendMessage 入参不得包含身份字段 $key');
      }
      expect(params['conversationId'], 'conv-1');
      expect(params['text'], '你好');
      expect(params['idempotency_key'], 'msg-key-1');
    });

    test('conversation.blockUser → httpsCallable("blockUser")', () async {
      final repo = FirebasePlaygroundConversationRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
        functions: functions,
      );
      functions.responses['blockUser'] = <String, dynamic>{
        'blocked': true,
      };

      await repo.blockUser(const BlockUserCommand(
        blockedUserId: PlaygroundUserId('app-target'),
        idempotencyKey: 'block-key-1',
      ));

      expect(functions.calledNames, contains('blockUser'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'blockUser 入参不得包含身份字段 $key');
      }
      expect(params['targetAppUserId'], 'app-target');
      expect(params['idempotency_key'], 'block-key-1');
    });

    test('identity resolveActor → httpsCallable("resolveMyIdentity")', () async {
      final actor = await identityResolver.resolveActor();
      expect(actor.value, appUserId);
      expect(functions.calledNames, contains('resolveMyIdentity'));
    });
  });
}
