import 'package:drift/drift.dart';
import 'package:persistence_drift/persistence_drift.dart';

class SkillClassesDao {
  final PersistenceDriftDatabase db;
  SkillClassesDao(this.db);

  Future<List<SkillClass>> getAll() {
    return db.select(db.skillClasses).get();
  }

  Future<int> insert(SkillClassesCompanion companion) {
    return db.into(db.skillClasses).insert(companion);
  }
}
