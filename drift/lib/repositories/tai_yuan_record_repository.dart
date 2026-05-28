import 'package:persistence_drift/persistence_drift.dart';
import 'package:drift/drift.dart';

class TaiYuanRecordRepository {
  final PersistenceDriftDatabase db;

  TaiYuanRecordRepository(this.db);

  Future<int> insert(Insertable<TaiYuanRecord> record) {
    return db.taiYuanRecordsDao.insertRecord(record);
  }

  // 根据 calendar_uuid 获取对应胎元版本的方法
  Future<List<TaiYuanRecord>> queryByCalendarUuid(String calendarUuid) {
    return db.taiYuanRecordsDao.getByCalendar(calendarUuid);
  }

  Future<void> saveAndSwitchCurrentTaiYuan(String calendarUuid,
      Insertable<TaiYuanRecord> record, String newTaiYuanUuid) async {
    await db.transaction(() async {
      await insert(record);
      await (db.update(db.divinationCalendars)
            ..where((t) => t.uuid.equals(calendarUuid)))
          .write(DivinationCalendarsCompanion(
              currentTaiYuanUuid: Value(newTaiYuanUuid)));
    });
  }
}
