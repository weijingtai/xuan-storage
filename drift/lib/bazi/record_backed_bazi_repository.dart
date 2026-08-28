import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import '../record/record_entity_descriptor.dart';
import '../record/record_row_mapper.dart';
import '../record/record_storage_driver.dart';

class RecordBackedBaziRepository implements BaziRecordRepository {
  RecordBackedBaziRepository({
    required ScopedRecordStore store,
    required RecordModuleCodec<BaziRecordContract> codec,
    Uuid? uuid,
  }) : _store = store,
       _codec = codec,
       _uuid = uuid ?? const Uuid(),
       _l0 = CrudBaseRepository<Map<String, Object?>, String>(
         descriptor: recordEntityDescriptor(module: codec.module),
         driver: RecordStorageDriver(store: store),
       );

  final ScopedRecordStore _store;
  final RecordModuleCodec<BaziRecordContract> _codec;
  final Uuid _uuid;
  final CrudBaseRepository<Map<String, Object?>, String> _l0;

  RequestContext get _ctx => RequestContext(scopeUid: _store.scopeUid);

  BaziRecordContract _decodeRow(Map<String, Object?> row) => _codec.decode(
    RecordRowMapper.rowToMeta(row),
    RecordRowMapper.moduleDataOf(row),
  );

  // ── 内部复用原 Base 的已验证逻辑（供 L0 委托） ──
  Future<String> _saveInternal(BaziRecordContract contract) async {
    final currentUuid = _codec.uuidOf(contract);
    final effectiveUuid = currentUuid.isNotEmpty ? currentUuid : _uuid.v7();
    final fixed = currentUuid.isNotEmpty
        ? contract
        : _codec.withUuid(contract, effectiveUuid);
    final encoded = _codec.encode(fixed, scopeUid: _store.scopeUid);
    final row = RecordRowMapper.metaToRow(encoded.meta);
    final r = await _l0.put(row, _ctx);
    if (r case Err(error: final e)) throw e;
    return effectiveUuid;
  }

  Future<BaziRecordContract?> _getByUuidInternal(String uuid) async {
    final r = await _l0.getIncludingDeleted(uuid, _ctx);
    if (r case Ok(value: final row))
      return row == null ? null : _decodeRow(row);
    return null;
  }

  Future<List<BaziRecordContract>> _getAllInternal({int pageSize = 200}) async {
    final results = <BaziRecordContract>[];
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

  Future<List<BaziRecordContract>> _getAllByIndexInternal(
    String indexKey,
    String indexValue, {
    int limit = 200,
  }) async {
    final r = await _l0.getByIndex(indexKey, indexValue, _ctx, limit: limit);
    if (r case Ok(value: final rows)) return rows.map(_decodeRow).toList();
    return const [];
  }

  Future<bool> _softDeleteInternal(String uuid) async {
    final r = await _l0.softDelete(uuid, _ctx);
    return r is Ok;
  }

  // ── L0 切片实现 ──
  @override
  Future<Result<BaziRecordContract?>> get(String id, RequestContext ctx) async {
    final v = await _getByUuidInternal(id);
    return Ok(v);
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final v = await _getByUuidInternal(id);
    return Ok(v != null);
  }

  @override
  Future<Result<BaziRecordContract?>> getIncludingDeleted(
    String id,
    RequestContext ctx,
  ) => get(id, ctx);

  @override
  Future<Result<Rev>> put(
    BaziRecordContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    final id = await _saveInternal(entity);
    return Ok(Rev(id));
  }

  @override
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    await _softDeleteInternal(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    return Err(
      const XuanError(
        code: ErrorCode.invalidArgument,
        message: 'BaziRecord restore not supported',
      ),
    );
  }

  @override
  Future<Result<Page<BaziRecordContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final caseUuid = spec['caseUuid'] ?? spec['case_uuid'];
    List<BaziRecordContract> items;
    if (caseUuid is String && caseUuid.isNotEmpty) {
      items = await _getAllByIndexInternal('case_uuid', caseUuid);
    } else {
      items = await _getAllInternal();
    }
    int start = 0;
    if (page.cursor != null) {
      final idx = items.indexWhere((e) => e.uuid == page.cursor);
      if (idx != -1) start = idx + 1;
    }
    final end = (start + page.limit).clamp(0, items.length);
    final pageItems = items.sublist(start, end);
    final nextCursor = end < items.length
        ? (pageItems.isNotEmpty ? pageItems.last.uuid : null)
        : null;
    return Ok(Page(items: pageItems, nextCursor: nextCursor));
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final r = await query(spec, PageRequest(limit: 1000), ctx);
    return r.map((p) => p.items.length);
  }

  @override
  Future<Result<BatchOutcome<String>>> putAll(
    List<BaziRecordContract> entities,
    RequestContext ctx,
  ) async {
    final results = <({String id, Result<Rev> result})>[];
    for (final e in entities) {
      final r = await put(e, ctx);
      results.add((id: e.uuid, result: r));
    }
    return Ok(BatchOutcome(results));
  }

  @override
  Future<List<BaziRecordContract>> listRecords(String caseUuid) =>
      _getAllByIndexInternal('case_uuid', caseUuid);

  @override
  Future<BaziRecordContract?> getRecord(String uuid) =>
      _getByUuidInternal(uuid);

  @override
  Future<void> saveRecord(BaziRecordContract record) async {
    await _saveInternal(record);
  }

  @override
  Future<void> deleteRecord(String uuid) async {
    await _softDeleteInternal(uuid);
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final v = await body();
      return Ok(v);
    } on XuanError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }

  // ── 遗留别名（旧调用方与既有测试的过渡层，M4 随适配层一并退场） ──

  @override
  Future<List<BaziRecordContract>> listRecords(String caseUuid) =>
      _getAllByIndexInternal('case_uuid', caseUuid);

  @override
  Future<BaziRecordContract?> getRecord(String uuid) =>
      _getByUuidInternal(uuid);

  @override
  Future<void> saveRecord(BaziRecordContract record) async {
    await _saveInternal(record);
  }

  @override
  Future<void> deleteRecord(String uuid) async {
    await _softDeleteInternal(uuid);
  }
}
