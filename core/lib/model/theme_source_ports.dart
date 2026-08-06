// 包：persistence_core  文件：core/lib/model/theme_source_ports.dart

import 'package:persistence_core/model/theme_value_types.dart';

// §5.5.2：S5a 只保留一个注入端口（remote/package/signature 三类归 XRAP）。

/// 主题 token 与用户覆盖的本地读取端口。
///
/// 【为什么需要它】P3/P4 要验证的正是"启动路径**没有**发生 IO"，
/// 而"没有发生"只能通过可观测的抽象边界证明。生产实现读 XRAP 活跃世代
/// 的落地物 + drift 覆盖表；测试注入内存 fixture。
///
/// 【bundled 的来源】v4 裁定 4：`bundledManifest` 恒存在、冷启动零网络
/// （`dataset_source.dart:61`）。bundled token 由装配层从 XRAP 的
/// generation 0 落地物读出后注入，**S5a 不跨仓库去 theme 包找文件**
/// （stop condition #2）。
abstract interface class ThemeLocalReader {
  /// 读取 bundled（XRAP generation 0）的**已解析、已扁平化** token。
  ///
  /// 返回值不得为 null —— bundled 是最后兜底层，恒存在（XRAP 协议 P5）。
  Future<Map<String, dynamic>> readBundledTokens();

  /// 读取 XRAP **当前活跃世代**的主题 token；无已装主题时返回 null。
  ///
  /// 【不触发安装】本方法只读已翻转到活跃指针的落地物。
  /// 安装与指针翻转由 `DatasetInstaller` 负责，S5a 不介入。
  Future<Map<String, dynamic>?> readActiveThemeTokens(String themeId);

  /// 读取用户覆盖差量（private 层，XRAP 硬拒的那部分）。
  Future<Map<String, OverrideEntry>> readOverrides();
}
