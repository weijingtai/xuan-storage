/// Drift 实现的 RecordBlobUnitOfWork。
///
/// 在单个事务内先写记录与搜索索引、再对账 blob 引用、最后写入 outbox，任一步失败则整体回滚。
library;

import 'dart:convert';

import 'package:meta/meta.dart' show visibleForTesting;
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/sync/record_outbox_mapper.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

/// Drift-backed [RecordBlobUnitOfWork].
final class DriftRecordBlobUnitOfWork implements RecordBlobUnitOfWork {
  DriftRecordBlobUnitOfWork({
    required PersistenceDriftDatabase db,
    required String scopeUid,
    required DriftLocalBlobStore blobStore,
    required OutboxStore outboxStore,
    RecordAdapterRegistry? adapterRegistry,
    Future<void> Function()? injectFailureAfterRecord,
    Future<void> Function()? injectFailureAfterBlobRefs,
    Future<void> Function()? injectFailureAfterOutbox,
    Future<void> Function()? injectFailureAfterSave,
  }) : this._(
         db: db,
         scopeUid: scopeUid,
         blobStore: blobStore,
         adapterRegistry: adapterRegistry,
         outboxStore: outboxStore,
         injectFailureAfterRecord: injectFailureAfterRecord,
         injectFailureAfterBlobRefs: injectFailureAfterBlobRefs,
         injectFailureAfterOutbox: injectFailureAfterOutbox,
         injectFailureAfterSave: injectFailureAfterSave,
       );

  /// Test-only constructor for isolated record/blob tests that intentionally
  /// do not model sync outbox delivery. Production composition must use the
  /// required [OutboxStore] constructor above.
  @visibleForTesting
  factory DriftRecordBlobUnitOfWork.testWithoutOutbox({
    required PersistenceDriftDatabase db,
    required String scopeUid,
    required DriftLocalBlobStore blobStore,
    RecordAdapterRegistry? adapterRegistry,
    Future<void> Function()? injectFailureAfterRecord,
    Future<void> Function()? injectFailureAfterBlobRefs,
    Future<void> Function()? injectFailureAfterOutbox,
    Future<void> Function()? injectFailureAfterSave,
  }) => DriftRecordBlobUnitOfWork._(
    db: db,
    scopeUid: scopeUid,
    blobStore: blobStore,
    adapterRegistry: adapterRegistry,
    outboxStore: null,
    injectFailureAfterRecord: injectFailureAfterRecord,
    injectFailureAfterBlobRefs: injectFailureAfterBlobRefs,
    injectFailureAfterOutbox: injectFailureAfterOutbox,
    injectFailureAfterSave: injectFailureAfterSave,
  );

  DriftRecordBlobUnitOfWork._({
    required PersistenceDriftDatabase db,
    required String scopeUid,
    required DriftLocalBlobStore blobStore,
    required RecordAdapterRegistry? adapterRegistry,
    required OutboxStore? outboxStore,
    required Future<void> Function()? injectFailureAfterRecord,
    required Future<void> Function()? injectFailureAfterBlobRefs,
    required Future<void> Function()? injectFailureAfterOutbox,
    required Future<void> Function()? injectFailureAfterSave,
  }) : _db = db,
       _blobStore = blobStore,
       _recordDataSource = DriftRecordDataSource(db, scopeUid: scopeUid),
       _adapterRegistry = adapterRegistry,
       _outboxStore = outboxStore,
       _injectFailureAfterRecord =
           injectFailureAfterRecord ?? injectFailureAfterSave,
       _injectFailureAfterBlobRefs = injectFailureAfterBlobRefs,
       _injectFailureAfterOutbox = injectFailureAfterOutbox;

  final PersistenceDriftDatabase _db;
  final DriftLocalBlobStore _blobStore;
  final DriftRecordDataSource _recordDataSource;
  final RecordAdapterRegistry? _adapterRegistry;
  final OutboxStore? _outboxStore;
  final Future<void> Function()? _injectFailureAfterRecord;
  final Future<void> Function()? _injectFailureAfterBlobRefs;
  final Future<void> Function()? _injectFailureAfterOutbox;

  /// 直接在调用方当前事务中执行 Record + Blob 引用 + Outbox 写入。
  Future<void> saveWithBlobsDirect({
    required RecordMeta record,
    required Set<BlobHandle> referencedBlobs,
    Map<String, dynamic>? moduleData,
    List<SearchTag>? tags,
  }) async {
    final effectiveModuleData =
        moduleData ??
        (record.moduleDataJson != null
            ? jsonDecode(record.moduleDataJson!) as Map<String, dynamic>
            : null);
    final effectiveTags =
        tags ??
        _adapterRegistry
            ?.forModule(record.module)
            ?.extractSearchTags(record, effectiveModuleData) ??
        <SearchTag>[];

    // 1. Save record + search index
    await _recordDataSource.saveRecordDirect(record, effectiveTags);
    await _injectFailureAfterRecord?.call();

    // 2. Reconcile blob refs
    await _blobStore.reconcileRefs(
      ownerRecordUuid: record.uuid,
      handles: referencedBlobs,
    );
    await _injectFailureAfterBlobRefs?.call();

    // 3. Enqueue outbox
    final outbox = _outboxStore;
    if (outbox != null) {
      final outboxRecord = RecordOutboxMapper.toOutboxRecord(
        meta: record,
        moduleData: effectiveModuleData,
        tags: effectiveTags,
        opType: RecordOutboxMapper.opUpsert,
      );
      await outbox.enqueue(outboxRecord);
    }
    await _injectFailureAfterOutbox?.call();
  }

  @override
  Future<void> saveWithBlobs({
    required RecordMeta record,
    required Set<BlobHandle> referencedBlobs,
  }) async {
    await _db.transaction(() async {
      await saveWithBlobsDirect(
        record: record,
        referencedBlobs: referencedBlobs,
      );
    });
  }

  @override
  Future<void> deleteWithBlobs(String recordUuid) async {
    await _db.transaction(() async {
      final meta = await _recordDataSource.getRecord(recordUuid);

      // 1. Soft delete record
      final deleted = await _recordDataSource.softDeleteRecordDirect(
        recordUuid,
      );
      await _injectFailureAfterRecord?.call();

      // 2. Release blob refs
      await _blobStore.reconcileRefs(ownerRecordUuid: recordUuid, handles: {});
      await _injectFailureAfterBlobRefs?.call();

      // 3. Enqueue outbox
      if (deleted && meta != null) {
        final outbox = _outboxStore;
        if (outbox != null) {
          final outboxRecord = RecordOutboxMapper.toOutboxRecord(
            meta: meta.copyWith(deletedAt: DateTime.now().toUtc()),
            opType: RecordOutboxMapper.opDelete,
          );
          await outbox.enqueue(outboxRecord);
        }
      }
      await _injectFailureAfterOutbox?.call();
    });
  }

  @override
  Future<bool> restoreWithBlobs({
    required RecordMeta record,
    required Set<BlobHandle> referencedBlobs,
  }) async {
    final moduleData = record.moduleDataJson != null
        ? jsonDecode(record.moduleDataJson!) as Map<String, dynamic>
        : null;
    final tags =
        _adapterRegistry
            ?.forModule(record.module)
            ?.extractSearchTags(record, moduleData) ??
        <SearchTag>[];

    return await _db.transaction(() async {
      // 1. Restore record + search index
      final restored = await _recordDataSource.restoreRecordDirect(
        record,
        tags,
      );
      if (!restored) return false;
      await _injectFailureAfterRecord?.call();

      // 2. Reconcile blob refs
      await _blobStore.reconcileRefs(
        ownerRecordUuid: record.uuid,
        handles: referencedBlobs,
      );
      await _injectFailureAfterBlobRefs?.call();

      // 3. Enqueue outbox
      final outbox = _outboxStore;
      if (outbox != null) {
        final outboxRecord = RecordOutboxMapper.toOutboxRecord(
          meta: record,
          moduleData: moduleData,
          tags: tags,
          opType: RecordOutboxMapper.opUpsert,
        );
        await outbox.enqueue(outboxRecord);
      }
      await _injectFailureAfterOutbox?.call();

      return true;
    });
  }
}
