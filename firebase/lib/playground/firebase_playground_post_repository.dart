import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'package:persistence_core/persistence_core.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';

final class FirebasePlaygroundPostRepository
    implements PlaygroundPostRemoteDataSource {
  FirebasePlaygroundPostRepository({
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
  Future<PlaygroundPost> createPost(CreatePostCommand command) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final user = _auth.currentUser!;
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.posts).doc();

      final data = <String, dynamic>{
        'author_provider_uid': user.uid,
        'author_app_user_id': actor.value,
        'text': command.text,
        'allowed_chart_technique_ids': command.allowedChartTechniqueIds,
        'attachments': command.attachments.map(_attachmentToMap).toList(),
        'status': PlaygroundPostStatus.active.name,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': null,
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
    final timestamp = d['created_at'] as Timestamp?;
    final updatedTs = d['updated_at'] as Timestamp?;

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
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate(),
      hasOutcomeFeedback: d['has_outcome_feedback'] as bool? ?? false,
    );
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
