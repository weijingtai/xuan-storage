/// Drift 实现的 RecordBlobUnitOfWork。
///
/// 在单个事务内先写记录、再对账 blob 引用，任一步失败则整体回滚。
library;

import 'dart:convert';

import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

/// Drift-backed [RecordBlobUnitOfWork].
final class DriftRecordBlobUnitOfWork implements RecordBlobUnitOfWork {
  DriftRecordBlobUnitOfWork({
    required PersistenceDriftDatabase db,
    required String scopeUid,
    required DriftLocalBlobStore blobStore,
    RecordAdapterRegistry? adapterRegistry,
    Future<void> Function()? injectFailureAfterSave,
  })  : _db = db,
        _blobStore = blobStore,
        _recordDataSource = DriftRecordDataSource(db, scopeUid: scopeUid),
        _adapterRegistry = adapterRegistry,
        _injectFailureAfterSave = injectFailureAfterSave;

  final PersistenceDriftDatabase _db;
  final DriftLocalBlobStore _blobStore;
  final DriftRecordDataSource _recordDataSource;
  final RecordAdapterRegistry? _adapterRegistry;
  final Future<void> Function()? _injectFailureAfterSave;

  @override
  Future<void> saveWithBlobs({
    required RecordMeta record,
    required Set<BlobHandle> referencedBlobs,
  }) async {
    final moduleData = record.moduleDataJson != null
        ? jsonDecode(record.moduleDataJson!) as Map<String, dynamic>
        : null;
    final tags = _adapterRegistry
            ?.forModule(record.module)
            ?.extractSearchTags(record, moduleData) ??
        <SearchTag>[];

    await _db.transaction(() async {
      await _recordDataSource.saveRecord(record, tags);
      await _injectFailureAfterSave?.call();
      await _blobStore.reconcileRefs(
        ownerRecordUuid: record.uuid,
        handles: referencedBlobs,
      );
    });
  }

  @override
  Future<void> deleteWithBlobs(String recordUuid) async {
    await _db.transaction(() async {
      // 1. Soft delete record
      await _recordDataSource.softDeleteRecord(recordUuid);

      // 2. Release blob refs
      await _blobStore.reconcileRefs(
        ownerRecordUuid: recordUuid,
        handles: {},
      );
    });
  }
}