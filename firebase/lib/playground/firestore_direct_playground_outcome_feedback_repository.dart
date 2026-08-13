/// Firestore 直写最终反馈仓库（Task 5）。
///
/// Design: docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md
/// - §4.2：`feedback_{postId}` 独立文档；每帖一份当前事实；
/// - §4.3：append-only revision；撤回把 outcome_description='' 并置 deleted_at；
/// - §7.2：Poster-only；发布→编辑→撤回→再发布；发布不改 post 状态；
/// - 零 outbox/notification。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firestore_direct_playground_command_support.dart';

/// 最终反馈直写仓库 —— 生产装配的 provider。
final class FirestoreDirectPlaygroundOutcomeFeedbackRepository
    implements PlaygroundOutcomeFeedbackRepository {
  FirestoreDirectPlaygroundOutcomeFeedbackRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String _docId(String postId) => 'feedback_$postId';

  @override
  Future<PlaygroundOutcomeFeedback> setOutcomeFeedback(
      SetOutcomeFeedbackCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      final docId = _docId(command.postId.value);
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.outcomeFeedback)
          .doc(docId);

      final result = await _firestore.runTransaction((tx) async {
        await _assertPoster(tx, command.postId.value, actor.providerUid);

        final existing = await tx.get(docRef);
        final now = FieldValue.serverTimestamp();
        if (!existing.exists) {
          // 首次发布：创建事实 + revision 1。
          tx.set(docRef, {
            'id': docId,
            'post_id': command.postId.value,
            'outcome_description': command.body,
            'revision_no': 1,
            'current_revision_id': 'r0000000001',
            'created_at': now,
            'updated_at': now,
            'deleted_at': null,
          });
          tx.set(docRef.collection(PlaygroundFirestoreSchema.postRevisions)
              .doc('r0000000001'), _revisionPayload(
            id: 'r0000000001',
            parentId: '',
            revisionNo: 1,
            body: command.body,
          ));
          return _feedback(command.postId.value, actor, command.body, 1,
              null);
        }

        // 已存在：编辑（追加 revision）或再发布（清空 deleted_at）。
        final data = existing.data()!;
        final revisionNo = (data['revision_no'] as int? ?? 1) + 1;
        final revisionId = 'r${revisionNo.toString().padLeft(10, '0')}';
        final wasDeleted = data['deleted_at'] != null;

        tx.set(docRef.collection(PlaygroundFirestoreSchema.postRevisions)
            .doc(revisionId), _revisionPayload(
          id: revisionId,
          parentId: data['current_revision_id'] as String? ?? 'r0000000001',
          revisionNo: revisionNo,
          body: command.body,
        ));
        tx.update(docRef, {
          'outcome_description': command.body,
          'revision_no': revisionNo,
          'current_revision_id': revisionId,
          'updated_at': now,
          'deleted_at': null, // 再发布清空删除标记。
        });

        return _feedback(command.postId.value, actor, command.body, revisionNo,
            wasDeleted ? null : _tsToDate(data['created_at']));
      });

      return result;
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

  @override
  Future<void> revokeOutcomeFeedback(
      RevokeOutcomeFeedbackCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      final docId = _docId(command.postId.value);
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.outcomeFeedback)
          .doc(docId);

      await _firestore.runTransaction((tx) async {
        await _assertPoster(tx, command.postId.value, actor.providerUid);
        final existing = await tx.get(docRef);
        if (!existing.exists) {
          throw directPlaygroundError(
            code: PlaygroundErrorCode.notFound,
            machineCode: 'content/not-found',
            message: '反馈不存在',
          );
        }
        final data = existing.data()!;
        if (data['deleted_at'] != null) return; // 幂等：已撤回。

        final revisionNo = (data['revision_no'] as int? ?? 1) + 1;
        final revisionId = 'r${revisionNo.toString().padLeft(10, '0')}';

        // 先追加最后 revision（保存撤回前的正文），再清空并置 deleted_at。
        tx.set(docRef.collection(PlaygroundFirestoreSchema.postRevisions)
            .doc(revisionId), _revisionPayload(
          id: revisionId,
          parentId: data['current_revision_id'] as String? ?? 'r0000000001',
          revisionNo: revisionNo,
          body: data['outcome_description'] as String? ?? '',
        ));
        tx.update(docRef, {
          'outcome_description': '',
          'revision_no': revisionNo,
          'current_revision_id': revisionId,
          'updated_at': FieldValue.serverTimestamp(),
          'deleted_at': FieldValue.serverTimestamp(),
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

  @override
  Future<PlaygroundOutcomeFeedback?> getOutcomeFeedback(
      PlaygroundPostId postId) async {
    try {
      final docId = _docId(postId.value);
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.outcomeFeedback)
          .doc(docId)
          .get();
      if (!snap.exists) return null;
      final d = snap.data()!;
      return PlaygroundOutcomeFeedback(
        id: d['id'] as String? ?? docId,
        postId: PlaygroundPostId(d['post_id'] as String? ?? postId.value),
        authorUserId: PlaygroundUserId(''),
        body: d['outcome_description'] as String? ?? '',
        createdAt: _tsToDate(d['created_at']) ?? DateTime.now(),
        updatedAt: _tsToDate(d['updated_at']),
        deletedAt: _tsToDate(d['deleted_at']),
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

  Future<void> _assertPoster(
    Transaction tx,
    String postId,
    String providerUid,
  ) async {
    final ownerSnap = await tx.get(_firestore
        .collection(PlaygroundFirestoreSchema.postOwners)
        .doc(postId));
    final owner = ownerSnap.data();
    if (owner == null || owner['provider_uid'] != providerUid) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.forbidden,
        machineCode: 'authorization/forbidden',
        message: '仅帖子作者可操作最终反馈',
      );
    }
  }

  PlaygroundOutcomeFeedback _feedback(
    String postId,
    DirectWriteActor actor,
    String body,
    int revisionNo,
    DateTime? createdAt,
  ) {
    return PlaygroundOutcomeFeedback(
      id: _docId(postId),
      postId: PlaygroundPostId(postId),
      authorUserId: PlaygroundUserId(actor.appUserId),
      body: body,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: revisionNo > 1 ? DateTime.now() : null,
      deletedAt: null,
    );
  }

  Map<String, dynamic> _revisionPayload({
    required String id,
    required String parentId,
    required int revisionNo,
    required String body,
  }) {
    return {
      'id': id,
      'parent_id': parentId,
      'revision_no': revisionNo,
      'body': body,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  DateTime? _tsToDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
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
