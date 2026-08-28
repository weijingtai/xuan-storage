import 'package:drift/drift.dart';
import 'package:metaphysics_core/datamodel/seeker_model.dart';
import 'package:persistence_drift/persistence_drift.dart';

part 'seekers_dao.g.dart';

@Deprecated(
  '已迁移至 t_record_meta (module=\'seeker\')，请使用 RecordBackedSeekerRepository',
)
@DriftAccessor(tables: [Seekers])
class SeekersDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$SeekersDaoMixin {
  final PersistenceDriftDatabase db;
  final String? scopeUid;
  SeekersDao(this.db, {this.scopeUid}) : super(db);

  SimpleSelectStatement<$SeekersTable, SeekerModel> _baseSelect({
    String? scopeUid,
  }) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final s = select(db.seekers);
    if (effectiveScope != null) {
      s.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return s;
  }

  Future<List<SeekerModel>> getAllSeekers({String? scopeUid}) {
    return (_baseSelect(
      scopeUid: scopeUid,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<SeekerModel?> getSeekerByUuid(String uuid, {String? scopeUid}) {
    return (_baseSelect(scopeUid: scopeUid)
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  @Deprecated('使用 RecordModuleRegistry.repositoryFor(module: \'seeker\') 替代')
  Future<List<SeekerModel>> getSeekersByDivinationUuid(
    String divinationUuid, {
    String? scopeUid,
  }) {
    return (_baseSelect(scopeUid: scopeUid)..where(
          (t) => t.divinationUuid.equals(divinationUuid) & t.deletedAt.isNull(),
        ))
        .get();
  }

  Future<int> insertSeeker(SeekersCompanion companion) {
    if (scopeUid != null && !companion.scopeUid.present) {
      companion = companion.copyWith(scopeUid: Value(scopeUid));
    }
    return into(db.seekers).insert(companion);
  }

  Future<bool> updateSeeker(SeekersCompanion companion, {String? scopeUid}) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    if (effectiveScope != null) {
      return (update(db.seekers)..where(
            (t) =>
                t.uuid.equals(companion.uuid.value) &
                t.scopeUid.equals(effectiveScope),
          ))
          .write(companion)
          .then((count) => count > 0);
    }
    return update(db.seekers).replace(companion);
  }

  Future<int> softDeleteSeeker(String uuid, {String? scopeUid}) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = update(db.seekers)..where((t) => t.uuid.equals(uuid));
    if (effectiveScope != null) {
      query.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return query.write(SeekersCompanion(deletedAt: Value(DateTime.now())));
  }
}
