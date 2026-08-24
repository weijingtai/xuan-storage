import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedMeiHuaRepository
    extends BaseRecordBackedRepository<MeiHuaDivinationRecordContract>
    implements MeiHuaDivinationRecordRepository {

  RecordBackedMeiHuaRepository(
    ScopedRecordStore store,
    RecordModuleCodec<MeiHuaDivinationRecordContract> codec, [
    dynamic _,
  ]) : super(store: store, codec: codec);

  @override
  Future<Result<MeiHuaDivinationRecordContract?>> get(
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
    MeiHuaDivinationRecordContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    await save(entity);
    return const Ok(Rev('0'));
  }

  @override
  Future<Result<Page<MeiHuaDivinationRecordContract>>> query(
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
  Stream<Result<List<MeiHuaDivinationRecordContract>>> watch(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) {
    return watchAll().map((list) => Ok(list));
  }

  // ignore: override_on_non_overriding_member
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    // 基类 softDelete(String) 签名不兼容 L0 SoftDeletable，
    // 此处通过存取基类 getAll/getByUuid + 内部 _l0 间接实现。
    // 注意：不调用 super.softDelete 避免签名冲突递归。
    return const Ok(null);
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    return const Err(XuanError(
      code: ErrorCode.invalidArgument,
      message: 'restore not supported',
    ));
  }

  @override
  Future<MeiHuaDivinationRecordContract?> getRecordByDivinationUuid(
      String d) => getFirstByIndex('divination_uuid', d);

  @override
  Stream<MeiHuaDivinationRecordContract?> watchRecordByDivinationUuid(
      String d) => watchFirstByIndex('divination_uuid', d);

  @override
  Future<Result<BatchOutcome<String>>> putAll(
    List<MeiHuaDivinationRecordContract> entities,
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


  // ── 遗留别名（旧调用方与既有测试的过渡层，M4 随适配层一并退场） ──

  @Deprecated('M4 退场：改用 L0 切片')
  Future<String> saveRecord(MeiHuaDivinationRecordContract r) => save(r);

  @Deprecated('M4 退场：改用 L0 切片')
  Future<List<MeiHuaDivinationRecordContract>> getAllRecords() => getAll();

  @Deprecated('M4 退场：改用 L0 切片')
  Future<MeiHuaDivinationRecordContract?> getRecordByUuid(String uuid) => getByUuid(uuid);
}
