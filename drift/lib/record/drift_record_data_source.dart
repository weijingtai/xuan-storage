import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';

class DriftRecordDataSource {
  final PersistenceDriftDatabase db;
  final String scopeUid;
  DriftRecordDataSource(this.db, {required this.scopeUid});

  TRecordMetaCompanion _companion(RecordMeta r) => TRecordMetaCompanion(
    uuid: Value(r.uuid),
    scopeUid: Value(scopeUid),
    module: Value(r.module),
    category: Value(r.category),
    divinationType: Value(r.divinationType),
    caseUuid: Value(r.caseUuid),
    workItemUuid: Value(r.workItemUuid),
    seekerUuid: Value(r.seekerUuid),
    question: Value(r.question),
    detail: Value(r.detail),
    tag: Value(r.tag),
    directPredict: Value(r.directPredict),
    verificationStatus: Value(r.verificationStatus),
    seekerName: Value(r.seekerName),
    gender: Value(r.gender),
    fateYear: Value(r.fateYear),
    moduleDataJson: Value(r.moduleDataJson),
    navParamsJson: Value(r.navParamsJson),
    occurredAtUtc: Value(r.occurredAtUtc),
    reckoningType: Value(r.reckoningType),
    timezoneStr: Value(r.timezoneStr),
    latitude: Value(r.latitude),
    longitude: Value(r.longitude),
    locationName: Value(r.locationName),
    spacetimeJson: Value(r.spacetimeJson),
    createdAt: Value(r.createdAt),
    updatedAt: Value(r.updatedAt),
    deletedAt: Value(r.deletedAt),
    rev: Value(r.rev),
  );

  RecordMeta _toMeta(TRecordMetaData row) => RecordMeta(
    uuid: row.uuid,
    scopeUid: row.scopeUid,
    module: row.module,
    category: row.category,
    divinationType: row.divinationType,
    caseUuid: row.caseUuid,
    workItemUuid: row.workItemUuid,
    seekerUuid: row.seekerUuid,
    question: row.question,
    detail: row.detail,
    tag: row.tag,
    directPredict: row.directPredict,
    verificationStatus: row.verificationStatus,
    seekerName: row.seekerName,
    gender: row.gender,
    fateYear: row.fateYear,
    moduleDataJson: row.moduleDataJson,
    navParamsJson: row.navParamsJson,
    occurredAtUtc: row.occurredAtUtc?.toUtc(),
    reckoningType: row.reckoningType,
    timezoneStr: row.timezoneStr,
    latitude: row.latitude,
    longitude: row.longitude,
    locationName: row.locationName,
    spacetimeJson: row.spacetimeJson,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt?.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
    rev: row.rev,
  );

  /// Writes a record and its search index rows without opening a transaction.
  /// Callers composing a larger unit of work must invoke this from their
  /// existing transaction.
  Future<void> saveRecordDirect(RecordMeta record, List<SearchTag> tags) async {
    if (record.scopeUid != scopeUid) {
      throw StateError(
        'Record ${record.uuid} belongs to ${record.scopeUid}, not $scopeUid',
      );
    }
    final existing = await (db.select(
      db.tRecordMeta,
    )..where((t) => t.uuid.equals(record.uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != scopeUid) {
      throw StateError('Record ${record.uuid} belongs to another scope');
    }
    await db.into(db.tRecordMeta).insertOnConflictUpdate(_companion(record));
    await (db.delete(db.tRecordSearchIndex)..where(
          (t) => t.recordUuid.equals(record.uuid) & t.scopeUid.equals(scopeUid),
        ))
        .go();
    for (final t in tags) {
      await db
          .into(db.tRecordSearchIndex)
          .insert(
            TRecordSearchIndexCompanion(
              recordUuid: Value(record.uuid),
              scopeUid: Value(scopeUid),
              module: Value(record.module),
              indexKey: Value(t.key),
              indexValue: Value(t.value),
            ),
          );
    }
  }

  Future<void> saveRecord(RecordMeta record, List<SearchTag> tags) {
    return db.transaction(() => saveRecordDirect(record, tags));
  }

  /// 供 RecordLocalApplier 使用：直接写入本地，不触发 outbox。
  Future<void> applyRemoteRecord(RecordMeta record, List<SearchTag> tags) {
    if (record.scopeUid != scopeUid) {
      throw StateError(
        'Remote record ${record.uuid} belongs to ${record.scopeUid}, not $scopeUid',
      );
    }
    return db.transaction(() async {
      await db.into(db.tRecordMeta).insertOnConflictUpdate(_companion(record));
      await (db.delete(
        db.tRecordSearchIndex,
      )..where((t) => t.recordUuid.equals(record.uuid))).go();
      for (final t in tags) {
        await db
            .into(db.tRecordSearchIndex)
            .insert(
              TRecordSearchIndexCompanion(
                recordUuid: Value(record.uuid),
                scopeUid: Value(scopeUid),
                module: Value(record.module),
                indexKey: Value(t.key),
                indexValue: Value(t.value),
              ),
            );
      }
    });
  }

  Future<RecordMeta?> getRecord(String uuid, {String? module}) async {
    final query = db.select(db.tRecordMeta)
      ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid));
    if (module != null) query.where((t) => t.module.equals(module));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toMeta(row);
  }

  RecordSortBy _effectiveSortBy(String? category, RecordSortBy sortBy) {
    if (sortBy != RecordSortBy.auto) return sortBy;
    if (category == 'divination') return RecordSortBy.occurredAtDesc;
    return RecordSortBy.createdAtDesc;
  }

  Future<List<RecordMeta>> listRecords({
    String? module,
    String? category,
    String? divinationType,
    int limit = 50,
    String? cursor,
    RecordSortBy sortBy = RecordSortBy.auto,
  }) async {
    final q = db.select(db.tRecordMeta)
      ..where((t) => t.scopeUid.equals(scopeUid) & t.deletedAt.isNull());
    if (module != null) q.where((t) => t.module.equals(module));
    if (category != null) q.where((t) => t.category.equals(category));
    if (divinationType != null) {
      q.where((t) => t.divinationType.equals(divinationType));
    }

    final effectiveSort = _effectiveSortBy(category, sortBy);

    if (cursor != null) {
      final parts = utf8.decode(base64Url.decode(cursor)).split('|');
      final cCreatedAt = DateTime.fromMicrosecondsSinceEpoch(
        int.parse(parts[0]),
        isUtc: true,
      );
      final cUuid = parts[1];

      if (effectiveSort == RecordSortBy.occurredAtDesc) {
        final cOccurredAt = parts.length > 2 && parts[2].isNotEmpty
            ? DateTime.fromMicrosecondsSinceEpoch(
                int.parse(parts[2]),
                isUtc: true,
              )
            : null;

        q.where((t) {
          if (cOccurredAt == null) {
            return t.occurredAtUtc.isNull() &
                (t.createdAt.isSmallerThanValue(cCreatedAt) |
                    (t.createdAt.equals(cCreatedAt) &
                        t.uuid.isBiggerThanValue(cUuid)));
          } else {
            return t.occurredAtUtc.isNull() |
                t.occurredAtUtc.isSmallerThanValue(cOccurredAt) |
                (t.occurredAtUtc.equals(cOccurredAt) &
                    (t.createdAt.isSmallerThanValue(cCreatedAt) |
                        (t.createdAt.equals(cCreatedAt) &
                            t.uuid.isBiggerThanValue(cUuid))));
          }
        });
      } else {
        q.where(
          (t) =>
              t.createdAt.isSmallerThanValue(cCreatedAt) |
              (t.createdAt.equals(cCreatedAt) &
                  t.uuid.isBiggerThanValue(cUuid)),
        );
      }
    }

    if (effectiveSort == RecordSortBy.occurredAtDesc) {
      q.orderBy([
        (t) => OrderingTerm.desc(t.occurredAtUtc, nulls: NullsOrder.last),
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.asc(t.uuid),
      ]);
    } else {
      q.orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.asc(t.uuid),
      ]);
    }

    q.limit(limit);
    return (await q.get()).map(_toMeta).toList();
  }

  Future<bool> softDeleteRecordDirect(String uuid, {String? module}) async {
    final n =
        await (db.update(db.tRecordMeta)..where((t) {
              final scopedUuid =
                  t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid);
              return module == null
                  ? scopedUuid
                  : scopedUuid & t.module.equals(module);
            }))
            .write(
              TRecordMetaCompanion(deletedAt: Value(DateTime.now().toUtc())),
            );
    await (db.delete(db.tRecordSearchIndex)..where(
          (t) => t.recordUuid.equals(uuid) & t.scopeUid.equals(scopeUid),
        ))
        .go();
    return n > 0;
  }

  Future<bool> softDeleteRecord(String uuid, {String? module}) {
    return db.transaction(() => softDeleteRecordDirect(uuid, module: module));
  }

  /// Restore (un-soft-delete) a previously soft-deleted record.
  ///
  /// Clears [deletedAt] and restores search index tags.
  /// Returns `true` if a record was restored, `false` if the uuid was not found
  /// or was already active (not soft-deleted).
  Future<bool> restoreRecordDirect(
    RecordMeta record,
    List<SearchTag> tags,
  ) async {
    if (record.scopeUid != scopeUid) {
      throw StateError(
        'Record ${record.uuid} belongs to ${record.scopeUid}, not $scopeUid',
      );
    }
    final existing =
        await (db.select(db.tRecordMeta)..where(
              (t) => t.uuid.equals(record.uuid) & t.scopeUid.equals(scopeUid),
            ))
            .getSingleOrNull();
    if (existing == null || existing.deletedAt == null) return false;

    await db.into(db.tRecordMeta).insertOnConflictUpdate(_companion(record));
    await (db.delete(db.tRecordSearchIndex)..where(
          (t) => t.recordUuid.equals(record.uuid) & t.scopeUid.equals(scopeUid),
        ))
        .go();
    for (final t in tags) {
      await db
          .into(db.tRecordSearchIndex)
          .insert(
            TRecordSearchIndexCompanion(
              recordUuid: Value(record.uuid),
              scopeUid: Value(scopeUid),
              module: Value(record.module),
              indexKey: Value(t.key),
              indexValue: Value(t.value),
            ),
          );
    }
    return true;
  }

  Future<bool> restoreRecord(RecordMeta record, List<SearchTag> tags) {
    return db.transaction(() => restoreRecordDirect(record, tags));
  }

  Stream<List<RecordMeta>> watchRecords({
    String? module,
    String? category,
    RecordSortBy sortBy = RecordSortBy.auto,
  }) {
    final q = db.select(db.tRecordMeta)
      ..where((t) => t.scopeUid.equals(scopeUid) & t.deletedAt.isNull());
    if (module != null) q.where((t) => t.module.equals(module));
    if (category != null) q.where((t) => t.category.equals(category));

    final effectiveSort = _effectiveSortBy(category, sortBy);
    if (effectiveSort == RecordSortBy.occurredAtDesc) {
      q.orderBy([
        (t) => OrderingTerm.desc(t.occurredAtUtc, nulls: NullsOrder.last),
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.asc(t.uuid),
      ]);
    } else {
      q.orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.asc(t.uuid),
      ]);
    }
    return q.watch().map((rows) => rows.map(_toMeta).toList());
  }

  /// Returns [RecordMeta] rows matching index query via JOIN.
  /// Scope-isolated; no N+1 UUID lookups.
  Future<List<RecordMeta>> findByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
    int limit = 50,
    RecordSortBy sortBy = RecordSortBy.auto,
  }) async {
    final metaAlias = db.tRecordMeta;
    final idxAlias = db.tRecordSearchIndex;
    final q = db.select(metaAlias).join([
      innerJoin(idxAlias, idxAlias.recordUuid.equalsExp(metaAlias.uuid)),
    ]);
    q.where(
      metaAlias.scopeUid.equals(scopeUid) &
          metaAlias.deletedAt.isNull() &
          idxAlias.module.equals(module) &
          idxAlias.scopeUid.equals(scopeUid) &
          idxAlias.indexKey.equals(indexKey) &
          idxAlias.indexValue.equals(indexValue),
    );

    final effectiveSort = _effectiveSortBy(null, sortBy);
    if (effectiveSort == RecordSortBy.occurredAtDesc) {
      q.orderBy([
        OrderingTerm.desc(metaAlias.occurredAtUtc, nulls: NullsOrder.last),
        OrderingTerm.desc(metaAlias.createdAt),
        OrderingTerm.asc(metaAlias.uuid),
      ]);
    } else {
      q.orderBy([
        OrderingTerm.desc(metaAlias.createdAt),
        OrderingTerm.asc(metaAlias.uuid),
      ]);
    }

    q.limit(limit);
    final rows = await q.map((row) => row.readTable(metaAlias)).get();
    return rows.map(_toMeta).toList();
  }

  Stream<List<RecordMeta>> watchByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
    RecordSortBy sortBy = RecordSortBy.auto,
  }) {
    final metaAlias = db.tRecordMeta;
    final idxAlias = db.tRecordSearchIndex;
    final q = db.select(metaAlias).join([
      innerJoin(idxAlias, idxAlias.recordUuid.equalsExp(metaAlias.uuid)),
    ]);
    q.where(
      metaAlias.scopeUid.equals(scopeUid) &
          metaAlias.deletedAt.isNull() &
          idxAlias.module.equals(module) &
          idxAlias.scopeUid.equals(scopeUid) &
          idxAlias.indexKey.equals(indexKey) &
          idxAlias.indexValue.equals(indexValue),
    );

    final effectiveSort = _effectiveSortBy(null, sortBy);
    if (effectiveSort == RecordSortBy.occurredAtDesc) {
      q.orderBy([
        OrderingTerm.desc(metaAlias.occurredAtUtc, nulls: NullsOrder.last),
        OrderingTerm.desc(metaAlias.createdAt),
        OrderingTerm.asc(metaAlias.uuid),
      ]);
    } else {
      q.orderBy([OrderingTerm.desc(metaAlias.createdAt)]);
    }

    return q
        .map((row) => row.readTable(metaAlias))
        .watch()
        .map((rows) => rows.map(_toMeta).toList());
  }

  static String encodeCursor(RecordMeta meta, RecordSortBy sortBy) {
    if (sortBy == RecordSortBy.occurredAtDesc) {
      final o = meta.occurredAtUtc?.microsecondsSinceEpoch.toString() ?? '';
      return base64Url.encode(
        utf8.encode('${meta.createdAt.microsecondsSinceEpoch}|${meta.uuid}|$o'),
      );
    }
    return base64Url.encode(
      utf8.encode('${meta.createdAt.microsecondsSinceEpoch}|${meta.uuid}'),
    );
  }

  /// 按 Case 查询其全部关联记录（跨模块，受 scope 约束）
  Future<List<RecordMeta>> listRecordsByCase(
    String caseUuid, {
    int? limit,
    String? cursor,
  }) async {
    final q = db.select(db.tRecordMeta)
      ..where(
        (t) =>
            t.scopeUid.equals(scopeUid) &
            t.deletedAt.isNull() &
            t.caseUuid.equals(caseUuid),
      )
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.asc(t.uuid),
      ]);

    if (cursor != null) {
      final parts = utf8.decode(base64Url.decode(cursor)).split('|');
      final cCreatedAt = DateTime.fromMicrosecondsSinceEpoch(
        int.parse(parts[0]),
        isUtc: true,
      );
      final cUuid = parts[1];
      q.where(
        (t) =>
            t.createdAt.isSmallerThanValue(cCreatedAt) |
            (t.createdAt.equals(cCreatedAt) &
                t.uuid.isBiggerThanValue(cUuid)),
      );
    }

    if (limit != null) q.limit(limit);
    return (await q.get()).map(_toMeta).toList();
  }

  /// 按 Case 聚合计数（不拉明细），受 scope 约束
  Future<int> countRecordsByCase(String caseUuid) async {
    final count = db.tRecordMeta.uuid.count();
    final q = db.selectOnly(db.tRecordMeta)
      ..addColumns([count])
      ..where(
        db.tRecordMeta.scopeUid.equals(scopeUid) &
            db.tRecordMeta.deletedAt.isNull() &
            db.tRecordMeta.caseUuid.equals(caseUuid),
      );
    final result = await q.getSingle();
    return result.read(count) ?? 0;
  }
}
