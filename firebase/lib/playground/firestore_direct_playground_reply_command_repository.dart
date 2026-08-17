/// Firestore 直写回复命令仓库（Task 4）。
///
/// Design: docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md
/// - §3.2：one-time anonymous 匿名 ID 内容派生为 `post_{postId}`（与帖子一致）；
/// - §4.1/§4.3：append-only revision；tombstone 清空公开正文；
/// - §6.2：root/discussion 两层；跨帖/跨 root/负 depth/第三层/墓碑目标拒绝；
/// - §8：确定性文档 ID；公开 reply 零内部 UID。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_public_mapper.dart';
import 'firestore_direct_playground_command_support.dart';

/// 回复直写命令仓库 —— 生产装配的 provider。
final class FirestoreDirectPlaygroundReplyCommandRepository
    implements PlaygroundReplyCommandRepository {
  FirestoreDirectPlaygroundReplyCommandRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundPublicMapper _mapper;

  static const _rootOperation = 'reply-root-create';
  static const _discussionOperation = 'reply-discussion-create';

  // ---- createRootReply ----

  @override
  Future<PublicReply> createRootReply(CreateRootReplyCommand command) async {
    try {
      final key = _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      final replyId = deterministicCreateId(
        operation: _rootOperation,
        authUid: actor.providerUid,
        idempotencyKey: key,
      );

      final postRef = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(command.postId.value);
      final replyRef = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc(replyId);
      final ownerRef = _firestore
          .collection(PlaygroundFirestoreSchema.replyOwners)
          .doc(replyId);
      final revisionRef = replyRef
          .collection(PlaygroundFirestoreSchema.postRevisions)
          .doc('r0000000001');

      return await boundedRetryWithConfirmation<PublicReply>(
        writeAction: () async {
          // 目标 post 必须存在且 active。
          final postSnap = await postRef.get();
          if (!postSnap.exists || postSnap.data()?['status'] != 'active') {
            throw directPlaygroundError(
              code: PlaygroundErrorCode.notFound,
              machineCode: 'content/not-found',
              message: '目标帖子不存在或已关闭',
            );
          }

          final presentation = _resolveReplyPresentation(
            postId: command.postId.value,
            actor: actor,
            mode: command.presentationMode,
          );

          final attachments =
              command.mediaAttachments.map(_attachmentToMap).toList(growable: false);
          final chartMap =
              command.chartAttachment != null ? _attachmentToMap(command.chartAttachment!) : null;

          final replyPayload = <String, dynamic>{
            'id': replyId,
            'post_id': command.postId.value,
            'presentation_mode': presentation['presentation_mode'],
            'presentation_identity_id': presentation['presentation_identity_id'],
            'presentation_display_alias': presentation['presentation_display_alias'],
            'presentation_avatar_url': presentation['presentation_avatar_url'],
            'public_profile_ref': presentation['public_profile_ref'],
            'depth': 0,
            'body': command.body,
            'is_tombstoned': false,
            'root_reply_id': null,
            'reply_to_reply_id': null,
            'technique_tags': command.techniqueTags,
            'chart_attachment': chartMap,
            'media_attachments': attachments,
            'revision_no': 1,
            'current_revision_id': 'r0000000001',
            'idempotency_key': key,
            'payload_hash': canonicalJsonHash({
              'post_id': command.postId.value,
              'body': command.body,
              'technique_tags': command.techniqueTags,
              'chart_attachment': chartMap,
              'media_attachments': attachments,
              'presentation_mode': presentation['presentation_mode'],
              'presentation_identity_id': presentation['presentation_identity_id'],
              'presentation_display_alias': presentation['presentation_display_alias'],
            }),
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          };

          final revisionPayload = _revisionPayload(
            id: 'r0000000001',
            parentId: '',
            revisionNo: 1,
            body: command.body,
            techniqueTags: command.techniqueTags,
            chartAttachment: chartMap,
            mediaAttachments: attachments,
            presentation: presentation,
          );

          final batch = _firestore.batch();
          batch.set(replyRef, replyPayload);
          batch.set(ownerRef, actor.ownerPayload(contentId: replyId));
          batch.set(revisionRef, revisionPayload);
          await batch.commit();
        },
        checkConfirmed: () async {
          final snap = await replyRef.get();
          if (snap.exists) {
            return _mapper.publicReplyFromDoc(replyId, snap.data()!);
          }
          return null;
        },
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

  // ---- createDiscussionReply ----

  @override
  Future<PublicReply> createDiscussionReply(
      CreateDiscussionReplyCommand command) async {
    try {
      final key = _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      final replyId = deterministicCreateId(
        operation: _discussionOperation,
        authUid: actor.providerUid,
        idempotencyKey: key,
      );

      final postRef = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(command.postId.value);
      final rootRef = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc(command.rootReplyId.value);
      final replyRef = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc(replyId);
      final ownerRef = _firestore
          .collection(PlaygroundFirestoreSchema.replyOwners)
          .doc(replyId);
      final revisionRef = replyRef
          .collection(PlaygroundFirestoreSchema.postRevisions)
          .doc('r0000000001');

      return await boundedRetryWithConfirmation<PublicReply>(
        writeAction: () async {
          // 目标 post 存在且 active。
          final postSnap = await postRef.get();
          if (!postSnap.exists || postSnap.data()?['status'] != 'active') {
            throw directPlaygroundError(
              code: PlaygroundErrorCode.notFound,
              machineCode: 'content/not-found',
              message: '目标帖子不存在或已关闭',
            );
          }

          // root 必须存在、同帖、depth=0、未墓碑。
          final rootSnap = await rootRef.get();
          if (!rootSnap.exists) {
            throw directPlaygroundError(
              code: PlaygroundErrorCode.notFound,
              machineCode: 'content/not-found',
              message: '根回复不存在',
            );
          }
          final rootData = rootSnap.data()!;
          if (rootData['post_id'] != command.postId.value ||
              rootData['depth'] != 0) {
            throw directPlaygroundError(
              code: PlaygroundErrorCode.invalidArgument,
              machineCode: 'validation/invalid-payload',
              message: '跨帖或非根回复',
            );
          }
          if (rootData['is_tombstoned'] == true) {
            throw directPlaygroundError(
              code: PlaygroundErrorCode.tombstoned,
              machineCode: 'content/tombstoned',
              message: '根回复已删除',
            );
          }

          // reply_to 若提供：必须存在、同帖、同 root、depth=0、未墓碑。
          if (command.replyToReplyId != null) {
            final replyToSnap = await _firestore
                .collection(PlaygroundFirestoreSchema.replies)
                .doc(command.replyToReplyId!.value)
                .get();
            if (!replyToSnap.exists) {
              throw directPlaygroundError(
                code: PlaygroundErrorCode.notFound,
                machineCode: 'content/not-found',
                message: '被回复对象不存在',
              );
            }
            final replyTo = replyToSnap.data()!;
            final sameRoot = replyTo['root_reply_id'] ==
                rootData['id'];
            if (replyTo['post_id'] != command.postId.value ||
                !sameRoot ||
                replyTo['depth'] != 0) {
              throw directPlaygroundError(
                code: PlaygroundErrorCode.invalidArgument,
                machineCode: 'validation/invalid-payload',
                message: '跨 root 或第三层回复',
              );
            }
            if (replyTo['is_tombstoned'] == true) {
              throw directPlaygroundError(
                code: PlaygroundErrorCode.tombstoned,
                machineCode: 'content/tombstoned',
                message: '被回复对象已删除',
              );
            }
          }

          final presentation = _resolveReplyPresentation(
            postId: command.postId.value,
            actor: actor,
            mode: command.presentationMode,
          );

          final attachments =
              command.mediaAttachments.map(_attachmentToMap).toList(growable: false);

          final replyPayload = <String, dynamic>{
            'id': replyId,
            'post_id': command.postId.value,
            'presentation_mode': presentation['presentation_mode'],
            'presentation_identity_id': presentation['presentation_identity_id'],
            'presentation_display_alias': presentation['presentation_display_alias'],
            'presentation_avatar_url': presentation['presentation_avatar_url'],
            'public_profile_ref': presentation['public_profile_ref'],
            'depth': 1,
            'body': command.body,
            'is_tombstoned': false,
            'root_reply_id': command.rootReplyId.value,
            'reply_to_reply_id': command.replyToReplyId?.value,
            'technique_tags': <String>[],
            'chart_attachment': null,
            'media_attachments': attachments,
            'revision_no': 1,
            'current_revision_id': 'r0000000001',
            'idempotency_key': key,
            'payload_hash': canonicalJsonHash({
              'post_id': command.postId.value,
              'root_reply_id': command.rootReplyId.value,
              'reply_to_reply_id': command.replyToReplyId?.value,
              'body': command.body,
              'media_attachments': attachments,
              'presentation_mode': presentation['presentation_mode'],
              'presentation_identity_id': presentation['presentation_identity_id'],
              'presentation_display_alias': presentation['presentation_display_alias'],
            }),
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          };

          final revisionPayload = _revisionPayload(
            id: 'r0000000001',
            parentId: '',
            revisionNo: 1,
            body: command.body,
            techniqueTags: const [],
            chartAttachment: null,
            mediaAttachments: attachments,
            presentation: presentation,
          );

          final batch = _firestore.batch();
          batch.set(replyRef, replyPayload);
          batch.set(ownerRef, actor.ownerPayload(contentId: replyId));
          batch.set(revisionRef, revisionPayload);
          await batch.commit();
        },
        checkConfirmed: () async {
          final snap = await replyRef.get();
          if (snap.exists) {
            return _mapper.publicReplyFromDoc(replyId, snap.data()!);
          }
          return null;
        },
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

  // ---- editReply ----

  @override
  Future<PublicReply> editReply(EditReplyCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);
      final replyId = command.replyId.value;

      final replyRef = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc(replyId);

      return await boundedRetryWithConfirmation<PublicReply>(
        writeAction: () async {
          await _assertReplyOwner(replyId, actor.providerUid);
          final snap = await replyRef.get();
          if (!snap.exists) {
            throw directPlaygroundError(
              code: PlaygroundErrorCode.notFound,
              machineCode: 'content/not-found',
              message: '回复不存在',
            );
          }
          final current = snap.data()!;
          if (current['is_tombstoned'] == true) {
            throw directPlaygroundError(
              code: PlaygroundErrorCode.tombstoned,
              machineCode: 'content/tombstoned',
              message: '回复已删除，无法编辑',
            );
          }

          final revisionNo = (current['revision_no'] as int? ?? 1) + 1;
          final revisionId = 'r${revisionNo.toString().padLeft(10, '0')}';
          final presentation = _presentationFrom(current, actor);
          final List<Map<String, dynamic>> attachments =
              command.mediaAttachments != null
                  ? command.mediaAttachments!.map(_attachmentToMap).toList()
                  : (current['media_attachments'] as List<dynamic>?)
                          ?.whereType<Map<String, dynamic>>()
                          .toList() ??
                      <Map<String, dynamic>>[];
          final techniqueTags = command.techniqueTags ??
              (current['technique_tags'] as List<dynamic>?)?.cast<String>() ??
              <String>[];
          final Map<String, dynamic>? chartMap = command.chartAttachment != null
              ? _attachmentToMap(command.chartAttachment!)
              : (current['chart_attachment'] as Map<String, dynamic>?);

          final batch = _firestore.batch();
          batch.set(
            replyRef.collection(PlaygroundFirestoreSchema.postRevisions).doc(revisionId),
            _revisionPayload(
              id: revisionId,
              parentId: current['current_revision_id'] as String? ?? 'r0000000001',
              revisionNo: revisionNo,
              body: command.body,
              techniqueTags: techniqueTags,
              chartAttachment: chartMap,
              mediaAttachments: attachments,
              presentation: presentation,
            ),
          );
          batch.update(replyRef, {
            'body': command.body,
            'technique_tags': techniqueTags,
            'chart_attachment': chartMap,
            'media_attachments': attachments,
            'revision_no': revisionNo,
            'current_revision_id': revisionId,
            'updated_at': FieldValue.serverTimestamp(),
          });
          await batch.commit();
        },
        checkConfirmed: () async {
          final snap = await replyRef.get();
          if (snap.exists) {
            return _mapper.publicReplyFromDoc(replyId, snap.data()!);
          }
          return null;
        },
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

  // ---- tombstoneReply ----

  @override
  Future<void> tombstoneReply(DeleteReplyCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);
      final replyId = command.replyId.value;

      final replyRef = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc(replyId);

      await boundedRetryWithConfirmation<bool>(
        writeAction: () async {
          await _assertReplyOwner(replyId, actor.providerUid);
          final snap = await replyRef.get();
          if (!snap.exists) {
            throw directPlaygroundError(
              code: PlaygroundErrorCode.notFound,
              machineCode: 'content/not-found',
              message: '回复不存在',
            );
          }
          final current = snap.data()!;
          if (current['is_tombstoned'] == true) {
            return; // 幂等。
          }

          final revisionNo = (current['revision_no'] as int? ?? 1) + 1;
          final revisionId = 'r${revisionNo.toString().padLeft(10, '0')}';
          final presentation = _presentationFrom(current, actor);

          final batch = _firestore.batch();
          batch.set(
            replyRef.collection(PlaygroundFirestoreSchema.postRevisions).doc(revisionId),
            _revisionPayload(
              id: revisionId,
              parentId: current['current_revision_id'] as String? ?? 'r0000000001',
              revisionNo: revisionNo,
              body: current['body'] as String? ?? '',
              techniqueTags: const [],
              chartAttachment: null,
              mediaAttachments: const [],
              presentation: presentation,
            ),
          );
          batch.update(replyRef, {
            'is_tombstoned': true,
            'body': '',
            'technique_tags': <dynamic>[],
            'chart_attachment': null,
            'media_attachments': <dynamic>[],
            'revision_no': revisionNo,
            'current_revision_id': revisionId,
            'updated_at': FieldValue.serverTimestamp(),
          });
          await batch.commit();
        },
        checkConfirmed: () async {
          final snap = await replyRef.get();
          if (snap.exists && snap.data()?['is_tombstoned'] == true) {
            return true;
          }
          return null;
        },
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

  // ---- helpers ----

  Future<void> _assertReplyOwner(
    String replyId,
    String providerUid,
  ) async {
    final ownerSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.replyOwners)
        .doc(replyId)
        .get();
    final owner = ownerSnap.data();
    if (owner == null || owner['provider_uid'] != providerUid) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.forbidden,
        machineCode: 'authorization/forbidden',
        message: '仅回复作者可操作',
      );
    }
  }

  /// 解析展示身份（§3.2）。one-time anonymous 匿名 ID 内容派生为
  /// `post_{postId}`（与帖子一致，确定性、零状态）；stableAlias 用账号公开投影。
  Map<String, dynamic> _resolveReplyPresentation({
    required String postId,
    required DirectWriteActor actor,
    required PlaygroundPresentationMode mode,
  }) {
    if (mode == PlaygroundPresentationMode.oneTimeAnonymous) {
      return actor.oneTimeAnonymousPresentationPayload(identityId: 'post_$postId');
    }
    return actor.presentationPayload();
  }

  Map<String, dynamic> _presentationFrom(
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
}
