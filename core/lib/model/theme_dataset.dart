// 包：persistence_core  文件：core/lib/model/theme_dataset.dart

import 'package:persistence_core/model/dataset/dataset_descriptor.dart';
import 'package:persistence_core/model/dataset/dataset_manifest.dart';
import 'package:persistence_core/model/dataset/dataset_materializer.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/theme_storage_policies.dart';

/// 主题数据集的 XRAP 声明。
///
/// 【接入 XRAP 的全部动作】构造 DatasetDescriptor 并调 DatasetRegistry.register
/// （`dataset_descriptor.dart:3-4`）。
///
/// 【为什么 materializer 工厂从外部传入】契约层（`core/lib/model/`）**不得依赖**
/// reference 层（`core/lib/reference/`）—— 否则 A3「契约层零实现」与分层方向双双被破坏。
/// 把工厂做成入参后，`InMemoryThemeMaterializer` 与共享 `InMemoryThemeTokenStore`
/// 的知识全部留在 reference 层，契约层只做原样透传（§4.5 第 2 步）。
DatasetDescriptor themeDatasetDescriptor({
  required DatasetMaterializer Function() materializer,
}) =>
    DatasetDescriptor(
      datasetId: themeDatasetId, // 'theme.package'
      appSchemaRevision: kThemeAppSchemaRevision, // 本 app 的落地结构版本
      policy: officialThemePolicy,
      bundledManifest: kThemeBundledManifest, // generation 0，恒存在
      materializer: materializer, // 原样透传，契约层不认识 reference 层
    );

/// 数据集稳定标识。**不得内联字面量**（同 entityType 常量的理由）。
const themeDatasetId = 'theme.package';

/// 本 app 的主题落地结构版本。落地逻辑升级到能读更高结构时递增
/// （`dataset_descriptor.dart:20-27` 的 minSdkVersion 模型）。
const kThemeAppSchemaRevision = 1;

/// 主题内置世代（generation 0）的清单占位。
///
/// ⚠ **占位值**：sha256 / bytes / rowCount 必须是构建脚本产出的真值
/// （XRAP 安装器会比对，不符则不进 ready，不变式 I4）。
/// 真值由 BUILD-THEME 任务（构建脚本）填入，本 ACT 仅让契约编译通过。
///
/// ⚠ `final` 不是 `const` —— [publishedAtUtc] 是 DateTime，无 const 构造器。
final kThemeBundledManifest = DatasetManifest(
  datasetId: themeDatasetId,
  contentVersion: '2026-08-06', // 真值：构建日期（照 T1 geo 的 '2026-08-03'），
  // 不参与兼容判定（dataset_manifest.dart:43-45），人可读用于诊断
  // 真值来源：assets/lib/theme/default.jsonl（generation 0 内置载荷）
  minimumAppSchemaRevision: 1,
  payloadFormat: DatasetPayloadFormat.prebuilt,
  carriers: {Carrier.row},
  payloadSha256:
      'aa62ab4aaa45038a2625dc0fcf26daee616c1a7c40d00bf50ab081f15d634af1',
  // 真值：assets/lib/theme/default.jsonl 的 sha256（构建脚本产出）
  payloadBytes: 27458, // 真值：default.jsonl 字节数
  declaredRowCount: 338, // 真值：default.jsonl 行数（token 数）
  publishedAtUtc: DateTime.utc(2026, 1, 1),
);
