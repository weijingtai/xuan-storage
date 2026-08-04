/// XRAP 数据集注册表与装配期声明（协议 §3）。
///
/// 【本文件是协议的入口】—— 一个模块「接入 XRAP」的全部动作，
/// 就是在装配期构造一个 [DatasetDescriptor] 并调用 [DatasetRegistry.register]。
///
/// [DatasetDescriptor] 本身定义在 dataset_descriptor.dart。
library;

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../storage_classification.dart';
import 'dataset_descriptor.dart';
import 'dataset_error.dart';
import 'dataset_manifest.dart';

/// 全局数据集注册表（协议 §3）。
///
/// 与 S1a 的 `StoragePolicyRegistry` 同形制：装配期显式注册，
/// 注册期强制不变式并抛异常，契约测试遍历 [all]。
///
/// 【为什么不用顶层 const】—— const 声明无法被运行时遍历，
/// 协议一致性门禁与契约测试都需要遍历（《总纲》§2.3.1 同一理由）。
abstract final class DatasetRegistry {
  static final Map<String, DatasetDescriptor> _byId = {};

  /// 注册一个数据集。
  ///
  /// 注册期校验（任一不满足抛 [DatasetRegistrationError]）：
  /// - 同一 datasetId 重复注册；
  /// - descriptor.datasetId 与 bundledManifest.datasetId 不一致；
  /// - policy 的 visibility 不是 resource（不变式 I9）；
  /// - policy 的 publisher 不是 official（不变式 I9，当前阶段约束）；
  /// - bundledManifest.carriers 不是 policy.carriers 的子集（不变式 I8）；
  /// - supportedSchemaRevisions 为空集；
  /// - bundledManifest.schemaRevision 不在 supportedSchemaRevisions 内
  ///   （自己都装不进自己的内置世代，属装配错误）；
  /// - carriers 含 row 但 bundledManifest.declaredRowCount 为 null。
  static void register(DatasetDescriptor d) {
    if (_byId.containsKey(d.datasetId)) {
      throw DatasetRegistrationError(
        datasetId: d.datasetId,
        violation: '该 datasetId 已注册',
        fix: '同一数据集只能注册一次；检查是否有重复的装配期调用。',
      );
    }
    if (d.datasetId != d.bundledManifest.datasetId) {
      throw DatasetRegistrationError(
        datasetId: d.datasetId,
        violation:
            'descriptor.datasetId 与 bundledManifest.datasetId 不一致'
            '（后者为 "${d.bundledManifest.datasetId}"）',
        fix: '两处 datasetId 必须逐字相同。',
      );
    }
    if (d.policy.visibility != DataVisibility.resource) {
      throw DatasetRegistrationError(
        datasetId: d.datasetId,
        violation: 'policy 的 visibility 是 ${d.policy.visibility}，不是 resource',
        fix: '数据集必须用 StoragePolicy.resource 声明（协议不变式 I9）。',
      );
    }
    if (d.policy.publisher != Publisher.official) {
      throw DatasetRegistrationError(
        datasetId: d.datasetId,
        violation: 'policy 的 publisher 是 ${d.policy.publisher}，不是 official',
        fix: '当前阶段资源一律官方下发（《总纲》§9.1）。开放 UGC 时才放宽。',
      );
    }
    if (!d.bundledManifest.carriers.every(d.policy.carriers.contains)) {
      throw DatasetRegistrationError(
        datasetId: d.datasetId,
        violation:
            'bundledManifest.carriers ${d.bundledManifest.carriers} '
            '不是 policy.carriers ${d.policy.carriers} 的子集',
        fix: '清单声明的载体不得超出策略允许的载体（协议不变式 I8）。',
      );
    }
    if (d.bundledManifest.payloadFormat != DatasetPayloadFormat.prebuilt) {
      throw DatasetRegistrationError(
        datasetId: d.datasetId,
        violation:
            '内置世代的 payloadFormat 是 ${d.bundledManifest.payloadFormat.name}，'
            '不是 prebuilt',
        fix: '内置载荷必须是构建期做好的落地形态，设备上零解析（协议 §4.2）。'
            '把原始 JSON/CSV 的解析移到构建期脚本里。',
      );
    }
    if (!d.supports(d.bundledManifest)) {
      throw DatasetRegistrationError(
        datasetId: d.datasetId,
        violation:
            '内置世代要求 app 结构版本 >= '
            '${d.bundledManifest.minimumAppSchemaRevision}，'
            '但本 app 声明为 ${d.appSchemaRevision}',
        fix: '本 app 连自己的内置世代都读不了，属装配错误。',
      );
    }
    if (d.bundledManifest.requiresRowCountCheck &&
        d.bundledManifest.declaredRowCount == null) {
      throw DatasetRegistrationError(
        datasetId: d.datasetId,
        violation: 'carriers 含 row 但 declaredRowCount 为 null',
        fix: 'row 类数据集必须声明行数，否则落地后无法自检（协议不变式 I4）。',
      );
    }
    _byId[d.datasetId] = d;
  }

  /// 查询一个数据集的声明。
  ///
  /// 未注册返回 null —— 调用方必须 fail closed（拒绝安装与读取），
  /// 不得默认放行（与 StoragePolicyRegistry.lookup 同约定）。
  static DatasetDescriptor? lookup(String datasetId) => _byId[datasetId];

  /// 全部已注册数据集。协议一致性门禁与契约测试遍历用。
  static Map<String, DatasetDescriptor> get all => Map.unmodifiable(_byId);

  /// 清空注册表。**仅测试用**，保证测试之间互不污染。
  @visibleForTesting
  static void clearForTesting() => _byId.clear();
}
