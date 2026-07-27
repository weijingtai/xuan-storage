import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/bazi/bazi_module_registry.dart';
import 'package:persistence_drift/bazi/record_backed_bazi_repository.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

BaziRecordContract _rec({
  String uuid = '',
  String caseUuid = 'case-A',
  int idx = 0,
}) =>
    BaziRecordContract(
      uuid: uuid,
      caseUuid: caseUuid,
      recordDate: DateTime.utc(2026, 7, idx + 1),
      chartSnapshotJson: '{"idx":$idx}',
      snapshotSchemaVersion: 1,
      note: 'note-$idx',
      createdAt: DateTime.utc(2026, 7, idx + 1),
    );

RecordBackedBaziRepository _build(PersistenceDriftDatabase db) {
  final ds = DriftRecordDataSource(db, scopeUid: 's1');
  final codec = BaziModuleRegistry.codec();
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([codec]));
  return BaziModuleRegistry.repository(store: store) as RecordBackedBaziRepository;
}

void main() {
  test('listRecords returns only records for the given caseUuid', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);

    await repo.saveRecord(_rec(caseUuid: 'case-A', idx: 0));
    await repo.saveRecord(_rec(caseUuid: 'case-A', idx: 1));
    await repo.saveRecord(_rec(caseUuid: 'case-B', idx: 2));

    final groupA = await repo.listRecords('case-A');
    expect(groupA, hasLength(2));
    expect(groupA[0].caseUuid, 'case-A');
    expect(groupA[1].caseUuid, 'case-A');
    expect(groupA[0].note, anyOf('note-0', 'note-1'));
    expect(groupA[1].note, anyOf('note-0', 'note-1'));

    final groupB = await repo.listRecords('case-B');
    expect(groupB, hasLength(1));
    expect(groupB.single.caseUuid, 'case-B');
    expect(groupB.single.note, 'note-2');
  });

  test('listRecords returns empty list for non-existent caseUuid', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);

    await repo.saveRecord(_rec(caseUuid: 'case-A', idx: 0));

    final result = await repo.listRecords('non-existent-case');
    expect(result, isEmpty);
  });

  test('getRecord returns saved record, deleteRecord removes it from listRecords', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);

    const knownUuid = 'test-uuid-c0';
    await repo.saveRecord(_rec(uuid: knownUuid, caseUuid: 'case-C', idx: 0));

    final retrieved = await repo.getRecord(knownUuid);
    expect(retrieved, isNotNull);
    expect(retrieved!.uuid, knownUuid);
    expect(retrieved.caseUuid, 'case-C');
    expect(retrieved.note, 'note-0');
    expect(retrieved.recordDate, DateTime.utc(2026, 7, 1));

    final beforeDelete = await repo.listRecords('case-C');
    expect(beforeDelete, hasLength(1));

    await repo.deleteRecord(knownUuid);

    final afterDelete = await repo.listRecords('case-C');
    expect(afterDelete, isEmpty);
  });
}
