import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/bazi/bazi_module_registry.dart';
import 'package:persistence_drift/bazi/record_backed_bazi_repository.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
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

Future<List<BaziRecordContract>> _queryByCase(RecordBackedBaziRepository repo, String caseUuid) async {
  final r = await repo.query({'caseUuid': caseUuid}, PageRequest(limit: 200), RequestContext(scopeUid: 's1'));
  return (r as Ok<Page<BaziRecordContract>>).value.items;
}

void main() {
  test('listRecords returns only records for the given caseUuid', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);

    await repo.put(_rec(caseUuid: 'case-A', idx: 0), RequestContext(scopeUid: 's1'));
    await repo.put(_rec(caseUuid: 'case-A', idx: 1), RequestContext(scopeUid: 's1'));
    await repo.put(_rec(caseUuid: 'case-B', idx: 2), RequestContext(scopeUid: 's1'));

    final groupA = await _queryByCase(repo, 'case-A');
    expect(groupA, hasLength(2));
    expect(groupA[0].caseUuid, 'case-A');
    expect(groupA[1].caseUuid, 'case-A');
    expect(groupA[0].note, anyOf('note-0', 'note-1'));
    expect(groupA[1].note, anyOf('note-0', 'note-1'));

    final groupB = await _queryByCase(repo, 'case-B');
    expect(groupB, hasLength(1));
    expect(groupB.single.caseUuid, 'case-B');
    expect(groupB.single.note, 'note-2');
  });

  test('listRecords returns empty list for non-existent caseUuid', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);

    await repo.put(_rec(caseUuid: 'case-A', idx: 0), RequestContext(scopeUid: 's1'));

    final result = await _queryByCase(repo, 'non-existent-case');
    expect(result, isEmpty);
  });

  test('getRecord returns saved record, deleteRecord removes it from listRecords', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);

    const knownUuid = 'test-uuid-c0';
    await repo.put(_rec(uuid: knownUuid, caseUuid: 'case-C', idx: 0), RequestContext(scopeUid: 's1'));

    final retrievedRes = await repo.get(knownUuid, RequestContext(scopeUid: 's1'));
    final retrieved = (retrievedRes as Ok<BaziRecordContract?>).value;
    expect(retrieved, isNotNull);
    expect(retrieved!.uuid, knownUuid);
    expect(retrieved.caseUuid, 'case-C');
    expect(retrieved.note, 'note-0');
    expect(retrieved.recordDate, DateTime.utc(2026, 7, 1));

    final beforeDelete = await _queryByCase(repo, 'case-C');
    expect(beforeDelete, hasLength(1));

    await repo.softDelete(knownUuid, RequestContext(scopeUid: 's1'));

    final afterDelete = await _queryByCase(repo, 'case-C');
    expect(afterDelete, isEmpty);
  });
}
