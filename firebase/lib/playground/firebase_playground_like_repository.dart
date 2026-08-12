import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'package:persistence_core/persistence_core.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';

final class FirebasePlaygroundLikeRepository
    implements PlaygroundLikeRemoteDataSource {
  FirebasePlaygroundLikeRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _auth = auth,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

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
      // BLOCK-01：敏感写走受信 Functions `setLike`。
      // 客户端只传业务参数 + idempotency_key，绝不传可伪造身份字段。
      final params = <String, dynamic>{
        'action': command.liked ? 'like' : 'unlike',
        if (command.postId != null) 'postId': command.postId!.value,
        if (command.replyId != null) 'replyId': command.replyId!.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      await _functions.httpsCallable('setLike').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<bool> isLiked(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId}) async {
    try {
      // 读路径保持直连（Rules `allow read: if request.auth != null`）。
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
      // 读路径保持直连。
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
