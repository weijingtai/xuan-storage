// 包：persistence_core  文件：core/lib/model/theme_token_types.dart

import 'package:persistence_core/model/theme_resolution.dart';

/// 一份已合并、源无关的主题 token 集合。
///
/// 【为什么不直接返回 theme 包的 XuanThemeSet】依赖方向：persistence_* 不得
/// 依赖 theme（§2.2）。本类型是中立形状，由装配层适配成 theme 能消费的结构。
///
/// 形状与 xuan_config 的 ConfigResult 对齐（light/dark 各含 components/chart/
/// semantic），因此装配层的适配是机械映射，不含业务逻辑。
final class ThemeTokenSet {
  /// 亮色模式 token。
  final ThemeTokenSection light;

  /// 暗色模式 token。
  final ThemeTokenSection dark;

  /// 溯源信息：这份结果由哪些层合并而来。
  final ThemeResolution resolution;

  const ThemeTokenSet({
    required this.light,
    required this.dark,
    required this.resolution,
  });
}

/// 单 brightness 下的 token 分区。值保持 Map 形态（源无关），
/// 由装配层交给 theme 包做 typed 解析 —— 本层不解析业务语义。
final class ThemeTokenSection {
  /// 组件 token：组件 id → 原始 Map。
  final Map<String, dynamic> components;

  /// 图表 token，可空。
  final Map<String, dynamic>? chart;

  /// 语义 token（五行色板等），可空。
  final Map<String, dynamic>? semantic;

  const ThemeTokenSection({
    required this.components,
    this.chart,
    this.semantic,
  });
}
