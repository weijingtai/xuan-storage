import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import '../record/base_record_backed_repository.dart';

/// 基于 Record 存储的铁板神数仓储实现（L0 切片）
class RecordBackedTiebanRepository
    extends BaseRecordBackedRepository<TiebanDivinationRecordContract>
    implements TiebanRecordRepository {

  RecordBackedTiebanRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  // ── Readable ──

  @override
  Future<Result<TiebanDivinationRecordContract?>> get(
    String id,
    RequestContext ctx,
  ) async {
    try {
      final result = await super.getByUuid(id);
      return Ok(result);
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: '获取铁板神数记录失败: $e',
      ));
    }
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final r = await get(id, ctx);
    return switch (r) {
      Ok(:final value) => Ok(value != null),
      Err(:final error) => Err(error),
    };
  }

  // ── Writable ──

  @override
  Future<Result<Rev>> put(
    TiebanDivinationRecordContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    try {
      await super.save(entity);
      return const Ok(Rev('v1'));
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: '保存铁板神数记录失败: $e',
      ));
    }
  }

  // ── SoftDeletable ──

  @override
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    try {
      await super.softDelete(id);
      return const Ok(null);
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: '软删除铁板神数记录失败: $e',
      ));
    }
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    return Err(XuanError(
      code: ErrorCode.internal,
      message: 'restore 尚未实现',
    ));
  }

  // ── SoftDeleteReadable ──

  @override
  Future<Result<TiebanDivinationRecordContract?>> getIncludingDeleted(
    String id,
    RequestContext ctx,
  ) => get(id, ctx);

  // ── Queryable ──

  @override
  Future<Result<Page<TiebanDivinationRecordContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    try {
      final results = await super.getAll(pageSize: page.limit);
      return Ok(Page(items: results));
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: '查询铁板神数记录失败: $e',
      ));
    }
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    try {
      final results = await super.getAll();
      return Ok(results.length);
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: '计数铁板神数记录失败: $e',
      ));
    }
  }

  // ── Watchable ──

  @override
  Stream<Result<List<TiebanDivinationRecordContract>>> watch(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) => super.watchAll().map((list) => Ok(list));

  // ── BatchWritable ──

  @override
  Future<Result<BatchOutcome<String>>> putAll(
    List<TiebanDivinationRecordContract> entities,
    RequestContext ctx,
  ) async {
    final results = <({String id, Result<Rev> result})>[];
    for (final entity in entities) {
      final r = await put(entity, ctx);
      results.add((id: entity.uuid, result: r));
    }
    return Ok(BatchOutcome(results));
  }

  // ── Transactional ──

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async =>
      Ok(await body());
}
