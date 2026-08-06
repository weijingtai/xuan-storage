import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/theme_resolution.dart';
import 'package:persistence_core/model/theme_source_ports.dart';
import 'package:persistence_core/model/theme_token_types.dart';
import 'package:persistence_core/model/theme_value_types.dart';
import 'package:persistence_core/reference/in_memory_theme_resource_store.dart';

import 'support/theme_bench_fixture.dart';
import 'support/theme_probes.dart';

/// S5a 契约层 · ACT 01 中立数据结构与溯源类型 + ACT 06 store 行为。
///
/// 本文件由 ACT 01 先写"形状"部分用例；ACT 02 / ACT 06 会扩充同一文件。
/// 覆盖验收：A6（ThemeTokenSet 三字段）、A15（ThemeResolution 默认值、
/// ThemeLayerKind 优先级顺序）、A10/A11/A12/A13、A16。
void main() {
  group('ACT 06 store 行为', () {
    test('contract_shape_and_resolution', () async {
      // A6/A7/A15/A16：经 store.resolve() 驱动，验证形状、贡献数、不可变性。
      final fixture = ThemeBenchFixture();
      final store = InMemoryThemeResourceStore(
        scopeUid: 'u1',
        localReader: CountingLocalReader(fixture.bundledTokens),
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
      final fixture = ThemeBenchFixture();

      // ① packageTokens=A（fixture.packageTokens 覆盖 bundled 的 8 个组件各 3 叶子）。
      final storeA = InMemoryThemeResourceStore(
        scopeUid: 'u1',
        localReader: _MutableLocalReader(
          fixture.bundledTokens,
          packageTokens: fixture.packageTokens,
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
      final storeB = InMemoryThemeResourceStore(
        scopeUid: 'u1',
        localReader: _MutableLocalReader(fixture.bundledTokens),
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
      final fixture = ThemeBenchFixture();
      final store = InMemoryThemeResourceStore(
        scopeUid: 'u1',
        localReader: CountingLocalReader(fixture.bundledTokens),
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
      final before = await store.listOverrides();
      await expectLater(
        store.applyOverrides(
          patch: const {k1: <String, dynamic>{'nested': true}},
          origin: OverrideOrigin.manual,
        ),
        throwsA(isA<StateError>()),
      );
      final after = await store.listOverrides();
      expect(after, before);
    });

    test('A12_removeOverrides_falls_back_and_idempotent', () async {
      const k1 = 'light.components.four_zhu_card.shadow.color';
      const orphan = 'light.components.ghost_component_0.radius';
      final fixture = ThemeBenchFixture();
      final store = InMemoryThemeResourceStore(
        scopeUid: 'u1',
        localReader: _MutableLocalReader(
          fixture.bundledTokens,
          packageTokens: fixture.packageTokens,
        ),
      );

      // ① apply {k1:'o1'}（package 层 k1='#C0C0C0'）-> remove 后回落到 package。
      await store.applyOverrides(
        patch: const {k1: 'o1'},
        origin: OverrideOrigin.manual,
      );
      var r = await store.resolve();
      expect(_valueAt(r, k1), 'o1');
      await store.removeOverrides({k1});
      r = await store.resolve();
      expect(_valueAt(r, k1), '#C0C0C0');

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
  });

  group('ACT 02 主门面 / 值类型 / 注入端口', () {
    test('store_has_no_install_methods', () {
      // A7：本端口不提供任何安装类方法（install/uninstall/download/fetch/verify 归 XRAP）。
      // dart:mirrors 在 Flutter 不可用，用源码扫描断言。
      final source =
          File('lib/model/theme_resource_store.dart').readAsStringSync();
      final installLike =
          RegExp(r'Future<.*>\s+(install|uninstall|download|fetch|verify)\s*\(')
              .allMatches(source);
      expect(
        installLike,
        isEmpty,
        reason: 'ThemeResourceStore 不得出现安装类方法名（归 XRAP，§0.0 裁定 3）',
      );
    });

    test('read_write_asymmetry_dartdoc_present', () {
      // A6：读写不对称的 dartdoc 锚点 —— 逐方法判定，红在断言而非编译。
      final source =
          File('lib/model/theme_resource_store.dart').readAsStringSync();
      final lines = source.split('\n');

      String dartdocBlockFor(String declLine) {
        final declIndex = lines.indexWhere((l) => l.contains(declLine));
        expect(declIndex, greaterThan(0),
            reason: '未找到声明行: $declLine');
        final start = declIndex - 20;
        return lines.sublist(start < 0 ? 0 : start, declIndex)
            .where((l) => l.trimLeft().startsWith('///'))
            .join('\n');
      }

      final applyDoc = dartdocBlockFor('Future<void> applyOverrides');
      final removeDoc = dartdocBlockFor('Future<void> removeOverrides');
      final resolveDoc = dartdocBlockFor('Future<ThemeTokenSet> resolve');

      expect(applyDoc, contains('只作用于用户覆盖层'));
      expect(removeDoc, contains('只作用于用户覆盖层'));
      expect(resolveDoc, contains('三层合并'));
    });

    test('override_origin_from_package_records_values', () {
      // "存值不存引用"：取自 B 包记录的是值快照。
      final fromPackage =
          OverrideOrigin.fromPackage(themeId: 'pkg.a', version: '1.2');
      expect(fromPackage.kind, 'package');
      expect(fromPackage.sourceThemeId, 'pkg.a');
      expect(fromPackage.sourceThemeVersion, '1.2');

      const manual = OverrideOrigin.manual;
      expect(manual.kind, 'manual');
      expect(manual.sourceThemeId, isNull);
      expect(manual.sourceThemeVersion, isNull);
    });
  });
  group('ACT 01 中立数据结构与溯源类型', () {
    test('token_set_and_section_shape', () {
      final resolution = ThemeResolution(
        activeThemeId: 'demo-theme',
        activeThemeVersion: '1.0.0',
        selectionOrigin: ThemeSelectionOrigin.userSelected,
        layers: const [
          ThemeLayerInfo(
            kind: ThemeLayerKind.userOverride,
            sourceId: 'user_override',
            contributedKeyCount: 2,
          ),
        ],
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );
      final set = ThemeTokenSet(
        light: ThemeTokenSection(
          components: const {
            'Button': <String, dynamic>{'color': '#000000'},
          },
          chart: const <String, dynamic>{'axisColor': '#111111'},
          semantic: const <String, dynamic>{'fire': '#ff0000'},
        ),
        dark: ThemeTokenSection(
          components: const {
            'Button': <String, dynamic>{'color': '#ffffff'},
          },
        ),
        resolution: resolution,
      );

      // 三字段可读、类型正确。
      expect(set.light, isA<ThemeTokenSection>());
      expect(set.dark, isA<ThemeTokenSection>());
      expect(set.resolution, same(resolution));

      // components 是组件 id -> 原始 Map。
      expect(set.light.components.containsKey('Button'), isTrue);
      expect(set.light.components['Button'], isA<Map<String, dynamic>>());

      // chart / semantic 可为 null（dark 未提供即为 null）。
      expect(set.light.chart, isNotNull);
      expect(set.light.semantic, isNotNull);
      expect(set.dark.chart, isNull);
      expect(set.dark.semantic, isNull);
    });

    test('resolution_orphan_default_empty', () {
      final resolution = ThemeResolution(
        activeThemeId: null,
        activeThemeVersion: null,
        selectionOrigin: ThemeSelectionOrigin.bundledFallback,
        layers: const [
          ThemeLayerInfo(
            kind: ThemeLayerKind.bundled,
            sourceId: 'bundled',
            contributedKeyCount: 0,
          ),
        ],
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );
      // 不传 orphanedOverrideKeys，默认必须是 const []（不是 null）。
      expect(resolution.orphanedOverrideKeys, const <String>[]);
      expect(resolution.activeThemeId, isNull);
      expect(resolution.activeThemeVersion, isNull);
    });

    test('layer_kind_priority_order', () {
      // 三层模型优先级从高到低：userOverride > installedPackage > bundled。
      // 这是 §6.1 三层模型的编译期锚点。
      expect(
        ThemeLayerKind.values,
        const [
          ThemeLayerKind.userOverride,
          ThemeLayerKind.installedPackage,
          ThemeLayerKind.bundled,
        ],
      );
    });
  });
}

/// 可变 packageTokens 的 reader，A10/A12 换包 / 卸载用例用。
///
/// bundled 恒非空；packageTokens 可为 null（卸载）；overrides 恒空
/// （覆盖层由 store.applyOverrides 写入，不走 reader）。
final class _MutableLocalReader implements ThemeLocalReader {
  _MutableLocalReader(this._bundled, {Map<String, dynamic>? packageTokens})
      : _packageTokens = packageTokens;

  final Map<String, dynamic> _bundled;
  final Map<String, dynamic>? _packageTokens;

  @override
  Future<Map<String, dynamic>> readBundledTokens() async => _bundled;

  @override
  Future<Map<String, dynamic>?> readActiveThemeTokens(String themeId) async =>
      _packageTokens;

  @override
  Future<Map<String, OverrideEntry>> readOverrides() async =>
      const <String, OverrideEntry>{};
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
