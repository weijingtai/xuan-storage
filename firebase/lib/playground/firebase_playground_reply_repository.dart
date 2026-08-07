import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'package:persistence_core/persistence_core.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';

final class FirebasePlaygroundReplyRepository
    implements PlaygroundReplyRemoteDataSource {
  FirebasePlaygroundReplyRepository({
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
  Future<PlaygroundRootReply> createRootReply(CreateRootReplyCommand command) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final user = _auth.currentUser!;
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.replies).doc();

      final data = <String, dynamic>{
        'post_id': command.postId.value,
        'author_provider_uid': user.uid,
        'author_app_user_id': actor.value,
        'depth': 0,
        'body': command.body,
        'is_root': true,
        'root_reply_id': null,
        'reply_to_reply_id': null,
        'technique_tags': command.techniqueTags,
        'chart_attachment':
            command.chartAttachment != null ? _attachmentToMap(command.chartAttachment!) : null,
        'media_attachments':
            command.mediaAttachments.map(_attachmentToMap).toList(),
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': null,
        'revisions': <Map<String, dynamic>>[],
      };

      if (command.idempotencyKey != null) {
        data['idempotency_key'] = command.idempotencyKey;
      }

      await docRef.set(data);
      final snap = await docRef.get();
      return _docToRootReply(snap.data()!, docRef.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundDiscussionReply> createDiscussionReply(
      CreateDiscussionReplyCommand command) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final user = _auth.currentUser!;
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.replies).doc();

      final data = <String, dynamic>{
        'post_id': command.postId.value,
        'author_provider_uid': user.uid,
        'author_app_user_id': actor.value,
        'depth': 1,
        'body': command.body,
        'is_root': false,
        'root_reply_id': command.rootReplyId.value,
        'reply_to_reply_id': command.replyToReplyId?.value,
        'technique_tags': <String>[],
        'chart_attachment': null,
        'media_attachments':
            command.mediaAttachments.map(_attachmentToMap).toList(),
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': null,
        'revisions': <Map<String, dynamic>>[],
      };

      if (command.idempotencyKey != null) {
        data['idempotency_key'] = command.idempotencyKey;
      }

      await docRef.set(data);
      final snap = await docRef.get();
      return _docToDiscussionReply(snap.data()!, docRef.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundRootReply> editRootReply(EditReplyCommand command) async {
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
      return _docToRootReply(snap.data()!, docRef.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundDiscussionReply> editDiscussionReply(EditReplyCommand command) async {
    try {
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc(command.replyId.value);

      final updates = <String, dynamic>{
        'body': command.body,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (command.mediaAttachments != null) {
        updates['media_attachments'] =
            command.mediaAttachments!.map(_attachmentToMap).toList();
      }

      await docRef.update(updates);
      final snap = await docRef.get();
      return _docToDiscussionReply(snap.data()!, docRef.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteReply(DeleteReplyCommand command) async {
    try {
      await _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc(command.replyId.value)
          .update({
        'status': 'tombstoned',
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<Object>> getReplies(GetRepliesQuery query) async {
    try {
      var q = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .where('post_id', isEqualTo: query.postId.value)
          .where('status', isEqualTo: 'active')
          .orderBy('depth', descending: false)
          .orderBy('created_at', descending: false)
          .limit(query.limit);

      if (query.cursor != null && query.cursor!.isNotEmpty) {
        final startDoc = FirebasePlaygroundCursor.toDocumentReference(
            query.cursor!, _firestore);
        if (startDoc != null) {
          final startSnap = await startDoc.get();
          q = q.startAfterDocument(startSnap);
        }
      }

      final snaps = await q.get();
      final items = <Object>[];

      for (final snap in snaps.docs) {
        final d = snap.data();
        final isRoot = d['is_root'] as bool? ?? true;
        if (isRoot) {
          items.add(_docToRootReply(d, snap.id));
        } else {
          items.add(_docToDiscussionReply(d, snap.id));
        }
      }

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == query.limit
          ? FirebasePlaygroundCursor.fromQueryDocument(snaps.docs.last)
          : null;

      return PlaygroundPage(
        items: items,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  PlaygroundRootReply _docToRootReply(Map<String, dynamic> d, String docId) {
    final timestamp = d['created_at'] as Timestamp?;
    final updatedTs = d['updated_at'] as Timestamp?;
    final chartAtt = d['chart_attachment'];

    return PlaygroundRootReply(
      id: PlaygroundReplyId(docId),
      postId: PlaygroundPostId(d['post_id'] as String? ?? ''),
      authorUserId: PlaygroundUserId(
          d['author_app_user_id'] as String? ?? d['author_provider_uid'] as String? ?? ''),
      body: d['body'] as String? ?? '',
      techniqueTags:
          (d['technique_tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      chartAttachment: chartAtt is Map<String, dynamic>
          ? _mapToAttachment(chartAtt)
          : null,
      mediaAttachments: _parseAttachments(d['media_attachments']),
      revisions: _parseRevisions(d['revisions']),
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate(),
      isTombstoned: d['status'] == 'tombstoned',
    );
  }

  PlaygroundDiscussionReply _docToDiscussionReply(Map<String, dynamic> d, String docId) {
    final timestamp = d['created_at'] as Timestamp?;
    final updatedTs = d['updated_at'] as Timestamp?;
    final replyToId = d['reply_to_reply_id'] as String?;

    return PlaygroundDiscussionReply(
      id: PlaygroundReplyId(docId),
      postId: PlaygroundPostId(d['post_id'] as String? ?? ''),
      rootReplyId: PlaygroundReplyId(d['root_reply_id'] as String? ?? ''),
      replyToReplyId: replyToId != null ? PlaygroundReplyId(replyToId) : null,
      authorUserId: PlaygroundUserId(
          d['author_app_user_id'] as String? ?? d['author_provider_uid'] as String? ?? ''),
      body: d['body'] as String? ?? '',
      mediaAttachments: _parseAttachments(d['media_attachments']),
      revisions: _parseRevisions(d['revisions']),
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate(),
      isTombstoned: d['status'] == 'tombstoned',
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
