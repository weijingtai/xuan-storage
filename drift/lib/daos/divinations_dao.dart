import 'package:drift/drift.dart';
import 'package:metaphysics_core/datamodel/divination_request_info_datamodel.dart';
import 'package:persistence_drift/persistence_drift.dart';

part 'divinations_dao.g.dart';

@DriftAccessor(tables: [Divinations])
class DivinationsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$DivinationsDaoMixin {
  final PersistenceDriftDatabase db;
  DivinationsDao(this.db) : super(db);

  SimpleSelectStatement<$DivinationsTable, DivinationRequestInfoDataModel>
      _baseSelect() => select(db.divinations);

  Future<List<DivinationRequestInfoDataModel>> getAllDivinations() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<DivinationRequestInfoDataModel?> getDivinationByUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertDivination(DivinationsCompanion companion) {
    return into(db.divinations).insert(companion);
  }

  Future<bool> updateDivination(DivinationsCompanion companion) {
    return update(db.divinations).replace(companion);
  }

  Future<int> softDeleteDivination(String uuid) {
    return (update(db.divinations)..where((t) => t.uuid.equals(uuid)))
        .write(DivinationsCompanion(deletedAt: Value(DateTime.now())));
  }
}
