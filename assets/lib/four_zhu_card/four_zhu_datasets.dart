/// four_zhu_card 域数据集的 XRAP 接入（照 kanyu_datasets.dart 样板，XRAP §3）。
///
/// 本文件注册 3 个数据集：
/// - `four_zhu.default_template` - 默认模板（1 行文档表，entityType=layout_template）
/// - `four_zhu.market_templates` - 市场模板（4 行文档表，templateId+layoutTemplate）
/// - `four_zhu.outbox_templates` - 出站模板（4 行文档表，layout_template 形态）
///
/// 内置载荷为构建期产出的 `*.sql`（CREATE TABLE + INSERT + DELETE 幂等），
/// 属 [DatasetPayloadFormat.prebuilt]。非表形 JSON 以「JSON 文档表」落地
/// （协议注册期强制内置 manifest 必须 prebuilt，rawText 会被 DatasetRegistry 拒绝）。
///
/// 全链路：
/// ```
/// 领域 Repository（xrap_four_zhu_repositories.dart）
///      │  查询 FourZhuDatabase（drift）
///      ▼
/// FourZhuDatabase（drift，ResourceDatasetDatabase §9.1）
///      │  启动时由 DatasetInstaller.ensureInstalled 把 *.sql 执行进库
///      ▼
/// *.sql dump（default_template_document.sql / market_templates_document.sql / outbox_templates_document.sql）
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:persistence_core/persistence_core.dart';

import 'drift/four_zhu_database.dart';

/// four_zhu_card 域内置载荷的 manifest 真值。
///
/// 这些数字由 `assets/tool/build_four_zhu_sql.py` 产出，记录于
/// `assets/lib/four_zhu_card/assets/BUILD-REPORT.md`。改了源 JSON 必须重跑脚本
/// 并更新此处，否则 sha256 校验会失败（不变式 I3）。
class _FourZhuManifests {
  static final defaultTemplate = DatasetManifest(
    datasetId: 'four_zhu.default_template',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '4ac90dd9de2461ced56ee8a3a8d3690134004da56d54cafe1ef82c477df46c16',
    payloadBytes: 19101,
    declaredRowCount: 1,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );

  static final marketTemplates = DatasetManifest(
    datasetId: 'four_zhu.market_templates',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '367cfc024e1dedc137dc9f55bc591b847808dfb1d42dbf270a2cb69853496577',
    payloadBytes: 97826,
    declaredRowCount: 4,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );

  static final outboxTemplates = DatasetManifest(
    datasetId: 'four_zhu.outbox_templates',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '062c3a11697f8c67c43161d3ec16b9866a29ded13c21535c1972cdf5c707196d',
    payloadBytes: 98880,
    declaredRowCount: 4,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );
}

/// four_zhu_card 域共用的资源策略。
final _fourZhuPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// four_zhu_card 域各数据集的内置 asset 路径（rootBundle 形态）。
const _kDefaultTemplateAssetPath =
    'packages/persistence_assets/lib/four_zhu_card/assets/default_template_document.sql';
const _kMarketTemplatesAssetPath =
    'packages/persistence_assets/lib/four_zhu_card/assets/market_templates_document.sql';
const _kOutboxTemplatesAssetPath =
    'packages/persistence_assets/lib/four_zhu_card/assets/outbox_templates_document.sql';

/// 注册 four_zhu_card 域全部数据集。
///
/// 在 app 装配期调用一次（如 main.dart 或 DI 容器初始化）。
/// 重复注册会抛 [DatasetRegistrationError]（协议 §6 I9 / 注册期校验）。
///
/// [db] 是共享的 [FourZhuDatabase] 实例（materializer 把 .sql 灌入它）。
void registerFourZhuDatasets({required FourZhuDatabase db}) {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'four_zhu.default_template',
      appSchemaRevision: 1,
      policy: _fourZhuPolicy,
      bundledManifest: _FourZhuManifests.defaultTemplate,
      materializer: () => FourZhuSqlMaterializer(
        datasetId: 'four_zhu.default_template',
        assetPath: _kDefaultTemplateAssetPath,
        declaredRowCount: 1,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'four_zhu.market_templates',
      appSchemaRevision: 1,
      policy: _fourZhuPolicy,
      bundledManifest: _FourZhuManifests.marketTemplates,
      materializer: () => FourZhuSqlMaterializer(
        datasetId: 'four_zhu.market_templates',
        assetPath: _kMarketTemplatesAssetPath,
        declaredRowCount: 4,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'four_zhu.outbox_templates',
      appSchemaRevision: 1,
      policy: _fourZhuPolicy,
      bundledManifest: _FourZhuManifests.outboxTemplates,
      materializer: () => FourZhuSqlMaterializer(
        datasetId: 'four_zhu.outbox_templates',
        assetPath: _kOutboxTemplatesAssetPath,
        declaredRowCount: 4,
        db: db,
      ),
    ),
  );
}

/// four_zhu_card 域 `*.sql` 载荷的落地器。
///
/// 协议契约（§3.3）：materialize 只写入入参给定的 generation，
/// 不触碰活跃指针。本实现遵守。
///
/// 落地方式：把 .sql 文本作为 SQL 脚本执行进 [FourZhuDatabase]。
/// drift 已建好表，.sql 的 `CREATE TABLE IF NOT EXISTS` 幂等跳过，
/// 只执行 INSERT。
class FourZhuSqlMaterializer implements AssetBackedMaterializer {
  FourZhuSqlMaterializer({
    required this.datasetId,
    required this.assetPath,
    required this.declaredRowCount,
    required this.db,
  });

  @override
  final String datasetId;

  /// 内置 asset 路径（rootBundle 形态）。
  final String assetPath;
  final int declaredRowCount;
  final FourZhuDatabase db;

  @override
  Future<Uint8List> loadBundledBytes() async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  @override
  Future<MaterializeOutcome> materialize({
    required DatasetManifest manifest,
    required Stream<List<int>> payload,
    required int generation,
    CancellationToken? cancel,
  }) async {
    // 消费 payload 字节流（installer 已校验 sha256，这里只管落地）。
    final bytes = <int>[];
    await for (final chunk in payload) {
      bytes.addAll(chunk);
    }
    final sqlText = utf8.decode(bytes);

    // 执行 .sql 脚本进 drift 库。
    await db.customStatement(sqlText);

    // 统计实际落地行数（I4 自检）。
    final tableName = _tableNameFor(datasetId);
    final countResult = await db
        .customSelect('SELECT COUNT(*) AS c FROM $tableName')
        .getSingle();
    final actualRows = countResult.read<int>('c');

    return MaterializeOutcome(
      rowCount: actualRows,
      bytesOnDisk: bytes.length,
    );
  }

  @override
  Future<void> dropGeneration(int generation) async {
    // 内存版安装器不持久化，drop 无副作用。
  }

  /// datasetId -> drift 表名映射。
  String _tableNameFor(String datasetId) {
    switch (datasetId) {
      case 'four_zhu.default_template':
        return 'default_template_document';
      case 'four_zhu.market_templates':
        return 'market_templates_document';
      case 'four_zhu.outbox_templates':
        return 'outbox_templates_document';
      default:
        throw ArgumentError('未知 datasetId: $datasetId');
    }
  }
}
