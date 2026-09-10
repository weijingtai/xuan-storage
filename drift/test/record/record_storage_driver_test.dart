import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

void main() {
  late PersistenceDriftDatabase db;
  late DriftRecordDataSource ds;
  late LocalRecordRepository store;
  late RecordStorageDriver driver;

  setUp(() async {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    ds = DriftRecordDataSource(db, scopeUid: 'scope_A');
    store = LocalRecordRepository(ds, RecordAdapterRegistry(const []));
    driver = RecordStorageDriver(store: store);
  });

  tearDown(() => db.close());

  Map<String, Object?> row(String id,
          {int rev = 1,
          String? deletedAt,
          String createdAt = '2026-01-01T00:00:00.000Z'}) =>
      {
        'id': id,
        'scope_uid': 'scope_A',
        'module': 'meihua',
        'category': 'divination',
        'divination_type': 'mei_hua',
        'question': 'q$id',
        'detail': null,
        'tag': null,
        'module_data': '{"k":"v"}',
        'created_at': createdAt,
        'updated_at': null,
        'deleted_at': deletedAt,
        '_rev': '$rev',
      };

  test('write 创建记录并返回递增 rev', () async {
    final rev1 = await driver.write('meihua', 'a', row('a'));
    final rev2 = await driver.write('meihua', 'a', row('a', rev: 2));
    expect(rev1, '1');
    expect(rev2, '2');
    final got = await driver
        .readOne('meihua', 'a', const RawFilter(scopeUid: 'scope_A'));
    expect(got?['_rev'], '2');
  });

  test('write expectedRev 不匹配抛 StorageRevMismatch', () async {
    await driver.write('meihua', 'a', row('a'));
    expect(
        () => driver.write('meihua', 'a', row('a'), expectedRev: 'stale'),
        throwsA(isA<StorageRevMismatch>()));
  });

  test('scope 不匹配时 readOne 返回 null', () async {
    await driver.write('meihua', 'a', row('a'));
    expect(
        await driver
            .readOne('meihua', 'a', const RawFilter(scopeUid: 'scope_B')),
        isNull);
  });

  test('软删行默认不可见，includeSoftDeleted 可见', () async {
    await driver.write('meihua', 'a', row('a'));
    await driver.write('meihua', 'a',
        row('a', deletedAt: '2026-02-01T00:00:00.000Z'));
    expect(
        await driver
            .readOne('meihua', 'a', const RawFilter(scopeUid: 'scope_A')),
        isNull);
    final got = await driver.readOne('meihua', 'a',
        const RawFilter(scopeUid: 'scope_A', includeSoftDeleted: true));
    expect(got?['deleted_at'], isNotNull);
  });

  test('readMany 按 createdAt DESC 返回并支持 id 游标', () async {
    for (var i = 0; i < 3; i++) {
      await driver.write('meihua', 'r$i',
          row('r$i', rev: i + 1, createdAt: '2026-01-0${i + 1}T00:00:00.000Z'));
    }
    final rows = await driver.readMany(
        'meihua', const RawFilter(scopeUid: 'scope_A'), const RawPage(limit: 2));
    expect(rows.map((r) => r['id']).toList(), ['r2', 'r1']);
    final next = await driver.readMany(
        'meihua',
        const RawFilter(scopeUid: 'scope_A'),
        const RawPage(limit: 2, cursor: 'id:r1'));
    expect(next.map((r) => r['id']).toList(), ['r0']);
  });

  test('count 排除软删且按 scope 隔离', () async {
    await driver.write('meihua', 'a', row('a'));
    await driver.write(
        'meihua', 'a', row('a', deletedAt: '2026-02-01T00:00:00.000Z'));
    await driver.write('meihua', 'b', row('b'));
    expect(await driver.count('meihua', const RawFilter(scopeUid: 'scope_A')),
        1);
    expect(await driver.count('meihua', const RawFilter(scopeUid: 'scope_B')),
        0);
  });

  test('watchMany 发出初始快照且 scope 隔离', () async {
    await driver.write('meihua', 'a', row('a'));
    final first = await driver
        .watchMany('meihua', const RawFilter(scopeUid: 'scope_A'),
            const RawPage(limit: 100))
        .first;
    expect(first.map((r) => r['id']), contains('a'));
    final empty = await driver
        .watchMany('meihua', const RawFilter(scopeUid: 'scope_B'),
            const RawPage(limit: 100))
        .first;
    expect(empty, isEmpty);
  });

  test('readMany equals 走内存等值过滤', () async {
    await driver.write('meihua', 'a', row('a'));
    final rows = await driver.readMany(
        'meihua',
        const RawFilter(scopeUid: 'scope_A', equals: {'question': 'qa'}),
        const RawPage(limit: 10));
    expect(rows.map((r) => r['id']), contains('a'));
    final none = await driver.readMany(
        'meihua',
        const RawFilter(scopeUid: 'scope_A', equals: {'question': 'zzz'}),
        const RawPage(limit: 10));
    expect(none, isEmpty);
  });

  test('supportsTransaction 为 true（当底层为 Drift 时）', () async {
    expect(driver.supportsTransaction, isTrue);
  });

  test('supportsTransaction 为 false 且 inTransaction 直接执行（无 DB 支撑时退化）', () async {
    final fakeDriver = RecordStorageDriver(store: _FakeStore());
    expect(fakeDriver.supportsTransaction, isFalse);
    final v = await fakeDriver.inTransaction(() async => 42);
    expect(v, 42);
  });

  group('Transactional T1-T5 契约断言 (RecordStorageDriver)', () {
    late CrudBaseRepository<Map<String, Object?>, String> crud;

    setUp(() {
      crud = CrudBaseRepository<Map<String, Object?>, String>(
        descriptor: recordEntityDescriptor(module: 'meihua'),
        driver: driver,
      );
    });

    test('T1: body 内写入后正常返回 → 数据在、得 Ok', () async {
      final r = await crud.inTransaction(() async {
        await driver.write('meihua', 't1', row('t1'));
        return 'success_val';
      });

      expect(r, isA<Ok<String>>());
      expect((r as Ok<String>).value, 'success_val');
      final found = await driver.readOne('meihua', 't1', const RawFilter(scopeUid: 'scope_A'));
      expect(found, isNotNull);
      expect(found?['id'], 't1');
    });

    test('T2: body 内写入后抛 XuanError → 写入零残留、得 Err 且 code 一致', () async {
      final r = await crud.inTransaction<String>(() async {
        await driver.write('meihua', 't2', row('t2'));
        throw const XuanError(code: ErrorCode.invalidArgument, message: 'dup');
      });

      expect(r, isA<Err<String>>());
      final err = (r as Err<String>).error;
      expect(err.code, ErrorCode.invalidArgument);
      final found = await driver.readOne('meihua', 't2', const RawFilter(scopeUid: 'scope_A'));
      expect(found, isNull, reason: 'T2 回滚后数据库中不得残留 t2 记录');
    });

    test('T3: body 内写入后抛普通异常 → 写入零残留、得 Err(internal)、不向上抛', () async {
      final r = await crud.inTransaction<String>(() async {
        await driver.write('meihua', 't3', row('t3'));
        throw const FormatException('unexpected format');
      });

      expect(r, isA<Err<String>>());
      final err = (r as Err<String>).error;
      expect(err.code, ErrorCode.internal);
      final found = await driver.readOne('meihua', 't3', const RawFilter(scopeUid: 'scope_A'));
      expect(found, isNull, reason: 'T3 回滚后数据库中不得残留 t3 记录');
    });

    test('T4: body 返回 Err → 不回滚，写入仍在', () async {
      final r = await crud.inTransaction<Result<String>>(() async {
        await driver.write('meihua', 't4', row('t4'));
        return const Err(XuanError(code: ErrorCode.conflictUnique, message: 'biz error'));
      });

      expect(r, isA<Ok<Result<String>>>());
      final inner = (r as Ok<Result<String>>).value;
      expect(inner, isA<Err<String>>());
      final found = await driver.readOne('meihua', 't4', const RawFilter(scopeUid: 'scope_A'));
      expect(found, isNotNull, reason: 'T4 返回 Err 不触发回滚，写入仍在');
    });

    test('T5: 嵌套事务 — 内层失败不破坏外层，外层回滚连内层一起撤', () async {
      // 组合 1：外层成功，内层失败回滚（内层失败不破坏外层）
      await db.transaction(() async {
        await driver.write('meihua', 'outer_1', row('outer_1'));
        final innerResult = await crud.inTransaction<void>(() async {
          await driver.write('meihua', 'inner_fail', row('inner_fail'));
          throw const XuanError(code: ErrorCode.invalidArgument, message: 'inner fail');
        });
        expect(innerResult, isA<Err<void>>());
        // 外层继续写入并正常提交
        await driver.write('meihua', 'outer_2', row('outer_2'));
      });

      expect(await driver.readOne('meihua', 'outer_1', const RawFilter(scopeUid: 'scope_A')), isNotNull);
      expect(await driver.readOne('meihua', 'outer_2', const RawFilter(scopeUid: 'scope_A')), isNotNull);
      expect(await driver.readOne('meihua', 'inner_fail', const RawFilter(scopeUid: 'scope_A')), isNull,
          reason: '内层失败回滚，inner_fail 必须零残留');

      // 组合 2：内层成功，外层失败回滚（外层回滚连内层一起撤）
      expect(
        () => db.transaction(() async {
          await driver.write('meihua', 'outer_fail_1', row('outer_fail_1'));
          final innerResult = await crud.inTransaction<void>(() async {
            await driver.write('meihua', 'inner_ok', row('inner_ok'));
          });
          expect(innerResult, isA<Ok<void>>());
          throw const FormatException('outer disaster');
        }),
        throwsA(isA<FormatException>()),
      );

      expect(await driver.readOne('meihua', 'outer_fail_1', const RawFilter(scopeUid: 'scope_A')), isNull);
      expect(await driver.readOne('meihua', 'inner_ok', const RawFilter(scopeUid: 'scope_A')), isNull,
          reason: '外层回滚时，内层已成功的写入也必须随外层一并撤销');
    });
  });
}

class _FakeStore implements ScopedRecordStore {
  @override
  String get scopeUid => 'scope_fake';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
