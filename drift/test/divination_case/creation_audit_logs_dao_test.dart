import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  test('insertAuditLog inserts a row with every field round-tripped', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final auditedAt = DateTime(2026, 7, 26, 9, 15, 30);
    final rowId = await db.creationAuditLogsDao.insertAuditLog(
      caseUuid: 'case-insert',
      auditedAt: auditedAt,
      changeType: 'update',
      entityType: 'judgement',
      entityUuid: 'judgement-1',
      oldJson: '{"text":"old"}',
      newJson: '{"text":"new"}',
      summary: 'judgement text changed',
      operatorId: 'operator-1',
    );

    expect(rowId, 1);

    final rows =
        await db.creationAuditLogsDao.getAuditLogsByCaseUuid('case-insert');
    expect(rows.length, 1);

    final row = rows.single;
    expect(row.id, 1);
    expect(row.caseUuid, 'case-insert');
    expect(row.auditedAt, auditedAt);
    expect(row.changeType, 'update');
    expect(row.entityType, 'judgement');
    expect(row.entityUuid, 'judgement-1');
    expect(row.oldJson, '{"text":"old"}');
    expect(row.newJson, '{"text":"new"}');
    expect(row.summary, 'judgement text changed');
    expect(row.operatorId, 'operator-1');
  });

  test('getAuditLogsByCaseUuid returns newest records first', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await _insertAuditLog(
      db,
      caseUuid: 'case-sort',
      auditedAt: DateTime(2026, 7, 26, 8),
      summary: 'oldest',
    );
    await _insertAuditLog(
      db,
      caseUuid: 'case-sort',
      auditedAt: DateTime(2026, 7, 26, 10),
      summary: 'newest',
    );
    await _insertAuditLog(
      db,
      caseUuid: 'case-sort',
      auditedAt: DateTime(2026, 7, 26, 9),
      summary: 'middle',
    );
    await _insertAuditLog(
      db,
      caseUuid: 'other-case',
      auditedAt: DateTime(2026, 7, 26, 11),
      summary: 'other case newest',
    );

    final rows =
        await db.creationAuditLogsDao.getAuditLogsByCaseUuid('case-sort');

    expect(rows.map((row) => row.summary).toList(), [
      'newest',
      'middle',
      'oldest',
    ]);
    expect(rows.map((row) => row.caseUuid).toList(), [
      'case-sort',
      'case-sort',
      'case-sort',
    ]);
  });

  test('watchAuditLogsByCaseUuid emits newly inserted rows', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final emittedSummaries = db.creationAuditLogsDao
        .watchAuditLogsByCaseUuid('case-watch')
        .map((rows) => rows.map((row) => row.summary).toList());
    final expectation = expectLater(
      emittedSummaries,
      emits(<String?>['watch inserted']),
    );

    await _insertAuditLog(
      db,
      caseUuid: 'case-watch',
      auditedAt: DateTime(2026, 7, 26, 12),
      summary: 'watch inserted',
    );

    await expectation;
  });

  test('getAuditLogsByTimeRange includes boundaries and excludes outside rows',
      () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final start = DateTime(2026, 7, 26, 9);
    final middle = DateTime(2026, 7, 26, 10);
    final end = DateTime(2026, 7, 26, 11);

    await _insertAuditLog(
      db,
      caseUuid: 'case-range',
      auditedAt: DateTime(2026, 7, 26, 8, 59, 59),
      summary: 'before range',
    );
    await _insertAuditLog(
      db,
      caseUuid: 'case-range',
      auditedAt: start,
      summary: 'start boundary',
    );
    await _insertAuditLog(
      db,
      caseUuid: 'case-range',
      auditedAt: middle,
      summary: 'inside range',
    );
    await _insertAuditLog(
      db,
      caseUuid: 'case-range',
      auditedAt: end,
      summary: 'end boundary',
    );
    await _insertAuditLog(
      db,
      caseUuid: 'case-range',
      auditedAt: DateTime(2026, 7, 26, 11, 0, 1),
      summary: 'after range',
    );

    final rows = await db.creationAuditLogsDao.getAuditLogsByTimeRange(
      start: start,
      end: end,
    );

    expect(rows.map((row) => row.summary).toList(), [
      'end boundary',
      'inside range',
      'start boundary',
    ]);
    expect(rows.map((row) => row.auditedAt).toList(), [
      end,
      middle,
      start,
    ]);
  });

  test('deleteAuditLogsByCaseUuid deletes only the requested case', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await _insertAuditLog(
      db,
      caseUuid: 'case-delete',
      auditedAt: DateTime(2026, 7, 26, 8),
      summary: 'delete first',
    );
    await _insertAuditLog(
      db,
      caseUuid: 'case-delete',
      auditedAt: DateTime(2026, 7, 26, 9),
      summary: 'delete second',
    );
    await _insertAuditLog(
      db,
      caseUuid: 'case-keep',
      auditedAt: DateTime(2026, 7, 26, 10),
      summary: 'keep this row',
    );

    final deletedCount =
        await db.creationAuditLogsDao.deleteAuditLogsByCaseUuid('case-delete');
    expect(deletedCount, 2);

    final deletedRows =
        await db.creationAuditLogsDao.getAuditLogsByCaseUuid('case-delete');
    expect(deletedRows.length, 0);

    final keptRows =
        await db.creationAuditLogsDao.getAuditLogsByCaseUuid('case-keep');
    expect(keptRows.length, 1);
    expect(keptRows.single.caseUuid, 'case-keep');
    expect(keptRows.single.summary, 'keep this row');
  });
}

Future<int> _insertAuditLog(
  PersistenceDriftDatabase db, {
  required String caseUuid,
  required DateTime auditedAt,
  required String summary,
}) {
  return db.creationAuditLogsDao.insertAuditLog(
    caseUuid: caseUuid,
    auditedAt: auditedAt,
    changeType: 'update',
    entityType: 'case',
    entityUuid: 'entity-$summary',
    oldJson: '{"value":"before $summary"}',
    newJson: '{"value":"after $summary"}',
    summary: summary,
    operatorId: 'operator-test',
  );
}
