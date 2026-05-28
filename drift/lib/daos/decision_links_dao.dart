import 'package:drift/drift.dart';
import 'package:persistence_drift/persistence_drift.dart';

part 'decision_links_dao.g.dart';

@DriftAccessor(tables: [DecisionLinks])
class DecisionLinksDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$DecisionLinksDaoMixin {
  final PersistenceDriftDatabase db;
  DecisionLinksDao(this.db) : super(db);

  Future<int> upsert(DecisionLinksCompanion record) =>
      into(db.decisionLinks).insertOnConflictUpdate(record);

  Future<DecisionLinkRow?> getById(String id, String scopeUid) =>
      (select(db.decisionLinks)
            ..where((t) => t.id.equals(id) & t.scopeUid.equals(scopeUid)))
          .getSingleOrNull();

  Future<List<DecisionLinkRow>> listBySource(String sourceUuid, String scopeUid) =>
      (select(db.decisionLinks)
            ..where((t) => t.sourceUuid.equals(sourceUuid) & t.scopeUid.equals(scopeUid))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)]))
          .get();
}
