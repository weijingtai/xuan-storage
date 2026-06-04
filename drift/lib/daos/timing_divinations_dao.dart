import 'package:drift/drift.dart';
import 'package:metaphysics_core/datamodel/timing_divination_model.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/tables/tables.dart';

part 'timing_divinations_dao.g.dart';

@DriftAccessor(tables: [TimingDivinations])
class TimingDivinationsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$TimingDivinationsDaoMixin {
  final PersistenceDriftDatabase db;
  TimingDivinationsDao(this.db) : super(db);

  SimpleSelectStatement<$TimingDivinationsTable, TimingDivinationModel>
      _baseSelect() => select(db.timingDivinations);

  Future<List<TimingDivinationModel>> getAllTimingDivinations() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<TimingDivinationModel?> getTimingDivinationByUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertTimingDivination(TimingDivinationsCompanion companion) {
    return into(db.timingDivinations).insert(companion);
  }

  Future<bool> updateTimingDivination(TimingDivinationsCompanion companion) {
    return update(db.timingDivinations).replace(companion);
  }

  Future<int> softDeleteTimingDivination(String uuid) {
    return (update(db.timingDivinations)..where((t) => t.uuid.equals(uuid)))
        .write(TimingDivinationsCompanion(deletedAt: Value(DateTime.now())));
  }
}
