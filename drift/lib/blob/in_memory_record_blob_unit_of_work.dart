/// 内存实现的 RecordBlobUnitOfWork fake。
///
/// 用于测试，不依赖 Drift 数据库。具有与 DriftRecordBlobUnitOfWork 同等的原子性与可观察契约。
library;

import 'dart:convert';

import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/record/record_adapter_registry.dart';
import 'package:persistence_drift/sync/record_outbox_mapper.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

/// In-memory fake of [RecordBlobUnitOfWork].
final class InMemoryRecordBlobUnitOfWork implements RecordBlobUnitOfWork {
  InMemoryRecordBlobUnitOfWork({
    OutboxStore? outboxStore,
    RecordAdapterRegistry? adapterRegistry,
    Future<void> Function()? injectFailureAfterRecord,
    Future<void> Function()? injectFailureAfterBlobRefs,
    Future<void> Function()? injectFailureAfterOutbox,
    Future<void> Function()? injectFailureAfterSave,
  })  : _outboxStore = outboxStore,
        _adapterRegistry = adapterRegistry,
        _injectFailureAfterRecord = injectFailureAfterRecord ?? injectFailureAfterSave,
        _injectFailureAfterBlobRefs = injectFailureAfterBlobRefs,
        _injectFailureAfterOutbox = injectFailureAfterOutbox;

  final Map<String, RecordMeta> _records = {};
  final Map<String, Set<BlobHandle>> _refs = {};
  final Map<String, List<SearchTag>> _searchTags = {};
  final OutboxStore? _outboxStore;
  final RecordAdapterRegistry? _adapterRegistry;
  final Future<void> Function()? _injectFailureAfterRecord;
  final Future<void> Function()? _injectFailureAfterBlobRefs;
  final Future<void> Function()? _injectFailureAfterOutbox;
  bool _locked = false;

  /// Returns all stored records (for test assertions).
  Map<String, RecordMeta> get records => Map.unmodifiable(_records);

  /// Returns all stored blob refs (for test assertions).
  Map<String, Set<BlobHandle>> get refs =>
      _refs.map((k, v) => MapEntry(k, Set.unmodifiable(v)));

  /// Returns all stored search tags (for test assertions).
  Map<String, List<SearchTag>> get searchTags =>
      _searchTags.map((k, v) => MapEntry(k, List.unmodifiable(v)));

  @override
  Future<void> saveWithBlobs({
    required RecordMeta record,
    required Set<BlobHandle> referencedBlobs,
  }) async {
    if (_locked) throw StateError('Transaction conflict');
    _locked = true;
    final prevRecords = Map<String, RecordMeta>.of(_records);
    final prevRefs = _refs.map((k, v) => MapEntry(k, Set<BlobHandle>.of(v)));
    final prevTags = _searchTags.map((k, v) => MapEntry(k, List<SearchTag>.of(v)));

    try {
      final moduleData = record.moduleDataJson != null
          ? jsonDecode(record.moduleDataJson!) as Map<String, dynamic>
          : null;
      final tags = _adapterRegistry
              ?.forModule(record.module)
              ?.extractSearchTags(record, moduleData) ??
          <SearchTag>[];

      // 1. Record + tags
      _records[record.uuid] = record;
      _searchTags[record.uuid] = tags;
      await _injectFailureAfterRecord?.call();

      // 2. Blob refs
      _refs[record.uuid] = Set.of(referencedBlobs);
      await _injectFailureAfterBlobRefs?.call();

      // 3. Outbox
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
    } catch (_) {
      _records
        ..clear()
        ..addAll(prevRecords);
      _refs
        ..clear()
        ..addAll(prevRefs);
      _searchTags
        ..clear()
        ..addAll(prevTags);
      rethrow;
    } finally {
      _locked = false;
    }
  }

  @override
  Future<void> deleteWithBlobs(String recordUuid) async {
    if (_locked) throw StateError('Transaction conflict');
    _locked = true;
    final prevRecords = Map<String, RecordMeta>.of(_records);
    final prevRefs = _refs.map((k, v) => MapEntry(k, Set<BlobHandle>.of(v)));
    final prevTags = _searchTags.map((k, v) => MapEntry(k, List<SearchTag>.of(v)));

    try {
      final existing = _records[recordUuid];
      if (existing != null) {
        _records[recordUuid] = existing.copyWith(deletedAt: DateTime.now().toUtc());
        _searchTags.remove(recordUuid);
      }
      await _injectFailureAfterRecord?.call();

      _refs.remove(recordUuid);
      await _injectFailureAfterBlobRefs?.call();

      if (existing != null) {
        final outbox = _outboxStore;
        if (outbox != null) {
          final outboxRecord = RecordOutboxMapper.toOutboxRecord(
            meta: existing.copyWith(deletedAt: DateTime.now().toUtc()),
            opType: RecordOutboxMapper.opDelete,
          );
          await outbox.enqueue(outboxRecord);
        }
      }
      await _injectFailureAfterOutbox?.call();
    } catch (_) {
      _records
        ..clear()
        ..addAll(prevRecords);
      _refs
        ..clear()
        ..addAll(prevRefs);
      _searchTags
        ..clear()
        ..addAll(prevTags);
      rethrow;
    } finally {
      _locked = false;
    }
  }

  @override
  Future<bool> restoreWithBlobs({
    required RecordMeta record,
    required Set<BlobHandle> referencedBlobs,
  }) async {
    if (_locked) throw StateError('Transaction conflict');
    _locked = true;
    final prevRecords = Map<String, RecordMeta>.of(_records);
    final prevRefs = _refs.map((k, v) => MapEntry(k, Set<BlobHandle>.of(v)));
    final prevTags = _searchTags.map((k, v) => MapEntry(k, List<SearchTag>.of(v)));

    try {
      final existing = _records[record.uuid];
      if (existing == null || existing.deletedAt == null) {
        return false;
      }
      final moduleData = record.moduleDataJson != null
          ? jsonDecode(record.moduleDataJson!) as Map<String, dynamic>
          : null;
      final tags = _adapterRegistry
              ?.forModule(record.module)
              ?.extractSearchTags(record, moduleData) ??
          <SearchTag>[];

      // Restore record
      _records[record.uuid] = record;
      _searchTags[record.uuid] = tags;
      await _injectFailureAfterRecord?.call();

      // Restore refs
      _refs[record.uuid] = Set.of(referencedBlobs);
      await _injectFailureAfterBlobRefs?.call();

      // Enqueue outbox
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
    } catch (_) {
      _records
        ..clear()
        ..addAll(prevRecords);
      _refs
        ..clear()
        ..addAll(prevRefs);
      _searchTags
        ..clear()
        ..addAll(prevTags);
      rethrow;
    } finally {
      _locked = false;
    }
  }
}