import 'dart:async';

import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';
import '../record/base_record_backed_repository.dart';
import '../record/record_row_mapper.dart';

/// 基于 record 存储的紫微斗数记录仓储（L0 切片实现）。
///
/// 实现 [ZiweiRecordRepository] 的全部 L0 切片方法，
/// 内部委托 [_l0]（CrudBaseRepository + RecordStorageDriver）完成持久化。
class RecordBackedZiweiRepository
    extends BaseRecordBackedRepository<ZiweiDivinationRecordContract>
    implements ZiweiRecordRepository {

  RecordBackedZiweiRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  // ── Readable ──

  @override
  Future<Result<ZiweiDivinationRecordContract?>> get(
    String id,
    RequestContext ctx,
  ) async {
    final r = await _l0.getIncludingDeleted(id, _ctx);
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
    final currentUuid = _codec.uuidOf(entity);
    final effectiveUuid = currentUuid.isNotEmpty ? currentUuid : _uuid.v7();
    final fixed = currentUuid.isNotEmpty
        ? entity
        : _codec.withUuid(entity, effectiveUuid);
    final encoded = _codec.encode(fixed, scopeUid: _store.scopeUid);
    _validateEncodedMeta(encoded.meta, effectiveUuid);
    final row = RecordRowMapper.metaToRow(encoded.meta);
    return _l0.put(row, _ctx, pre: pre);
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
      Ok(:final value) => Ok(Page(
        items: value.items.map(_decodeRow).toList(),
        nextCursor: value.nextCursor,
      )),
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
    return _l0.watch(spec, _ctx).map((r) => switch (r) {
      Ok(:final value) => Ok(value.map(_decodeRow).toList()),
      Err(:final error) => Err(error),
    });
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
      results.add((
        id: effectiveUuid,
        result: await _l0.put(row, _ctx),
      ));
    }
    return Ok(BatchOutcome<String>(results));
  }

  // ── Transactional ──

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) {
    return _l0.inTransaction(body);
  }
}
