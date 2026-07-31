import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';

final class FirebasePlaygroundLikeRepository
    implements PlaygroundLikeRepository {
  FirebasePlaygroundLikeRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
  })  : _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundIdentityResolver _identityResolver;

  String _likeDocId({PlaygroundPostId? postId, PlaygroundReplyId? replyId}) {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'anonymous';
    final targetId = postId?.value ?? replyId?.value ?? 'unknown';
    final targetType = postId != null ? 'post' : 'reply';
    return '${uid}_${targetType}_$targetId';
  }

  @override
  Future<void> setLike(SetLikeCommand command) async {
    try {
      final docId = _likeDocId(
          postId: command.postId, replyId: command.replyId);
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.likes).doc(docId);

      if (command.liked) {
        final user = _auth.currentUser;
        final actor = await _identityResolver.resolveActor();
        await docRef.set({
          'user_provider_uid': user?.uid,
          'user_app_user_id': actor.value,
          'target_type': command.postId != null ? 'post' : 'reply',
          'target_id':
              command.postId?.value ?? command.replyId?.value ?? '',
          'post_id': command.postId?.value,
          'reply_id': command.replyId?.value,
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<bool> isLiked(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId}) async {
    try {
      final docId = _likeDocId(postId: postId, replyId: replyId);
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .doc(docId)
          .get();
      return snap.exists;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<int> getLikeCount(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId}) async {
    try {
      final targetId = postId?.value ?? replyId?.value ?? '';
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .where('target_id', isEqualTo: targetId)
          .get();
      return snaps.docs.length;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }
}
