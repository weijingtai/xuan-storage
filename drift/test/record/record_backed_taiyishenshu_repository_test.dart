import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/taiyishenshu/taiyishenshu_module_registry.dart';
import 'package:persistence_drift/taiyishenshu/record_backed_taiyi_repository.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

TaiyiDivinationRecordContract _rec({String uuid = '', String schoolId = 'sch1'}) => TaiyiDivinationRecordContract(
      uuid: uuid,
      question: 'q',
      datetimeJson: '{}',
      schoolId: schoolId,
      juNumber: 1,
      taiYiPalaceJson: '{}',
      ninePalaceJson: '{}',
      deitiesJson: '{}',
      paramsJson: '{}',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

RecordBackedTaiyiRepository _build(PersistenceDriftDatabase db) {
  final ds = DriftRecordDataSource(db, scopeUid: 's1');
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([TaiyishenshuModuleRegistry.codec()]));
  return TaiyishenshuModuleRegistry.repository(store: store) as RecordBackedTaiyiRepository;
}

void main() {
  test('save then getAll returns it', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.saveRecord(_rec());
    final all = await repo.getAllRecords();
    expect(all.single.uuid, id);
    expect(all.single.schoolId, 'sch1');
  });

  test('getRecordByUuid retrieves correctly', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.saveRecord(_rec());
    final retrieved = await repo.getRecordByUuid(id);
    expect(retrieved?.uuid, id);
  });

  test('soft delete hides record', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.saveRecord(_rec());
    expect(await repo.softDeleteRecord(id), isTrue);
    expect(await repo.getAllRecords(), isEmpty);
  });

  test('watchAllRecords emits on save', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final firstEmit = repo.watchAllRecords().first;
    await repo.saveRecord(_rec());
    final list = await firstEmit;
    expect(list, hasLength(1));
  });

  test('getAllRecords returns more than 1000 records (no silent cap)', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    for (var i = 0; i < 1001; i++) {
      await repo.saveRecord(_rec(schoolId: 'sch-$i'));
    }
    final all = await repo.getAllRecords();
    expect(all.length, 1001);
  });
}
