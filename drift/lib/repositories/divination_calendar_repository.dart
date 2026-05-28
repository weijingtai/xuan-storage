import 'package:persistence_drift/persistence_drift.dart';
import 'package:drift/drift.dart';

class DivinationCalendarRepository {
  final PersistenceDriftDatabase db;
  late final DivinationCalendarsDao _dao;

  DivinationCalendarRepository(this.db) : _dao = DivinationCalendarsDao(db);

  Future<int> insert(Insertable<DivinationCalendar> record) {
    return _dao.insertCalendar(record);
  }

  Future<List<DivinationCalendar>> getAll() {
    return _dao.getBySource("");
  }
}
