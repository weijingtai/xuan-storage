// 包：persistence_core  文件：core/lib/model/theme_value_types.dart

/// 本地可用的主题（XRAP 活跃世代落地物 + generation 0 内置世代）。
///
/// 【S5a 不定义安装态类型】安装态（安装时刻 / 占用字节 / 是否内置 /
/// publisher）全部归 XRAP —— 它由 DatasetInstaller 维护世代与状态机
/// （`dataset_installer.dart:188-192`）。S5a 只需要「本地有哪些主题可选」。
///
/// 【不含"可下载但未安装"的主题】那是 XRAP catalog 的职责，不在本端口。
final class LocalTheme {
  /// 主题 id（对应 defaultThemeId 的取值）。
  final String id;

  /// 展示名。
  final String displayName;

  /// 作者。
  final String author;

  /// 该主题落地物所在的 XRAP 世代号。generation 0 即 bundled 内置世代。
  final int generation;

  /// 构造一条本地可用主题。
  const LocalTheme({
    required this.id,
    required this.displayName,
    required this.author,
    required this.generation,
  });
}

/// 一条用户覆盖记录。
final class OverrideEntry {
  /// 覆盖的值。
  final dynamic value;

  /// 来源（手动编辑 / 取自某个主题包）。
  final OverrideOrigin origin;

  /// 写入时刻（UTC）。
  final DateTime updatedAtUtc;

  const OverrideEntry({
    required this.value,
    required this.origin,
    required this.updatedAtUtc,
  });
}

/// 覆盖来源。
///
/// 【存值不存引用】取自 B 包的覆盖记录的是**值快照**，不是对 B 包的引用。
/// 因此 B 包卸载后用户的设计不受影响，B 包升级也不会悄悄改变用户看到的样子。
/// 本字段仅用于诊断与"B 有新版本，是否更新这部分"的提示。
final class OverrideOrigin {
  /// 用户手动编辑。
  static const manual = OverrideOrigin._('manual', null, null);

  /// 来源类型标识。
  final String kind;

  /// 取值来源的主题包 id（manual 时为 null）。
  final String? sourceThemeId;

  /// 取值时该主题包的版本（manual 时为 null）。
  final String? sourceThemeVersion;

  const OverrideOrigin._(this.kind, this.sourceThemeId, this.sourceThemeVersion);

  /// 取自某个主题包的某个版本。
  const OverrideOrigin.fromPackage({
    required String themeId,
    required String version,
  }) : this._('package', themeId, version);
}
