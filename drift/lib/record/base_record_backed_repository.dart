import 'dart:async';

import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';

import 'record_entity_descriptor.dart';
import 'record_row_mapper.dart';
import 'record_storage_driver.dart';

/// Type-safe reusable record-storage base.
///
/// M1 起该基类降级为**适配层**：既有九个方法保留原签名，内部全部委托
/// L0 契约内核（[CrudBaseRepository] + [RecordStorageDriver] +
/// [recordEntityDescriptor]）。保证八个模块的 record_backed_* 仓储
/// **零改动**继续可用。M4 将整体退场，调用方直接使用 L0 切片。
///
/// 依赖仅限 [ScopedRecordStore] 与 [RecordModuleCodec<TContract>] 端口，
/// 不 import Drift 表类或数据源内部。
abstract class BaseRecordBackedRepository<TContract> {
  BaseRecordBackedRepository({
    required ScopedRecordStore store,
    required RecordModuleCodec<TContract> codec,
    Uuid? uuid,
  })  : _store = store,
        _codec = codec,
        _uuid = uuid ?? const Uuid(),
        _l0 = CrudBaseRepository<Map<String, Object?>, String>(
          descriptor: recordEntityDescriptor(module: codec.module),
          driver: RecordStorageDriver(store: store),
        );

  final ScopedRecordStore _store;
  final RecordModuleCodec<TContract> _codec;
  final Uuid _uuid;

  /// L0 契约内核仓储（切片组合：CrudBaseRepository + RecordStorageDriver）。
  final CrudBaseRepository<Map<String, Object?>, String> _l0;

  String get module => _codec.module;

  RequestContext get _ctx => RequestContext(scopeUid: _store.scopeUid);

  /// 行 → 契约实体：RecordMeta + moduleData 一起交给 codec decode。
  TContract _decodeRow(Map<String, Object?> row) => _codec.decode(
        RecordRowMapper.rowToMeta(row),
        RecordRowMapper.moduleDataOf(row),
      );

  // ── save ──
  @Deprecated('M4 退场，改用 L0 切片')
  Future<String> save(TContract contract) async {
    final currentUuid = _codec.uuidOf(contract);
    final effectiveUuid = currentUuid.isNotEmpty ? currentUuid : _uuid.v7();
    final fixed =
        currentUuid.isNotEmpty ? contract : _codec.withUuid(contract, effectiveUuid);
    final encoded = _codec.encode(fixed, scopeUid: _store.scopeUid);
    _validateEncodedMeta(encoded.meta, effectiveUuid);
    final row = RecordRowMapper.metaToRow(encoded.meta);
    final r = await _l0.put(row, _ctx);
    if (r case Err(error: final e)) {
      throw e;
    }
    return effectiveUuid;
  }

  // ── read ──
  @Deprecated('M4 退场，改用 L0 切片')
  Future<TContract?> getByUuid(String uuid) async {
    final r = await _l0.getIncludingDeleted(uuid, _ctx);
    if (r case Ok(value: final row)) {
      return row == null ? null : _decodeRow(row);
    }
    return null;
  }

  @Deprecated('M4 退场，改用 L0 切片')
  Future<List<TContract>> getAll({int pageSize = 200}) async {
    final results = <TContract>[];
    String? cursor;
    while (true) {
      final r = await _l0.query(
        const {},
        PageRequest(limit: pageSize, cursor: cursor),
        _ctx,
      );
      final page = (r as Ok<Page<Map<String, Object?>>>).value;
      results.addAll(page.items.map(_decodeRow));
      if (!page.hasMore) break;
      cursor = page.nextCursor;
    }
    return results;
  }

  // ── watch ──
  @Deprecated('M4 退场，改用 L0 切片')
  Stream<List<TContract>> watchAll() => _l0
      .watch({'category': _codec.category}, _ctx)
      .map((r) => ((r as Ok<List<Map<String, Object?>>>).value)
          .map(_decodeRow)
          .toList());

  @Deprecated('M4 退场，改用 L0 切片')
  Future<List<TContract>> getLatest({int limit = 10}) async {
    final r = await _l0.query(const {}, PageRequest(limit: limit), _ctx);
    return ((r as Ok<Page<Map<String, Object?>>>).value)
        .items
        .map(_decodeRow)
        .toList();
  }

  // ── delete ──
  @Deprecated('M4 退场，改用 L0 切片')
  Future<bool> softDelete(String uuid) async {
    final r = await _l0.softDelete(uuid, _ctx);
    return r is Ok;
  }

  // ── index queries ──
  @Deprecated('M4 退场，改用 L0 切片')
  Future<TContract?> getFirstByIndex(String indexKey, String indexValue) async {
    final r = await _l0.getByIndex(indexKey, indexValue, _ctx, limit: 1);
    if (r case Ok(value: final rows)) {
      return rows.isEmpty ? null : _decodeRow(rows.first);
    }
    return null;
  }

  @Deprecated('M4 退场，改用 L0 切片')
  Future<List<TContract>> getAllByIndex(String indexKey, String indexValue,
      {int limit = 200}) async {
    final r = await _l0.getByIndex(indexKey, indexValue, _ctx, limit: limit);
    if (r case Ok(value: final rows)) {
      return rows.map(_decodeRow).toList();
    }
    return const [];
  }

  @Deprecated('M4 退场，改用 L0 切片')
  Stream<TContract?> watchFirstByIndex(String indexKey, String indexValue) =>
      _l0
          .watchByIndex(indexKey, indexValue, _ctx, limit: 1)
          .map((r) {
            if (r case Ok(value: final rows)) {
              return rows.isEmpty ? null : _decodeRow(rows.first);
            }
            return null;
          });

  void _validateEncodedMeta(RecordMeta meta, String expectedUuid) {
    if (meta.uuid != expectedUuid) {
      throw RecordCodecMismatch(message: 'uuid mismatch');
    }
    if (meta.module != _codec.module) {
      throw RecordCodecMismatch(message: 'module mismatch');
    }
    if (meta.scopeUid != _store.scopeUid) {
      throw RecordCodecMismatch(message: 'scope mismatch');
    }
  }
}
