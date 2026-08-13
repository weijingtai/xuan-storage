import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';

/// Phase 7B：举报端口 adapter（PlaygroundReportRepository）。
///
/// - submitReport 直写 `playground_reports`（Rules 允许客户端创建，reporter
///   取自 Auth session 的 provider uid；**零可伪造身份字段**）；
/// - 严格单目标 [PlaygroundContentTarget]（六类 target_type/target_id）；
/// - getMyReportState 读单文档返回 [PlaygroundReportState]。
final class FirebasePlaygroundReportRepository
    implements PlaygroundReportRepository {
  FirebasePlaygroundReportRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<PlaygroundReportReceipt> submitReport(
      PlaygroundReportCommand command) async {
    try {
      final user = _auth.currentUser!;
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.reports).doc();

      final (targetType, targetId) = _encodeTarget(command.target);

      final data = <String, dynamic>{
        'reporter_provider_uid': user.uid,
        'target_type': targetType,
        'target_id': targetId,
        'reason': command.reason.name,
        'state': PlaygroundReportState.pending.name,
        'created_at': FieldValue.serverTimestamp(),
        if (command.description != null) 'description': command.description,
        if (command.evidenceRef != null) 'evidence_ref': command.evidenceRef,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };

      await docRef.set(data);

      return PlaygroundReportReceipt(
        reportId: PlaygroundReportId(docRef.id),
        target: command.target,
        state: PlaygroundReportState.pending,
        submittedAt: DateTime.now(),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundReportState> getMyReportState(
      PlaygroundReportId reportId) async {
    try {
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.reports)
          .doc(reportId.value)
          .get();
      if (!snap.exists) return PlaygroundReportState.pending;
      final state = snap.data()?['state'] as String? ?? 'pending';
      return _stateFromName(state);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  static (String, String) _encodeTarget(PlaygroundContentTarget target) {
    return switch (target) {
      PostTarget(:final id) => ('post', id.value),
      ReplyTarget(:final id) => ('reply', id.value),
      ProfileTarget(:final presentationUserId) => ('profile', presentationUserId.value),
      ConversationTarget(:final id) => ('conversation', id.value),
      MessageTarget(:final id) => ('message', id.value),
      MediaTarget(:final attachmentId) => ('media', attachmentId.value),
    };
  }

  static PlaygroundReportState _stateFromName(String name) {
    for (final state in PlaygroundReportState.values) {
      if (state.name == name) return state;
    }
    return PlaygroundReportState.pending;
  }
}
