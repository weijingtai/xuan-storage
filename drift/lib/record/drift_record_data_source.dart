import 'dart:convert';
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
        navParamsJson: Value(r.navParamsJson),
        occurredAtUtc: Value(r.occurredAtUtc),
        reckoningType: Value(r.reckoningType),
        timezoneStr: Value(r.timezoneStr),
        latitude: Value(r.latitude),
        longitude: Value(r.longitude),
        locationName: Value(r.locationName),
        spacetimeJson: Value(r.spacetimeJson),
        createdAt: Value(r.createdAt),
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
        occurredAtUtc: row.occurredAtUtc,
        reckoningType: row.reckoningType,
        timezoneStr: row.timezoneStr,
        latitude: row.latitude,
        longitude: row.longitude,
        locationName: row.locationName,
        spacetimeJson: row.spacetimeJson,
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

  /// 供 RecordLocalApplier 使用：直接写入本地，不触发 outbox。
  Future<void> applyRemoteRecord(RecordMeta record, List<SearchTag> tags) {
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

  RecordSortBy _effectiveSortBy(String? category, RecordSortBy sortBy) {
    if (sortBy != RecordSortBy.auto) return sortBy;
    if (category == 'divination') return RecordSortBy.occurredAtDesc;
    return RecordSortBy.createdAtDesc;
  }

  Future<List<RecordMeta>> listRecords({
    String? module, String? category, String? divinationType,
    int limit = 50, String? cursor,
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
      final cCreatedAt = DateTime.fromMicrosecondsSinceEpoch(int.parse(parts[0]), isUtc: true);
      final cUuid = parts[1];

      if (effectiveSort == RecordSortBy.occurredAtDesc) {
        final cOccurredAt = parts.length > 2 && parts[2].isNotEmpty
            ? DateTime.fromMicrosecondsSinceEpoch(int.parse(parts[2]), isUtc: true)
            : null;

        q.where((t) {
          if (cOccurredAt == null) {
            return t.occurredAtUtc.isNull() & (
              t.createdAt.isSmallerThanValue(cCreatedAt) |
              (t.createdAt.equals(cCreatedAt) & t.uuid.isBiggerThanValue(cUuid))
            );
          } else {
            return t.occurredAtUtc.isNull() |
              t.occurredAtUtc.isSmallerThanValue(cOccurredAt) |
              (t.occurredAtUtc.equals(cOccurredAt) & (
                t.createdAt.isSmallerThanValue(cCreatedAt) |
                (t.createdAt.equals(cCreatedAt) & t.uuid.isBiggerThanValue(cUuid))
              ));
          }
        });
      } else {
        q.where((t) =>
            t.createdAt.isSmallerThanValue(cCreatedAt) |
            (t.createdAt.equals(cCreatedAt) & t.uuid.isBiggerThanValue(cUuid)));
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

  Future<bool> softDeleteRecord(String uuid) {
    return db.transaction(() async {
      final n = await (db.update(db.tRecordMeta)
            ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid)))
          .write(TRecordMetaCompanion(deletedAt: Value(DateTime.now())));
      await (db.delete(db.tRecordSearchIndex)
            ..where((t) => t.recordUuid.equals(uuid) & t.scopeUid.equals(scopeUid)))
          .go();
      return n > 0;
    });
  }

  Stream<List<RecordMeta>> watchRecords({
    String? module, String? category,
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
      innerJoin(idxAlias, idxAlias.recordUuid.equalsExp(metaAlias.uuid))
    ]);
    q.where(metaAlias.scopeUid.equals(scopeUid) &
        metaAlias.deletedAt.isNull() &
        idxAlias.module.equals(module) &
        idxAlias.scopeUid.equals(scopeUid) &
        idxAlias.indexKey.equals(indexKey) &
        idxAlias.indexValue.equals(indexValue));

    final effectiveSort = _effectiveSortBy(null, sortBy);
    if (effectiveSort == RecordSortBy.occurredAtDesc) {
      q.orderBy([
        OrderingTerm.desc(metaAlias.occurredAtUtc, nulls: NullsOrder.last),
        OrderingTerm.desc(metaAlias.createdAt),
        OrderingTerm.asc(metaAlias.uuid)
      ]);
    } else {
      q.orderBy([OrderingTerm.desc(metaAlias.createdAt), OrderingTerm.asc(metaAlias.uuid)]);
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
      innerJoin(idxAlias, idxAlias.recordUuid.equalsExp(metaAlias.uuid))
    ]);
    q.where(metaAlias.scopeUid.equals(scopeUid) &
        metaAlias.deletedAt.isNull() &
        idxAlias.module.equals(module) &
        idxAlias.scopeUid.equals(scopeUid) &
        idxAlias.indexKey.equals(indexKey) &
        idxAlias.indexValue.equals(indexValue));

    final effectiveSort = _effectiveSortBy(null, sortBy);
    if (effectiveSort == RecordSortBy.occurredAtDesc) {
      q.orderBy([
        OrderingTerm.desc(metaAlias.occurredAtUtc, nulls: NullsOrder.last),
        OrderingTerm.desc(metaAlias.createdAt),
        OrderingTerm.asc(metaAlias.uuid)
      ]);
    } else {
      q.orderBy([OrderingTerm.desc(metaAlias.createdAt)]);
    }

    return q.map((row) => row.readTable(metaAlias)).watch().map((rows) => rows.map(_toMeta).toList());
  }

  static String encodeCursor(RecordMeta meta, RecordSortBy sortBy) {
    if (sortBy == RecordSortBy.occurredAtDesc) {
      final o = meta.occurredAtUtc?.microsecondsSinceEpoch.toString() ?? '';
      return base64Url.encode(utf8.encode('${meta.createdAt.microsecondsSinceEpoch}|${meta.uuid}|$o'));
    }
    return base64Url.encode(utf8.encode('${meta.createdAt.microsecondsSinceEpoch}|${meta.uuid}'));
  }
}

