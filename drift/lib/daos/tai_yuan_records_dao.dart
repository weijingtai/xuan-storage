import 'package:drift/drift.dart';

import 'package:persistence_drift/persistence_drift.dart';


part 'tai_yuan_records_dao.g.dart';

@DriftAccessor(tables: [TaiYuanRecords])
class TaiYuanRecordsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$TaiYuanRecordsDaoMixin {
  TaiYuanRecordsDao(super.db);

  Future<int> insertRecord(Insertable<TaiYuanRecord> record) {
    return into(taiYuanRecords).insert(record);
  }

  Future<List<TaiYuanRecord>> getByCalendar(String calendarUuid) {
    return (select(taiYuanRecords)
          ..where((t) => t.calendarUuid.equals(calendarUuid)))
        .get();
  }
}
