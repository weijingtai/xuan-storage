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

  Future<List<DecisionLinkRow>> listByTarget(String targetUuid, String scopeUid) =>
      (select(db.decisionLinks)
            ..where((t) => t.targetUuid.equals(targetUuid) & t.scopeUid.equals(scopeUid))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)]))
          .get();

  Future<List<DecisionLinkRow>> listBySession(String sessionId, String scopeUid) =>
      (select(db.decisionLinks)
            ..where((t) => t.sessionId.equals(sessionId) & t.scopeUid.equals(scopeUid)))
          .get();

  Future<List<DecisionLinkRow>> listByType(String sourceUuid, String linkType, String scopeUid) =>
      (select(db.decisionLinks)
            ..where((t) => t.sourceUuid.equals(sourceUuid) & t.linkType.equals(linkType) & t.scopeUid.equals(scopeUid)))
          .get();

  Future<int> deleteBySession(String sessionId, String scopeUid) =>
      (delete(db.decisionLinks)
            ..where((t) => t.sessionId.equals(sessionId) & t.scopeUid.equals(scopeUid)))
          .go();

  Future<List<DecisionLinkRow>> getMergeChain(String startUuid, String scopeUid) async {
    final results = <DecisionLinkRow>[];
    var current = startUuid;
    while (true) {
      final links = await listBySource(current, scopeUid);
      final mergeLinks = links.where((l) => l.linkType == 'merge').toList();
      if (mergeLinks.isEmpty) break;
      results.addAll(mergeLinks);
      current = mergeLinks.first.targetUuid;
    }
    return results;
  }
}
