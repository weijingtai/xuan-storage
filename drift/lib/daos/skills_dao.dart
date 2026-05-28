import 'package:drift/drift.dart';
import 'package:persistence_drift/persistence_drift.dart';

class SkillsDao {
  final PersistenceDriftDatabase db;
  SkillsDao(this.db);

  Future<List<Skill>> getAll() {
    return (db.select(db.skills)..where((t) => t.deletedAt.isNull())).get();
  }

  Future<int> insert(SkillsCompanion companion) {
    return db.into(db.skills).insert(companion);
  }
}
