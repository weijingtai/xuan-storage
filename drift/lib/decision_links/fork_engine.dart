import 'package:drift/drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import '../persistence_drift.dart';

class ForkEngine {
  final DecisionLinksDao _dao;
  final ScopedRecordStore _recordStore;
  final Uuid _uuid;

  ForkEngine(this._dao, this._recordStore, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  String get scopeUid => _recordStore.scopeUid;

  /// 从一条源记录分叉出多条子记录，每一条记录创建 fork 类型 link。
  /// 返回共享的 sessionId。
  Future<String> fork(String sourceUuid, List<String> targetUuids, {String? sessionId}) async {
    if (scopeUid.isEmpty) throw AssertionError('scopeUid must not be empty');
    final source = await _recordStore.getRecord(sourceUuid, module: '');
    if (source == null) throw StateError('Source record $sourceUuid not found');
    if (source.deletedAt != null) throw StateError('Source record $sourceUuid is deleted');
    if (source.scopeUid != scopeUid) throw StateError('Source scope mismatch');

    final effectiveSessionId = sessionId ?? _uuid.v7();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < targetUuids.length; i++) {
      final targetUuid = targetUuids[i];
      final target = await _recordStore.getRecord(targetUuid, module: '');
      if (target == null) throw StateError('Target record $targetUuid not found');
      if (target.deletedAt != null) throw StateError('Target record $targetUuid is deleted');
      if (target.scopeUid != scopeUid) throw StateError('Target scope mismatch');

      await _dao.upsert(DecisionLinksCompanion.insert(
        id: _uuid.v7(),
        sourceUuid: sourceUuid,
        targetUuid: targetUuid,
        intent: 'fork',
        linkType: Value('fork'),
        sessionId: Value(effectiveSessionId),
        scopeUid: scopeUid,
        createdAtMs: nowMs + i,
        updatedAtMs: nowMs + i,
      ));
    }

    return effectiveSessionId;
  }
}
