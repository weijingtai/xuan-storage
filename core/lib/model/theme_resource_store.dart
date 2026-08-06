// 包：persistence_core  文件：core/lib/model/theme_resource_store.dart

import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/theme_token_types.dart';
import 'package:persistence_core/model/theme_value_types.dart';

/// 主题资源的读写门面。
///
/// 【设计要点 · 读写不对称】（§2.5）
/// - 读 [resolve]：返回**合并后**的完整结果；
/// - 写 [applyOverrides] / [removeOverrides]：**只作用于用户覆盖层**。
/// 二者不是逆运算。切勿把 resolve 的结果整份写回。
///
/// 【设计要点 · 源无关】调用方不感知数据来自 bundled asset、已装主题包、
/// drift、还是远端下载 —— 对齐总纲 §2.1:140「Repository 必须对来源无感」。
///
/// 通用约定（§3.6）：失败抛 StorageError 子类，不用 null 表达失败；
/// 可能超过 1 秒的方法接受 CancellationToken。
abstract interface class ThemeResourceStore {
  /// 作用域 uid（多账号隔离）。
  String get scopeUid;

  // ── 读 ──

  /// 解析当前生效主题：三层合并（override > 已装包 > bundled），逐 key 取第一命中。
  ///
  /// 【性能硬约束】本方法**不得发起任何网络请求、不得触发 XRAP 安装流程**。
  /// 它只读本地已就绪的数据（XRAP 已翻转到活跃世代的落地物 + 用户覆盖层）。
  /// 详见 §7 启动路径预算。
  ///
  /// 【幂等与缓存】相同输入（活跃世代号 + 覆盖层版本）连续调用必须返回
  /// `identical` 的实例，以便 `XuanThemeScope.updateShouldNotify` 的深比较
  /// 被 identical 短路（§7.2）。
  Future<ThemeTokenSet> resolve({CancellationToken? cancel});

  /// 当前生效主题的解析结果流。覆盖层变更、主题切换、
  /// **XRAP 活跃指针翻转**时推送新值。
  ///
  /// 【为什么是 Stream】XRAP 安装完成后翻转活跃指针是异步事件，
  /// UI 需要被通知而非轮询 —— 这是"安装不阻塞启动"（§7.3）的落地形式。
  Stream<ThemeTokenSet> watchResolved();

  /// 本地可用的主题清单。
  ///
  /// 【数据来源】XRAP 的活跃世代落地物 + bundled 世代（generation 0）。
  /// **不含"可下载但未安装"的主题** —— 那是 XRAP catalog 的职责，不在本端口。
  Future<List<LocalTheme>> listLocalThemes();

  // ── 写 · 主题选择 ──

  /// 用户显式选择主题。写入 private 层，跨设备同步。
  ///
  /// 选择后 [ThemeResolution.selectionOrigin] 变为 userSelected，
  /// 此后 xuan_config 下发的 defaultThemeId **不再覆盖**用户的选择。
  ///
  /// [themeId] 必须在 [listLocalThemes] 中，否则抛 StorageError
  /// （调用方应先经 XRAP 的 `DatasetInstaller` 安装）。
  Future<void> selectTheme(String themeId);

  /// 清除用户的主题选择，回到跟随官方下发。
  Future<void> clearThemeSelection();

  // ── 写 · 用户覆盖层（§2.6）──

  /// 批量应用覆盖差量。**原子提交**：要么全成，要么全不成。
  ///
  /// 参数说明：
  /// - [patch]: token 路径 → 值。路径形如
  ///   `light.components.four_zhu_card.shadow.color`（含 brightness 前缀，
  ///   light/dark 完全独立 —— 见 §6.3）。
  /// - [origin]: 该覆盖的来源，用于诊断与"B 包有新版本要不要更新这部分"的提示。
  ///
  /// 【只存差量】未出现在 [patch] 中的 key 不受影响，不会被清除（§2.4）。
  /// 【只作用于用户覆盖层】§2.5 读写不对称：写不碰主题包与 bundled。
  /// 【幂等】相同 patch 重复应用结果一致。
  Future<void> applyOverrides({
    required Map<String, dynamic> patch,
    required OverrideOrigin origin,
  });

  /// 删除指定覆盖，恢复到下层（已装包 → bundled）。
  ///
  /// 【为什么需要独立方法】[applyOverrides] 无法表达删除：传 null 有歧义
  /// （"设为空值"还是"删除这条覆盖"）。"恢复全部默认" =
  /// removeOverrides(当前全部已覆盖 key)。
  ///
  /// 【只作用于用户覆盖层】仅删用户覆盖，不动主题包与 bundled。
  /// 不存在的 key 静默忽略（幂等）。
  Future<void> removeOverrides(Set<String> tokenKeys);

  /// 当前全部用户覆盖（诊断与"恢复默认"UI 用）。
  Future<Map<String, OverrideEntry>> listOverrides();
}

// ⚠️ 本端口不提供任何安装类方法（归 XRAP，§0.0 裁定 3）。
