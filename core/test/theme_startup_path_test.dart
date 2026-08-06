import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/dataset/dataset_registry.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/theme_dataset.dart';
import 'package:persistence_core/model/theme_module_registry.dart';
import 'package:persistence_core/model/theme_source_ports.dart';
import 'package:persistence_core/model/theme_token_types.dart';
import 'package:persistence_core/model/theme_value_types.dart';
import 'package:persistence_core/reference/in_memory_theme_materializer.dart';
import 'package:persistence_core/reference/in_memory_theme_resource_store.dart';
import 'package:persistence_core/reference/theme_assembly.dart';

import 'support/theme_bench_fixture.dart';
import 'support/theme_probes.dart';

/// S5a · ACT 05b 测试支撑自检（fixture 与探针）+ ACT 06 启动路径。
///
/// 本文件由 ACT 05b 先写 fixture / 探针的 3 条自检用例；
/// ACT 06 扩充 P3/P4/P6/A21/P2/P5 启动路径用例。
void main() {
  group('ACT 06 启动路径与装配', () {
    test('A21_assembly_chain_shares_one_tokenstore', () async {
      // A21 ①②：注册 materializer 工厂（闭包捕获共享 tokenStore），
      // CountingDatasetInstaller 会真调工厂并驱动 materialize。
      final fixture = ThemeBenchFixture();
      final tokenStore = InMemoryThemeTokenStore();
      // 三步全清（与 ACT 03 theme_module_registry_test 同口径）：
      // StoragePolicyRegistry 不清的话，跨用例重复注册 strategy 会抛
      // 'entityType 已注册'（resetForTesting 只重置 _registered 标志）。
      StoragePolicyRegistry.clearForTesting();
      DatasetRegistry.clearForTesting();
      ThemeModuleRegistry.resetForTesting();
      ThemeModuleRegistry.register(
        themeMaterializer: () => InMemoryThemeMaterializer(tokenStore),
      );
      final installer =
          CountingDatasetInstaller(bundledPayload: fixture.bundledJsonlBytes);

      // ② await installer.ensureInstalled(themeDatasetId)
      await installer.ensureInstalled(themeDatasetId);

      // ③ 工厂新建的实例把落地物写进了共享 store。
      expect(tokenStore.generations.contains(0), isTrue);

      // ④ 读路径拿到安装期落地的那一份。
      final reader = XrapThemeLocalReader(
        tokenStore: tokenStore,
        installer: installer,
        initialOverrides: const <String, OverrideEntry>{},
      );
      final bundled = await reader.readBundledTokens();
      expect(bundled.length, fixture.bundledTokens.length);

      // ⑤ 连调两次工厂，各落地一代 -> 两代都在共享 store 里。
      final d = DatasetRegistry.lookup(themeDatasetId)!;
      final m1 = d.materializer();
      await m1.materialize(
        manifest: d.bundledManifest,
        payload: fixture.bundledJsonlBytes(),
        generation: 1,
      );
      final m2 = d.materializer();
      await m2.materialize(
        manifest: d.bundledManifest,
        payload: fixture.bundledJsonlBytes(),
        generation: 2,
      );
      expect(tokenStore.generations, containsAll(<int>{0, 1, 2}));
    });

    test('P3_a1_constructor_tearoff_function_type', () {
      // P3-a1：tear-off 先赋 Object，参数表变化时红在运行时断言而非编译期。
      final Object ctor = InMemoryThemeResourceStore.new;
      expect(
        ctor,
        isA<
            InMemoryThemeResourceStore Function({
              required String scopeUid,
              required ThemeLocalReader localReader,
            })>(),
      );
    });

    test('P3_a2_import_whitelist', () {
      // P3-a2：import 集合白名单（设计 §5.5.4 原 6 条 package: 等价 + dart:async）。
      final source = File('lib/reference/in_memory_theme_resource_store.dart')
          .readAsStringSync();
      final imports = RegExp(
        r"^import\s+'(?<uri>[^']+)'.*;$",
        multiLine: true,
      ).allMatches(source).map((m) => m.namedGroup('uri')!).toSet();
      const allowed = <String>{
        'package:persistence_core/model/theme_token_types.dart',
        'package:persistence_core/model/theme_resolution.dart',
        'package:persistence_core/model/theme_resource_store.dart',
        'package:persistence_core/model/theme_source_ports.dart',
        'package:persistence_core/model/theme_value_types.dart',
        'package:persistence_core/reference/theme_token_merger.dart',
        'dart:async',
      };
      // ① IMPORTS ⊆ ALLOWED
      expect(imports.difference(allowed), isEmpty);
      // ② 正向控制：必需两条必须被 import（防空集静默全绿）。
      expect(
        imports,
        contains('package:persistence_core/model/theme_source_ports.dart'),
      );
      expect(
        imports,
        contains('package:persistence_core/model/theme_resource_store.dart'),
      );
      // ③ 防绕过：不得用 export/part/part of。
      expect(
        RegExp(r'^(export|part|part of)\s', multiLine: true).hasMatch(source),
        isFalse,
      );
    });

    test('P3_b_behavior_positive_control', () async {
      // P3-b：确实走了本地读取路径，而不是什么都没做。
      final fixture = ThemeBenchFixture();
      final reader = CountingLocalReader(fixture.bundledTokens);
      final store = InMemoryThemeResourceStore(
        scopeUid: 'u1',
        localReader: reader,
      );
      await store.resolve();
      expect(reader.bundledReadCount, greaterThan(0));
      expect(reader.overrideReadCount, greaterThan(0));
    });

    test('P4_resolve_does_not_trigger_install', () async {
      final fixture = ThemeBenchFixture();
      // 三步清理：让 assembleThemeStore 内的 register 真正生效。
      // ⚠️ 不能预注册自己的 tokenStore：assemble 的 register 幂等 no-op 后，
      // 落地物会进预注册工厂的 tokenStore，而 reader 用的是 assemble 自己
      // 创建的 tokenStore —— 装配链断开（R4-P1-3 断链形态，§4.5）。
      // 故让 assemble 自己完成「建 store -> 注册工厂 -> 落地 -> 装配 reader」，
      // 落地物与 reader 指向同一份。
      StoragePolicyRegistry.clearForTesting();
      DatasetRegistry.clearForTesting();
      ThemeModuleRegistry.resetForTesting();
      final installerSpy =
          CountingDatasetInstaller(bundledPayload: fixture.bundledJsonlBytes);
      final store = await assembleThemeStore(
        scopeUid: 'u1',
        installer: installerSpy,
        initialOverrides: fixture.overrides,
      );

      // 装配期：装配确实把 XRAP 接上了（正向控制）。
      expect(installerSpy.ensureInstalledCallCount, 1);
      expect(installerSpy.checkForUpdateCallCount, 0);
      // generation 0 落地且读路径可见：resolve 成功、无已装包（bundled 兜底）。
      final assembled = await store.resolve();
      expect(assembled.resolution.activeThemeId, isNull);

      installerSpy.resetCounts();
      await store.resolve();

      // resolve 期：零安装。
      expect(installerSpy.ensureInstalledCallCount, 0);
      expect(installerSpy.checkForUpdateCallCount, 0);
      expect(installerSpy.rollbackToCallCount, 0);
      expect(installerSpy.collectGarbageCallCount, 0);
      // resolve 期正向控制：确实经 XRAP 活跃指针读了落地物。
      expect(installerSpy.activeCallCount, greaterThan(0));
      expect(installerSpy.calledDatasetIds, contains(themeDatasetId));
    });

    test('P2_same_input_identical_then_override_breaks', () async {
      final fixture = ThemeBenchFixture();
      final store = InMemoryThemeResourceStore(
        scopeUid: 'u1',
        localReader: CountingLocalReader(fixture.bundledTokens),
      );
      final a = await store.resolve();
      final b = await store.resolve();
      expect(identical(a, b), isTrue);

      await store.applyOverrides(
        patch: const {'light.components.four_zhu_card.radius': 9.0},
        origin: OverrideOrigin.manual,
      );
      final c = await store.resolve();
      expect(identical(a, c), isFalse);
    });

    test('P5_no_back_reference', () async {
      final fixture = ThemeBenchFixture();
      late ThemeTokenSet result;
      {
        final store = InMemoryThemeResourceStore(
          scopeUid: 'u1',
          localReader: CountingLocalReader(fixture.bundledTokens),
        );
        result = await store.resolve();
      } // store 离开作用域，结果仍可读（无回指）。
      expect(result.light.components, isNotEmpty);
      // 结构断言：ThemeTokenSection 字段类型不出现 ThemeResourceStore / layer 引用。
      final source =
          File('lib/model/theme_token_types.dart').readAsStringSync();
      expect(source.contains('ThemeResourceStore'), isFalse);
    });

    test('P6_active_read_hang_returns_bundled_under_50ms', () async {
      final fixture = ThemeBenchFixture();
      final store = InMemoryThemeResourceStore(
        scopeUid: 'u1',
        localReader: SlowLocalReader(fixture.bundledTokens),
      );
      final sw = Stopwatch()..start();
      final result = await store.resolve();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
      // 来自 bundled 层：无活跃世代 -> activeThemeId == null。
      expect(result.resolution.activeThemeId, isNull);
    });
  });

  group('ACT 05b 测试支撑自检', () {
    test('fixture_leaf_count_lower_bound', () {
      // §7.5：叶子总数下限 700，防空输入假通过。
      final fixture = ThemeBenchFixture();
      expect(fixture.leafCount, greaterThanOrEqualTo(700));
    });

    test('counting_installer_implements_six_methods', () {
      // 构造成功即证明六个抽象方法都有实现（缺一编译不过）。
      final fixture = ThemeBenchFixture();
      final installer =
          CountingDatasetInstaller(bundledPayload: fixture.bundledJsonlBytes);

      // 六个计数字段初值一律 0。
      expect(installer.ensureInstalledCallCount, 0);
      expect(installer.checkForUpdateCallCount, 0);
      expect(installer.activeCallCount, 0);
      expect(installer.generationsCallCount, 0);
      expect(installer.rollbackToCallCount, 0);
      expect(installer.collectGarbageCallCount, 0);
      // calledDatasetIds 是 List（可重复），初值空。
      expect(installer.calledDatasetIds, isEmpty);
    });

    test('bundled_jsonl_has_no_g_field', () async {
      // R4-P0 回归守卫：载荷行只有 k/v/t，无 g。
      final fixture = ThemeBenchFixture();
      final bytes = await fixture
          .bundledJsonlBytes()
          .fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
      final lines = utf8
          .decode(bytes)
          .split('\n')
          .where((l) => l.trim().isNotEmpty);
      var rowCount = 0;
      for (final line in lines) {
        final j = jsonDecode(line) as Map<String, dynamic>;
        expect(
          j.keys.toSet().difference({'k', 'v', 't'}),
          isEmpty,
          reason: '载荷行不得含 g 或其它字段: $line',
        );
        rowCount++;
      }
      expect(rowCount, greaterThan(0));
    });
  });
}
