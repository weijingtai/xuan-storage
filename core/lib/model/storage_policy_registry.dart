/// 全局策略注册表（设计稿 §2.3.1）。
///
/// §2.4 的顶层 const 策略声明无法被运行时遍历，因此策略必须显式注册，
/// 契约测试与推送过滤都消费这张表。推送侧按 entityType 查表做通道过滤，
/// 查不到即 fail closed（拒绝推送）。
library;

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'storage_classification.dart';
import 'storage_policy.dart';

/// 存储策略注册表。
///
/// 功能说明：
/// - 各模块 registry 在装配期调用 [register] 注册本模块实体类型的策略。
/// - 推送过滤（S1b 的 peekBatch(channel)）与契约测试遍历消费 [all] / [lookup]。
///
/// 注册期不变式（设计稿 §2.3.2，全部在 [register] 内抛 StateError）：
/// - 不变式 #4：resource 策略当前阶段 publisher 必须为 official（§9.1）。
/// - 不变式 #5：sources 非空 当且仅当 visibility 属于 resource 或 control。
///   结构性不变式 #1/#2/#3 由 storage_policy.dart 的参数表保证，无需重复校验。
abstract final class StoragePolicyRegistry {
  static final Map<String, StoragePolicy> _byEntityType = {};

  /// 注册一个实体类型的存储策略。
  ///
  /// 参数说明：
  /// - [entityType]: 实体类型标识（如 'xiang_reading' / 'playground_post'）。
  /// - [policy]: 该实体类型的存储策略。
  ///
  /// 约束：
  /// - 同一 [entityType] 重复注册抛 [StateError]。
  /// - resource 策略 publisher 非 official 抛 [StateError]（不变式 #4）。
  /// - sources 非空性不满足「resource 或 control 必非空、其余必为空」时
  ///   抛 [StateError]（不变式 #5）。新模块注册错了在装配期立刻炸。
  static void register(String entityType, StoragePolicy policy) {
    if (_byEntityType.containsKey(entityType)) {
      throw StateError(
        'entityType "$entityType" 已注册，禁止重复注册',
      );
    }
    if (policy.visibility == DataVisibility.resource &&
        policy.publisher != Publisher.official) {
      throw StateError(
        'resource 策略当前阶段 publisher 必须为 official（§2.3.2 不变式 #4），'
        '收到: ${policy.publisher}',
      );
    }
    final sourcesNonEmpty = policy.sources.isNotEmpty;
    final isResourceOrControl = policy.visibility == DataVisibility.resource ||
        policy.visibility == DataVisibility.control;
    if (sourcesNonEmpty != isResourceOrControl) {
      throw StateError(
        'sources 非空当且仅当 visibility 属于 resource 或 control'
        '（§2.3.2 不变式 #5），收到: visibility=${policy.visibility}, '
        'sources=$sourcesNonEmpty',
      );
    }
    _byEntityType[entityType] = policy;
  }

  /// 查询一个实体类型的存储策略。
  ///
  /// 返回值：
  /// - 未注册的 [entityType] 返回 null —— 调用方必须 fail closed（拒绝推送），
  ///   不得默认放行。
  static StoragePolicy? lookup(String entityType) => _byEntityType[entityType];

  /// 全部已注册策略（entityType → policy）。
  ///
  /// 用途：
  /// - 契约测试遍历用（§2.3.2 不变式清单的运行时验证手段）。
  static Map<String, StoragePolicy> get all =>
      Map.unmodifiable(_byEntityType);

  /// 清空注册表。
  ///
  /// 用途：
  /// - 仅测试用，保证测试之间互不污染。
  @visibleForTesting
  static void clearForTesting() {
    _byEntityType.clear();
  }
}
