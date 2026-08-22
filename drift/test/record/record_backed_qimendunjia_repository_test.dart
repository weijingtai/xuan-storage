import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/qimendunjia/qimendunjia_module_registry.dart';
import 'package:persistence_drift/qimendunjia/record_backed_qimen_repository.dart';
import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';
import 'package:test/test.dart';

QimenDivinationRecordContract _rec({String uuid = '', String juType = 't1'}) => QimenDivinationRecordContract(
      uuid: uuid,
      question: 'q',
      datetimeJson: '{}',
      juType: juType,
      juNumber: 1,
      paiPanJson: '{}',
      shiJiJson: '{}',
      yueJiangJson: '{}',
      paramsJson: '{}',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

RecordBackedQimenRepository _build(PersistenceDriftDatabase db) {
  final ds = DriftRecordDataSource(db, scopeUid: 's1');
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([QimendunjiaModuleRegistry.codec()]));
  return QimendunjiaModuleRegistry.repository(store: store) as RecordBackedQimenRepository;
}

void main() {
  test('save then query returns it', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.put(_rec());
    final all = await repo.query(const {});
    expect(all.single.uuid, id);
    expect(all.single.juType, 't1');
  });

  test('get retrieves correctly', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.put(_rec());
    final retrieved = await repo.get(id);
    expect(retrieved?.uuid, id);
  });

  test('soft delete hides record', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.put(_rec());
    expect(await repo.delete(id), isTrue);
    expect(await repo.query(const {}), isEmpty);
  });

  test('watchAll emits on save', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final firstEmit = repo.watchAll().firstWhere((l) => l.isNotEmpty);
    await repo.put(_rec());
    final list = await firstEmit;
    expect(list, hasLength(1));
  });

  test('query returns more than 1000 records (no silent cap)', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    for (var i = 0; i < 1001; i++) {
      await repo.put(_rec(juType: 'ju-$i'));
    }
    final all = await repo.query(const {});
    expect(all.length, 1001);
  });
}
