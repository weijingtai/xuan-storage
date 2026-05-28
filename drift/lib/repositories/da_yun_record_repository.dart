import 'package:persistence_drift/persistence_drift.dart';
import 'package:drift/drift.dart';

class DaYunRecordRepository {
  final PersistenceDriftDatabase db;

  DaYunRecordRepository(this.db);

  Future<int> insert(Insertable<DaYunRecord> record) {
    return db.daYunRecordsDao.insertRecord(record);
  }

  Future<List<DaYunRecord>> queryBySourceUuid(String sourceUuid) {
    return db.daYunRecordsDao.getBySource(sourceUuid);
  }

  // 针对特定 sourceUuid 和算法维度组合查询
  Future<DaYunRecord?> querySpecific(
      String sourceUuid, String jieQiType, String precision) async {
    return (db.select(db.daYunRecords)
          ..where((t) =>
              t.sourceUuid.equals(sourceUuid) &
              t.jieQiType.equals(jieQiType) &
              t.precision.equals(precision)))
        .getSingleOrNull();
  }
}
