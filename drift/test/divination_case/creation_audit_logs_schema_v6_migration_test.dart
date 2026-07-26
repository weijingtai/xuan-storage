import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('schema v5 opens as v6 with creation audit logs table and indexes',
      () async {
    final sqliteDb = sqlite3.openInMemory();
    sqliteDb.execute('PRAGMA user_version = 5;');

    final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
    addTearDown(db.close);

    await _assertAuditTableRoundTrips(db, 'case-migrated');
    await _assertAuditIndexes(db);
  });

  test('new database creates creation audit logs table and indexes', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await _assertAuditTableRoundTrips(db, 'case-new');
    await _assertAuditIndexes(db);
  });
}

Future<void> _assertAuditTableRoundTrips(
  PersistenceDriftDatabase db,
  String caseUuid,
) async {
  final auditedAt = DateTime(2026, 7, 26, 10, 30);

  await db.creationAuditLogsDao.insertAuditLog(
    caseUuid: caseUuid,
    auditedAt: auditedAt,
    changeType: 'create',
    entityType: 'case',
    entityUuid: 'entity-$caseUuid',
    oldJson: '{"old":null}',
    newJson: '{"title":"created"}',
    summary: 'created $caseUuid',
    operatorId: 'operator-1',
  );

  final rows = await db.creationAuditLogsDao.getAuditLogsByCaseUuid(caseUuid);
  expect(rows.length, 1);

  final row = rows.single;
  expect(row.caseUuid, caseUuid);
  expect(row.auditedAt, auditedAt);
  expect(row.changeType, 'create');
  expect(row.entityType, 'case');
  expect(row.entityUuid, 'entity-$caseUuid');
  expect(row.oldJson, '{"old":null}');
  expect(row.newJson, '{"title":"created"}');
  expect(row.summary, 'created $caseUuid');
  expect(row.operatorId, 'operator-1');
}

Future<void> _assertAuditIndexes(PersistenceDriftDatabase db) async {
  final rows = await db.customSelect(
    "SELECT name FROM sqlite_master "
    "WHERE type='index' AND tbl_name='t_creation_audit_logs' "
    "ORDER BY name",
  ).get();
  final indexNames = rows.map((row) => row.read<String>('name')).toList();

  expect(indexNames, [
    'idx_audit_audited_at',
    'idx_audit_case_uuid',
  ]);
}
