import 'package:persistence_core/persistence_core.dart' hide XuanError;
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';
import '../blob/blob_metadata_repository.dart';
import '../record/record_entity_descriptor.dart';
import '../record/record_row_mapper.dart';
import '../record/record_storage_driver.dart';
import 'xiang_delete_media_handler.dart';

/// Drift-backed [XiangReadingRepository] built on L0 契约内核
/// ([CrudBaseRepository] + [RecordStorageDriver] + [recordEntityDescriptor]).
///
/// 该适配器不持有 Xiang 私有记录列表：所有读写流经统一的 [ScopedRecordStore]，
/// [softDelete] 标记共享 Record 已删除，使后续 [get] 返回 null（治理规则 TDD-XG-09）。
///
/// `put` 返回持久化后的 [XiangReading]，而 L0 内核返回 record uuid，
/// 因此适配器组合（而非继承）内核并在两者之间映射。`get` 额外遵守端口契约：
/// 软删除记录应被视为不存在——L0 内核的 `getIncludingDeleted` 无论 `deletedAt`
/// 都返回解码后的元数据，因此适配器在解码前检查共享 Record 的 `deletedAt`。
///
/// C3：生产装配注入共享 [RecordBlobUnitOfWork] + [BlobMetadataRepository]，
/// `put` 把 Record 与全部 `evidence.mediaRef.refId` 解析出的真实 handle 一起
/// 交给共享 UoW 原子落库（Record + search index + blob ref + outbox 同事务，
/// 事务内逐条校验字节，缺失/损坏 fail closed）。未装配 UoW 的旧装配（纯记录
/// 测试 / 删除审计测试）保留直接 L0 保存路径，不提升任何 blob 引用。
class XiangReadingRepositoryImpl implements XiangReadingRepository {
  XiangReadingRepositoryImpl({
    required ScopedRecordStore store,
    required RecordModuleCodec<XiangReading> codec,
    RecordBlobUnitOfWork? unitOfWork,
    BlobMetadataRepository? blobMetadataRepository,
    XiangDeleteMediaHandler? deleteMediaHandler,
  }) : _store = store,
       _codec = codec,
       _unitOfWork = unitOfWork,
       _blobMetadataRepository = blobMetadataRepository,
       _l0 = CrudBaseRepository<Map<String, Object?>, String>(
         descriptor: recordEntityDescriptor(module: codec.module),
         driver: RecordStorageDriver(store: store),
       ),
       _deleteMediaHandler = deleteMediaHandler;

  final ScopedRecordStore _store;
  final RecordModuleCodec<XiangReading> _codec;
  final RecordBlobUnitOfWork? _unitOfWork;
  final BlobMetadataRepository? _blobMetadataRepository;
  final CrudBaseRepository<Map<String, Object?>, String> _l0;
  final XiangDeleteMediaHandler? _deleteMediaHandler;

  RequestContext get _ctx => RequestContext(scopeUid: _store.scopeUid);

  /// 行 → 契约实体：RecordMeta + moduleData 一起交给 codec decode。
  XiangReading _decodeRow(Map<String, Object?> row) => _codec.decode(
    RecordRowMapper.rowToMeta(row),
    RecordRowMapper.moduleDataOf(row),
  );

  // ── L0 切片实现 ──

  @override
  Future<Result<XiangReading?>> get(String id, RequestContext ctx) async {
    final r = await _l0.getIncludingDeleted(id, ctx);
    if (r case Ok(value: final row)) {
      if (row == null) return const Ok(null);
      // 检查软删状态：软删除记录应被视为不存在
      final meta = RecordRowMapper.rowToMeta(row);
      if (meta.deletedAt != null) return const Ok(null);
      return Ok(_decodeRow(row));
    }
    return const Ok(null);
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final r = await get(id, ctx);
    return r.map((v) => v != null);
  }

  @override
  Future<Result<Rev>> put(
    XiangReading entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    // 内部保存逻辑：处理 uuid 生成和编码
    final currentUuid = _codec.uuidOf(entity);
    final effectiveUuid = currentUuid.isNotEmpty
        ? currentUuid
        : _generateUuid();
    final fixed = currentUuid.isNotEmpty
        ? entity
        : _codec.withUuid(entity, effectiveUuid);
    final encoded = _codec.encode(fixed, scopeUid: _store.scopeUid);

    final uow = _unitOfWork;
    final metaRepo = _blobMetadataRepository;
    if (uow == null || metaRepo == null) {
      // 未装配共享 UoW（纯记录装配）时保持既有直接保存路径。生产装配
      // （C3，Shell composition root）必须同时注入 UoW 与 blob 元数据仓库。
      final row = RecordRowMapper.metaToRow(encoded.meta);
      final r = await _l0.put(row, ctx, pre: pre);
      if (r case Err(error: final e)) return Err(e);
      return Ok(Rev(effectiveUuid));
    }

    // C3：收集全部 evidence.mediaRef.refId，经共享 BlobMetadataRepository
    // 解析为真实 handle（scope 约束）。解析不到即 fail closed（零写入）。
    final handles = <BlobHandle>{};
    for (final evidence in fixed.evidence) {
      final refId = evidence.mediaRef?.refId;
      if (refId == null || refId.isEmpty) continue;
      final handle = await metaRepo.getHandle(refId);
      if (handle == null) {
        return Err(
          XuanError(
            code: ErrorCode.notFound,
            message: '媒体引用无法解析（blob 元数据缺失）：$refId',
            reason: 'blob.missing',
            suggestion: '请重新采集该媒体后再保存',
          ),
        );
      }
      handles.add(handle);
    }

    try {
      // 共享 UoW 是唯一原子校验/保存边界：Record + search index + blob ref
      // + outbox 同事务，事务内逐条 openRead 完整消费（C1），失败整体回滚。
      await uow.saveWithBlobs(
        record: encoded.meta,
        referencedBlobs: handles,
      );
    } on StorageError catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'Xiang 记录媒体校验未通过：${e.message}',
          reason: e.code,
          suggestion: e.suggestion,
        ),
      );
    }
    // 返回持久化后的实体（可能包含新生成的 uuid）
    return Ok(Rev(effectiveUuid));
  }

  /// 便捷保存（非接口成员：接口只暴露 [put]）。
  Future<XiangReading> save(XiangReading reading) async {
    final currentUuid = _codec.uuidOf(reading);
    final effectiveUuid = currentUuid.isNotEmpty
        ? currentUuid
        : _generateUuid();
    final fixed = currentUuid.isNotEmpty
        ? reading
        : _codec.withUuid(reading, effectiveUuid);
    final res = await put(fixed, _ctx);
    if (res case Err(error: final e)) throw e;
    return fixed;
  }

  /// 便捷加载（非接口成员：接口只暴露 [get]）。
  Future<XiangReading?> load(String uuid) async {
    final res = await get(uuid, _ctx);
    if (res case Ok(value: final val)) return val;
    return null;
  }

  @override
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    // FA12 单一方针：删除经媒体生命周期处理引用并落库审计（TDD-T7）。
    final handler = _deleteMediaHandler;
    if (handler != null) {
      await handler.handleDelete(id);
      return const Ok(null);
    }
    // 未装配 handler（旧装配）时退化为纯软删。
    return _l0.softDelete(id, ctx, pre: pre);
  }


  @override
  Future<Result<void>> restore(String id, RequestContext ctx) {
    return _l0.restore(id, ctx);
  }

  @override
  Future<Result<XiangReading?>> getIncludingDeleted(
    String id,
    RequestContext ctx,
  ) {
    return _l0.getIncludingDeleted(id, ctx).then((r) {
      if (r case Ok(value: final row)) {
        return Ok(row == null ? null : _decodeRow(row));
      }
      return const Ok(null);
    });
  }

  @override
  Future<Result<Page<XiangReading>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) {
    return _l0.query(spec, page, ctx).then((r) {
      if (r case Ok(value: final pageData)) {
        return Ok(
          Page(
            items: pageData.items.map(_decodeRow).toList(),
            nextCursor: pageData.nextCursor,
          ),
        );
      }
      return const Err(
        XuanError(code: ErrorCode.internal, message: 'query failed'),
      );
    });
  }

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) {
    return _l0.count(spec, ctx);
  }

  @override
  Future<Result<BatchOutcome<String>>> putAll(
    List<XiangReading> entities,
    RequestContext ctx,
  ) {
    return _l0
        .putAll(
          entities.map((e) {
            final encoded = _codec.encode(e, scopeUid: _store.scopeUid);
            return RecordRowMapper.metaToRow(encoded.meta);
          }).toList(),
          ctx,
        )
        .then((r) {
          if (r case Ok(value: final outcome)) {
            return Ok(
              BatchOutcome(
                outcome.results.map((item) {
                  return (id: item.id, result: item.result);
                }).toList(),
              ),
            );
          }
          return const Err(
            XuanError(code: ErrorCode.internal, message: 'putAll failed'),
          );
        });
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) {
    return _l0.inTransaction(body);
  }

  String _generateUuid() {
    // 简化的 uuid 生成，实际应使用 uuid 包
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }
}
