import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';
import 'package:uuid/uuid.dart';
import '../record/base_record_backed_repository.dart';
import '../record/record_entity_descriptor.dart';
import '../record/record_row_mapper.dart';
import '../record/record_storage_driver.dart';

/// 基于 record 存储的大六壬记录仓储（L0 切片实现）。
///
/// 实现 [DaliurenRecordRepository] 的全部 L0 切片方法，内部委托自建 [_l0]
/// （CrudBaseRepository + RecordStorageDriver）完成持久化，
/// 自身只负责 DaliurenDivinationRecordContract ↔ 扁平行的编解码。
class RecordBackedDaliurenRepository
    extends BaseRecordBackedRepository<DaliurenDivinationRecordContract>
    implements DaliurenRecordRepository {
  RecordBackedDaliurenRepository({
    required ScopedRecordStore store,
    required RecordModuleCodec<DaliurenDivinationRecordContract> codec,
    Uuid? uuid,
  })  : _store = store,
        _codec = codec,
        _uuid = uuid ?? const Uuid(),
        super(store: store, codec: codec, uuid: uuid);

  // 子类无法访问父类私有字段，故自建同源成员（与 liuyao 模块一致）。
  final ScopedRecordStore _store;
  final RecordModuleCodec<DaliurenDivinationRecordContract> _codec;
  final Uuid _uuid;

  /// L0 契约内核仓储（CrudBaseRepository + RecordStorageDriver）。
  late final CrudBaseRepository<Map<String, Object?>, String> _l0 =
      CrudBaseRepository<Map<String, Object?>, String>(
    descriptor: recordEntityDescriptor(module: _codec.module),
    driver: RecordStorageDriver(store: _store),
  );

  /// 实体 → L0 扁平行（补齐 UUID 后编码）。
  Map<String, Object?> _encodeToRow(
    DaliurenDivinationRecordContract entity, {
    required String scopeUid,
  }) {
    final currentUuid = _codec.uuidOf(entity);
    final effectiveUuid = currentUuid.isNotEmpty ? currentUuid : _uuid.v7();
    final fixed =
        currentUuid.isNotEmpty ? entity : _codec.withUuid(entity, effectiveUuid);
    final encoded = _codec.encode(fixed, scopeUid: scopeUid);
    return RecordRowMapper.metaToRow(encoded.meta);
  }

  /// L0 扁平行 → 实体。
  DaliurenDivinationRecordContract _decodeRow(Map<String, Object?> row) => _codec.decode(
        RecordRowMapper.rowToMeta(row),
        RecordRowMapper.moduleDataOf(row),
      );

  // ── L0 Readable ──

  @override
  Future<Result<DaliurenDivinationRecordContract?>> get(String id, RequestContext ctx) async {
    final r = await _l0.get(id, ctx);
    return r.map((row) => row == null ? null : _decodeRow(row));
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) =>
      _l0.exists(id, ctx);

  // ── L0 Writable ──

  @override
  Future<Result<Rev>> put(
    DaliurenDivinationRecordContract entity,
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
  Future<Result<DaliurenDivinationRecordContract?>> getIncludingDeleted(
    String id,
    RequestContext ctx,
  ) async {
    final r = await _l0.getIncludingDeleted(id, ctx);
    return r.map((row) => row == null ? null : _decodeRow(row));
  }

  // ── L0 Queryable ──

  @override
  Future<Result<Page<DaliurenDivinationRecordContract>>> query(
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
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) =>
      _l0.count(spec, ctx);

  // ── L0 Watchable ──

  @override
  Stream<Result<List<DaliurenDivinationRecordContract>>> watch(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) =>
      _l0.watch(spec, ctx).map((r) => r.map(
            (rows) => rows.map(_decodeRow).toList(),
          ));

  // ── L0 BatchWritable ──

  @override
  Future<Result<BatchOutcome<String>>> putAll(
    List<DaliurenDivinationRecordContract> entities,
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

  // ── 遗留别名（旧调用方与既有测试的过渡层，M4 随适配层一并退场） ──

  @Deprecated('M4 退场：改用 L0 切片')
  Future<String> saveRecord(DaliurenDivinationRecordContract r) => save(r);

  @Deprecated('M4 退场：改用 L0 切片')
  Future<List<DaliurenDivinationRecordContract>> getAllRecords() => getAll();

  @Deprecated('M4 退场：改用 L0 切片')
  Future<DaliurenDivinationRecordContract?> getRecordByUuid(String uuid) => getByUuid(uuid);

  @Deprecated('M4 退场：改用 L0 切片')
  Future<bool> softDeleteRecord(String uuid) => softDeleteLegacy(uuid);

  @Deprecated('M4 退场：改用 L0 切片')
  Stream<List<DaliurenDivinationRecordContract>> watchAllRecords() => watchAll();
}
