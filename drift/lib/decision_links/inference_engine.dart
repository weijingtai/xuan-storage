import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import '../persistence_drift.dart';

class InferenceEngine {
  final DecisionLinksDao _dao;
  final ScopedRecordStore _recordStore;
  final Uuid _uuid;

  InferenceEngine(this._dao, this._recordStore, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  String get scopeUid => _recordStore.scopeUid;

  Future<String> inferLink({
    required String sourceUuid,
    required String targetUuid,
    required String intent,
    String? sessionId,
    double confidence = 1.0,
    Map<String, dynamic>? inferenceMeta,
  }) async {
    await _validateInputs(sourceUuid, targetUuid);

    final effectiveType = confidence < 0.7 ? 'inference_ambiguous' : 'inference';
    final linkId = _uuid.v7();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final meta = <String, dynamic>{
      'confidence': confidence,
      'inferredAt': DateTime.now().toUtc().toIso8601String(),
      if (inferenceMeta != null) ...inferenceMeta,
    };

    await _dao.upsert(DecisionLinksCompanion.insert(
      id: linkId,
      sourceUuid: sourceUuid,
      targetUuid: targetUuid,
      intent: intent,
      linkType: Value(effectiveType),
      sessionId: Value(sessionId),
      inferenceMetaJson: Value(jsonEncode(meta)),
      scopeUid: scopeUid,
      createdAtMs: nowMs,
      updatedAtMs: nowMs,
    ));
    return linkId;
  }

  Future<int> undoSession(String sessionId) =>
      _dao.deleteBySession(sessionId, scopeUid);

  Future<void> _validateInputs(String sourceUuid, String targetUuid) async {
    if (scopeUid.isEmpty) throw AssertionError('scopeUid must not be empty');
    final source = await _recordStore.getRecord(sourceUuid, module: '');
    if (source == null) throw StateError('Source record $sourceUuid not found');
    if (source.deletedAt != null) throw StateError('Source record $sourceUuid is deleted');
    if (source.scopeUid != scopeUid) throw StateError('Source scope mismatch');
    final target = await _recordStore.getRecord(targetUuid, module: '');
    if (target == null) throw StateError('Target record $targetUuid not found');
    if (target.deletedAt != null) throw StateError('Target record $targetUuid is deleted');
    if (target.scopeUid != scopeUid) throw StateError('Target scope mismatch');
  }
}
