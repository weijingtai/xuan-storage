import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/liuyao/liuyao_record_codec.dart';
import 'package:persistence_drift/liuyao/record_backed_liuyao_repository.dart';
import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

SixYaoDivinationRecord _rec({String uuid = '', int originalGuaId = 1, int? changedGuaId}) => SixYaoDivinationRecord(
      uuid: uuid,
      question: '出行?',
      yaoResults: const [
        SixYaoYaoResult(index: 0, yaoType: YaoType.shaoyang),
        SixYaoYaoResult(index: 1, yaoType: YaoType.shaoyin),
        SixYaoYaoResult(index: 2, yaoType: YaoType.laoyang),
        SixYaoYaoResult(index: 3, yaoType: YaoType.laoyin),
        SixYaoYaoResult(index: 4, yaoType: YaoType.shaoyang),
        SixYaoYaoResult(index: 5, yaoType: YaoType.shaoyin),
      ],
      originalGuaId: originalGuaId,
      changedGuaId: changedGuaId,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

RecordBackedLiuYaoRepository _build(PersistenceDriftDatabase db) {
  final ds = DriftRecordDataSource(db, scopeUid: 's1');
  final codec = LiuYaoRecordCodec();
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([codec]));
  return RecordBackedLiuYaoRepository(store: store, codec: codec);
}

void main() {
  test('save then getAll returns it', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final id = await repo.saveRecord(_rec());
    final all = await repo.getAllRecords();
    expect(all.single.uuid, id);
    expect(all.single.originalGuaId, 1);
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

  test('getLatestRecords returns up to limit', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    for (var i = 0; i < 5; i++) {
      await repo.saveRecord(_rec(originalGuaId: i));
    }
    final latest = await repo.getLatestRecords(limit: 3);
    expect(latest, hasLength(3));
  });

  test('getRecordsByOriginalGua and getRecordsByChangedGua find via index', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    await repo.saveRecord(_rec(originalGuaId: 10, changedGuaId: 20));
    await repo.saveRecord(_rec(originalGuaId: 10, changedGuaId: null));
    await repo.saveRecord(_rec(originalGuaId: 11, changedGuaId: 20));

    final listOrig = await repo.getRecordsByOriginalGua(10);
    expect(listOrig, hasLength(2));

    final listChanged = await repo.getRecordsByChangedGua(20);
    expect(listChanged, hasLength(2));
  });

  test('getAllRecords returns more than 1000 records (no silent cap)', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    for (var i = 0; i < 1001; i++) {
      await repo.saveRecord(_rec(originalGuaId: i));
    }
    final all = await repo.getAllRecords();
    expect(all.length, 1001);
  });
}
