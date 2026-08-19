import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  @override
  Future<PlaygroundOutcomeFeedback> setOutcomeFeedback(
      SetOutcomeFeedbackCommand command) async {
    try {
      // BLOCK-01：敏感写走受信 Functions `setOutcomeFeedback`。
      // 只传业务参数（postId + body 内容）+ idempotency_key；actor 来自 Auth context。
      final params = <String, dynamic>{
        'postId': command.postId.value,
        'outcome_description': command.body,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      final result = await _functions
          .httpsCallable('setOutcomeFeedback')
          .call<Map<String, dynamic>>(params);
      final data = result.data;

      return PlaygroundOutcomeFeedback(
        id: data['id'] as String? ?? '',
        postId: command.postId,
        authorUserId: PlaygroundUserId(
            data['author_app_user_id'] as String? ?? ''),
        body: data['outcome_description'] as String? ?? command.body,
        createdAt:
            DateTime.tryParse(data['created_at'] as String? ?? '') ??
                DateTime.now(),
        updatedAt: null,
        deletedAt: null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> revokeOutcomeFeedback(
      RevokeOutcomeFeedbackCommand command) async {
    try {
      // BLOCK-01：敏感写走受信 Functions `revokeOutcomeFeedback`。
      final params = <String, dynamic>{
        'postId': command.postId.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      await _functions.httpsCallable('revokeOutcomeFeedback').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundOutcomeFeedback?> getOutcomeFeedback(
      PlaygroundPostId postId) async {
    try {
      // 读路径保持直连（Rules `allow read: if request.auth != null`）。
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
          d['author_app_user_id'] as String? ??
              d['author_provider_uid'] as String? ??
              ''),
      body: (d['outcome_description'] as String?) ?? d['body'] as String? ?? '',
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate(),
      deletedAt: deletedTs?.toDate(),
    );
  }
}
