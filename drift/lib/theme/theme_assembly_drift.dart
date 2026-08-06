// 包：persistence_drift  文件：drift/lib/theme/theme_assembly_drift.dart
// THEME-DRIFT：drift 版装配入口（照 core/lib/reference/theme_assembly.dart 的
// assembleThemeStore 四步，并存不替换 —— design.md D7）。
//
// 【它按顺序做四件事，缺一不可】：
//   1. `final tokenStore = DriftThemeTokenStore(db);`
//   2. `ThemeModuleRegistry.register(
//          themeMaterializer: () => DriftThemeMaterializer(tokenStore));`
//   3. `await installer.ensureInstalled(themeDatasetId);`
//      —— 保证 generation 0 已落地。该方法**不触网**。
//   4. `return DriftThemeResourceStore(...)`，reader 用 DriftThemeLocalReader
//      把 XRAP 落地产物接到 S5a 读路径上。
//
// ⚠️ 与内存版一样**不接收 localReader**：reader 由本函数按第 4 步自己造 ——
// 若把 reader 做成入参，测试就只在测自己传进去的假货。需要注入探针 reader
// 的用例直接构造 `DriftThemeResourceStore`，不走本函数（照 P3-b/P6 的做法）。

import 'package:persistence_core/model/dataset/dataset_installer.dart';
import 'package:persistence_core/model/dataset/dataset_source.dart';
import 'package:persistence_core/model/theme_dataset.dart' show themeDatasetId;
import 'package:persistence_core/model/theme_module_registry.dart';
import 'package:persistence_core/model/theme_resource_store.dart';

import 'drift_theme_local_reader.dart';
import 'drift_theme_materializer.dart';
import 'drift_theme_resource_store.dart';
import 'drift_theme_token_store.dart';
import 'theme_database.dart';

/// drift 版装配入口（D7：与内存版 `assembleThemeStore` 并存，不替换）。
///
/// [bundledSource] 传给生产侧的 [DriftThemeDatasetInstaller]（本函数接收的
/// [installer] 即由调用方用它构造），测试可传 null 并注入 fake installer。
Future<ThemeResourceStore> assembleThemeStoreDrift({
  required String scopeUid,
  required ThemeDatabase db,
  required DatasetInstaller installer,
  required DatasetSource? bundledSource,
}) async {
  // 第 1 步：全进程一个共享落地物 store（工厂闭包捕获它，§4.5）。
  final tokenStore = DriftThemeTokenStore(db);
  // 第 2 步：注册策略 + XRAP 数据集，materializer 工厂捕获 tokenStore。
  ThemeModuleRegistry.register(
    themeMaterializer: () => DriftThemeMaterializer(tokenStore),
  );
  // 第 3 步：确保 generation 0 已落地（不触网；幂等，已 ready 直接返回）。
  await installer.ensureInstalled(themeDatasetId);
  // 第 4 步：把 XRAP 落地产物接到 store 的唯一本地读取端口上。
  return DriftThemeResourceStore(
    scopeUid: scopeUid,
    db: db,
    localReader: DriftThemeLocalReader(
      db: db,
      tokenStore: tokenStore,
      installer: installer,
      scopeUid: scopeUid,
    ),
  );
}
