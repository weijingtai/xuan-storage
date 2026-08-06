// 包：persistence_core  文件：core/lib/model/theme_storage_policies.dart

import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';

/// 主题数据集：resource 类。**给 XRAP 的 DatasetDescriptor 用**。
///
/// XRAP 注册期强制 publisher == official（`dataset_registry.dart:62-68`，
/// 不变式 I9），且策略的 carriers 是 manifest carriers 的上界（I8）。
const officialThemePolicy = StoragePolicy.resource(
  carriers: {Carrier.row, Carrier.blob},
  sources: {Source.bundled, Source.officialRemote},
); // publisher 默认 official

/// 用户覆盖层：private 类，当前仅 row。
/// **XRAP 装不下这个** —— publisher 非 official，注册期会被硬拒（§0.0 裁定 2）。
const themeOverridePolicy = StoragePolicy.private(
  carriers: {Carrier.row},
);

/// 用户主题选择：private 类。同样不进 XRAP。
const themeSelectionPolicy = StoragePolicy.private(
  carriers: {Carrier.row},
);

/// 主题包实体类型。**不得内联字符串字面量** —— 测试与生产必须引用同一常量，
/// 否则拼写漂移不会被编译器发现。
const themePackageEntityType = 'theme_package';

/// 用户覆盖实体类型。同上，不得内联。
const themeOverrideEntityType = 'theme_override';

/// 用户主题选择实体类型。同上，不得内联。
const themeSelectionEntityType = 'theme_selection';
