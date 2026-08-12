import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';

final class FirebasePlaygroundVerificationRepository
    implements PlaygroundVerificationRepository {
  FirebasePlaygroundVerificationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _identityResolver = identityResolver,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebasePlaygroundIdentityResolver _identityResolver;
  final FirebaseFunctions _functions;

  @override
  Future<PlaygroundVerification> verifyRootReply(
      VerifyRootReplyCommand command) async {
    try {
      // BLOCK-01：敏感写走受信 Functions `verifyRootReply`。
      // 只传业务参数 + idempotency_key；actor/Poster 校验在 Functions 侧。
      final params = <String, dynamic>{
        'postId': command.postId.value,
        'rootReplyId': command.rootReplyId.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      final result =
          await _functions.httpsCallable('verifyRootReply').call<Map<String, dynamic>>(params);
      final data = result.data;

      return PlaygroundVerification(
        postId: command.postId,
        rootReplyId: command.rootReplyId,
        posterUserId: PlaygroundUserId(
            data['verifier_app_user_id'] as String? ?? ''),
        createdAt:
            DateTime.tryParse(data['created_at'] as String? ?? '') ??
                DateTime.now(),
        revokedAt: null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundVerification> revokeVerification(
      RevokeVerificationCommand command) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final params = <String, dynamic>{
        'postId': command.postId.value,
        'rootReplyId': command.rootReplyId.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      // BLOCK-01：敏感写走受信 Functions `revokeVerification`。
      await _functions
          .httpsCallable('revokeVerification')
          .call<Map<String, dynamic>>(params);

      return PlaygroundVerification(
        postId: command.postId,
        rootReplyId: command.rootReplyId,
        posterUserId: actor,
        createdAt: DateTime.now(),
        revokedAt: DateTime.now(),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<List<PlaygroundVerification>> getVerificationsForPost(
      PlaygroundPostId postId) async {
    try {
      // 读路径保持直连（Rules `allow read: if request.auth != null`）。
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .where('post_id', isEqualTo: postId.value)
          .get();

      return snaps.docs.map((doc) {
        final d = doc.data();
        final timestamp = d['created_at'] as Timestamp?;
        final revokedTs = d['revoked_at'] as Timestamp?;
        return PlaygroundVerification(
          postId: PlaygroundPostId(d['post_id'] as String? ?? ''),
          rootReplyId: PlaygroundReplyId(d['root_reply_id'] as String? ?? ''),
          posterUserId: PlaygroundUserId(
              d['verifier_app_user_id'] as String? ??
                  d['poster_app_user_id'] as String? ??
                  ''),
          createdAt: timestamp?.toDate() ?? DateTime.now(),
          revokedAt: revokedTs?.toDate(),
        );
      }).toList();
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<bool> isRootReplyVerified(PlaygroundReplyId rootReplyId) async {
    try {
      // 读路径保持直连。
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .where('root_reply_id', isEqualTo: rootReplyId.value)
          .where('revoked_at', isNull: true)
          .limit(1)
          .get();

      return snaps.docs.isNotEmpty;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }
}
