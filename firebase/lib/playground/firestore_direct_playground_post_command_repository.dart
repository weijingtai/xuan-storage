/// Firestore 直写帖子命令仓库（Task 3）。
///
/// Design: docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md
/// - §3.2/§3.3：公开帖子不含内部身份；owner 私有文档同批创建；
/// - §4.1/§4.3：append-only revision；tombstone 先追加最后 revision 再清空公开正文；
/// - §4.4/§5：payload 键集合与 schema fixture 一致；
/// - §6.1：帖子 Rules 不变量（create/update 仅 owner）；
/// - §8：确定性文档 ID = sha256(v1|op|authUid|key)，payload hash canonical。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_public_mapper.dart';
import 'firestore_direct_playground_command_support.dart';

/// 帖子直写命令仓库 —— 生产装配的 provider。
final class FirestoreDirectPlaygroundPostCommandRepository
    implements PlaygroundPostCommandRepository {
  FirestoreDirectPlaygroundPostCommandRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundPublicMapper _mapper;

  static const _operation = 'post-create';

  // ---- create ----

  @override
  Future<PublicPost> createPost(CreatePostCommand command) async {
    try {
      _assertNoPrivacyContext(command.privacyContext,
          command.privacyConfirmations);
      final key = _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      final postId = deterministicCreateId(
        operation: _operation,
        authUid: actor.providerUid,
        idempotencyKey: key,
      );
      final presentation = _postPresentation(command, postId, actor);
      final attachments =
          command.attachments.map(_attachmentToMap).toList(growable: false);
      final publicPayload = <String, dynamic>{
        'id': postId,
        'text': command.text,
        'presentation_mode': presentation['presentation_mode'],
        'presentation_identity_id': presentation['presentation_identity_id'],
        'presentation_display_alias': presentation['presentation_display_alias'],
        'presentation_avatar_url': presentation['presentation_avatar_url'],
        'public_profile_ref': presentation['public_profile_ref'],
        'status': 'active',
        'allowed_chart_technique_ids': command.allowedChartTechniqueIds,
        'attachments': attachments,
        'has_chart': command.allowedChartTechniqueIds.isNotEmpty ||
            attachments.isNotEmpty,
        'revision_no': 1,
        'current_revision_id': 'r0000000001',
        'idempotency_key': key,
        'payload_hash': canonicalJsonHash({
          'text': command.text,
          'allowed_chart_technique_ids': command.allowedChartTechniqueIds,
          'attachments': attachments,
          'presentation_mode': presentation['presentation_mode'],
          'presentation_identity_id': presentation['presentation_identity_id'],
          'presentation_display_alias': presentation['presentation_display_alias'],
        }),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      final revision = _revisionPayload(
        id: 'r0000000001',
        parentId: '',
        revisionNo: 1,
        body: command.text,
        techniqueTags: const [],
        chartAttachment: null,
        mediaAttachments: const [],
        presentation: presentation,
      );

      await _firestore.runTransaction((tx) async {
        final postRef =
            _firestore.collection(PlaygroundFirestoreSchema.posts).doc(postId);
        final existing = await tx.get(postRef);
        if (existing.exists) {
          final existingPayload =
              existing.data()?['payload_hash'] as String?;
          if (existingPayload == publicPayload['payload_hash']) {
            return; // 幂等 replay：同一 key 同一 payload。
          }
          throw directPlaygroundError(
            code: PlaygroundErrorCode.conflict,
            machineCode: 'idempotency/payload-conflict',
            message: '同一幂等键已被用于不同内容',
          );
        }

        final ownerRef = _firestore
            .collection(PlaygroundFirestoreSchema.postOwners)
            .doc(postId);
        final revisionRef = postRef
            .collection(PlaygroundFirestoreSchema.postRevisions)
            .doc('r0000000001');

        tx.set(postRef, publicPayload);
        tx.set(ownerRef,
            actor.ownerPayload(contentId: postId));
        tx.set(revisionRef, revision);
      });

      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId)
          .get();
      return _mapper.publicPostFromDoc(
        postId,
        snap.data()!,
        replyCount: 0,
        likeCount: 0,
        verificationCount: 0,
        viewerState: const PlaygroundPostViewerState(
          isOwner: true,
          canEdit: true,
          canDelete: true,
          canSetFeedback: true,
        ),
        presentationMode: command.presentationMode,
      );
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw directPlaygroundError(
        code: PlaygroundErrorCode.unavailable,
        machineCode: 'provider/unavailable',
        message: 'Firestore 暂不可用',
        cause: e,
      );
    }
  }

  // ---- edit ----

  @override
  Future<PublicPost> editPost(EditPostCommand command) async {
    try {
      _assertNoPrivacyContext(command.privacyContext,
          command.privacyConfirmations);
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);
      final postId = command.postId.value;

      final postRef =
          _firestore.collection(PlaygroundFirestoreSchema.posts).doc(postId);
      final result = await _firestore.runTransaction((tx) async {
        final ownerSnap = await tx.get(_firestore
            .collection(PlaygroundFirestoreSchema.postOwners)
            .doc(postId));
        final owner = ownerSnap.data();
        if (owner == null || owner['provider_uid'] != actor.providerUid) {
          throw directPlaygroundError(
            code: PlaygroundErrorCode.forbidden,
            machineCode: 'authorization/forbidden',
            message: '仅帖子作者可编辑',
          );
        }

        final postSnap = await tx.get(postRef);
        if (!postSnap.exists) {
          throw directPlaygroundError(
            code: PlaygroundErrorCode.notFound,
            machineCode: 'content/not-found',
            message: '帖子不存在',
          );
        }
        final current = postSnap.data()!;
        if (current['status'] == 'tombstoned') {
          throw directPlaygroundError(
            code: PlaygroundErrorCode.tombstoned,
            machineCode: 'content/tombstoned',
            message: '帖子已删除，无法编辑',
          );
        }

        final revisionNo = (current['revision_no'] as int? ?? 1) + 1;
        final revisionId =
            'r${revisionNo.toString().padLeft(10, '0')}';
        final presentation = _revisionPresentationFrom(current, actor);

        final attachments = command.attachments != null
            ? command.attachments!.map(_attachmentToMap).toList()
            : current['attachments'] as List<dynamic>? ?? <dynamic>[];
        final techniqueIds = command.allowedChartTechniqueIds ??
            (current['allowed_chart_technique_ids'] as List<dynamic>?)
                    ?.cast<String>() ??
            <String>[];

        tx.set(postRef.collection(PlaygroundFirestoreSchema.postRevisions)
            .doc(revisionId), _revisionPayload(
          id: revisionId,
          parentId: current['current_revision_id'] as String? ?? 'r0000000001',
          revisionNo: revisionNo,
          body: command.text,
          techniqueTags: const [],
          chartAttachment: null,
          mediaAttachments: const [],
          presentation: presentation,
        ));
        tx.update(postRef, {
          'text': command.text,
          'allowed_chart_technique_ids': techniqueIds,
          'attachments': attachments,
          'revision_no': revisionNo,
          'current_revision_id': revisionId,
          'updated_at': FieldValue.serverTimestamp(),
        });

        // 本地构造更新后的文档（fake/emulator 不支持事务内读后写）。
        final updated = <String, dynamic>{...current}
          ..['text'] = command.text
          ..['allowed_chart_technique_ids'] = techniqueIds
          ..['attachments'] = attachments
          ..['revision_no'] = revisionNo
          ..['current_revision_id'] = revisionId;
        return updated;
      });

      return _mapper.publicPostFromDoc(
        postId,
        result,
        replyCount: 0,
        likeCount: 0,
        verificationCount: 0,
        viewerState: const PlaygroundPostViewerState(
          isOwner: true,
          canEdit: true,
          canDelete: true,
          canSetFeedback: true,
        ),
      );
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw directPlaygroundError(
        code: PlaygroundErrorCode.unavailable,
        machineCode: 'provider/unavailable',
        message: 'Firestore 暂不可用',
        cause: e,
      );
    }
  }

  // ---- tombstone ----

  @override
  Future<void> tombstonePost(DeletePostCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);
      final postId = command.postId.value;

      final postRef =
          _firestore.collection(PlaygroundFirestoreSchema.posts).doc(postId);
      await _firestore.runTransaction((tx) async {
        final ownerSnap = await tx.get(_firestore
            .collection(PlaygroundFirestoreSchema.postOwners)
            .doc(postId));
        final owner = ownerSnap.data();
        if (owner == null || owner['provider_uid'] != actor.providerUid) {
          throw directPlaygroundError(
            code: PlaygroundErrorCode.forbidden,
            machineCode: 'authorization/forbidden',
            message: '仅帖子作者可删除',
          );
        }

        final postSnap = await tx.get(postRef);
        if (!postSnap.exists) {
          throw directPlaygroundError(
            code: PlaygroundErrorCode.notFound,
            machineCode: 'content/not-found',
            message: '帖子不存在',
          );
        }
        final current = postSnap.data()!;
        if (current['status'] == 'tombstoned') {
          return; // 幂等：已墓碑。
        }

        // 先追加最后 revision，保存公开正文快照。
        final revisionNo = (current['revision_no'] as int? ?? 1) + 1;
        final revisionId =
            'r${revisionNo.toString().padLeft(10, '0')}';
        final presentation = _revisionPresentationFrom(current, actor);

        tx.set(postRef.collection(PlaygroundFirestoreSchema.postRevisions)
            .doc(revisionId), _revisionPayload(
          id: revisionId,
          parentId: current['current_revision_id'] as String? ?? 'r0000000001',
          revisionNo: revisionNo,
          body: current['text'] as String? ?? '',
          techniqueTags: const [],
          chartAttachment: null,
          mediaAttachments: const [],
          presentation: presentation,
        ));

        // 再清空公开正文/附件/技法。
        tx.update(postRef, {
          'status': 'tombstoned',
          'text': '',
          'attachments': <dynamic>[],
          'allowed_chart_technique_ids': <dynamic>[],
          'revision_no': revisionNo,
          'current_revision_id': revisionId,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw directPlaygroundError(
        code: PlaygroundErrorCode.unavailable,
        machineCode: 'provider/unavailable',
        message: 'Firestore 暂不可用',
        cause: e,
      );
    }
  }

  // ---- get ----

  @override
  Future<PublicPost?> getPublicPost(PlaygroundPostId postId) async {
    try {
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId.value)
          .get();
      if (!snap.exists) return null;
      final doc = snap.data()!;

      final viewerState = await _mapper.viewerStateForPost(postId.value, doc);
      return _mapper.publicPostFromDoc(
        postId.value,
        doc,
        replyCount: 0,
        likeCount: 0,
        verificationCount: 0,
        viewerState: viewerState,
      );
    } catch (e) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.unavailable,
        machineCode: 'provider/unavailable',
        message: 'Firestore 暂不可用',
        cause: e,
      );
    }
  }

  // ---- helpers ----

  Map<String, dynamic> _postPresentation(
    CreatePostCommand command,
    String postId,
    DirectWriteActor actor,
  ) {
    if (command.presentationMode == PlaygroundPresentationMode.oneTimeAnonymous) {
      return actor.oneTimeAnonymousPresentationPayload(identityId: 'post_$postId');
    }
    return actor.presentationPayload();
  }

  Map<String, dynamic> _revisionPresentationFrom(
    Map<String, dynamic> current,
    DirectWriteActor actor,
  ) {
    final mode = current['presentation_mode'] as String? ?? 'stableAlias';
    return {
      'presentation_mode': mode,
      'presentation_identity_id':
          current['presentation_identity_id'] ?? actor.publicPresentationId,
      'presentation_display_alias':
          current['presentation_display_alias'] ?? actor.publicDisplayAlias,
      'presentation_avatar_url': current['presentation_avatar_url'],
      'public_profile_ref': current['public_profile_ref'],
    };
  }

  Map<String, dynamic> _revisionPayload({
    required String id,
    required String parentId,
    required int revisionNo,
    required String body,
    required List<String> techniqueTags,
    required Map<String, dynamic>? chartAttachment,
    required List<Map<String, dynamic>> mediaAttachments,
    required Map<String, dynamic> presentation,
  }) {
    return {
      'id': id,
      'parent_id': parentId,
      'revision_no': revisionNo,
      'body': body,
      'presentation_mode': presentation['presentation_mode'],
      'presentation_identity_id': presentation['presentation_identity_id'],
      'presentation_display_alias': presentation['presentation_display_alias'],
      'presentation_avatar_url': presentation['presentation_avatar_url'],
      'public_profile_ref': presentation['public_profile_ref'],
      'technique_tags': techniqueTags,
      'chart_attachment': chartAttachment,
      'media_attachments': mediaAttachments,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _attachmentToMap(PlaygroundAttachment a) {
    return {
      'type': a.type.name,
      if (a.techniqueId != null) 'technique_id': a.techniqueId,
      if (a.schoolId != null) 'school_id': a.schoolId,
      if (a.publicChartSnapshot != null)
        'public_chart_snapshot': a.publicChartSnapshot,
      if (a.rendererSchemaVersion != null)
        'renderer_schema_version': a.rendererSchemaVersion,
      if (a.chartSource != null) 'chart_source': a.chartSource!.name,
      if (a.mediaObjectId != null) 'media_object_id': a.mediaObjectId!.value,
      if (a.mimeType != null) 'mime_type': a.mimeType,
      if (a.width != null) 'width': a.width,
      if (a.height != null) 'height': a.height,
      if (a.durationSeconds != null) 'duration_seconds': a.durationSeconds,
      if (a.moderationState != null) 'moderation_state': a.moderationState!.name,
    };
  }

  static String _requireIdempotencyKey(String? key) {
    if (key == null || key.isEmpty) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'idempotency/invalid-key',
        message: '缺少幂等键',
      );
    }
    return key;
  }

  static void _assertNoPrivacyContext(
    PlaygroundPrivacyContext? context,
    List<PlaygroundPrivacyConfirmation> confirmations,
  ) {
    final hasContext = context != null &&
        (context.gender != null ||
            context.birthplace != null ||
            context.yearLife != null ||
            context.publiclyConfirmedFields.isNotEmpty);
    if (hasContext || confirmations.isNotEmpty) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'privacy/storage-unavailable',
        message: '隐私存储合同尚未完成，无法发布',
      );
    }
  }
}
