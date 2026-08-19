import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:test/test.dart';

void main() {
  group('Record save roundtrip via L0.put', () {
    late PersistenceDriftDatabase db;
    late DriftRecordDataSource ds;
    late MeihuaRecordAdapter adapter;
    late LocalRecordRepository store;
    late RecordBackedMeiHuaRepository repo;

    setUp(() {
      db = PersistenceDriftDatabase(NativeDatabase.memory());
      ds = DriftRecordDataSource(db, scopeUid: 'scope_RT');
      adapter = MeihuaRecordAdapter(scopeUid: 'scope_RT');
      store = LocalRecordRepository(ds, RecordAdapterRegistry([adapter]));
      repo = RecordBackedMeiHuaRepository(store, adapter, ds);
    });

    tearDown(() => db.close());

    test('save writes via L0.put and reads back full contract losslessly', () async {
      final original = MeiHuaDivinationRecordContract(
        uuid: 'mh-custom-uuid-001',
        divinationUuid: 'div-uuid-888',
        question: '今年事业发展如何？',
        originalUpperGua: 3,
        originalLowerGua: 5,
        changingYao: 2,
        changedUpperGua: 4,
        changedLowerGua: 5,
        huUpperGua: 1,
        huLowerGua: 8,
        method: 'coins',
        paramsJson: '{"custom_param":"xyz","version":2}',
        createdAt: DateTime.utc(2026, 8, 19, 10, 30, 0),
        updatedAt: DateTime.utc(2026, 8, 19, 10, 35, 0),
      );

      final returnedId = await repo.saveRecord(original);
      expect(returnedId, 'mh-custom-uuid-001');

      // 1. getByUuid
      final byUuid = await repo.getRecordByUuid('mh-custom-uuid-001');
      expect(byUuid, isNotNull);
      expect(byUuid!.uuid, original.uuid);
      expect(byUuid.divinationUuid, original.divinationUuid);
      expect(byUuid.question, original.question);
      expect(byUuid.originalUpperGua, original.originalUpperGua);
      expect(byUuid.originalLowerGua, original.originalLowerGua);
      expect(byUuid.changingYao, original.changingYao);
      expect(byUuid.changedUpperGua, original.changedUpperGua);
      expect(byUuid.changedLowerGua, original.changedLowerGua);
      expect(byUuid.huUpperGua, original.huUpperGua);
      expect(byUuid.huLowerGua, original.huLowerGua);
      expect(byUuid.method, original.method);
      expect(byUuid.paramsJson, original.paramsJson);
      expect(byUuid.createdAt, original.createdAt);
      expect(byUuid.updatedAt, original.updatedAt);
      expect(byUuid.deletedAt, isNull);

      // 2. getRecordByDivinationUuid (index query)
      final byIndex = await repo.getRecordByDivinationUuid('div-uuid-888');
      expect(byIndex, isNotNull);
      expect(byIndex!.uuid, original.uuid);
      expect(byIndex.divinationUuid, original.divinationUuid);
      expect(byIndex.question, original.question);
      expect(byIndex.paramsJson, original.paramsJson);

      // 3. getAllRecords
      final all = await repo.getAllRecords();
      expect(all.length, 1);
      expect(all.first.uuid, original.uuid);
      expect(all.first.question, original.question);
    });

    test('save auto-generates uuid when empty and roundtrips', () async {
      final item = MeiHuaDivinationRecordContract(
        uuid: '',
        divinationUuid: 'div-auto-uuid',
        question: '自动生成 UUID 测试',
        originalUpperGua: 1,
        originalLowerGua: 1,
        changingYao: 1,
        changedUpperGua: 1,
        changedLowerGua: 2,
        huUpperGua: 1,
        huLowerGua: 1,
        method: 'time',
        paramsJson: '{}',
        createdAt: DateTime.utc(2026, 8, 19),
        updatedAt: DateTime.utc(2026, 8, 19),
      );

      final generatedId = await repo.saveRecord(item);
      expect(generatedId, isNotEmpty);

      final fetched = await repo.getRecordByUuid(generatedId);
      expect(fetched, isNotNull);
      expect(fetched!.uuid, generatedId);
      expect(fetched.question, '自动生成 UUID 测试');
    });
  });
}
