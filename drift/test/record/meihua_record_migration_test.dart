import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:test/test.dart';

void main() {
  test('migrates records idempotently', () async {
    // 旧库
    final oldDb = MeiHuaDatabase(NativeDatabase.memory());
    addTearDown(oldDb.close);
    final oldDao = MeiHuaDivinationsDao(oldDb);
    final now = DateTime.utc(2026);
    await oldDao.insertRecord(MeiHuaGuaInfosCompanion.insert(
      uuid: 'm1', divinationUuid: 'd1', question: const Value('q1'),
      originalUpperGua: 1, originalLowerGua: 2, changingYao: 3,
      changedUpperGua: 4, changedLowerGua: 5, huUpperGua: 6, huLowerGua: 7,
      method: 'time', paramsJson: '{}',
      createdAt: now, updatedAt: now,
    ));
    await oldDao.insertRecord(MeiHuaGuaInfosCompanion.insert(
      uuid: 'm2', divinationUuid: 'd2', question: const Value('q2'),
      originalUpperGua: 3, originalLowerGua: 4, changingYao: 5,
      changedUpperGua: 6, changedLowerGua: 7, huUpperGua: 8, huLowerGua: 1,
      method: 'number', paramsJson: '{}',
      createdAt: now, updatedAt: now,
    ));

    // 新库
    final newDb = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(newDb.close);
    final ds = DriftRecordDataSource(newDb, scopeUid: 'local');
    final adapter = MeihuaRecordAdapter(scopeUid: 'local');
    final repo = LocalRecordRepository(ds, RecordAdapterRegistry([adapter]));
    final meihuaRepo = RecordBackedMeiHuaRepository(repo, adapter, ds);

    // 第一次迁移
    final count1 = await migrateMeihuaRecords(oldDao: oldDao, target: meihuaRepo);
    expect(count1, 2);
    expect((await meihuaRepo.getAllRecords()).length, 2);

    // 第二次迁移（幂等）
    final count2 = await migrateMeihuaRecords(oldDao: oldDao, target: meihuaRepo);
    expect(count2, 0);
    expect((await meihuaRepo.getAllRecords()).length, 2);
  });
}
