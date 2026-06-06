import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';

import 'meihua_database.dart';
import 'meihua_gua_infos.dart';
import 'meihua_divinations_dao.dart';

/// Drift-backed implementation of [MeiHuaDivinationRecordRepository].
class DriftMeiHuaDivinationRecordRepository
    implements MeiHuaDivinationRecordRepository {
  final MeiHuaDatabase _database;
  final MeiHuaDivinationsDao _dao;

  DriftMeiHuaDivinationRecordRepository(this._database)
      : _dao = MeiHuaDivinationsDao(_database);

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
  Future<String> saveRecord(MeiHuaDivinationRecordContract record) async {
    final uuid = record.uuid.isNotEmpty ? record.uuid : const Uuid().v4();
    await _dao.insertRecord(
      MeiHuaGuaInfosCompanion(
        uuid: Value(uuid),
        divinationUuid: Value(
            record.divinationUuid.isNotEmpty ? record.divinationUuid : uuid),
        question: Value(record.question),
        originalUpperGua: Value(record.originalUpperGua),
        originalLowerGua: Value(record.originalLowerGua),
        changingYao: Value(record.changingYao),
        changedUpperGua: Value(record.changedUpperGua),
        changedLowerGua: Value(record.changedLowerGua),
        huUpperGua: Value(record.huUpperGua),
        huLowerGua: Value(record.huLowerGua),
        method: Value(record.method),
        paramsJson: Value(record.paramsJson),
        createdAt: Value(record.createdAt),
        updatedAt: Value(record.updatedAt),
      ),
    );
    return uuid;
  }

  @override
  Future<List<MeiHuaDivinationRecordContract>> getAllRecords() async {
    final rows = await _dao.getAllRecords();
    return rows.map(_toContract).toList();
  }

  @override
  Stream<List<MeiHuaDivinationRecordContract>> watchAllRecords() {
    return _dao
        .watchAllRecords()
        .map((rows) => rows.map(_toContract).toList());
  }

  @override
  Future<MeiHuaDivinationRecordContract?> getRecordByUuid(String uuid) async {
    final row = await _dao.getRecordByUuid(uuid);
    return row == null ? null : _toContract(row);
  }

  @override
  Future<MeiHuaDivinationRecordContract?> getRecordByDivinationUuid(
      String divinationUuid) async {
    final row = await _dao.getRecordByDivinationUuid(divinationUuid);
    return row == null ? null : _toContract(row);
  }

  @override
  Stream<MeiHuaDivinationRecordContract?> watchRecordByDivinationUuid(
      String divinationUuid) {
    return _dao
        .watchRecordByDivinationUuid(divinationUuid)
        .map((row) => row == null ? null : _toContract(row));
  }

  @override
  Future<bool> softDeleteRecord(String uuid) async {
    final count = await _dao.softDeleteRecord(uuid);
    return count > 0;
  }
}
