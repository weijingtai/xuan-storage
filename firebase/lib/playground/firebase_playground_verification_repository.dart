import 'package:cloud_firestore/cloud_firestore.dart';
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
  })  : _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundIdentityResolver _identityResolver;

  String _verificationDocId(PlaygroundPostId postId, PlaygroundReplyId replyId) {
    return '${postId.value}_${
        replyId.value}';
  }

  @override
  Future<PlaygroundVerification> verifyRootReply(
      VerifyRootReplyCommand command) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final user = _auth.currentUser!;

      return _firestore.runTransaction<PlaygroundVerification>((tx) async {
        final postRef = _firestore
            .collection(PlaygroundFirestoreSchema.posts)
            .doc(command.postId.value);
        final postSnap = await tx.get(postRef);

        if (!postSnap.exists) {
          throw const PlaygroundError(
            code: PlaygroundErrorCode.notFound,
            message: '帖子不存在',
            machineCode: 'verification/post-not-found',
          );
        }

        final authorProviderUid =
            postSnap.data()?['author_provider_uid'] as String? ?? '';

        if (authorProviderUid == user.uid) {
          throw const PlaygroundError(
            code: PlaygroundErrorCode.forbidden,
            message: '不能验证自己的帖子',
            machineCode: 'verification/self-verification',
          );
        }

        final verificationRef = _firestore
            .collection(PlaygroundFirestoreSchema.verifications)
            .doc(_verificationDocId(command.postId, command.rootReplyId));

        final existingSnap = await tx.get(verificationRef);
        if (existingSnap.exists &&
            existingSnap.data()?['revoked_at'] == null) {
          throw const PlaygroundError(
            code: PlaygroundErrorCode.conflict,
            message: '该回复已被验证',
            machineCode: 'verification/already-verified',
          );
        }

        tx.set(verificationRef, {
          'post_id': command.postId.value,
          'root_reply_id': command.rootReplyId.value,
          'poster_provider_uid': user.uid,
          'poster_app_user_id': actor.value,
          'created_at': FieldValue.serverTimestamp(),
          'revoked_at': null,
        });

        return PlaygroundVerification(
          postId: command.postId,
          rootReplyId: command.rootReplyId,
          posterUserId: actor,
          createdAt: DateTime.now(),
        );
      });
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundVerification> revokeVerification(
      RevokeVerificationCommand command) async {
    try {
      return _firestore.runTransaction<PlaygroundVerification>((tx) async {
        final verificationRef = _firestore
            .collection(PlaygroundFirestoreSchema.verifications)
            .doc(_verificationDocId(command.postId, command.rootReplyId));

        final existingSnap = await tx.get(verificationRef);
        if (!existingSnap.exists ||
            existingSnap.data()?['revoked_at'] != null) {
          throw const PlaygroundError(
            code: PlaygroundErrorCode.notFound,
            message: '未找到活跃的验证记录',
            machineCode: 'verification/not-found',
          );
        }

        tx.update(verificationRef, {
          'revoked_at': FieldValue.serverTimestamp(),
        });

        final d = existingSnap.data()!;
        return PlaygroundVerification(
          postId: command.postId,
          rootReplyId: command.rootReplyId,
          posterUserId: PlaygroundUserId(
              d['poster_app_user_id'] as String? ?? ''),
          createdAt:
              (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          revokedAt: DateTime.now(),
        );
      });
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<List<PlaygroundVerification>> getVerificationsForPost(
      PlaygroundPostId postId) async {
    try {
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
              d['poster_app_user_id'] as String? ?? ''),
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
