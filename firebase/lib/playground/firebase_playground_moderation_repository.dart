import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';

final class FirebasePlaygroundModerationRepository
    implements PlaygroundModerationRepository {
  FirebasePlaygroundModerationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
  })  : _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundIdentityResolver _identityResolver;

  @override
  Future<void> reportContent(ReportContentCommand command) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final user = _auth.currentUser!;

      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.reports).doc();

      final data = <String, dynamic>{
        'reporter_provider_uid': user.uid,
        'reporter_app_user_id': actor.value,
        'post_id': command.postId?.value,
        'reply_id': command.replyId?.value,
        'reported_user_id': command.reportedUserId?.value,
        'reason': command.reason.name,
        'description': command.description,
        'created_at': FieldValue.serverTimestamp(),
      };

      await docRef.set(data);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> quarantinePost(PlaygroundPostId postId) async {
    try {
      await _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId.value)
          .update({
        'status': PlaygroundPostStatus.quarantined.name,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> emergencyTakeDown(PlaygroundPostId postId) async {
    try {
      await _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId.value)
          .update({
        'status': PlaygroundPostStatus.tombstoned.name,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }
}
