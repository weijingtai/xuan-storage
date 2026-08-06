// 包：persistence_core  文件：core/lib/model/theme_module_registry.dart

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:persistence_core/model/dataset/dataset_materializer.dart';
import 'package:persistence_core/model/dataset/dataset_registry.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/theme_dataset.dart';
import 'package:persistence_core/model/theme_storage_policies.dart';

/// 主题模块的策略注册入口。
///
/// 【调用时机】由装配层（xuan-shell 的 DI bootstrap）在**构造任何
/// ThemeResourceStore 之前**调用一次。
///
/// 【幂等】StoragePolicyRegistry.register 对重复 entityType 抛 StateError
/// （storage_policy_registry.dart:38-42），而热重启 / 测试会重复进入装配期。
/// 因此本函数用注册标志保证「只注册一次」，重复调用直接返回。
///
/// 【为何不用 try-catch 吞 StateError】那会掩盖「别的模块抢注了同名
/// entityType」这一真实错误。标志位只防自己重入，不防冲突。
abstract final class ThemeModuleRegistry {
  static bool _registered = false;

  /// 注册主题模块：三条存储策略 + 一个 XRAP 数据集。幂等。
  ///
  /// [themeMaterializer] 是**落地器工厂**，由装配层给出（§4.5 第 2 步）。
  /// 契约层不认识 reference 层的 `InMemoryThemeMaterializer`，故只透传不构造。
  static void register({
    required DatasetMaterializer Function() themeMaterializer,
  }) {
    if (_registered) return;
    // 1) S1a 策略注册
    StoragePolicyRegistry.register(themePackageEntityType, officialThemePolicy);
    StoragePolicyRegistry.register(themeOverrideEntityType, themeOverridePolicy);
    StoragePolicyRegistry.register(themeSelectionEntityType, themeSelectionPolicy);
    // 2) XRAP 数据集注册（§5.6.2）。注册期会校验 publisher == official 等
    //    不变式，失败抛 DatasetRegistrationError。
    DatasetRegistry.register(
      themeDatasetDescriptor(materializer: themeMaterializer),
    );
    _registered = true;
  }

  /// 仅测试用：重置标志，配合 StoragePolicyRegistry.clearForTesting()
  /// 与 DatasetRegistry 的对应清理方法。
  @visibleForTesting
  static void resetForTesting() => _registered = false;
}
