// 包：persistence_core  文件：core/lib/reference/theme_assembly.dart
// 【reference】§4.5 装配数据流：把 XRAP 的落地产物接到 S5a 读路径上。
// 五步链的第 1/2/4 步在本文件；第 3 步在 XRAP DatasetInstaller，
// 第 5 步在 InMemoryThemeResourceStore（它对 tokenStore/installer 一无所知）。

import 'package:persistence_core/model/dataset/dataset_installer.dart';
import 'package:persistence_core/model/theme_dataset.dart';
import 'package:persistence_core/model/theme_module_registry.dart';
import 'package:persistence_core/model/theme_resource_store.dart';
import 'package:persistence_core/model/theme_source_ports.dart';
import 'package:persistence_core/model/theme_value_types.dart';
import 'package:persistence_core/reference/in_memory_theme_materializer.dart';
import 'package:persistence_core/reference/in_memory_theme_resource_store.dart';

/// 把 XRAP 的落地产物接到 S5a 读路径上的 reference reader。
///
/// 【它是 §4.5 第 4 步的落地形态】生产实现（drift）换掉本类即可，
/// `InMemoryThemeResourceStore` 一行不改 —— 这正是端口存在的意义。
final class XrapThemeLocalReader implements ThemeLocalReader {
  /// 构造。三个入参分别对应三个读方法的数据来源。
  ///
  /// - [tokenStore]: §4.5 第 1 步创建的那一个，与 materializer 工厂捕获的是**同一个实例**；
  /// - [installer]: XRAP 安装器。**只用来读活跃指针**（`active`），
  ///   reader 不得调 `ensureInstalled` / `checkForUpdate`（P4 会断言）；
  /// - [initialOverrides]: 用户覆盖差量的初始快照。生产实现改为查 drift 覆盖表。
  XrapThemeLocalReader({
    required InMemoryThemeTokenStore tokenStore,
    required DatasetInstaller installer,
    required Map<String, OverrideEntry> initialOverrides,
  })  : _tokens = tokenStore,
        _installer = installer,
        _initialOverrides = Map<String, OverrideEntry>.unmodifiable(
          initialOverrides,
        );

  /// §4.5 第 1 步创建的共享落地物 store。
  final InMemoryThemeTokenStore _tokens;

  /// XRAP 安装器。只读活跃指针（`active`）。
  final DatasetInstaller _installer;

  /// 用户覆盖差量的初始快照（只读视图）。
  final Map<String, OverrideEntry> _initialOverrides;

  /// bundled = XRAP 的 **generation 0**（`dataset_descriptor.dart:33-37`：
  /// 内置世代恒存在，且作为 generation 0 参与统一机制）。
  ///
  /// 实现：`_tokens.tokensOf(0)`；为 null 抛 `StateError`（fail closed）——
  /// 说明装配漏了第 3 步的 `ensureInstalled`，**不得静默返回空 Map**
  /// （空 Map 会让三层合并全部落空却全绿）。
  @override
  Future<Map<String, dynamic>> readBundledTokens() async {
    final tokens = _tokens.tokensOf(0);
    if (tokens == null) {
      throw StateError(
        'generation 0 未落地：装配期漏调 ensureInstalled（§4.5 第 3 步）',
      );
    }
    return tokens;
  }

  /// 活跃世代的 token。**六步，无分支歧义**：
  ///   1. `themeId != themeDatasetId` → 抛 `ArgumentError`。
  ///      reference 阶段主题包与 XRAP 数据集一一对应，themeId 即 datasetId；
  ///      「多主题包并存」需要多个 datasetId，属 THEME-DRIFT，不在 S5a。
  ///   2. `final active = await installer.active(themeDatasetId);`
  ///   3. `active == null || !active.isUsable` → 返回 null（无 ready 世代）
  ///   4. `active.generation == 0` → 返回 null
  ///      （第 0 代是 bundled，由 readBundledTokens 承担，不重复算作"已装主题包"）
  ///   5. `final t = _tokens.tokensOf(active.generation);`
  ///      `t == null` → 返回 null（指针指向的世代无落地物：结构性不一致，
  ///      fail closed 交给 bundled 兜底，与 P6 同一条降级路径）
  ///   6. 返回 `t`
  @override
  Future<Map<String, dynamic>?> readActiveThemeTokens(String themeId) async {
    if (themeId != themeDatasetId) {
      throw ArgumentError(
        'reference 阶段 themeId 必须为数据集 id $themeDatasetId'
        '（多主题包并存属 THEME-DRIFT，不在 S5a）',
      );
    }
    final active = await _installer.active(themeDatasetId);
    if (active == null || !active.isUsable) return null;
    if (active.generation == 0) return null;
    final tokens = _tokens.tokensOf(active.generation);
    if (tokens == null) return null;
    return tokens;
  }

  /// 返回 [initialOverrides] 的只读视图。
  @override
  Future<Map<String, OverrideEntry>> readOverrides() async =>
      _initialOverrides;
}

/// reference 装配入口。**P4 的唯一注入点**。
///
/// 【为什么需要它】P4 要断言「启动路径不触发安装」，就必须有一个能同时看到
/// store 与 installer 的位置。生产装配在 xuan-shell 的 DI bootstrap，
/// reference 装配在这里，二者形状一致 —— 测试对装配函数编程，不对实现编程。
///
/// 【它按顺序做四件事，缺一不可】
///   1. `final tokenStore = InMemoryThemeTokenStore();`
///   2. `ThemeModuleRegistry.register(
///          themeMaterializer: () => InMemoryThemeMaterializer(tokenStore));`
///   3. `await installer.ensureInstalled(themeDatasetId);`
///      —— 保证 generation 0 已落地。该方法**不触网**（`dataset_installer.dart`：
///      「这是读路径唯一允许调用的安装方法 —— 它不触网」）。
///   4. `return InMemoryThemeResourceStore(
///          scopeUid: scopeUid,
///          localReader: XrapThemeLocalReader(
///              tokenStore: tokenStore, installer: installer,
///              initialOverrides: initialOverrides));`
///
/// ⚠️ **本函数不接收 `localReader`**。reader 由它自己按第 4 步造 ——
/// 若把 reader 做成入参，P4 就只在测自己传进去的假货，证明不了生产链路。
/// P3-b / P6 需要注入探针 reader 时，**直接构造 `InMemoryThemeResourceStore`**
/// （§5.5.4），不走装配函数。
Future<ThemeResourceStore> assembleThemeStore({
  required String scopeUid,
  required DatasetInstaller installer,
  required Map<String, OverrideEntry> initialOverrides,
}) async {
  // 第 1 步：全进程一个共享落地物 store（工厂闭包捕获它，§4.5）。
  final tokenStore = InMemoryThemeTokenStore();
  // 第 2 步：注册策略 + XRAP 数据集，materializer 工厂捕获 tokenStore。
  ThemeModuleRegistry.register(
    themeMaterializer: () => InMemoryThemeMaterializer(tokenStore),
  );
  // 第 3 步：确保 generation 0 已落地（不触网；幂等，已 ready 直接返回）。
  await installer.ensureInstalled(themeDatasetId);
  // 第 4 步：把 XRAP 落地产物接到 store 的唯一本地读取端口上。
  return InMemoryThemeResourceStore(
    scopeUid: scopeUid,
    localReader: XrapThemeLocalReader(
      tokenStore: tokenStore,
      installer: installer,
      initialOverrides: initialOverrides,
    ),
  );
}
