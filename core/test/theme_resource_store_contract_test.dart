import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/theme_resolution.dart';
import 'package:persistence_core/model/theme_token_types.dart';

/// S5a 契约层 · ACT 01 中立数据结构与溯源类型。
///
/// 本文件由 ACT 01 先写"形状"部分用例；ACT 02 / ACT 06 会扩充同一文件。
/// 覆盖验收：A6（ThemeTokenSet 三字段）、A15（ThemeResolution 默认值、
/// ThemeLayerKind 优先级顺序）。
void main() {
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
