import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_public_mapper.dart';
import 'playground_http_transport.dart';
import 'playground_transport_config.dart';

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
    PlaygroundTransportConfig? config,
    PlaygroundHttpTransport? httpTransport,
    Uri? baseUri,
  })  : _auth = auth,
        _functions = functions,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth),
        _config = config ?? PlaygroundTransportConfig.defaults(),
        _httpTransport = httpTransport,
        _baseUri = baseUri;

  final FirebaseAuth _auth;
  final FirebaseFunctions? _functions;
  final FirebasePlaygroundPublicMapper _mapper;
  final PlaygroundTransportConfig _config;
  final PlaygroundHttpTransport? _httpTransport;
  final Uri? _baseUri;

  FirebaseFunctions get _effectiveFunctions =>
      _functions ?? FirebaseFunctions.instance;

  Uri get _effectiveBaseUri =>
      _baseUri ?? Uri.parse('http://127.0.0.1:8080/v1');

  @override
  Future<PublicReply> createRootReply(CreateRootReplyCommand command) async {
    try {
      if (_config.isRestCreateRootReplyEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST createRootReply');
        }
        final uri = _effectiveBaseUri
            .resolve('/playground/posts/${command.postId.value}/replies');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (command.idempotencyKey != null)
            'Idempotency-Key': command.idempotencyKey!,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final bodyMap = <String, dynamic>{
          'body': command.body,
          'techniqueTags': command.techniqueTags,
          if (command.chartAttachment != null)
            'chartAttachment': _attachmentToMap(command.chartAttachment!),
          'mediaAttachments':
              command.mediaAttachments.map(_attachmentToMap).toList(),
          'presentation_mode': command.presentationMode.name,
        };
        final resp = await transport.post(
          uri,
          headers: headers,
          body: jsonEncode(bodyMap),
        );
        if (resp.statusCode >= 400) {
          throw FirebasePlaygroundErrorMapper.mapHttpStatus(
              resp.statusCode, resp.body);
        }
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return _mapper.publicReplyFromDoc(data['id'] as String, data);
      }

      final result = await _effectiveFunctions.httpsCallable('createRootReply').call<Map<String, dynamic>>({
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
      if (_config.isRestCreateDiscussionReplyEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST createDiscussionReply');
        }
        final uri = _effectiveBaseUri
            .resolve('/playground/replies/${command.rootReplyId.value}/discussion');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (command.idempotencyKey != null)
            'Idempotency-Key': command.idempotencyKey!,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final bodyMap = <String, dynamic>{
          'postId': command.postId.value,
          if (command.replyToReplyId != null)
            'replyToReplyId': command.replyToReplyId!.value,
          'body': command.body,
          'mediaAttachments':
              command.mediaAttachments.map(_attachmentToMap).toList(),
          'presentation_mode': command.presentationMode.name,
        };
        final resp = await transport.post(
          uri,
          headers: headers,
          body: jsonEncode(bodyMap),
        );
        if (resp.statusCode >= 400) {
          throw FirebasePlaygroundErrorMapper.mapHttpStatus(
              resp.statusCode, resp.body);
        }
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return _mapper.publicReplyFromDoc(data['id'] as String, data);
      }

      final result = await _effectiveFunctions.httpsCallable('createDiscussionReply').call<Map<String, dynamic>>({
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
      if (_config.isRestEditReplyEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST editReply');
        }
        final uri = _effectiveBaseUri
            .resolve('/playground/replies/${command.replyId.value}');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (command.idempotencyKey != null)
            'Idempotency-Key': command.idempotencyKey!,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final bodyMap = <String, dynamic>{
          'body': command.body,
          if (command.techniqueTags != null)
            'techniqueTags': command.techniqueTags,
          if (command.chartAttachment != null)
            'chartAttachment': _attachmentToMap(command.chartAttachment!),
          if (command.mediaAttachments != null)
            'mediaAttachments':
                command.mediaAttachments!.map(_attachmentToMap).toList(),
        };
        final resp = await transport.patch(
          uri,
          headers: headers,
          body: jsonEncode(bodyMap),
        );
        if (resp.statusCode >= 400) {
          throw FirebasePlaygroundErrorMapper.mapHttpStatus(
              resp.statusCode, resp.body);
        }
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return _mapper.publicReplyFromDoc(
            data['id'] as String? ?? command.replyId.value, data);
      }

      final result = await _effectiveFunctions.httpsCallable('editReply').call<Map<String, dynamic>>({
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
      if (_config.isRestDeleteReplyEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST deleteReply');
        }
        final uri = _effectiveBaseUri
            .resolve('/playground/replies/${command.replyId.value}');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          if (command.idempotencyKey != null)
            'Idempotency-Key': command.idempotencyKey!,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final resp = await transport.delete(
          uri,
          headers: headers,
        );
        if (resp.statusCode >= 400) {
          throw FirebasePlaygroundErrorMapper.mapHttpStatus(
              resp.statusCode, resp.body);
        }
        return;
      }

      await _effectiveFunctions.httpsCallable('deleteReply').call({
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
