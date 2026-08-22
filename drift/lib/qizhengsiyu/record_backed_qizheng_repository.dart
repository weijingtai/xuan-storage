import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedQiZhengRepository
    extends BaseRecordBackedRepository<QiZhengSiYuPanContract>
    implements QiZhengRecordRepository {

  RecordBackedQiZhengRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override
  Future<Result<QiZhengSiYuPanContract?>> get(String id, RequestContext ctx) async {
    final item = await getByUuid(id);
    return Ok(item);
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final item = await getByUuid(id);
    return Ok(item != null);
  }

  @override
  Future<Result<Rev>> put(
    QiZhengSiYuPanContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    await save(entity);
    return Ok(Rev(0));
  }

  @override
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    await super.softDelete(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    return const Err(XuanError(
      code: ErrorCode.unimplemented,
      message: 'restore not supported',
    ));
  }

  @override
  Future<Result<QiZhengSiYuPanContract?>> getIncludingDeleted(
    String id,
    RequestContext ctx,
  ) async {
    final item = await getByUuid(id);
    return Ok(item);
  }

  @override
  Future<Result<Page<QiZhengSiYuPanContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final all = await getAll();
    return Ok(Page(items: all, nextCursor: null));
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final all = await getAll();
    return Ok(all.length);
  }

  @override
  Stream<Result<List<QiZhengSiYuPanContract>>> watch(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) {
    return watchAll().map((list) => Ok(list));
  }

  @override
  Future<Result<BatchOutcome<String>>> putAll(
    List<QiZhengSiYuPanContract> entities,
    RequestContext ctx,
  ) async {
    final results = <({String id, Result<Rev> result})>[];
    for (final e in entities) {
      final r = await put(e, ctx);
      results.add((id: _codec.uuidOf(e), result: r));
    }
    return Ok(BatchOutcome(results));
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final result = await body();
      return Ok(result);
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: 'Transaction failed: $e',
      ));
    }
  }
}
