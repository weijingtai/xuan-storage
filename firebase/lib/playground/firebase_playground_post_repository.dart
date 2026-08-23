import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'package:persistence_core/persistence_core.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'playground_http_transport.dart';
import 'playground_transport_config.dart';

final class FirebasePlaygroundPostRepository
    implements PlaygroundPostRemoteDataSource {
  FirebasePlaygroundPostRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
    PlaygroundTransportConfig? config,
    PlaygroundHttpTransport? httpTransport,
    Uri? baseUri,
  })  : _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver,
        _config = config ?? PlaygroundTransportConfig.defaults(),
        _httpTransport = httpTransport,
        _baseUri = baseUri;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundIdentityResolver _identityResolver;
  final PlaygroundTransportConfig _config;
  final PlaygroundHttpTransport? _httpTransport;
  final Uri? _baseUri;

  Uri get _effectiveBaseUri =>
      _baseUri ?? Uri.parse('http://127.0.0.1:8080/v1');

  @override
  Future<PlaygroundPost> createPost(CreatePostCommand command) async {
    try {
      if (_config.isRestCreatePostEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST createPost');
        }
        final uri = _effectiveBaseUri.resolve('/playground/posts');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (command.idempotencyKey != null)
            'Idempotency-Key': command.idempotencyKey!,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final bodyMap = <String, dynamic>{
          'text': command.text,
          'presentation_mode': command.presentationMode.name,
          'allowed_chart_technique_ids': command.allowedChartTechniqueIds,
          'attachments': command.attachments.map(_attachmentToMap).toList(),
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
        return _docToPost(data, data['id'] as String? ?? '');
      }

      final user = _auth.currentUser!;
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.posts).doc();

      // 写 payload 键集合恰好等于 Rules postCreateFieldsOk allowlist：
      // 客户端不写 author_app_user_id（decode 回退 author_provider_uid，§3.2）。
      final data = <String, dynamic>{
        'author_provider_uid': user.uid,
        'text': command.text,
        'allowed_chart_technique_ids': command.allowedChartTechniqueIds,
        'attachments': command.attachments.map(_attachmentToMap).toList(),
        'status': PlaygroundPostStatus.active.name,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'revisions': <Map<String, dynamic>>[],
        'has_outcome_feedback': false,
      };

      if (command.idempotencyKey != null) {
        data['idempotency_key'] = command.idempotencyKey;
      }

      await docRef.set(data);
      final snap = await docRef.get();
      return _docToPost(snap.data()!, docRef.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPost> editPost(EditPostCommand command) async {
    try {
      if (_config.isRestEditPostEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST editPost');
        }
        final uri = _effectiveBaseUri
            .resolve('/playground/posts/${command.postId.value}');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (command.idempotencyKey != null)
            'Idempotency-Key': command.idempotencyKey!,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final bodyMap = <String, dynamic>{
          'text': command.text,
          if (command.allowedChartTechniqueIds != null)
            'allowed_chart_technique_ids': command.allowedChartTechniqueIds,
          if (command.attachments != null)
            'attachments':
                command.attachments!.map(_attachmentToMap).toList(),
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
        return _docToPost(data, data['id'] as String? ?? command.postId.value);
      }

      final actor = await _identityResolver.resolveActor();
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(command.postId.value);

      final revision = <String, dynamic>{
        'body': command.text,
        'edited_by': actor.value,
        'edited_at': FieldValue.serverTimestamp(),
        if (command.idempotencyKey != null)
          'change_description': command.idempotencyKey,
      };

      final updates = <String, dynamic>{
        'text': command.text,
        'updated_at': FieldValue.serverTimestamp(),
        'revisions': FieldValue.arrayUnion([revision]),
      };

      if (command.allowedChartTechniqueIds != null) {
        updates['allowed_chart_technique_ids'] =
            command.allowedChartTechniqueIds;
      }
      if (command.attachments != null) {
        updates['attachments'] =
            command.attachments!.map(_attachmentToMap).toList();
      }

      await docRef.update(updates);
      final snap = await docRef.get();
      return _docToPost(snap.data()!, docRef.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPost> deletePost(DeletePostCommand command) async {
    try {
      if (_config.isRestTombstonePostEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST tombstonePost');
        }
        final uri = _effectiveBaseUri
            .resolve('/playground/posts/${command.postId.value}');
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
        return PlaygroundPost(
          id: command.postId,
          text: '',
          authorUserId: const PlaygroundUserId(''),
          status: PlaygroundPostStatus.tombstoned,
          createdAt: DateTime.now(),
        );
      }

      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(command.postId.value);

      await docRef.update({
        'status': PlaygroundPostStatus.tombstoned.name,
        'updated_at': FieldValue.serverTimestamp(),
      });
      final snap = await docRef.get();
      return _docToPost(snap.data()!, docRef.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId) async {
    try {
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId.value);
      final snap = await docRef.get();
      if (!snap.exists) return null;
      return _docToPost(snap.data()!, snap.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  PlaygroundPost _docToPost(Map<String, dynamic> d, String docId) {
    final statusStr = d['status'] as String? ?? PlaygroundPostStatus.active.name;
    final createdAt = _parseDate(d['created_at']) ?? DateTime.now();
    final updatedAt = _parseDate(d['updated_at']);

    final appUserId =
        d['author_app_user_id'] as String? ?? d['author_provider_uid'] as String? ?? '';

    return PlaygroundPost(
      id: PlaygroundPostId(docId),
      text: d['text'] as String? ?? '',
      authorUserId: PlaygroundUserId(appUserId),
      status: PlaygroundPostStatus.values.byName(statusStr),
      allowedChartTechniqueIds:
          (d['allowed_chart_technique_ids'] as List<dynamic>?)
                  ?.cast<String>() ??
              const <String>[],
      attachments: _parseAttachments(d['attachments']),
      revisions: _parseRevisions(d['revisions']),
      createdAt: createdAt,
      updatedAt: updatedAt,
      hasOutcomeFeedback: d['has_outcome_feedback'] as bool? ?? false,
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  static List<PlaygroundAttachment> _parseAttachments(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((a) => _mapToAttachment(a as Map<String, dynamic>))
        .toList();
  }

  static List<PlaygroundRevision> _parseRevisions(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((r) {
      final rm = r as Map<String, dynamic>;
      final editedAt = rm['edited_at'];
      return PlaygroundRevision(
        body: rm['body'] as String? ?? '',
        editedBy: rm['edited_by'] as String? ?? '',
        editedAt: (editedAt is Timestamp)
            ? editedAt.toDate()
            : (editedAt is DateTime ? editedAt : DateTime.now()),
        changeDescription: rm['change_description'] as String?,
      );
    }).toList();
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

PlaygroundAttachment _mapToAttachment(Map<String, dynamic> m) {
  final typeStr = m['type'] as String? ?? 'image';
  final type = PlaygroundAttachmentType.values.byName(typeStr);
  final mediaIdStr = m['media_object_id'] as String?;
  final moderationStr = m['moderation_state'] as String?;
  final moderationState = moderationStr != null
      ? PlaygroundModerationState.values.byName(moderationStr)
      : PlaygroundModerationState.pending;

  switch (type) {
    case PlaygroundAttachmentType.xuanChart:
      final chartSourceStr = m['chart_source'] as String? ?? 'createdInPlayground';
      return PlaygroundAttachment.xuanChart(
        techniqueId: m['technique_id'] as String? ?? '',
        schoolId: m['school_id'] as String?,
        publicChartSnapshot: m['public_chart_snapshot'] as String? ?? '',
        rendererSchemaVersion: m['renderer_schema_version'] as int? ?? 1,
        source: PlaygroundChartSource.values.byName(chartSourceStr),
      );
    case PlaygroundAttachmentType.image:
      return PlaygroundAttachment.image(
        mediaObjectId: PlaygroundAttachmentId(mediaIdStr ?? ''),
        mimeType: m['mime_type'] as String? ?? 'image/png',
        width: m['width'] as int?,
        height: m['height'] as int?,
        moderationState: moderationState,
      );
    case PlaygroundAttachmentType.video:
      return PlaygroundAttachment.video(
        mediaObjectId: PlaygroundAttachmentId(mediaIdStr ?? ''),
        mimeType: m['mime_type'] as String? ?? 'video/mp4',
        width: m['width'] as int?,
        height: m['height'] as int?,
        durationSeconds: m['duration_seconds'] as int?,
        moderationState: moderationState,
      );
  }
}
