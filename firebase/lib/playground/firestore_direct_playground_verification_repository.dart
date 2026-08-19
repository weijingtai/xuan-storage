/// Firestore 直写应验仓库（Task 5）。
///
/// Design: docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md
/// - §4.2：`verify_{postId}_{rootReplyId}` 独立文档，不改 reply；
/// - §7.1：Poster-only；同帖、depth=0、未墓碑、非 Poster 自己回复；
///   verify→revoke→reverify 状态机；created_at 保持、revoked_at null↔time；
/// - §12.2：canVerify 只表示 viewer 是帖子 owner，真正越权写由 Rules 拒绝
///   （此处 adapter 做前置校验，防异常路径）。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firestore_direct_playground_command_support.dart';

/// 应验直写仓库 —— 生产装配的 provider。
final class FirestoreDirectPlaygroundVerificationRepository
    implements PlaygroundVerificationRepository {
  FirestoreDirectPlaygroundVerificationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String _docId(String postId, String rootReplyId) =>
      'verify_${postId}_$rootReplyId';

  @override
  Future<PlaygroundVerification> verifyRootReply(
      VerifyRootReplyCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      final docId = _docId(command.postId.value, command.rootReplyId.value);
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .doc(docId);

      final result = await _firestore.runTransaction((tx) async {
        // Poster-only。
        await _assertPoster(tx, command.postId.value, actor.providerUid);

        // 目标回复校验：同帖、depth=0、未墓碑、非 Poster 自己。
        await _assertVerifyTarget(tx, command, actor.providerUid);

        final existing = await tx.get(docRef);
        final now = FieldValue.serverTimestamp();
        if (!existing.exists) {
          tx.set(docRef, {
            'id': docId,
            'post_id': command.postId.value,
            'root_reply_id': command.rootReplyId.value,
            'created_at': now,
            'revoked_at': null,
          });
          return _verification(command, actor, null);
        }

        final data = existing.data()!;
        // re-verify：非空 revoked_at → null（created_at 不变）。
        tx.update(docRef, {
          'revoked_at': null,
        });
        return _verification(
          command,
          actor,
          _tsToDate(data['created_at']),
        );
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
  Future<PlaygroundVerification> revokeVerification(
      RevokeVerificationCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      final docId = _docId(command.postId.value, command.rootReplyId.value);
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .doc(docId);

      final result = await _firestore.runTransaction((tx) async {
        await _assertPoster(tx, command.postId.value, actor.providerUid);
        final existing = await tx.get(docRef);
        if (!existing.exists) {
          throw directPlaygroundError(
            code: PlaygroundErrorCode.notFound,
            machineCode: 'content/not-found',
            message: '应验事实不存在',
          );
        }
        tx.update(docRef, {
          'revoked_at': FieldValue.serverTimestamp(),
        });
        return _verification(
          command,
          actor,
          _tsToDate(existing.data()!['created_at']),
          revokedAt: DateTime.now(),
        );
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
  Future<List<PlaygroundVerification>> getVerificationsForPost(
      PlaygroundPostId postId) async {
    try {
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .where('post_id', isEqualTo: postId.value)
          .get();
      return snaps.docs.map((doc) {
        final d = doc.data();
        return PlaygroundVerification(
          postId: PlaygroundPostId(d['post_id'] as String? ?? ''),
          rootReplyId: PlaygroundReplyId(d['root_reply_id'] as String? ?? ''),
          posterUserId: PlaygroundUserId(''),
          createdAt: _tsToDate(d['created_at']) ?? DateTime.now(),
          revokedAt: _tsToDate(d['revoked_at']),
        );
      }).toList();
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
  Future<bool> isRootReplyVerified(PlaygroundReplyId rootReplyId) async {
    try {
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .where('root_reply_id', isEqualTo: rootReplyId.value)
          .where('revoked_at', isNull: true)
          .limit(1)
          .get();
      return snaps.docs.isNotEmpty;
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
        message: '仅帖子作者可应验',
      );
    }
  }

  Future<void> _assertVerifyTarget(
    Transaction tx,
    VerifyRootReplyCommand command,
    String posterUid,
  ) async {
    final replySnap = await tx.get(_firestore
        .collection(PlaygroundFirestoreSchema.replies)
        .doc(command.rootReplyId.value));
    if (!replySnap.exists) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.notFound,
        machineCode: 'content/not-found',
        message: '目标回复不存在',
      );
    }
    final reply = replySnap.data()!;
    if (reply['post_id'] != command.postId.value) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'validation/invalid-payload',
        message: '跨帖应验',
      );
    }
    if (reply['depth'] != 0) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'validation/invalid-payload',
        message: '只能应验根回复',
      );
    }
    if (reply['is_tombstoned'] == true) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.tombstoned,
        machineCode: 'content/tombstoned',
        message: '回复已删除',
      );
    }
    // 禁止应验 Poster 自己的回复。
    final replyOwnerSnap = await tx.get(_firestore
        .collection(PlaygroundFirestoreSchema.replyOwners)
        .doc(command.rootReplyId.value));
    final replyOwner = replyOwnerSnap.data();
    if (replyOwner != null && replyOwner['provider_uid'] == posterUid) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.forbidden,
        machineCode: 'authorization/forbidden',
        message: '不能应验自己的回复',
      );
    }
  }

  PlaygroundVerification _verification(
    dynamic command,
    DirectWriteActor actor,
    DateTime? createdAt, {
    DateTime? revokedAt,
  }) {
    final postId = command is VerifyRootReplyCommand
        ? command.postId
        : (command as RevokeVerificationCommand).postId;
    final rootReplyId = command is VerifyRootReplyCommand
        ? command.rootReplyId
        : (command as RevokeVerificationCommand).rootReplyId;
    return PlaygroundVerification(
      postId: postId,
      rootReplyId: rootReplyId,
      posterUserId: PlaygroundUserId(actor.appUserId),
      createdAt: createdAt ?? DateTime.now(),
      revokedAt: revokedAt,
    );
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
