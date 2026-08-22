import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/ziweidoushu/ziweidoushu_module_registry.dart';
import 'package:persistence_drift/ziweidoushu/record_backed_ziwei_repository.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';
import 'package:test/test.dart';

const _ctx = RequestContext(scopeUid: 's1');

ZiweiDivinationRecordContract _rec({String uuid = '', String birthDatetime = '2026-06-28 23:00:00'}) => ZiweiDivinationRecordContract(
      uuid: uuid,
      question: 'q',
      birthDatetimeJson: birthDatetime,
      isMale: true,
      chartRequestJson: '{}',
      chartResultJson: '{}',
      fourTransformationsJson: '{}',
      paramsJson: '{}',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

RecordBackedZiweiRepository _build(PersistenceDriftDatabase db) {
  final ds = DriftRecordDataSource(db, scopeUid: 's1');
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([ZiweidoushuModuleRegistry.codec()]));
  return ZiweidoushuModuleRegistry.repository(store: store) as RecordBackedZiweiRepository;
}

/// 解包 Result：成功返回值，失败抛异常
T _unwrap<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final error) => throw error,
};

void main() {
  test('put 后 query 可获取记录', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final rev = _unwrap(await repo.put(_rec(), _ctx));
    expect(rev, isNotNull);
    final page = _unwrap(await repo.query(const {}, PageRequest(limit: 100), _ctx));
    expect(page.items.single.uuid, isNotEmpty);
    expect(page.items.single.birthDatetimeJson, '2026-06-28 23:00:00');
  });

  test('get 按 id 获取记录', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final rev = _unwrap(await repo.put(_rec(), _ctx));
    // put 返回的 Rev 值就是 uuid
    final retrieved = _unwrap(await repo.get(rev.value, _ctx));
    expect(retrieved?.uuid, rev.value);
  });

  test('软删除后 query 不可见', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final rev = _unwrap(await repo.put(_rec(), _ctx));
    await repo.softDelete(rev.value, _ctx);
    final page = _unwrap(await repo.query(const {}, PageRequest(limit: 100), _ctx));
    expect(page.items, isEmpty);
  });

  test('watch 在 put 后发出新事件', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    final firstEmit = repo.watch(const {}, _ctx).firstWhere((r) => switch (r) {
      Ok(:final value) => value.isNotEmpty,
      Err() => false,
    });
    await repo.put(_rec(), _ctx);
    final result = await firstEmit;
    final list = _unwrap(result);
    expect(list, hasLength(1));
  });

  test('query 可返回超过 1000 条记录（无静默上限）', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _build(db);
    for (var i = 0; i < 1001; i++) {
      await repo.put(_rec(birthDatetime: 'date-$i'), _ctx);
    }
    // 用分页取全量
    final all = <ZiweiDivinationRecordContract>[];
    String? cursor;
    while (true) {
      final page = _unwrap(await repo.query(
        const {},
        PageRequest(limit: 200, cursor: cursor),
        _ctx,
      ));
      all.addAll(page.items);
      if (!page.hasMore) break;
      cursor = page.nextCursor;
    }
    expect(all.length, 1001);
  });
}
