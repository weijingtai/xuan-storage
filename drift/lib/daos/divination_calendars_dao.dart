import 'package:drift/drift.dart';
import 'package:persistence_drift/persistence_drift.dart';

class DivinationCalendarsDao {
  final PersistenceDriftDatabase db;
  DivinationCalendarsDao(this.db);

  Future<int> insertCalendar(Insertable<DivinationCalendar> calendar) {
    return db.into(db.divinationCalendars).insert(calendar);
  }

  Future<List<DivinationCalendar>> getBySource(String sourceUuid) {
    return (db.select(db.divinationCalendars)
          ..where((t) => t.sourceUuid.equals(sourceUuid)))
        .get();
  }
}
