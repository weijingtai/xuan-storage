// 包：persistence_core (test_support)  文件：core/lib/test_support/theme_bench_fixture.dart
// THEME-DRIFT T6：主题共同 fixture 上移版（原 core/test/support/theme_bench_fixture.dart）。
//
// 【为什么上移】drift 契约测试（drift/test/theme/）要跨包引用同一份 fixture，
// Dart 的 test/ 目录不可跨包引用，照 T5 探针同法提到 lib/test_support/。
// core/test/support/theme_bench_fixture.dart 改为 re-export 保持既有 import 路径不变。

import 'dart:convert';

import 'package:persistence_core/model/theme_value_types.dart';

/// 共同 fixture（§7.5）：
/// - bundled 层：16 个 components，每个含 §6.2 全部原子组
///   （shadow 4 + border 2 + padding 4）+ 8 标量 -> 每组件 18 叶子；
///   其中 6 个组件各带 1 个 variant（对齐 default.yaml variants=6）
/// - package 层：覆盖 8 个组件的各 3 叶子
/// - override 层：50 条（含 5 条 orphan，驱动 §6.6 第 5 步）
/// - light/dark 各一份 -> 全量 (16×18 + 6×18) × 2 = 792 叶子 key
///
/// 禁止用空 Map 跑 P1 —— 那是假通过。叶子总数断言 >= 700。
final class ThemeBenchFixture {
  ThemeBenchFixture() {
    assert(leafCount >= 700, 'fixture 叶子数不得低于 700（§7.5 防空输入假通过）');
  }

  static const _components = <String>[
    'four_zhu_card',
    'liu_yao_card',
    'meihua_card',
    'qi_men_card',
    'tai_yi_card',
    'ziwei_card',
    'daliuren_card',
    'tieban_card',
    'xuan_kong_card',
    'shen_sha_card',
    'xing_ming_card',
    'liu_ren_card',
    'jing_zhe_card',
    'gui_shen_card',
    'kong_wang_card',
    'fei_gong_card',
  ];

  /// 前 6 个组件各带 1 个 variant（对齐 default.yaml 实测 variants=6）。
  static const _variantOf = <String, String>{
    'four_zhu_card': 'four_zhu_card_variant',
    'liu_yao_card': 'liu_yao_card_variant',
    'meihua_card': 'meihua_card_variant',
    'qi_men_card': 'qi_men_card_variant',
    'tai_yi_card': 'tai_yi_card_variant',
    'ziwei_card': 'ziwei_card_variant',
  };

  static const _scalarFields = <String>[
    'radius',
    'gap',
    'opacity',
    'min_width',
    'min_height',
    'max_width',
    'max_height',
    'z_index',
  ];

  static const _shadowFields = <String>[
    'color',
    'blur_radius',
    'offset_x',
    'offset_y',
  ];

  static const _borderFields = <String>['color', 'width'];

  static const _paddingFields = <String>['top', 'bottom', 'left', 'right'];

  /// 一个组件在一个 brightness 下的全部叶子 key（shadow 4 + border 2 + padding 4 + 标量 8 = 18）。
  static List<String> _componentKeys(String brightness, String component) {
    final base = '$brightness.components.$component';
    return [
      for (final f in _shadowFields) '$base.shadow.$f',
      for (final f in _borderFields) '$base.border.$f',
      for (final f in _paddingFields) '$base.padding.$f',
      for (final f in _scalarFields) '$base.$f',
    ];
  }

  static dynamic _valueFor(String key) {
    if (key.endsWith('.color')) return '#8B0000';
    if (key.endsWith('.blur_radius')) return 4.0;
    if (key.endsWith('.offset_x') || key.endsWith('.offset_y')) return 0.0;
    return 1.0;
  }

  /// bundled 层扁平 token（key 形如 light.components.four_zhu_card.shadow.color）。
  Map<String, dynamic> get bundledTokens {
    final tokens = <String, dynamic>{};
    for (final brightness in const ['light', 'dark']) {
      for (final component in _components) {
        for (final key in _componentKeys(brightness, component)) {
          tokens[key] = _valueFor(key);
        }
        final variant = _variantOf[component];
        if (variant != null) {
          for (final key in _componentKeys(brightness, variant)) {
            tokens[key] = _valueFor(key);
          }
        }
      }
    }
    return tokens;
  }

  /// package 层扁平 token（覆盖 bundled 的 8 个组件各 3 叶子）。
  Map<String, dynamic> get packageTokens {
    final tokens = <String, dynamic>{};
    final covered = _components.sublist(0, 8);
    for (final brightness in const ['light', 'dark']) {
      for (final component in covered) {
        final base = '$brightness.components.$component';
        tokens['$base.shadow.color'] = '#C0C0C0';
        tokens['$base.radius'] = 6.0;
        tokens['$base.border.width'] = 2.0;
      }
    }
    return tokens;
  }

  /// override 层 50 条（含 5 条 orphan，orphan 的 key 不在 bundled/package）。
  Map<String, OverrideEntry> get overrides {
    final entries = <String, OverrideEntry>{};
    // 45 条有效覆盖：轮转取 bundled 的叶子 key（light 组件段）。
    final pool = <String>[];
    for (final component in _components) {
      pool.addAll(_componentKeys('light', component));
    }
    for (var i = 0; i < 45; i++) {
      final key = pool[i % pool.length];
      entries[key] = OverrideEntry(
        value: _valueFor(key),
        origin: OverrideOrigin.manual,
        updatedAtUtc: DateTime.utc(2026, 8, 5),
      );
    }
    // 5 条 orphan：key 不存在于 bundled/package。
    for (var i = 0; i < 5; i++) {
      final key = 'light.components.ghost_component_$i.radius';
      entries[key] = OverrideEntry(
        value: 99.0,
        origin: OverrideOrigin.manual,
        updatedAtUtc: DateTime.utc(2026, 8, 5),
      );
    }
    return entries;
  }

  static String _typeOf(dynamic value) {
    if (value is String) return 's';
    if (value is num) return 'n';
    if (value is bool) return 'b';
    if (value is List) return 'a';
    return 'z';
  }

  /// §4.3 行 schema 的 JSONL 字节流，供 CountingDatasetInstaller 落地 generation 0。
  /// 每次返回一条新的 `Stream<List<int>>`（Stream 只能监听一次）。
  /// 内容 == bundledTokens 扁平 key 按 {"k":..,"v":..,"t":..} 序列化，无 g 字段（R4-P0）。
  Stream<List<int>> Function() get bundledJsonlBytes {
    final rows = <String>[];
    bundledTokens.forEach((key, value) {
      rows.add(jsonEncode({'k': key, 'v': value, 't': _typeOf(value)}));
    });
    final data = utf8.encode('${rows.join('\n')}\n');
    return () => Stream.value(data);
  }

  /// 叶子总数下限断言（>= 700，防 fixture 被悄悄改小，§7.5）。
  int get leafCount => bundledTokens.length;
}
