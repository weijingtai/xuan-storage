import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:test/test.dart';

MeiHuaDivinationRecordContract _rec({String uuid = '', String div = 'd1'}) =>
    MeiHuaDivinationRecordContract(
      uuid: uuid, divinationUuid: div, question: 'q',
      originalUpperGua: 1, originalLowerGua: 2, changingYao: 3,
      changedUpperGua: 4, changedLowerGua: 5, huUpperGua: 6, huLowerGua: 7,
      method: 'time', paramsJson: '{}',
      createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026));

RecordBackedMeiHuaRepository _build(PersistenceDriftDatabase db) {
  final ds = DriftRecordDataSource(db, scopeUid: 's1');
  final adapter = MeihuaRecordAdapter(scopeUid: 's1');
  final records = LocalRecordRepository(ds, RecordAdapterRegistry([adapter]));
  return RecordBackedMeiHuaRepository(records, adapter, ds);
}

void main() {
  test('save then getAll returns it', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.saveRecord(_rec());
    final all = await repo.getAllRecords();
    expect(all.single.uuid, id);
    expect(all.single.originalUpperGua, 1);
  });

  test('getRecordByDivinationUuid resolves via search index', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    await repo.saveRecord(_rec(div: 'dX'));
    final hit = await repo.getRecordByDivinationUuid('dX');
    expect(hit?.divinationUuid, 'dX');
  });

  test('getAllRecords returns more than 1000 records (no silent cap)', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    for (var i = 0; i < 1001; i++) {
      await repo.saveRecord(_rec());
    }
    final all = await repo.getAllRecords();
    expect(all.length, 1001);
  });

  test('soft delete hides record', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.saveRecord(_rec());
    expect(await repo.softDeleteRecord(id), isTrue);
    expect(await repo.getAllRecords(), isEmpty);
  });
}
