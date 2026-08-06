// 包：persistence_drift (test)  文件：drift/test/theme/theme_mutation_selfcheck_test.dart
// THEME-DRIFT T6.5：三条变异自检（A3/A4/A5）—— 本任务的真验收门槛（§八）。
//
// 每条：注入变异 -> 跑测试 -> 确认红在目标断言（不是编译失败）-> 恢复 -> 绿。
// 变异注入点与预期红逐条记录在文件注释与 commit message：
//   - A3（identical 缓存）：变异 = 注释掉 resolve() 的缓存命中 return
//     -> 红在 `identical(r1, r2)` 断言
//   - A4（30ms 超时降级）：变异 = 注释掉 _readActiveWithTimeout 的 .timeout(...)
//     -> 红在 A4 测试超时（resolve 永不返回，无法在 50ms 内完成）
//   - A5（applyOverrides 原子）：变异 = 去掉 _db.transaction 逐条写
//     -> 红在 `containsKey('k2')` 断言（k2 留下半套）

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/theme_resolution.dart'
    show ThemeSelectionOrigin;
import 'package:persistence_core/model/theme_value_types.dart'
    show OverrideOrigin;
import 'package:persistence_core/test_support/theme_bench_fixture.dart';
import 'package:persistence_core/test_support/theme_probes.dart';
import 'package:persistence_drift/theme/drift_theme_resource_store.dart';
import 'package:persistence_drift/theme/theme_database.dart';

void main() {
  group('变异自检', () {
    test('A3_同 key 重复 resolve 返回 identical 对象', () async {
      // 缓存命中返回同一实例（D4）。变异：注释掉 resolve() 里
      // `if (_cache != null && ...) return _cache!;` -> 每次重算 -> 此断言红。
      final store = await _makeStore();
      final r1 = await store.resolve();
      final r2 = await store.resolve();
      expect(identical(r1, r2), isTrue); // ← 不许改成 ==
    });

    test('A4_活跃世代慢读取 30ms 超时降级到 bundled', () async {
      // SlowLocalReader.readActiveThemeTokens 永不完成；30ms 超时降级到
      // bundled（P6）。变异：注释掉 .timeout(...) -> resolve 永不返回，
      // 测试 hang 到框架超时 -> A4 红。
      final fixture = ThemeBenchFixture();
      final db = ThemeDatabase(NativeDatabase.memory());
      final store = DriftThemeResourceStore(
        scopeUid: 'u1',
        db: db,
        localReader: SlowLocalReader(fixture.bundledTokens),
      );
      final sw = Stopwatch()..start();
      final r = await store.resolve();
      expect(sw.elapsedMilliseconds, lessThan(50)); // 50ms 内返回
      // 降级到 bundled（无 packageTokens）。
      expect(r.resolution.selectionOrigin, ThemeSelectionOrigin.bundledFallback);
      await db.close();
    });

    test('A5_applyOverrides 中途失败不留半套（事务回滚）', () async {
      // D5 原子：校验在事务外（拦 Map），写入在单事务内。
      // 注入「写入段中途失败」而非「校验前置」：k3 是不可 JSON 编码的对象
      // （非 Map，能过校验段），jsonEncode 在事务内抛 -> 整批回滚，
      // k2 不得留下。变异：去掉 _db.transaction 逐条写 -> k2 已落库，
      // k3 抛异常但回滚不再发生 -> containsKey('k2') 断言红（§八第 3 条）。
      // ⚠ key 必须用合法扁平 key（light./dark. 前缀）—— resolve 的 merge
      // 会校验扁平 key 格式（theme_token_merger._validateFlatKey），
      // 短 key 会让 _refreshAndNotify 里的 resolve 先抛。
      const k1 = 'light.components.four_zhu_card.shadow.color';
      const k2 = 'light.components.four_zhu_card.shadow.blur_radius';
      final store = await _makeStore();
      await store.applyOverrides(
        patch: const {k1: 'a'},
        origin: OverrideOrigin.manual,
      );
      await expectLater(
        store.applyOverrides(
          patch: {
            k2: 'b',
            'light.components.four_zhu_card.border.width': Object(),
          }, // 后者非 Map，过校验段；jsonEncode 抛
          origin: OverrideOrigin.manual,
        ),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
      final list = await store.listOverrides();
      expect(list.containsKey(k2), isFalse); // ← k2 不该留下（原子回滚）
    });
  });
}

/// 造内存库 + Drift store（CountingLocalReader 提供 bundled，DB 只承载覆盖/选择）。
Future<DriftThemeResourceStore> _makeStore() async {
  final fixture = ThemeBenchFixture();
  final db = ThemeDatabase(NativeDatabase.memory());
  return DriftThemeResourceStore(
    scopeUid: 'u1',
    db: db,
    localReader: CountingLocalReader(fixture.bundledTokens),
  );
}
