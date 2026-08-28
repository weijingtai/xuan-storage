import 'package:drift/drift.dart';
import 'package:persistence_drift/persistence_drift.dart';

class SkillClassesDao {
  final PersistenceDriftDatabase db;
  final String? scopeUid;
  SkillClassesDao(this.db, {this.scopeUid});

  Future<List<SkillClass>> getAll({String? scopeUid}) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = db.select(db.skillClasses);
    if (effectiveScope != null) {
      query.where(
        (t) => t.scopeUid.equals(effectiveScope) | t.scopeUid.isNull(),
      );
    }
    return query.get();
  }

  Future<int> insert(SkillClassesCompanion companion) {
    if (scopeUid != null && !companion.scopeUid.present) {
      companion = companion.copyWith(scopeUid: Value(scopeUid));
    }
    return db.into(db.skillClasses).insert(companion);
  }
}
