import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';

import 'meihua_database.dart';
import 'meihua_gua_infos.dart';
import 'meihua_divinations_dao.dart';

/// Drift-backed implementation of [MeiHuaDivinationRecordRepository].
class DriftMeiHuaDivinationRecordRepository
    implements MeiHuaDivinationRecordRepository {
  final MeiHuaDatabase _database;
  final MeiHuaDivinationsDao _dao;
  final String? scopeUid;

  DriftMeiHuaDivinationRecordRepository(this._database, {this.scopeUid})
    : _dao = MeiHuaDivinationsDao(_database, scopeUid: scopeUid);

  MeiHuaDivinationRecordContract _toContract(MeiHuaGuaInfo row) {
    return MeiHuaDivinationRecordContract(
      uuid: row.uuid,
      divinationUuid: row.divinationUuid,
      question: row.question,
      originalUpperGua: row.originalUpperGua,
      originalLowerGua: row.originalLowerGua,
      changingYao: row.changingYao,
      changedUpperGua: row.changedUpperGua,
      changedLowerGua: row.changedLowerGua,
      huUpperGua: row.huUpperGua,
      huLowerGua: row.huLowerGua,
      method: row.method,
      paramsJson: row.paramsJson,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  @override
  Future<Result<Rev>> put(
    MeiHuaDivinationRecordContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    final uuid = entity.uuid.isNotEmpty ? entity.uuid : const Uuid().v4();
    await _dao.insertRecord(
      MeiHuaGuaInfosCompanion(
        uuid: Value(uuid),
        scopeUid: Value(scopeUid),
        divinationUuid: Value(
          entity.divinationUuid.isNotEmpty ? entity.divinationUuid : uuid,
        ),
        question: Value(entity.question),
        originalUpperGua: Value(entity.originalUpperGua),
        originalLowerGua: Value(entity.originalLowerGua),
        changingYao: Value(entity.changingYao),
        changedUpperGua: Value(entity.changedUpperGua),
        changedLowerGua: Value(entity.changedLowerGua),
        huUpperGua: Value(entity.huUpperGua),
        huLowerGua: Value(entity.huLowerGua),
        method: Value(entity.method),
        paramsJson: Value(entity.paramsJson),
        createdAt: Value(entity.createdAt),
        updatedAt: Value(entity.updatedAt),
      ),
    );
    return const Ok(Rev('0'));
  }

  @override
  Future<Result<Page<MeiHuaDivinationRecordContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final rows = await _dao.getAllRecords();
    final items = rows.map(_toContract).toList();
    return Ok(Page(items: items, nextCursor: null));
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final rows = await _dao.getAllRecords();
    return Ok(rows.length);
  }

  @override
  Stream<Result<List<MeiHuaDivinationRecordContract>>> watch(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) {
    return _dao.watchAllRecords().map(
      (rows) => Ok(rows.map(_toContract).toList()),
    );
  }

  @override
  Future<Result<MeiHuaDivinationRecordContract?>> get(
    String id,
    RequestContext ctx,
  ) async {
    final row = await _dao.getRecordByUuid(id);
    return Ok(row == null ? null : _toContract(row));
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final row = await _dao.getRecordByUuid(id);
    return Ok(row != null);
  }

  @override
  Future<MeiHuaDivinationRecordContract?> getRecordByDivinationUuid(
    String divinationUuid,
  ) async {
    final row = await _dao.getRecordByDivinationUuid(divinationUuid);
    return row == null ? null : _toContract(row);
  }

  @override
  Stream<MeiHuaDivinationRecordContract?> watchRecordByDivinationUuid(
    String divinationUuid,
  ) {
    return _dao
        .watchRecordByDivinationUuid(divinationUuid)
        .map((row) => row == null ? null : _toContract(row));
  }

  @override
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    final count = await _dao.softDeleteRecord(id);
    if (count > 0) return const Ok(null);
    return const Err(XuanError(code: ErrorCode.notFound, message: '要软删的记录不存在'));
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    return const Err(
      XuanError(
        code: ErrorCode.invalidArgument,
        message: 'restore not supported for drift records',
      ),
    );
  }

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
      return Err(
        XuanError(code: ErrorCode.internal, message: 'Transaction failed: $e'),
      );
    }
  }

  @override
  Future<String> saveRecord(MeiHuaDivinationRecordContract r) async {
    final uuid = r.uuid.isNotEmpty ? r.uuid : const Uuid().v4();
    final toSave = r.uuid.isNotEmpty
        ? r
        : MeiHuaDivinationRecordContract(
            uuid: uuid,
            divinationUuid: r.divinationUuid,
            question: r.question,
            originalUpperGua: r.originalUpperGua,
            originalLowerGua: r.originalLowerGua,
            changingYao: r.changingYao,
            changedUpperGua: r.changedUpperGua,
            changedLowerGua: r.changedLowerGua,
            huUpperGua: r.huUpperGua,
            huLowerGua: r.huLowerGua,
            method: r.method,
            paramsJson: r.paramsJson,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
            deletedAt: r.deletedAt,
          );
    await put(toSave, RequestContext(scopeUid: scopeUid ?? ''));
    return uuid;
  }

  @override
  Future<List<MeiHuaDivinationRecordContract>> getAllRecords() async {
    final res = await query(
      const {},
      PageRequest(limit: 1000),
      RequestContext(scopeUid: scopeUid ?? ''),
    );
    return (res as Ok<Page<MeiHuaDivinationRecordContract>>).value.items;
  }

  @override
  Future<MeiHuaDivinationRecordContract?> getRecordByUuid(String uuid) async {
    final res = await get(uuid, RequestContext(scopeUid: scopeUid ?? ''));
    return (res as Ok<MeiHuaDivinationRecordContract?>).value;
  }

  @override
  Future<bool> softDeleteRecord(String uuid) async {
    final count = await _dao.softDeleteRecord(uuid);
    return count > 0;
  }

  @override
  Stream<List<MeiHuaDivinationRecordContract>> watchAllRecords() {
    return _dao.watchAllRecords().map((rows) => rows.map(_toContract).toList());
  }
}
