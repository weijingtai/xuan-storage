// 包：persistence_core (test_support)  文件：core/lib/test_support/theme_resource_store_contract_suite.dart
// THEME-DRIFT T5：主题 store 行为契约套件（提取自
// core/test/theme_resource_store_contract_test.dart 的「ACT 06 store 行为」组）。
//
// 【为什么存在】照 signaling_contract_suite.dart：S5a 交付的 4 条 store 行为
// 用例原本写死在 core/test/ 里，drift/test/ 导入不到（Dart 的 test/ 目录不可
// 跨包引用）。提取到这里后，内存版（InMemoryThemeResourceStore）与 drift 版
// （DriftThemeResourceStore）跑同一套 —— 契约的约束不会各写各的（design.md D6）。
//
// 【为什么 makeStore 返回 Future】drift 版造库是异步的（NativeDatabase 需要
// await），统一签名为 `Future<ThemeResourceStore> Function(...)`，两处调用一致。
//
// 【为什么探针在 lib/test_support/theme_probes.dart】套件在 lib/ 下不能 import
// test/；CountingLocalReader / MutableLocalReader 提到 lib 侧（test/ 下的
// theme_probes.dart 改为 re-export）。
//
// 【为什么走深路径消费、不进 barrel】（决定记录 D3）barrel 不得含 test_support
// （core/test/s1b_architecture_guard_test.dart:53 已断言）。消费方一律
// `import 'package:persistence_core/test_support/theme_resource_store_contract_suite.dart'`。

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/theme_source_ports.dart';
import 'package:persistence_core/model/theme_token_types.dart';
import 'package:persistence_core/model/theme_resource_store.dart';
import 'package:persistence_core/model/theme_value_types.dart';

import 'theme_probes.dart';

/// 运行全部主题 store 行为契约测试。
///
/// 参数说明：
/// - [implementationName]: 实现名，只用于测试分组展示（'InMemory' / 'Drift'）。
/// - [makeStore]: 用给定 scopeUid 与 localReader 构造 store。**必须返回
///   Future**（drift 版造库是异步的）。
/// - [makeBundledFixture]: bundled 层扁平 token 的工厂（照 §7.5 fixture）。
/// - [makePackageFixture]: package 层扁平 token 的工厂；**可为 null**（该
///   实现无已装主题包时，A10/A12 的「卸载」路径仍会被测到）。
FutureOr<void> runThemeResourceStoreContractSuite({
  required String implementationName,
  required Future<ThemeResourceStore> Function({
    required String scopeUid,
    required ThemeLocalReader localReader,
  }) makeStore,
  required Map<String, dynamic> Function() makeBundledFixture,
  required Map<String, dynamic> Function()? makePackageFixture,
}) {
  group('契约 · $implementationName', () {
    test('contract_shape_and_resolution', () async {
      // A6/A7/A15/A16：经 store.resolve() 驱动，验证形状、贡献数、不可变性。
      final store = await makeStore(
        scopeUid: 'u1',
        localReader: CountingLocalReader(makeBundledFixture()),
      );
      final result = await store.resolve();
      expect(result, isA<ThemeTokenSet>());

      // A15：各层 contributedKeyCount 之和 == 结果 key 总数。
      final contributed = result.resolution.layers
          .fold<int>(0, (acc, l) => acc + l.contributedKeyCount);
      final leafCount = _leafCount(result.light.components) +
          (result.light.chart == null ? 0 : _leafCount(result.light.chart!)) +
          (result.light.semantic == null
              ? 0
              : _leafCount(result.light.semantic!)) +
          _leafCount(result.dark.components) +
          (result.dark.chart == null ? 0 : _leafCount(result.dark.chart!)) +
          (result.dark.semantic == null
              ? 0
              : _leafCount(result.dark.semantic!));
      expect(contributed, leafCount);

      // A16：components 及嵌套 Map 逐层不可变。
      expect(
        () => result.light.components['__new__'] = 1,
        throwsUnsupportedError,
      );
      expect(
        () => result.light.components.remove('four_zhu_card'),
        throwsUnsupportedError,
      );
      final nested =
          result.light.components['four_zhu_card'] as Map<String, dynamic>;
      expect(() => nested['__new__'] = 1, throwsUnsupportedError);
    });

    test('A10_override_survives_package_swap_and_uninstall', () async {
      // A10：换主题包 / 卸载主题包，用户覆盖仍生效（经 store.resolve() 驱动）。
      const k1 = 'light.components.four_zhu_card.shadow.color';

      // ① packageTokens=A（若提供了 package fixture）。
      final storeA = await makeStore(
        scopeUid: 'u1',
        localReader: MutableLocalReader(
          makeBundledFixture(),
          packageTokens: makePackageFixture?.call(),
        ),
      );
      await storeA.applyOverrides(
        patch: const {k1: 'o1'},
        origin: OverrideOrigin.manual,
      );
      final ra = await storeA.resolve();
      expect(_valueAt(ra, k1), 'o1');
      expect((await storeA.listOverrides()).containsKey(k1), isTrue);

      // ② packageTokens=null（卸载），override 仍生效。
      final storeB = await makeStore(
        scopeUid: 'u1',
        localReader: MutableLocalReader(makeBundledFixture()),
      );
      await storeB.applyOverrides(
        patch: const {k1: 'o1'},
        origin: OverrideOrigin.manual,
      );
      final rb = await storeB.resolve();
      expect(_valueAt(rb, k1), 'o1');
      expect((await storeB.listOverrides()).containsKey(k1), isTrue);
    });

    test('A11_applyOverrides_only_patch_keys_and_atomic', () async {
      const k1 = 'light.components.four_zhu_card.shadow.color';
      const k2 = 'light.components.four_zhu_card.shadow.blur_radius';
      final store = await makeStore(
        scopeUid: 'u1',
        localReader: CountingLocalReader(makeBundledFixture()),
      );

      // ① 先 apply {k1,k2}，再 apply {k1}：未出现的 k2 不被清除。
      await store.applyOverrides(
        patch: const {k1: 'a', k2: 'b'},
        origin: OverrideOrigin.manual,
      );
      await store.applyOverrides(
        patch: const {k1: 'a2'},
        origin: OverrideOrigin.manual,
      );
      final r = await store.resolve();
      expect(_valueAt(r, k1), 'a2');
      expect(_valueAt(r, k2), 'b');

      // ② 含非法条目的 patch：原子回滚，整批不生效。
      // 比较用规范化记录（值/来源/时间戳逐字段）而非 OverrideEntry 实例：
      // OverrideEntry 无 ==，内存版恰好返回同一实例、drift 版每次从 DB 重建
      // —— 实例同一性断言只对内存版成立，逐字段比较对两种实现都成立（不弱化）。
      final before = _entrySnapshot(await store.listOverrides());
      await expectLater(
        store.applyOverrides(
          patch: const {k1: <String, dynamic>{'nested': true}},
          origin: OverrideOrigin.manual,
        ),
        throwsA(isA<StateError>()),
      );
      final after = _entrySnapshot(await store.listOverrides());
      expect(after, before);
    });

    test('A12_removeOverrides_falls_back_and_idempotent', () async {
      const k1 = 'light.components.four_zhu_card.shadow.color';
      const orphan = 'light.components.ghost_component_0.radius';
      final store = await makeStore(
        scopeUid: 'u1',
        localReader: MutableLocalReader(
          makeBundledFixture(),
          packageTokens: makePackageFixture?.call(),
        ),
      );

      // ① apply {k1:'o1'}（package 层 k1='#C0C0C0'）-> remove 后回落到
      // package（无 package fixture 时回落到 bundled '#8B0000'）。
      await store.applyOverrides(
        patch: const {k1: 'o1'},
        origin: OverrideOrigin.manual,
      );
      var r = await store.resolve();
      expect(_valueAt(r, k1), 'o1');
      await store.removeOverrides({k1});
      r = await store.resolve();
      expect(
        _valueAt(r, k1),
        makePackageFixture == null ? '#8B0000' : '#C0C0C0',
      );

      // ② remove 不存在的 key：幂等不抛。
      await store.removeOverrides({'light.components.no_such.radius'});

      // ③ A13③：orphan key（package 与 bundled 均不含）在 listOverrides 仍存在。
      await store.applyOverrides(
        patch: const {orphan: 99.0},
        origin: OverrideOrigin.manual,
      );
      final list = await store.listOverrides();
      expect(list.containsKey(orphan), isTrue);
    });

    test('A6_watchResolved_写操作后推送新值', () async {
      // A6：覆盖层变更 / 主题切换必须经 watchResolved 推送新值（广播流）。
      // 变异的注入点：注释掉两版 store `_refreshAndNotify` 里的
      // `_controller.add(await resolve())` -> 下方 `pushed isNotEmpty`
      // 断言红（**不是**超时、**不是**编译失败 —— 订阅在写操作前建立，
      // 写操作后等待微任务 flush，变异后收集列表恒为空）。
      const k1 = 'light.components.four_zhu_card.shadow.color';
      final store = await makeStore(
        scopeUid: 'u1',
        localReader: CountingLocalReader(makeBundledFixture()),
      );
      final pushed = <ThemeTokenSet>[];
      final sub = store.watchResolved().listen(pushed.add);
      try {
        // ① applyOverrides 推送新值（覆盖 o1 生效）。
        await store.applyOverrides(
          patch: const {k1: 'o1'},
          origin: OverrideOrigin.manual,
        );
        // 广播流异步分发：让出事件循环把已排队的推送送完。
        await Future<void>.delayed(Duration.zero);
        expect(pushed, isNotEmpty,
            reason: 'applyOverrides 后 watchResolved 必须推送新值'); // ← 变异红在这
        expect(_valueAt(pushed.last, k1), 'o1');

        // ② removeOverrides 再次推送（回落到 bundled '#8B0000'）。
        final before = pushed.length;
        await store.removeOverrides({k1});
        await Future<void>.delayed(Duration.zero);
        expect(pushed.length, greaterThan(before),
            reason: 'removeOverrides 后 watchResolved 必须再次推送新值');
        expect(_valueAt(pushed.last, k1), '#8B0000');
      } finally {
        await sub.cancel();
      }
    });
  });
}

/// 从 resolve 结果里按扁平 key 取嵌套值（key 形如 light.components.x.y）。
///
/// 反扁平化后 components 是嵌套 Map（four_zhu_card -> shadow -> color），
/// 扁平 key 的段序与嵌套深度一一对应。
dynamic _valueAt(ThemeTokenSet set, String flatKey) {
  final segments = flatKey.split('.');
  // segments[0] == 'light' | 'dark'，segments[1] == 'components'。
  final section = segments[0] == 'light' ? set.light : set.dark;
  dynamic node = section.components;
  for (final seg in segments.sublist(2)) {
    node = (node as Map<String, dynamic>)[seg];
  }
  return node;
}

/// 递归统计嵌套 Map 的叶子数。
int _leafCount(Map<String, dynamic> map) {
  var count = 0;
  for (final v in map.values) {
    if (v is Map<String, dynamic>) {
      count += _leafCount(v);
    } else {
      count++;
    }
  }
  return count;
}

/// 把覆盖表快照规范化为可深比较的记录（值/来源/时间戳逐字段）。
///
/// [OverrideEntry] 无 `==`，直接用 expect(after, before) 依赖实例同一性：
/// 内存版恰好返回同一实例能过，drift 版每次从 DB 重建对象必然不等。
/// 用 record 深比较后，两种实现都以「内容未变」判定原子回滚成立。
Map<String, Object?> _entrySnapshot(Map<String, OverrideEntry> entries) =>
    entries.map(
      (key, e) => MapEntry(
        key,
        (
          e.value,
          e.origin.kind,
          e.origin.sourceThemeId,
          e.origin.sourceThemeVersion,
          e.updatedAtUtc,
        ),
      ),
    );
