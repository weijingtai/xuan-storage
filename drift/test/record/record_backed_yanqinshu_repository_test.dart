import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/yanqinshu/record_backed_yanqinshu_repository.dart';
import 'package:persistence_drift/yanqinshu/yanqinshu_module_registry.dart';
import 'package:repository_interface_yanqinshu/repository_interface_yanqinshu.dart';
import 'package:test/test.dart';

YanqinshuDivinationRecordContract _rec({String uuid = '', String schoolId = 'yantongzuan'}) =>
    YanqinshuDivinationRecordContract(
      uuid: uuid,
      question: '占失物',
      technique: 'divine',
      schoolId: schoolId,
      lunarDateJson: '{}',
      ganzhiJson: '{}',
      paramsJson: '{}',
      baseDataJson: '{"rel": "生我"}',
      viewDataJson: '{"left": "虚日鼠"}',
      conclusionJson: '{"main": "大吉"}',
      sourceMetadataJson: '{"book": "演禽通纂"}',
      createdAt: DateTime.utc(2026, 8, 20),
      updatedAt: DateTime.utc(2026, 8, 20),
      deletedAt: null,
    );

RecordBackedYanqinshuRepository _build(PersistenceDriftDatabase db) {
  final ds = DriftRecordDataSource(db, scopeUid: 's1');
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([YanqinshuModuleRegistry.codec()]));
  return YanqinshuModuleRegistry.repository(store: store) as RecordBackedYanqinshuRepository;
}

void main() {
  test('save then getAll returns it', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.saveRecord(_rec());
    final all = await repo.getAllRecords();
    expect(all.single.uuid, id);
    expect(all.single.schoolId, 'yantongzuan');
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
    final firstEmit = repo.watchAllRecords().firstWhere((l) => l.isNotEmpty);
    await repo.saveRecord(_rec());
    final list = await firstEmit;
    expect(list, hasLength(1));
  });
}
