import 'package:drift/drift.dart';
import 'package:persistence_drift/persistence_drift.dart';

part 'divination_tags_dao.g.dart';

@DriftAccessor(tables: [DivinationTags])
class DivinationTagsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$DivinationTagsDaoMixin {
  final PersistenceDriftDatabase db;
  DivinationTagsDao(this.db) : super(db);

  Future<void> insertTags(List<DivinationTagsCompanion> tags) async {
    await batch((b) => b.insertAll(db.divinationTags, tags, mode: InsertMode.insertOrReplace));
  }

  Future<List<String>> findDivinationUuids({
    required String scopeUid,
    required String domain,
    required String tagKey,
    required String tagValue,
  }) async {
    final rows = await (select(db.divinationTags)
          ..where((t) =>
              t.scopeUid.equals(scopeUid) &
              t.domain.equals(domain) &
              t.tagKey.equals(tagKey) &
              t.tagValue.equals(tagValue)))
        .get();
    return rows.map((r) => r.divinationUuid).toList();
  }

  Future<void> clearForDivination(String divinationUuid) async {
    await (delete(db.divinationTags)..where((t) => t.divinationUuid.equals(divinationUuid))).go();
  }
}
