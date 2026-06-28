import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:flutter_test/flutter_test.dart';

PersistenceDriftDatabase _db() => PersistenceDriftDatabase(NativeDatabase.memory());

RecordBackedMeiHuaRepository _repo(PersistenceDriftDatabase db) {
  final ds = DriftRecordDataSource(db, scopeUid: 'e2e');
  final adapter = MeihuaRecordAdapter(scopeUid: 'e2e');
  final records = LocalRecordRepository(ds, RecordAdapterRegistry([adapter]));
  return RecordBackedMeiHuaRepository(records, adapter, ds);
}

void main() {
  group('record e2e', () {
    late PersistenceDriftDatabase db;
    late MeiHuaDivinationRecordRepository repo;

    setUp(() {
      db = _db();
      repo = _repo(db);
    });

    tearDown(() => db.close());

    test('save → getAllRecords → getRecordByUuid', () async {
      await repo.saveRecord(MeiHuaDivinationRecordContract(
        uuid: '', divinationUuid: 'd1', question: '问事业',
        originalUpperGua: 1, originalLowerGua: 2, changingYao: 3,
        changedUpperGua: 4, changedLowerGua: 5, huUpperGua: 6, huLowerGua: 7,
        method: 'time', paramsJson: '{}',
        createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026),
      ));

      final all = await repo.getAllRecords();
      expect(all.length, 1);
      expect(all.first.question, '问事业');

      final byId = await repo.getRecordByUuid(all.first.uuid);
      expect(byId, isNotNull);
      expect(byId!.originalUpperGua, 1);
    });

    test('save → getRecordByDivinationUuid via search index', () async {
      await repo.saveRecord(MeiHuaDivinationRecordContract(
        uuid: '', divinationUuid: 'd-search',
        question: '寻物', originalUpperGua: 3, originalLowerGua: 4,
        changingYao: 5, changedUpperGua: 6, changedLowerGua: 7,
        huUpperGua: 8, huLowerGua: 1, method: 'number', paramsJson: '{}',
        createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026),
      ));

      final found = await repo.getRecordByDivinationUuid('d-search');
      expect(found, isNotNull);
      expect(found!.method, 'number');
    });

    test('softDelete hides record', () async {
      await repo.saveRecord(MeiHuaDivinationRecordContract(
        uuid: '', divinationUuid: 'd-del', question: '可删除',
        originalUpperGua: 1, originalLowerGua: 2, changingYao: 3,
        changedUpperGua: 4, changedLowerGua: 5,
        huUpperGua: 6, huLowerGua: 7,
        method: 'manual', paramsJson: '{}',
        createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026),
      ));
      final allBefore = await repo.getAllRecords();
      expect(allBefore.length, 1);

      await repo.softDeleteRecord(allBefore.first.uuid);
      final allAfter = await repo.getAllRecords();
      expect(allAfter.length, 0);
    });

    test('watchAllRecords emits on save', () async {
      final emitted = <List<MeiHuaDivinationRecordContract>>[];
      final sub = repo.watchAllRecords().listen(emitted.add);

      await repo.saveRecord(MeiHuaDivinationRecordContract(
        uuid: '', divinationUuid: 'w1', question: 'watch',
        originalUpperGua: 1, originalLowerGua: 2, changingYao: 3,
        changedUpperGua: 4, changedLowerGua: 5,
        huUpperGua: 6, huLowerGua: 7,
        method: 'time', paramsJson: '{}',
        createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026),
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      await sub.cancel();
      expect(emitted.length, greaterThanOrEqualTo(1));
      expect(emitted.last.length, 1);
    });
  });
}
