import 'package:drift/drift.dart';
import 'package:metaphysics_core/datamodel/timing_divination_model.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/tables/tables.dart';

part 'timing_divinations_dao.g.dart';

@DriftAccessor(tables: [TimingDivinations])
class TimingDivinationsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$TimingDivinationsDaoMixin {
  final PersistenceDriftDatabase db;
  final String? scopeUid;
  TimingDivinationsDao(this.db, {this.scopeUid}) : super(db);

  SimpleSelectStatement<$TimingDivinationsTable, TimingDivinationModel>
  _baseSelect({String? scopeUid}) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final s = select(db.timingDivinations);
    if (effectiveScope != null) {
      s.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return s;
  }

  Future<List<TimingDivinationModel>> getAllTimingDivinations({
    String? scopeUid,
  }) {
    return (_baseSelect(
      scopeUid: scopeUid,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<TimingDivinationModel?> getTimingDivinationByUuid(
    String uuid, {
    String? scopeUid,
  }) {
    return (_baseSelect(scopeUid: scopeUid)
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertTimingDivination(TimingDivinationsCompanion companion) {
    if (scopeUid != null && !companion.scopeUid.present) {
      companion = companion.copyWith(scopeUid: Value(scopeUid));
    }
    return into(db.timingDivinations).insert(companion);
  }

  Future<bool> updateTimingDivination(
    TimingDivinationsCompanion companion, {
    String? scopeUid,
  }) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    if (effectiveScope != null) {
      return (update(db.timingDivinations)..where(
            (t) =>
                t.uuid.equals(companion.uuid.value) &
                t.scopeUid.equals(effectiveScope),
          ))
          .write(companion)
          .then((count) => count > 0);
    }
    return update(db.timingDivinations).replace(companion);
  }

  Future<int> softDeleteTimingDivination(String uuid, {String? scopeUid}) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = update(db.timingDivinations)
      ..where((t) => t.uuid.equals(uuid));
    if (effectiveScope != null) {
      query.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return query.write(
      TimingDivinationsCompanion(deletedAt: Value(DateTime.now())),
    );
  }
}
