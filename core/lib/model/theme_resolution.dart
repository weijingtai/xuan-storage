// 包：persistence_core  文件：core/lib/model/theme_resolution.dart

/// 一次主题解析的完整溯源。
///
/// 【为什么必须有】S5c 的 A11 验收标准要求「任一配置值可回答来自哪个 sourceId /
/// 什么 version / 何时拉取」。主题是同一类问题：用户报"我的主题不对"时，
/// 必须能回答这份 token 由哪些层合成。
final class ThemeResolution {
  /// 生效的主题包 id；未安装任何包时为 null（纯 bundled）。
  final String? activeThemeId;

  /// 生效主题包的版本；同上可为 null。
  final String? activeThemeVersion;

  /// 主题 id 的来源：用户显式选择 / 官方下发 / 内置默认。
  final ThemeSelectionOrigin selectionOrigin;

  /// 参与合并的层，按优先级从高到低。
  final List<ThemeLayerInfo> layers;

  /// 本次解析时刻（UTC）。
  final DateTime resolvedAtUtc;

  /// 已失效的覆盖（指向当前主题包不存在的 token 路径）。
  /// 【不静默丢弃】用户的创作不得无声消失，UI 据此提示。
  final List<String> orphanedOverrideKeys;

  const ThemeResolution({
    required this.activeThemeId,
    required this.activeThemeVersion,
    required this.selectionOrigin,
    required this.layers,
    required this.resolvedAtUtc,
    this.orphanedOverrideKeys = const [],
  });
}

/// 主题 id 从哪来。决定"用户选过没有"，进而决定官方下发能否覆盖。
enum ThemeSelectionOrigin {
  /// 用户显式选择过（存于 private 层，优先级最高）。
  userSelected,

  /// xuan_config 下发的 defaultThemeId（用户未选过时生效）。
  officialDefault,

  /// 两者都拿不到，回退代码内置默认。
  bundledFallback,
}

/// 参与合并的一层。
final class ThemeLayerInfo {
  /// 层类型。
  final ThemeLayerKind kind;

  /// 该层来源标识（主题包 id / 'bundled' / 'user_override'）。
  final String sourceId;

  /// 该层贡献了多少个 token key（诊断用）。
  final int contributedKeyCount;

  const ThemeLayerInfo({
    required this.kind,
    required this.sourceId,
    required this.contributedKeyCount,
  });
}

/// 三层模型的层类型，优先级从高到低。
enum ThemeLayerKind {
  /// 用户覆盖差量（private，可同步）。
  userOverride,

  /// 已安装的主题包（resource，只读）。
  installedPackage,

  /// 编译进 app 的默认主题（bundled）。
  bundled,
}
