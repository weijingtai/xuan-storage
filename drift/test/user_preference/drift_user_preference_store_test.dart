import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriftUserPreferenceStore 单测', () {
    late PersistenceDriftDatabase db;
    late DriftUserPreferenceStore store;

    setUp(() {
      db = PersistenceDriftDatabase(NativeDatabase.memory());
      store = DriftUserPreferenceStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('未设置返回 null：读一个从未写过的 key 返回 null', () async {
      final val = await store.getPreference(
        scopeUid: 'scope-A',
        key: 'unwritten_key',
      );
      expect(val, isNull);
    });

    test('scope 隔离：scope-A 写入的偏好，用 scope-B 读取必须返回 null；两个 scope 同 key 互不干扰',
        () async {
      await store.setPreference(
        scopeUid: 'scope-A',
        key: 'view_mode',
        value: 'split',
      );

      // 1. scope-A 写入的偏好，用 scope-B 读取必须返回 null
      final scopeBVal = await store.getPreference(
        scopeUid: 'scope-B',
        key: 'view_mode',
      );
      expect(scopeBVal, isNull,
          reason: 'scope-A 写入的偏好，用 scope-B 读取必须返回 null');

      // 2. 两个 scope 用同一个 key 写不同的值，各自读回自己的值互不干扰
      await store.setPreference(
        scopeUid: 'scope-B',
        key: 'view_mode',
        value: 'combined',
      );

      final readA = await store.getPreference(
        scopeUid: 'scope-A',
        key: 'view_mode',
      );
      final readB = await store.getPreference(
        scopeUid: 'scope-B',
        key: 'view_mode',
      );

      expect(readA, equals('split'));
      expect(readB, equals('combined'));
    });

    test('Upsert 语义：同一 (scope, key) 重复 setPreference，是更新而不是插入第二行',
        () async {
      final t1 = DateTime.utc(2026, 9, 1, 10, 0);
      final t2 = DateTime.utc(2026, 9, 1, 11, 0);

      await store.setPreference(
        scopeUid: 'scope-A',
        key: 'history_filter',
        value: 'initial_val',
        updatedAt: t1,
      );

      var read = await store.getPreference(
        scopeUid: 'scope-A',
        key: 'history_filter',
      );
      expect(read, equals('initial_val'));

      // 重复 setPreference 同一 (scope, key)
      await store.setPreference(
        scopeUid: 'scope-A',
        key: 'history_filter',
        value: 'updated_val',
        updatedAt: t2,
      );

      read = await store.getPreference(
        scopeUid: 'scope-A',
        key: 'history_filter',
      );
      expect(read, equals('updated_val'));

      // 查底层真实表验证恰好只有 1 行，没有插入第二行
      final rows = await (db.select(db.userPreferences)
            ..where((t) =>
                t.scopeUid.equals('scope-A') & t.key.equals('history_filter')))
          .get();
      expect(rows, hasLength(1));
      expect(rows.first.value, equals('updated_val'));
    });

    test('getAllPreferences 列表方法：覆盖 scope 隔离', () async {
      await store.setPreference(
        scopeUid: 'scope-A',
        key: 'k1',
        value: 'v1_a',
      );
      await store.setPreference(
        scopeUid: 'scope-A',
        key: 'k2',
        value: 'v2_a',
      );
      await store.setPreference(
        scopeUid: 'scope-B',
        key: 'k1',
        value: 'v1_b',
      );

      final allA = await store.getAllPreferences(scopeUid: 'scope-A');
      final allB = await store.getAllPreferences(scopeUid: 'scope-B');

      expect(allA, equals({'k1': 'v1_a', 'k2': 'v2_a'}));
      expect(allB, equals({'k1': 'v1_b'}));
    });

    test('removePreference 删除方法：覆盖 scope 隔离', () async {
      await store.setPreference(
        scopeUid: 'scope-A',
        key: 'delete_target',
        value: 'keep_me_in_A',
      );
      await store.setPreference(
        scopeUid: 'scope-B',
        key: 'delete_target',
        value: 'delete_me_in_B',
      );

      // 在 scope-B 上删除该 key
      await store.removePreference(
        scopeUid: 'scope-B',
        key: 'delete_target',
      );

      // scope-B 已删除
      final readB = await store.getPreference(
        scopeUid: 'scope-B',
        key: 'delete_target',
      );
      expect(readB, isNull);

      // scope-A 必须不受影响
      final readA = await store.getPreference(
        scopeUid: 'scope-A',
        key: 'delete_target',
      );
      expect(readA, equals('keep_me_in_A'),
          reason: '在 scope-B 上删除不得破坏 scope-A 的数据');
    });
  });
}
