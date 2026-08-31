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

    // 2.5 ★ C1：事务内原子校验每个声明的 blob —— reconcile 已把 staged 提升
    //    为 committed，此刻逐条 openRead 并完整消费字节流。任何 absent /
    //    partial / corrupt / undecryptable 或流式传输错误都映射为现有
    //    StorageError 并抛出，使 Record、搜索索引、blob refs 与 outbox
    //    在同一事务中整体回滚（缺失/损坏的 blob 不得以部分状态入库）。
    for (final handle in referencedBlobs) {
      await _validateBlobReadable(handle);
    }

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

  /// C1：校验单个被引用 blob 在当前事务内可被完整读取。
  ///
  /// 复用现有 [LocalBlobStore.openRead]（不新增端口/回调/token），把五种
  /// [BlobReadResult] 与流式传输错误映射到现有 StorageError 类型：
  /// - [BlobAbsent] → [BlobNotFoundError]；
  /// - [BlobPartial] → `StorageError(storage.blob_partial)`；
  /// - [BlobCorrupt] 与未知流错误 → [BlobCorruptError]；
  /// - [BlobUndecryptable] 与 openRead 抛出的 [BlobUndecryptableError] →
  ///   [BlobUndecryptableError]。
  ///
  /// 只有 [BlobOk] 且其字节流被无错误消费完毕才算通过；否则抛出，由调用方
  /// 事务整体回滚。
  Future<void> _validateBlobReadable(BlobHandle handle) async {
    final BlobReadResult result;
    try {
      result = await _blobStore.openRead(handle);
    } on BlobUndecryptableError {
      throw BlobUndecryptableError();
    } on BlobCorruptError {
      throw BlobCorruptError();
    } on Object {
      // openRead 阶段的其它异常视为数据不可用（映射为损坏）。
      throw BlobCorruptError();
    }

    switch (result) {
      case BlobAbsent():
        throw BlobNotFoundError();
      case BlobPartial():
        throw StorageError(
          code: 'storage.blob_partial',
          message: 'Referenced blob is incomplete',
          reason:
              'Only part of the chunks of the referenced blob are present',
          suggestion: '请补齐缺失分块或重新上传该 blob 后再保存',
        );
      case BlobCorrupt():
        throw BlobCorruptError();
      case BlobUndecryptable():
        throw BlobUndecryptableError();
      case BlobOk(:final plaintext):
        // 完整消费流：SHA 校验与解密错误在流消费阶段才暴露。
        try {
          await for (final _ in plaintext) {}
        } on BlobUndecryptableError {
          throw BlobUndecryptableError();
        } on BlobCorruptError {
          throw BlobCorruptError();
        } on Object {
          // 流式传输中的其它错误视为损坏（与共享 media reader 的
          // _mapStreamErrors 同一映射口径）。
          throw BlobCorruptError();
        }
        return;
    }
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
