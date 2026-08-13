import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_public_mapper.dart';

/// Phase 7B：回复命令端口 adapter（PlaygroundReplyCommandRepository）。
///
/// - createRootReply/createDiscussionReply/editReply/tombstoneReply 复用
///   Phase 4 收敛的直写 payload（body/is_tombstoned 唯一权威，字段集 ==
///   Rules replyCreateFieldsOk allowlist；**零 status/is_root/
///   author_app_user_id/text**）；
/// - 返回安全 [PublicReply] 公开投影。
final class FirebasePlaygroundReplyCommandRepository
    implements PlaygroundReplyCommandRepository {
  FirebasePlaygroundReplyCommandRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundPublicMapper _mapper;

  @override
  Future<PublicReply> createRootReply(CreateRootReplyCommand command) async {
    try {
      final user = _auth.currentUser!;
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.replies).doc();

      final data = <String, dynamic>{
        'post_id': command.postId.value,
        'author_provider_uid': user.uid,
        'depth': 0,
        'body': command.body,
        'is_tombstoned': false,
        'root_reply_id': null,
        'reply_to_reply_id': null,
        'technique_tags': command.techniqueTags,
        'chart_attachment': command.chartAttachment != null
            ? _attachmentToMap(command.chartAttachment!)
            : null,
        'media_attachments':
            command.mediaAttachments.map(_attachmentToMap).toList(),
        'presentation_identity_id': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'revisions': <Map<String, dynamic>>[],
      };

      if (command.idempotencyKey != null) {
        data['idempotency_key'] = command.idempotencyKey;
      }

      await docRef.set(data);
      final snap = await docRef.get();
      return _mapper.publicReplyFromDoc(docRef.id, snap.data()!);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PublicReply> createDiscussionReply(
      CreateDiscussionReplyCommand command) async {
    try {
      final user = _auth.currentUser!;
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.replies).doc();

      final data = <String, dynamic>{
        'post_id': command.postId.value,
        'author_provider_uid': user.uid,
        'depth': 1,
        'body': command.body,
        'is_tombstoned': false,
        'root_reply_id': command.rootReplyId.value,
        'reply_to_reply_id': command.replyToReplyId?.value,
        'technique_tags': <String>[],
        'chart_attachment': null,
        'media_attachments':
            command.mediaAttachments.map(_attachmentToMap).toList(),
        'presentation_identity_id': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'revisions': <Map<String, dynamic>>[],
      };

      if (command.idempotencyKey != null) {
        data['idempotency_key'] = command.idempotencyKey;
      }

      await docRef.set(data);
      final snap = await docRef.get();
      return _mapper.publicReplyFromDoc(docRef.id, snap.data()!);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PublicReply> editReply(EditReplyCommand command) async {
    try {
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc(command.replyId.value);

      final updates = <String, dynamic>{
        'body': command.body,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (command.techniqueTags != null) {
        updates['technique_tags'] = command.techniqueTags;
      }
      if (command.chartAttachment != null) {
        updates['chart_attachment'] = _attachmentToMap(command.chartAttachment!);
      }
      if (command.mediaAttachments != null) {
        updates['media_attachments'] =
            command.mediaAttachments!.map(_attachmentToMap).toList();
      }

      await docRef.update(updates);
      final snap = await docRef.get();
      return _mapper.publicReplyFromDoc(command.replyId.value, snap.data()!);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> tombstoneReply(DeleteReplyCommand command) async {
    try {
      // tombstone 唯一语义 = is_tombstoned:true；写路径零 status。
      await _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc(command.replyId.value)
          .update({
        'is_tombstoned': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  static Map<String, dynamic> _attachmentToMap(PlaygroundAttachment a) {
    return {
      'type': a.type.name,
      'technique_id': a.techniqueId,
      'school_id': a.schoolId,
      'public_chart_snapshot': a.publicChartSnapshot,
      'renderer_schema_version': a.rendererSchemaVersion,
      'chart_source': a.chartSource?.name,
      'media_object_id': a.mediaObjectId?.value,
      'mime_type': a.mimeType,
      'width': a.width,
      'height': a.height,
      'duration_seconds': a.durationSeconds,
      'moderation_state': a.moderationState?.name,
    };
  }
}
