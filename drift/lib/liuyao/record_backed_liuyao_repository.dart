import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
import 'package:uuid/uuid.dart';
import '../record/base_record_backed_repository.dart';
import '../record/record_entity_descriptor.dart';
import '../record/record_row_mapper.dart';
import '../record/record_storage_driver.dart';

/// Drift-backed implementation of [SixYaoDivinationRecordRepository].
///
/// L0 切片全部委托内部 [_l0] 完成，自身只做
/// SixYaoDivinationRecord ↔ 扁平行的编解码。
class RecordBackedLiuYaoRepository
    extends BaseRecordBackedRepository<SixYaoDivinationRecord>
    implements SixYaoDivinationRecordRepository {

  RecordBackedLiuYaoRepository({
    required ScopedRecordStore store,
    required RecordModuleCodec<SixYaoDivinationRecord> codec,
    Uuid? uuid,
  })  : _store = store,
        _codec = codec,
        _uuidGen = uuid ?? const Uuid(),
        super(store: store, codec: codec, uuid: uuid);

  final ScopedRecordStore _store;
  final RecordModuleCodec<SixYaoDivinationRecord> _codec;
  final Uuid _uuidGen;

  /// L0 契约内核仓储（与父类 _l0 同源；子类无法访问父类私有字段，故自建）。
  late final CrudBaseRepository<Map<String, Object?>, String> _l0 =
      CrudBaseRepository<Map<String, Object?>, String>(
    descriptor: recordEntityDescriptor(module: _codec.module),
    driver: RecordStorageDriver(store: _store),
  );

  // ── 编码 / 解码辅助 ──

  /// 实体 → L0 扁平行。
  Map<String, Object?> _encodeToRow(
    SixYaoDivinationRecord entity, {
    required String scopeUid,
  }) {
    final currentUuid = _codec.uuidOf(entity);
    final effectiveUuid =
        currentUuid.isNotEmpty ? currentUuid : _uuidGen.v7();
    final fixed = currentUuid.isNotEmpty
        ? entity
        : _codec.withUuid(entity, effectiveUuid);
    final encoded = _codec.encode(fixed, scopeUid: scopeUid);
    return RecordRowMapper.metaToRow(encoded.meta);
  }

  /// L0 扁平行 → 实体。
  SixYaoDivinationRecord _decodeRow(Map<String, Object?> row) =>
      _codec.decode(
        RecordRowMapper.rowToMeta(row),
        RecordRowMapper.moduleDataOf(row),
      );

  // ── L0 Readable ──

  @override
  Future<Result<SixYaoDivinationRecord?>> get(
    String id,
    RequestContext ctx,
  ) async {
    final r = await _l0.get(id, ctx);
    return r.map((row) => row == null ? null : _decodeRow(row));
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) =>
      _l0.exists(id, ctx);

  // ── L0 Writable ──

  @override
  Future<Result<Rev>> put(
    SixYaoDivinationRecord entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) {
    final row = _encodeToRow(entity, scopeUid: ctx.scopeUid);
    return _l0.put(row, ctx, pre: pre);
  }

  // ── L0 SoftDeletable ──

  @override
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) =>
      _l0.softDelete(id, ctx, pre: pre);

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) =>
      _l0.restore(id, ctx);

  // ── L0 SoftDeleteReadable ──

  @override
  Future<Result<SixYaoDivinationRecord?>> getIncludingDeleted(
    String id,
    RequestContext ctx,
  ) async {
    final r = await _l0.getIncludingDeleted(id, ctx);
    return r.map((row) => row == null ? null : _decodeRow(row));
  }

  // ── L0 Queryable ──

  @override
  Future<Result<Page<SixYaoDivinationRecord>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final r = await _l0.query(spec, page, ctx);
    return r.map((p) => Page(
          items: p.items.map(_decodeRow).toList(),
          nextCursor: p.nextCursor,
        ));
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) =>
      _l0.count(spec, ctx);

  // ── L0 BatchWritable ──

  @override
  Future<Result<BatchOutcome<String>>> putAll(
    List<SixYaoDivinationRecord> entities,
    RequestContext ctx,
  ) {
    final rows = [
      for (final e in entities) _encodeToRow(e, scopeUid: ctx.scopeUid),
    ];
    return _l0.putAll(rows, ctx);
  }

  // ── L0 Transactional ──

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) =>
      _l0.inTransaction(body);

  // ── 领域扩展查询（索引查询） ──

  /// 按本卦 ID 查询记录。
  Future<List<SixYaoDivinationRecord>> getRecordsByOriginalGua(int guaId) =>
      getAllByIndex('original_gua_id', '$guaId', limit: 200);

  /// 按变卦 ID 查询记录。
  Future<List<SixYaoDivinationRecord>> getRecordsByChangedGua(int guaId) =>
      getAllByIndex('changed_gua_id', '$guaId', limit: 200);
}
