import 'dart:async';

import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';
import 'package:uuid/uuid.dart';
import '../record/base_record_backed_repository.dart';
import '../record/record_entity_descriptor.dart';
import '../record/record_row_mapper.dart';
import '../record/record_storage_driver.dart';

/// 基于 record 存储的紫微斗数记录仓储（L0 切片实现）。
///
/// 实现 [ZiweiRecordRepository] 的全部 L0 切片方法，
/// 内部委托 [_l0]（CrudBaseRepository + RecordStorageDriver）完成持久化。
class RecordBackedZiweiRepository
    extends BaseRecordBackedRepository<ZiweiDivinationRecordContract>
    implements ZiweiRecordRepository {
  RecordBackedZiweiRepository({
    required ScopedRecordStore store,
    required RecordModuleCodec<ZiweiDivinationRecordContract> codec,
    Uuid? uuid,
  }) : _store = store,
       _codec = codec,
       _uuid = uuid ?? const Uuid(),
       super(store: store, codec: codec, uuid: uuid);

  // 子类无法访问父类私有字段，故自建同源成员（与 liuyao 等模块一致）。
  final ScopedRecordStore _store;
  final RecordModuleCodec<ZiweiDivinationRecordContract> _codec;
  final Uuid _uuid;

  /// L0 契约内核仓储（CrudBaseRepository + RecordStorageDriver）。
  late final CrudBaseRepository<Map<String, Object?>, String> _l0 =
      CrudBaseRepository<Map<String, Object?>, String>(
        descriptor: recordEntityDescriptor(module: _codec.module),
        driver: RecordStorageDriver(store: _store),
      );

  RequestContext get _ctx => RequestContext(scopeUid: _store.scopeUid);

  /// 行 → 契约实体：RecordMeta + moduleData 一起交给 codec decode。
  ZiweiDivinationRecordContract _decodeRow(Map<String, Object?> row) =>
      _codec.decode(
        RecordRowMapper.rowToMeta(row),
        RecordRowMapper.moduleDataOf(row),
      );

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

  // ── Readable ──

  @override
  Future<Result<ZiweiDivinationRecordContract?>> get(
    String id,
    RequestContext ctx,
  ) async {
    final r = await _l0.get(id, _ctx);
    return switch (r) {
      Ok(:final value) => Ok(value == null ? null : _decodeRow(value)),
      Err(:final error) => Err(error),
    };
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    return _l0.exists(id, _ctx);
  }

  // ── Writable ──

  @override
  Future<Result<Rev>> put(
    ZiweiDivinationRecordContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    // 模块契约：put 返回的 Rev 即记录 uuid（便于调用方回读）。
    final currentUuid = _codec.uuidOf(entity);
    final effectiveUuid = currentUuid.isNotEmpty ? currentUuid : _uuid.v7();
    final fixed = currentUuid.isNotEmpty
        ? entity
        : _codec.withUuid(entity, effectiveUuid);
    final encoded = _codec.encode(fixed, scopeUid: ctx.scopeUid);
    _validateEncodedMeta(encoded.meta, effectiveUuid);
    final row = RecordRowMapper.metaToRow(encoded.meta);
    final r = await _l0.put(row, ctx, pre: pre);
    return switch (r) {
      Ok() => Ok(Rev(effectiveUuid)),
      Err(:final error) => Err(error),
    };
  }

  // ── Queryable ──

  @override
  Future<Result<Page<ZiweiDivinationRecordContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final r = await _l0.query(spec, page, _ctx);
    return switch (r) {
      Ok(:final value) => Ok(
        Page(
          items: value.items.map(_decodeRow).toList(),
          nextCursor: value.nextCursor,
        ),
      ),
      Err(:final error) => Err(error),
    };
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    return _l0.count(spec, _ctx);
  }

  // ── SoftDeletable ──

  @override
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    return _l0.softDelete(id, _ctx, pre: pre);
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    return _l0.restore(id, _ctx);
  }

  // ── SoftDeleteReadable ──

  @override
  Future<Result<ZiweiDivinationRecordContract?>> getIncludingDeleted(
    String id,
    RequestContext ctx,
  ) async {
    final r = await _l0.getIncludingDeleted(id, _ctx);
    return switch (r) {
      Ok(:final value) => Ok(value == null ? null : _decodeRow(value)),
      Err(:final error) => Err(error),
    };
  }

  // ── Watchable ──

  @override
  Stream<Result<List<ZiweiDivinationRecordContract>>> watch(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) {
    return _l0
        .watch(spec, _ctx)
        .map(
          (r) => switch (r) {
            Ok(:final value) => Ok(value.map(_decodeRow).toList()),
            Err(:final error) => Err(error),
          },
        );
  }

  // ── BatchWritable ──

  @override
  Future<Result<BatchOutcome<String>>> putAll(
    List<ZiweiDivinationRecordContract> entities,
    RequestContext ctx,
  ) async {
    final results = <({String id, Result<Rev> result})>[];
    for (final e in entities) {
      final currentUuid = _codec.uuidOf(e);
      final effectiveUuid = currentUuid.isNotEmpty ? currentUuid : _uuid.v7();
      final fixed = currentUuid.isNotEmpty
          ? e
          : _codec.withUuid(e, effectiveUuid);
      final encoded = _codec.encode(fixed, scopeUid: _store.scopeUid);
      _validateEncodedMeta(encoded.meta, effectiveUuid);
      final row = RecordRowMapper.metaToRow(encoded.meta);
      results.add((id: effectiveUuid, result: await _l0.put(row, _ctx)));
    }
    return Ok(BatchOutcome<String>(results));
  }

  // ── Transactional ──

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) {
    return _l0.inTransaction(body);
  }

  // ── 遗留别名（旧调用方与既有测试的过渡层，M4 随适配层一并退场） ──

  @override
  Future<String> saveRecord(ZiweiDivinationRecordContract record) =>
      save(record);

  @override
  Future<List<ZiweiDivinationRecordContract>> getAllRecords() => getAll();

  @override
  Future<ZiweiDivinationRecordContract?> getRecordByUuid(String uuid) =>
      getByUuid(uuid);

  @override
  Future<bool> softDeleteRecord(String uuid) => softDeleteLegacy(uuid);

  @override
  Stream<List<ZiweiDivinationRecordContract>> watchAllRecords() => watchAll();
}
