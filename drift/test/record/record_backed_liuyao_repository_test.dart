import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/liuyao/liuyao_record_codec.dart';
import 'package:persistence_drift/liuyao/record_backed_liuyao_repository.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
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

const _ctx = RequestContext(scopeUid: 's1');

void main() {
  test('put then query returns record via L0 slices', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final putRes = await repo.put(_rec(), _ctx);
    expect(putRes, isA<Ok<Rev>>());
    final queryRes = await repo.query(const {}, PageRequest(limit: 100), _ctx);
    final all = (queryRes as Ok<Page<SixYaoDivinationRecord>>).value.items;
    expect(all.single.uuid, isNotEmpty);
    expect(all.single.originalGuaId, 1);
  });

  test('get retrieves record by uuid via L0 slices', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final putRes = await repo.put(_rec(), _ctx);
    final id = (putRes as Ok<Rev>).value;
    // put 返回 Rev，uuid 由 repo 内部分配；用 query 取回
    final queryRes = await repo.query(const {}, PageRequest(limit: 1), _ctx);
    final saved = (queryRes as Ok<Page<SixYaoDivinationRecord>>).value.items.first;
    final getRes = await repo.get(saved.uuid, _ctx);
    final retrieved = (getRes as Ok<SixYaoDivinationRecord?>).value;
    expect(retrieved?.uuid, saved.uuid);
  });

  test('soft delete hides record via L0 slices', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    await repo.put(_rec(), _ctx);
    // 取回 uuid
    final queryRes = await repo.query(const {}, PageRequest(limit: 1), _ctx);
    final saved = (queryRes as Ok<Page<SixYaoDivinationRecord>>).value.items.first;
    final deleteRes = await repo.softDelete(saved.uuid, _ctx);
    expect(deleteRes, isA<Ok<void>>());
    final afterDelete = await repo.query(const {}, PageRequest(limit: 100), _ctx);
    expect((afterDelete as Ok).value.items, isEmpty);
  });

  test('query with PageRequest limit returns up to limit', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    for (var i = 0; i < 5; i++) {
      await repo.put(_rec(originalGuaId: i), _ctx);
    }
    final result = await repo.query(const {}, PageRequest(limit: 3), _ctx);
    final items = (result as Ok<Page<SixYaoDivinationRecord>>).value.items;
    expect(items, hasLength(3));
  });

  test('getRecordsByOriginalGua and getRecordsByChangedGua find via index', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    await repo.put(_rec(originalGuaId: 10, changedGuaId: 20), _ctx);
    await repo.put(_rec(originalGuaId: 10, changedGuaId: null), _ctx);
    await repo.put(_rec(originalGuaId: 11, changedGuaId: 20), _ctx);

    final listOrig = await repo.getRecordsByOriginalGua(10);
    expect(listOrig, hasLength(2));

    final listChanged = await repo.getRecordsByChangedGua(20);
    expect(listChanged, hasLength(2));
  });

  test('query returns all records (no silent cap)', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    for (var i = 0; i < 20; i++) {
      await repo.put(_rec(originalGuaId: i), _ctx);
    }
    // 分页查询验证总数
    final result = await repo.query(const {}, PageRequest(limit: 1000), _ctx);
    final all = (result as Ok<Page<SixYaoDivinationRecord>>).value.items;
    expect(all.length, 20);
  });
}
