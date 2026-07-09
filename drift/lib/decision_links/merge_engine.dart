import 'package:drift/drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import '../persistence_drift.dart';

class MergeEngine {
  final DecisionLinksDao _dao;
  final ScopedRecordStore _recordStore;
  final Uuid _uuid;

  MergeEngine(this._dao, this._recordStore, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  String get scopeUid => _recordStore.scopeUid;

  /// 多条源记录合并到一条已存在的目标记录。
  Future<void> mergeInto(
    List<String> sourceUuids,
    String targetUuid, {
    String? sessionId,
  }) async {
    if (scopeUid.isEmpty) throw AssertionError('scopeUid must not be empty');

    for (final sourceUuid in sourceUuids) {
      final source = await _recordStore.getRecord(sourceUuid, module: '');
      if (source == null) throw StateError('Source record $sourceUuid not found');
      if (source.deletedAt != null) throw StateError('Source record $sourceUuid is deleted');
      if (source.scopeUid != scopeUid) throw StateError('Source scope mismatch');
    }

    final target = await _recordStore.getRecord(targetUuid, module: '');
    if (target == null) throw StateError('Target record $targetUuid not found');
    if (target.deletedAt != null) throw StateError('Target record $targetUuid is deleted');
    if (target.scopeUid != scopeUid) throw StateError('Target scope mismatch');

    final effectiveSessionId = sessionId ?? _uuid.v7();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < sourceUuids.length; i++) {
      await _dao.upsert(DecisionLinksCompanion.insert(
        id: _uuid.v7(),
        sourceUuid: sourceUuids[i],
        targetUuid: targetUuid,
        intent: 'merge',
        linkType: Value('merge'),
        sessionId: Value(effectiveSessionId),
        mergeTargetUuid: Value(targetUuid),
        scopeUid: scopeUid,
        createdAtMs: nowMs + i,
        updatedAtMs: nowMs + i,
      ));
    }
  }
}
