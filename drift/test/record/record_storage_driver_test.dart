import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
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

  test('supportsTransaction 为 false 且 inTransaction 直接执行', () async {
    expect(driver.supportsTransaction, isFalse);
    final v = await driver.inTransaction(() async => 42);
    expect(v, 42);
  });
}
