import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/theme_resource_store.dart';
import 'package:persistence_core/model/theme_resolution.dart';
import 'package:persistence_core/model/theme_source_ports.dart';
import 'package:persistence_core/model/theme_token_types.dart';
import 'package:persistence_core/model/theme_value_types.dart';

/// S5a 契约层 · ACT 01 中立数据结构与溯源类型。
///
/// 本文件由 ACT 01 先写"形状"部分用例；ACT 02 / ACT 06 会扩充同一文件。
/// 覆盖验收：A6（ThemeTokenSet 三字段）、A15（ThemeResolution 默认值、
/// ThemeLayerKind 优先级顺序）。
void main() {
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
