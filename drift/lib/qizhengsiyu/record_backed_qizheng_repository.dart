import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedQiZhengRepository
    extends BaseRecordBackedRepository<QiZhengSiYuPanContract>
    implements QiZhengRecordRepository {
  RecordBackedQiZhengRepository({
    required super.store,
    required super.codec,
    super.uuid,
  }) : _codec = codec;

  final RecordModuleCodec<QiZhengSiYuPanContract> _codec;

  @override
  Future<Result<QiZhengSiYuPanContract?>> get(
    String id,
    RequestContext ctx,
  ) async {
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
    return const Ok(Rev('1'));
  }

  @override
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    await super.softDeleteLegacy(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    return const Err(
      XuanError(
        code: ErrorCode.invalidArgument,
        message: 'restore not supported',
      ),
    );
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
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) =>
      super.inTransaction(body);

  // ── 遗留别名（旧调用方与既有测试的过渡层，M4 随适配层一并退场） ──

  @Deprecated('M4 退场：改用 L0 切片')
  Future<String> saveRecord(QiZhengSiYuPanContract r) => save(r);

  @Deprecated('M4 退场：改用 L0 切片')
  Future<List<QiZhengSiYuPanContract>> getAllRecords() => getAll();

  @Deprecated('M4 退场：改用 L0 切片')
  Future<QiZhengSiYuPanContract?> getRecordByUuid(String uuid) =>
      getByUuid(uuid);

  @Deprecated('M4 退场：改用 L0 切片')
  Future<bool> softDeleteRecord(String uuid) => softDeleteLegacy(uuid);

  @Deprecated('M4 退场：改用 L0 切片')
  Stream<List<QiZhengSiYuPanContract>> watchAllRecords() => watchAll();
}
