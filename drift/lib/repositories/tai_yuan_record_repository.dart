import 'package:persistence_drift/persistence_drift.dart';
import 'package:drift/drift.dart';

class TaiYuanRecordRepository {
  final PersistenceDriftDatabase db;
  late final TaiYuanRecordsDao _dao;

  TaiYuanRecordRepository(this.db) : _dao = TaiYuanRecordsDao(db);

  Future<int> insert(Insertable<TaiYuanRecord> record) {
    return _dao.insertRecord(record);
  }

  Future<List<TaiYuanRecord>> queryByCalendarUuid(String calendarUuid) {
    return _dao.getByCalendar(calendarUuid);
  }

  // TODO(S7): restore saveAndSwitchCurrentTaiYuan when DivinationCalendars table is migrated
}
