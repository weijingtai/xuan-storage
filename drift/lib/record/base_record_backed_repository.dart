import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'record_cursor.dart';

/// Type-safe reusable record-storage base.
/// Depends only on [ScopedRecordStore] and [RecordModuleCodec<TContract>].
/// Does NOT import Drift, table classes, or datasource internals.
abstract class BaseRecordBackedRepository<TContract> {
  BaseRecordBackedRepository({
    required ScopedRecordStore store,
    required RecordModuleCodec<TContract> codec,
    Uuid? uuid,
  })  : _store = store,
        _codec = codec,
        _uuid = uuid ?? const Uuid();

  final ScopedRecordStore _store;
  final RecordModuleCodec<TContract> _codec;
  final Uuid _uuid;

  String get module => _codec.module;

  // ── save ──
  Future<String> save(TContract contract) async {
    final currentUuid = _codec.uuidOf(contract);
    final effectiveUuid = currentUuid.isNotEmpty ? currentUuid : _uuid.v7();
    final fixed = currentUuid.isNotEmpty ? contract : _codec.withUuid(contract, effectiveUuid);
    final encoded = _codec.encode(fixed, scopeUid: _store.scopeUid);
    _validateEncodedMeta(encoded.meta, effectiveUuid);
    await _store.saveRecord(encoded.meta, moduleData: encoded.moduleData);
    return effectiveUuid;
  }

  // ── read ──
  Future<TContract?> getByUuid(String uuid) async {
    final meta = await _store.getRecord(uuid, module: module);
    return meta == null ? null : _codec.decode(meta, null);
  }

  Future<List<TContract>> getAll({int pageSize = 200}) async {
    final results = <TContract>[];
    String? cursor;
    while (true) {
      final page = await _store.listRecords(module: module, limit: pageSize, cursor: cursor);
      if (page.isEmpty) break;
      results.addAll(page.map((m) => _codec.decode(m, null)));
      if (page.length < pageSize) break;
      cursor = RecordCursor(page.last.createdAt, page.last.uuid).encode();
    }
    return results;
  }

  Stream<List<TContract>> watchAll() =>
      _store.watchRecords(module: module).map((metas) => metas.map((m) => _codec.decode(m, null)).toList());

  Future<List<TContract>> getLatest({int limit = 10}) async {
    final metas = await _store.listRecords(module: module, limit: limit);
    return metas.map((m) => _codec.decode(m, null)).toList();
  }

  // ── delete ──
  Future<bool> softDelete(String uuid) => _store.softDeleteRecord(uuid, module: module);

  // ── index queries ──
  Future<TContract?> getFirstByIndex(String indexKey, String indexValue) async {
    final metas = await _store.findByIndex(module: module, indexKey: indexKey, indexValue: indexValue, limit: 1);
    return metas.isEmpty ? null : _codec.decode(metas.first, null);
  }

  Future<List<TContract>> getAllByIndex(String indexKey, String indexValue, {int limit = 200}) async {
    final metas = await _store.findByIndex(module: module, indexKey: indexKey, indexValue: indexValue, limit: limit);
    return metas.map((m) => _codec.decode(m, null)).toList();
  }

  Stream<TContract?> watchFirstByIndex(String indexKey, String indexValue) =>
      _store.watchByIndex(module: module, indexKey: indexKey, indexValue: indexValue)
          .map((metas) => metas.isEmpty ? null : _codec.decode(metas.first, null));

  void _validateEncodedMeta(RecordMeta meta, String expectedUuid) {
    if (meta.uuid != expectedUuid) throw RecordCodecMismatch(message: 'uuid mismatch');
    if (meta.module != _codec.module) throw RecordCodecMismatch(message: 'module mismatch');
    if (meta.scopeUid != _store.scopeUid) throw RecordCodecMismatch(message: 'scope mismatch');
  }
}
