import 'package:drift/drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import '../persistence_drift.dart';

class DriftRecordDataSource {
  final PersistenceDriftDatabase db;
  final String scopeUid;
  DriftRecordDataSource(this.db, {required this.scopeUid});

  TRecordMetaCompanion _companion(RecordMeta r) => TRecordMetaCompanion(
        uuid: Value(r.uuid), scopeUid: Value(scopeUid), module: Value(r.module),
        category: Value(r.category), divinationType: Value(r.divinationType),
        caseUuid: Value(r.caseUuid), workItemUuid: Value(r.workItemUuid),
        seekerUuid: Value(r.seekerUuid), question: Value(r.question),
        detail: Value(r.detail), tag: Value(r.tag),
        directPredict: Value(r.directPredict),
        verificationStatus: Value(r.verificationStatus),
        seekerName: Value(r.seekerName), gender: Value(r.gender),
        fateYear: Value(r.fateYear), moduleDataJson: Value(r.moduleDataJson),
        navParamsJson: Value(r.navParamsJson), createdAt: Value(r.createdAt),
        updatedAt: Value(r.updatedAt), deletedAt: Value(r.deletedAt),
        rev: Value(r.rev),
      );

  RecordMeta _toMeta(TRecordMetaData row) => RecordMeta(
        uuid: row.uuid, scopeUid: row.scopeUid, module: row.module,
        category: row.category, divinationType: row.divinationType,
        caseUuid: row.caseUuid, workItemUuid: row.workItemUuid,
        seekerUuid: row.seekerUuid, question: row.question, detail: row.detail,
        tag: row.tag, directPredict: row.directPredict,
        verificationStatus: row.verificationStatus, seekerName: row.seekerName,
        gender: row.gender, fateYear: row.fateYear,
        moduleDataJson: row.moduleDataJson, navParamsJson: row.navParamsJson,
        createdAt: row.createdAt, updatedAt: row.updatedAt,
        deletedAt: row.deletedAt, rev: row.rev,
      );

  Future<void> saveRecord(RecordMeta record, List<SearchTag> tags) {
    return db.transaction(() async {
      await db.into(db.tRecordMeta).insertOnConflictUpdate(_companion(record));
      await (db.delete(db.tRecordSearchIndex)
            ..where((t) => t.recordUuid.equals(record.uuid)))
          .go();
      for (final t in tags) {
        await db.into(db.tRecordSearchIndex).insert(TRecordSearchIndexCompanion(
              recordUuid: Value(record.uuid), scopeUid: Value(scopeUid),
              module: Value(record.module), indexKey: Value(t.key),
              indexValue: Value(t.value),
            ));
      }
    });
  }

  Future<RecordMeta?> getRecord(String uuid) async {
    final row = await (db.select(db.tRecordMeta)
          ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid)))
        .getSingleOrNull();
    return row == null ? null : _toMeta(row);
  }

  Future<List<RecordMeta>> listRecords({
    String? module, String? category, String? divinationType,
    int limit = 50, String? cursor,
  }) async {
    final q = db.select(db.tRecordMeta)
      ..where((t) => t.scopeUid.equals(scopeUid) & t.deletedAt.isNull());
    if (module != null) q.where((t) => t.module.equals(module));
    if (category != null) q.where((t) => t.category.equals(category));
    if (divinationType != null) {
      q.where((t) => t.divinationType.equals(divinationType));
    }
    if (cursor != null) {
      final c = RecordCursor.decode(cursor);
      q.where((t) =>
          t.createdAt.isSmallerThanValue(c.createdAt) |
          (t.createdAt.equals(c.createdAt) & t.uuid.isBiggerThanValue(c.uuid)));
    }
    q.orderBy([
      (t) => OrderingTerm.desc(t.createdAt),
      (t) => OrderingTerm.asc(t.uuid),
    ]);
    q.limit(limit);
    return (await q.get()).map(_toMeta).toList();
  }

  Future<bool> softDeleteRecord(String uuid) {
    return db.transaction(() async {
      final n = await (db.update(db.tRecordMeta)
            ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid)))
          .write(TRecordMetaCompanion(deletedAt: Value(DateTime.now())));
      await (db.delete(db.tRecordSearchIndex)
            ..where((t) => t.recordUuid.equals(uuid)))
          .go();
      return n > 0;
    });
  }

  Stream<List<RecordMeta>> watchRecords({String? module, String? category}) {
    final q = db.select(db.tRecordMeta)
      ..where((t) => t.scopeUid.equals(scopeUid) & t.deletedAt.isNull());
    if (module != null) q.where((t) => t.module.equals(module));
    if (category != null) q.where((t) => t.category.equals(category));
    q.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch().map((rows) => rows.map(_toMeta).toList());
  }
}
