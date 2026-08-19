import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

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
    FirebaseFunctions? functions,
  }) : _functions = functions ?? FirebaseFunctions.instance,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth);

  final FirebaseFunctions _functions;
  final FirebasePlaygroundPublicMapper _mapper;

  @override
  Future<PublicReply> createRootReply(CreateRootReplyCommand command) async {
    try {
      final result = await _functions.httpsCallable('createRootReply').call<Map<String, dynamic>>({
        'post_id': command.postId.value,
        'postId': command.postId.value,
        'body': command.body,
        'techniqueTags': command.techniqueTags,
        'chartAttachment': command.chartAttachment == null ? null : _attachmentToMap(command.chartAttachment!),
        'mediaAttachments': command.mediaAttachments.map(_attachmentToMap).toList(),
        if (command.idempotencyKey != null) 'idempotency_key': command.idempotencyKey,
      });
      return _mapper.publicReplyFromDoc(result.data['id'] as String, result.data);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PublicReply> createDiscussionReply(
      CreateDiscussionReplyCommand command) async {
    try {
      final result = await _functions.httpsCallable('createDiscussionReply').call<Map<String, dynamic>>({
        'postId': command.postId.value,
        'rootReplyId': command.rootReplyId.value,
        'replyToReplyId': command.replyToReplyId?.value,
        'body': command.body,
        'mediaAttachments': command.mediaAttachments.map(_attachmentToMap).toList(),
        if (command.idempotencyKey != null) 'idempotency_key': command.idempotencyKey,
      });
      return _mapper.publicReplyFromDoc(result.data['id'] as String, result.data);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PublicReply> editReply(EditReplyCommand command) async {
    try {
      final result = await _functions.httpsCallable('editReply').call<Map<String, dynamic>>({
        'replyId': command.replyId.value,
        'body': command.body,
        if (command.techniqueTags != null) 'techniqueTags': command.techniqueTags,
        if (command.chartAttachment != null) 'chartAttachment': _attachmentToMap(command.chartAttachment!),
        if (command.mediaAttachments != null) 'mediaAttachments': command.mediaAttachments!.map(_attachmentToMap).toList(),
        if (command.idempotencyKey != null) 'idempotency_key': command.idempotencyKey,
      });
      return _mapper.publicReplyFromDoc(result.data['id'] as String? ?? command.replyId.value, result.data);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> tombstoneReply(DeleteReplyCommand command) async {
    try {
      await _functions.httpsCallable('deleteReply').call({
        'replyId': command.replyId.value,
        if (command.idempotencyKey != null) 'idempotency_key': command.idempotencyKey,
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
