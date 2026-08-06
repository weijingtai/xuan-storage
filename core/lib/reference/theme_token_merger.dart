// 包：persistence_core  文件：core/lib/reference/theme_token_merger.dart
// 【reference】§6.6 合并算法的可执行形式。纯函数，无状态，零 IO。

import 'package:persistence_core/model/theme_resolution.dart';
import 'package:persistence_core/model/theme_token_types.dart';
import 'package:persistence_core/model/theme_value_types.dart';

// 原子组清单（写死，不得由执行者推断，§6.2）：
//   .shadow        -> color/blur_radius/offset_x/offset_y
//   .border        -> color/width
//   .text.text_shadow -> color/blur_radius/offset_x/offset_y
//   .padding/.margin -> top/bottom/left/right/all（标量整体替换，Map 按方向补全）
const _atomicGroups = <(String, List<String>)>[
  ('.shadow', <String>['color', 'blur_radius', 'offset_x', 'offset_y']),
  ('.border', <String>['color', 'width']),
  (
    '.text.text_shadow',
    <String>['color', 'blur_radius', 'offset_x', 'offset_y'],
  ),
  ('.padding', <String>['top', 'bottom', 'left', 'right', 'all']),
  ('.margin', <String>['top', 'bottom', 'left', 'right', 'all']),
];

/// 每层贡献的来源标记（第 3 步计数用）。
enum _SourceLayer { override, package, bundled }

/// 合并三层 token 为一份源无关的 ThemeTokenSet。
///
/// 输入（均已扁平化，key 形如 light.components.four_zhu_card.shadow.color）：
/// - bundledTokens: bundled 默认主题（恒存在，最后兜底）
/// - packageTokens: 已装主题包；null 表示无已装包
/// - overrides: 用户覆盖差量
/// - activeThemeId / activeThemeVersion / selectionOrigin: 溯源信息
///
/// 实现顺序（§6.6 末注）：1 输入校验 -> 5 orphan 判定 -> 2 逐 key 取值
/// -> 4 原子组补全 -> 3 记贡献数 -> 6 反扁平化。
ThemeTokenSet mergeThemeTokens({
  required Map<String, dynamic> bundledTokens,
  required Map<String, dynamic>? packageTokens,
  required Map<String, OverrideEntry> overrides,
  required String? activeThemeId,
  required String? activeThemeVersion,
  required ThemeSelectionOrigin selectionOrigin,
  required DateTime resolvedAtUtc,
}) {
  // ── 第 1 步 · 输入校验（不做扁平化）──
  _validateFlatTokens(bundledTokens);
  if (packageTokens != null) _validateFlatTokens(packageTokens);
  overrides.forEach((key, entry) {
    _validateFlatKey(key);
    assert(
      entry.value is! Map,
      '覆盖值不得为 Map（扁平输入契约违反）: $key',
    );
  });

  // ── 第 5 步 · orphan 判定（先于第 2 步，避免污染合并与原子组补全）──
  final orphanedKeys = <String>[];
  final effectiveOverrides = <String, OverrideEntry>{};
  overrides.forEach((key, entry) {
    final existsBelow = (packageTokens?.containsKey(key) ?? false) ||
        bundledTokens.containsKey(key);
    if (existsBelow) {
      effectiveOverrides[key] = entry;
    } else {
      orphanedKeys.add(key);
    }
  });

  // ── 第 2 步 · 逐 key 三层取值（null 也算命中，用 containsKey 不用 ??）──
  final merged = <String, dynamic>{};
  final source = <String, _SourceLayer>{};
  final allKeys = <String>{
    ...bundledTokens.keys,
    if (packageTokens != null) ...packageTokens.keys,
    ...effectiveOverrides.keys,
  };
  for (final key in allKeys) {
    if (effectiveOverrides.containsKey(key)) {
      merged[key] = effectiveOverrides[key]!.value;
      source[key] = _SourceLayer.override;
    } else if (packageTokens != null && packageTokens.containsKey(key)) {
      merged[key] = packageTokens[key];
      source[key] = _SourceLayer.package;
    } else {
      assert(bundledTokens.containsKey(key), 'bundled 必须恒含全部兜底 key');
      merged[key] = bundledTokens[key];
      source[key] = _SourceLayer.bundled;
    }
  }

  // ── 第 4 步 · 原子组补全（组内任一叶子来自较高层则补齐其余成员）──
  _completeAtomicGroups(merged, source, packageTokens, bundledTokens);

  // ── 第 3 步 · 记贡献数（在补全之后统计，防止填假数）──
  var overrideCount = 0;
  var packageCount = 0;
  var bundledCount = 0;
  for (final s in source.values) {
    if (s == _SourceLayer.override) {
      overrideCount++;
    } else if (s == _SourceLayer.package) {
      packageCount++;
    } else {
      bundledCount++;
    }
  }

  // ── 第 6 步 · 反扁平化 + 字典序稳定 + 逐层不可变 ──
  final light = _sectionFrom(merged, 'light');
  final dark = _sectionFrom(merged, 'dark');

  final layers = <ThemeLayerInfo>[
    ThemeLayerInfo(
      kind: ThemeLayerKind.userOverride,
      sourceId: 'user_override',
      contributedKeyCount: overrideCount,
    ),
    if (packageTokens != null)
      ThemeLayerInfo(
        kind: ThemeLayerKind.installedPackage,
        sourceId: activeThemeId ?? 'package',
        contributedKeyCount: packageCount,
      ),
    ThemeLayerInfo(
      kind: ThemeLayerKind.bundled,
      sourceId: 'bundled',
      contributedKeyCount: bundledCount,
    ),
  ];

  return ThemeTokenSet(
    light: light,
    dark: dark,
    resolution: ThemeResolution(
      activeThemeId: activeThemeId,
      activeThemeVersion: activeThemeVersion,
      selectionOrigin: selectionOrigin,
      layers: layers,
      resolvedAtUtc: resolvedAtUtc,
      orphanedOverrideKeys: List<String>.unmodifiable(orphanedKeys),
    ),
  );
}

/// 第 1 步：扁平 key 合法性（无空段、不以点开头/结尾、带 brightness 前缀）。
void _validateFlatTokens(Map<String, dynamic> tokens) {
  for (final key in tokens.keys) {
    _validateFlatKey(key);
    assert(
      tokens[key] is! Map,
      '扁平 token 的 value 不得为 Map（契约违反）: $key',
    );
  }
}

void _validateFlatKey(String key) {
  assert(!key.startsWith('.') && !key.endsWith('.') && !key.contains('..'),
      '扁平 key 含空段: $key');
  assert(
    key.startsWith('light.') || key.startsWith('dark.'),
    '扁平 key 必须以 brightness 前缀开头: $key',
  );
}

/// 第 4 步：原子组补全（§6.2 / §6.6）。
///
/// - 组内至少一个叶子来自较高层（override/package）时，其余缺失成员从较低层
///   按 package -> bundled 补齐；较低层也没有则保持缺失（token_loader 兜底）。
/// - padding/margin 双形态：较高层给标量 -> 整体替换不做补全；
///   较高层给 Map 方向 -> 丢弃较低层的标量形态，按方向补全。
void _completeAtomicGroups(
  Map<String, dynamic> merged,
  Map<String, _SourceLayer> source,
  Map<String, dynamic>? packageTokens,
  Map<String, dynamic> bundledTokens,
) {
  for (final group in _atomicGroups) {
    final suffix = group.$1;
    final members = group.$2;
    final isPadMargin = suffix == '.padding' || suffix == '.margin';

    // 找组锚点：任何成员叶子 key 的锚点以组后缀结尾。
    final anchors = <String>{};
    for (final key in merged.keys) {
      for (final member in members) {
        final memberSuffix = '.$member';
        if (key.endsWith(memberSuffix)) {
          final anchor = key.substring(0, key.length - memberSuffix.length);
          if (anchor.endsWith(suffix)) {
            anchors.add(anchor);
          }
        }
      }
    }

    for (final anchor in anchors) {
      // 组内来自较高层的成员名集合。
      final higherMembers = <String>{};
      for (final member in members) {
        final s = source['$anchor.$member'];
        if (s == _SourceLayer.override || s == _SourceLayer.package) {
          higherMembers.add(member);
        }
      }

      // padding/margin 双形态冲突处置。
      final scalarPresent = merged.containsKey(anchor);
      if (isPadMargin && scalarPresent) {
        if (higherMembers.isEmpty) {
          // 较高层给标量 -> 整体替换，丢弃较低层的方向成员，不做补全。
          for (final member in members) {
            merged.remove('$anchor.$member');
            source.remove('$anchor.$member');
          }
          continue;
        } else {
          // 较高层给 Map 方向 -> 丢弃较低层的标量形态。
          merged.remove(anchor);
          source.remove(anchor);
        }
      }

      // 没有任何叶子来自较高层 -> 无需补全（bundled 自带完整组）。
      if (higherMembers.isEmpty) continue;

      // 补齐缺失成员：package -> bundled。
      for (final member in members) {
        final memberKey = '$anchor.$member';
        if (merged.containsKey(memberKey)) continue;
        if (packageTokens != null && packageTokens.containsKey(memberKey)) {
          merged[memberKey] = packageTokens[memberKey];
          source[memberKey] = _SourceLayer.package;
        } else if (bundledTokens.containsKey(memberKey)) {
          merged[memberKey] = bundledTokens[memberKey];
          source[memberKey] = _SourceLayer.bundled;
        }
      }
    }
  }
}

/// 第 6 步：按 brightness 前缀拆出单侧 section，反扁平化并排序 + 不可变。
ThemeTokenSection _sectionFrom(Map<String, dynamic> flat, String brightness) {
  final prefix = '$brightness.';
  final componentsFlat = <String, dynamic>{};
  final chartFlat = <String, dynamic>{};
  final semanticFlat = <String, dynamic>{};

  for (final entry in flat.entries) {
    if (!entry.key.startsWith(prefix)) continue;
    final rest = entry.key.substring(prefix.length);
    final dot = rest.indexOf('.');
    if (dot < 0) continue; // 只有分区无叶子路径，本层不产出（契约层校验已拦）
    final section = rest.substring(0, dot);
    final path = rest.substring(dot + 1);
    if (section == 'components') {
      componentsFlat[path] = entry.value;
    } else if (section == 'chart') {
      chartFlat[path] = entry.value;
    } else if (section == 'semantic') {
      semanticFlat[path] = entry.value;
    } else {
      assert(false, '未知分区: $section');
    }
  }

  return ThemeTokenSection(
    components: _sortedUnmodifiableDeep(_nest(componentsFlat)),
    chart: chartFlat.isEmpty
        ? null
        : _sortedUnmodifiableDeep(_nest(chartFlat)),
    semantic: semanticFlat.isEmpty
        ? null
        : _sortedUnmodifiableDeep(_nest(semanticFlat)),
  );
}

/// 扁平路径 -> 嵌套 Map（插入序保持输入序，排序在 [_sortedUnmodifiableDeep]）。
Map<String, dynamic> _nest(Map<String, dynamic> flat) {
  final root = <String, dynamic>{};
  for (final entry in flat.entries) {
    final segments = entry.key.split('.');
    var node = root;
    for (var i = 0; i < segments.length - 1; i++) {
      node = node.putIfAbsent(
        segments[i],
        () => <String, dynamic>{},
      ) as Map<String, dynamic>;
    }
    node[segments.last] = entry.value;
  }
  return root;
}

/// 递归：每层 key 按字典序重建，并逐层 Map.unmodifiable（A16 / P7）。
Map<String, dynamic> _sortedUnmodifiableDeep(Map<String, dynamic> map) {
  final result = <String, dynamic>{};
  final keys = map.keys.toList()..sort();
  for (final key in keys) {
    final value = map[key];
    result[key] = value is Map<String, dynamic>
        ? _sortedUnmodifiableDeep(value)
        : value;
  }
  return Map<String, dynamic>.unmodifiable(result);
}
