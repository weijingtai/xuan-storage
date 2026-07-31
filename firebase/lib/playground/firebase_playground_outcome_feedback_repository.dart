import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';

final class FirebasePlaygroundOutcomeFeedbackRepository
    implements PlaygroundOutcomeFeedbackRepository {
  FirebasePlaygroundOutcomeFeedbackRepository({
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
  Future<PlaygroundOutcomeFeedback> setOutcomeFeedback(
      SetOutcomeFeedbackCommand command) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final user = _auth.currentUser!;

      final existingQuery = await _firestore
          .collection(PlaygroundFirestoreSchema.outcomeFeedback)
          .where('post_id', isEqualTo: command.postId.value)
          .where('deleted_at', isNull: true)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        final docRef = existingQuery.docs.first.reference;
        await docRef.update({
          'body': command.body,
          'updated_at': FieldValue.serverTimestamp(),
        });
        final snap = await docRef.get();
        final d = snap.data()!;
        return _docToFeedback(d, snap.id);
      }

      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.outcomeFeedback)
          .doc();

      final data = <String, dynamic>{
        'post_id': command.postId.value,
        'author_provider_uid': user.uid,
        'author_app_user_id': actor.value,
        'body': command.body,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': null,
        'deleted_at': null,
      };

      await docRef.set(data);
      return PlaygroundOutcomeFeedback(
        id: docRef.id,
        postId: command.postId,
        authorUserId: actor,
        body: command.body,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> revokeOutcomeFeedback(
      RevokeOutcomeFeedbackCommand command) async {
    try {
      final existingQuery = await _firestore
          .collection(PlaygroundFirestoreSchema.outcomeFeedback)
          .where('post_id', isEqualTo: command.postId.value)
          .where('deleted_at', isNull: true)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        await existingQuery.docs.first.reference.update({
          'deleted_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundOutcomeFeedback?> getOutcomeFeedback(
      PlaygroundPostId postId) async {
    try {
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.outcomeFeedback)
          .where('post_id', isEqualTo: postId.value)
          .where('deleted_at', isNull: true)
          .limit(1)
          .get();

      if (snaps.docs.isEmpty) return null;
      final doc = snaps.docs.first;
      return _docToFeedback(doc.data(), doc.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  PlaygroundOutcomeFeedback _docToFeedback(Map<String, dynamic> d, String docId) {
    final timestamp = d['created_at'] as Timestamp?;
    final updatedTs = d['updated_at'] as Timestamp?;
    final deletedTs = d['deleted_at'] as Timestamp?;
    return PlaygroundOutcomeFeedback(
      id: docId,
      postId: PlaygroundPostId(d['post_id'] as String? ?? ''),
      authorUserId: PlaygroundUserId(
          d['author_app_user_id'] as String? ?? d['author_provider_uid'] as String? ?? ''),
      body: d['body'] as String? ?? '',
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate(),
      deletedAt: deletedTs?.toDate(),
    );
  }
}
