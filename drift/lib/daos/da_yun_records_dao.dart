import 'package:drift/drift.dart';

import 'package:persistence_drift/persistence_drift.dart';


part 'da_yun_records_dao.g.dart';

@DriftAccessor(tables: [DaYunRecords])
class DaYunRecordsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$DaYunRecordsDaoMixin {
  DaYunRecordsDao(super.db);

  Future<int> insertRecord(Insertable<DaYunRecord> record) {
    return into(daYunRecords).insert(record);
  }

  Future<List<DaYunRecord>> getBySource(String sourceUuid) {
    return (select(daYunRecords)..where((t) => t.sourceUuid.equals(sourceUuid)))
        .get();
  }
}
