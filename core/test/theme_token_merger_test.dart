import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/theme_resolution.dart';
import 'package:persistence_core/model/theme_value_types.dart';
import 'package:persistence_core/reference/theme_token_merger.dart';

/// S5a reference 层 · ACT 04 三层合并算法纯函数 [mergeThemeTokens]。
///
/// 覆盖验收：A9（三层优先级 / null 命中）、A14c（原子组补全）、A13（orphan）、
/// A19（不吞非法值）、P7（字典序稳定）、A15（贡献计数）、A16（不可变）。
void main() {
  OverrideEntry overrideOf(dynamic value) => OverrideEntry(
        value: value,
        origin: OverrideOrigin.manual,
        updatedAtUtc: DateTime.utc(2026, 8, 5),
      );

  group('ACT 04 三层合并算法', () {
    test('three_layer_priority_override_package_bundled', () {
      const bundled = <String, dynamic>{'light.components.k1': 'b'};
      const package = <String, dynamic>{'light.components.k1': 'p'};
      final overrides = <String, OverrideEntry>{
        'light.components.k1': overrideOf('o'),
      };

      // override > package
      final r1 = mergeThemeTokens(
        bundledTokens: bundled,
        packageTokens: package,
        overrides: overrides,
        activeThemeId: 'pkg.a',
        activeThemeVersion: '1.0',
        selectionOrigin: ThemeSelectionOrigin.userSelected,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );
      expect(r1.light.components['k1'], 'o');

      // 删 override -> package
      final r2 = mergeThemeTokens(
        bundledTokens: bundled,
        packageTokens: package,
        overrides: {},
        activeThemeId: 'pkg.a',
        activeThemeVersion: '1.0',
        selectionOrigin: ThemeSelectionOrigin.userSelected,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );
      expect(r2.light.components['k1'], 'p');

      // 删 package -> bundled
      final r3 = mergeThemeTokens(
        bundledTokens: bundled,
        packageTokens: null,
        overrides: {},
        activeThemeId: null,
        activeThemeVersion: null,
        selectionOrigin: ThemeSelectionOrigin.bundledFallback,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );
      expect(r3.light.components['k1'], 'b');
    });

    test('null_value_counts_as_hit', () {
      const bundled = <String, dynamic>{'light.components.k1': 'b'};
      // package 显式给 null：必须命中 package（containsKey），不穿透到 bundled。
      const package = <String, dynamic>{'light.components.k1': null};

      final r = mergeThemeTokens(
        bundledTokens: bundled,
        packageTokens: package,
        overrides: {},
        activeThemeId: 'pkg.a',
        activeThemeVersion: '1.0',
        selectionOrigin: ThemeSelectionOrigin.userSelected,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );
      expect(r.light.components.containsKey('k1'), isTrue);
      expect(r.light.components['k1'], isNull);
    });

    test('atomic_group_completion_shadow', () {
      const bundled = <String, dynamic>{
        'light.components.four_zhu_card.shadow.color': 'bColor',
        'light.components.four_zhu_card.shadow.blur_radius': 4.0,
        'light.components.four_zhu_card.shadow.offset_x': 1.0,
        'light.components.four_zhu_card.shadow.offset_y': 2.0,
      };
      final overrides = <String, OverrideEntry>{
        'light.components.four_zhu_card.shadow.color': overrideOf('oColor'),
      };

      final r = mergeThemeTokens(
        bundledTokens: bundled,
        packageTokens: null,
        overrides: overrides,
        activeThemeId: null,
        activeThemeVersion: null,
        selectionOrigin: ThemeSelectionOrigin.bundledFallback,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );

      final shadow =
          r.light.components['four_zhu_card']!['shadow'] as Map<String, dynamic>;
      // color 来自 override，其余三叶子从 bundled 补齐 —— 四叶子齐全。
      expect(shadow['color'], 'oColor');
      expect(shadow['blur_radius'], 4.0);
      expect(shadow['offset_x'], 1.0);
      expect(shadow['offset_y'], 2.0);
    });

    test('orphan_not_in_result_but_kept_in_overrides', () {
      const bundled = <String, dynamic>{'light.components.k1': 'b'};
      final overrides = <String, OverrideEntry>{
        'light.components.k_orphan': overrideOf('x'),
      };

      final r = mergeThemeTokens(
        bundledTokens: bundled,
        packageTokens: null,
        overrides: overrides,
        activeThemeId: null,
        activeThemeVersion: null,
        selectionOrigin: ThemeSelectionOrigin.bundledFallback,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );

      // ① orphan 不参与合并输出（不凭空创造 token）。
      expect(r.light.components.containsKey('k_orphan'), isFalse);
      // ② key 进入 orphanedOverrideKeys（数据不删，A13 ①②）。
      expect(r.resolution.orphanedOverrideKeys, contains('light.components.k_orphan'));
    });

    test('merge_does_not_swallow_invalid_value', () {
      const bundled = <String, dynamic>{'light.components.btn.radius': 8.0};
      final overrides = <String, OverrideEntry>{
        'light.components.btn.radius': overrideOf('8px'), // 非法值，必须原样透传
      };

      final r = mergeThemeTokens(
        bundledTokens: bundled,
        packageTokens: null,
        overrides: overrides,
        activeThemeId: null,
        activeThemeVersion: null,
        selectionOrigin: ThemeSelectionOrigin.bundledFallback,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );
      expect(r.light.components['btn']!['radius'], '8px');
    });

    test('key_order_stable_and_sorted', () {
      // 故意乱序输入（Dart Map 保持插入序），验证输出按字典序。
      const bundled = <String, dynamic>{
        'light.components.z_component.k2': 1,
        'light.components.a_component.k1': 2,
        'light.chart.axis_color': 3,
        'dark.components.z_component.k2': 4,
        'dark.components.a_component.k1': 5,
      };
      const package = <String, dynamic>{
        'light.components.m_component.k3': 6,
      };

      List<List<String>> levelKeyLists(Map<String, dynamic> m) {
        final lists = <List<String>>[m.keys.toList()];
        for (final v in m.values) {
          if (v is Map<String, dynamic>) {
            lists.addAll(levelKeyLists(v));
          }
        }
        return lists;
      }

      List<List<String>>? first;
      for (var i = 0; i < 10; i++) {
        final r = mergeThemeTokens(
          bundledTokens: bundled,
          packageTokens: package,
          overrides: {},
          activeThemeId: 'pkg.a',
          activeThemeVersion: '1.0',
          selectionOrigin: ThemeSelectionOrigin.officialDefault,
          resolvedAtUtc: DateTime.utc(2026, 8, 5),
        );
        final allLists = [
          ...levelKeyLists(r.light.components),
          if (r.light.chart != null) ...levelKeyLists(r.light.chart!),
          ...levelKeyLists(r.dark.components),
        ];
        for (final list in allLists) {
          final sorted = list.toList()..sort();
          expect(list, sorted, reason: '每层 key 必须字典序');
        }
        if (first == null) {
          first = allLists;
        } else {
          expect(allLists, first, reason: '同一 fixture 多次合并顺序必须一致');
        }
      }
    });

    test('contributed_key_count_sums_to_total', () {
      const bundled = <String, dynamic>{
        'light.components.k1': 'b1',
        'light.components.k3': 'b3',
        'light.chart.axis_color': 1,
      };
      const package = <String, dynamic>{'light.components.k1': 'p1'};
      final overrides = <String, OverrideEntry>{
        'light.components.k2': overrideOf('o2'),
      };

      final r = mergeThemeTokens(
        bundledTokens: bundled,
        packageTokens: package,
        overrides: overrides,
        activeThemeId: 'pkg.a',
        activeThemeVersion: '1.0',
        selectionOrigin: ThemeSelectionOrigin.userSelected,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );

      int countLeaves(Map<String, dynamic> m) {
        var n = 0;
        for (final v in m.values) {
          n += v is Map<String, dynamic> ? countLeaves(v) : 1;
        }
        return n;
      }

      final totalLeaves = countLeaves(r.light.components) +
          countLeaves(r.dark.components) +
          (r.light.chart == null ? 0 : countLeaves(r.light.chart!)) +
          (r.light.semantic == null ? 0 : countLeaves(r.light.semantic!)) +
          (r.dark.chart == null ? 0 : countLeaves(r.dark.chart!)) +
          (r.dark.semantic == null ? 0 : countLeaves(r.dark.semantic!));

      final sumCounts = r.resolution.layers.fold<int>(
        0,
        (acc, layer) => acc + layer.contributedKeyCount,
      );
      expect(sumCounts, totalLeaves);
    });

    test('result_is_unmodifiable', () {
      const bundled = <String, dynamic>{
        'light.components.four_zhu_card.shadow.color': 'bColor',
        'light.components.four_zhu_card.shadow.blur_radius': 4.0,
      };
      final overrides = <String, OverrideEntry>{
        'light.components.four_zhu_card.shadow.color': overrideOf('oColor'),
      };

      final r = mergeThemeTokens(
        bundledTokens: bundled,
        packageTokens: null,
        overrides: overrides,
        activeThemeId: null,
        activeThemeVersion: null,
        selectionOrigin: ThemeSelectionOrigin.bundledFallback,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );

      // 顶层 components 不可写。
      expect(() => r.light.components['x'] = 1, throwsUnsupportedError);
      expect(() => r.light.components.remove('four_zhu_card'),
          throwsUnsupportedError);
      // 嵌套 Map 逐层不可写。
      final fourZhu = r.light.components['four_zhu_card'] as Map<String, dynamic>;
      expect(() => fourZhu['new_key'] = 1, throwsUnsupportedError);
      final shadow = fourZhu['shadow'] as Map<String, dynamic>;
      expect(() => shadow['color'] = 'x', throwsUnsupportedError);
    });
  });
}
