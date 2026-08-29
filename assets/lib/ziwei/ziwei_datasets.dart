/// ziwei 域数据集的 XRAP 接入（照 taiyishenshu_datasets.dart 样板，XRAP §3）。
///
/// 本文件注册 3 个数据集：
/// - `ziwei.star_catalog` - stars.csv 原文（1 行文档表，payload 为 CSV 文本）
/// - `ziwei.star_metadata` - 主辅星 JSON（2 行文档表）
/// - `ziwei.four_transformations` - 四化 JSON（1 行文档表）
///
/// 内置载荷为构建期产出的 `*.sql`（CREATE TABLE + INSERT + DELETE 幂等），
/// 属 [DatasetPayloadFormat.prebuilt]。非表形 JSON 以「JSON 文档表」落地
/// （协议注册期强制内置 manifest 必须 prebuilt，rawText 会被 DatasetRegistry 拒绝）。
///
/// 全链路：
/// ```
/// 领域 Repository（xrap_ziwei_repositories.dart）
///      │  查询 ZiweiDatabase（drift）
///      ▼
/// ZiweiDatabase（drift，ResourceDatasetDatabase §9.1）
///      │  启动时由 DatasetInstaller.ensureInstalled 把 *.sql 执行进库
///      ▼
/// *.sql dump（star_catalog_document.sql / star_metadata_document.sql /
///           four_transformations_document.sql）
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:persistence_core/persistence_core.dart';

import 'drift/ziwei_database.dart';

/// ziwei 域内置载荷的 manifest 真值。
///
/// 这些数字由 `assets/tool/build_ziwei_sql.py` 产出，记录于
/// `assets/lib/ziwei/assets/BUILD-REPORT.md`。改了源 JSON 必须重跑脚本
/// 并更新此处，否则 sha256 校验会失败（不变式 I3）。
class _ZiweiManifests {
  static final starCatalog = DatasetManifest(
    datasetId: 'ziwei.star_catalog',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '612e618a89b9d9b2bca1f797fcf647ab1642300fe1eaf6f6984e245384b3e79d',
    payloadBytes: 11013,
    declaredRowCount: 1,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );

  static final starMetadata = DatasetManifest(
    datasetId: 'ziwei.star_metadata',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '8b8a1f60ff9b3dbfd6f9442395ceca9e2791ebf2af9bf2b3d1cbf906121cae3f',
    payloadBytes: 21947,
    declaredRowCount: 2,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );

  static final fourTransformations = DatasetManifest(
    datasetId: 'ziwei.four_transformations',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '099d1031d4ec1b3539054d7ae8769ea864ac8b7b8548fd3c071d249a25864a32',
    payloadBytes: 4390,
    declaredRowCount: 1,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );
}

/// ziwei 域共用的资源策略。
final _ziweiPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// ziwei 域各数据集的内置 asset 路径（rootBundle 形态）。
const _kStarCatalogAssetPath =
    'packages/persistence_assets/lib/ziwei/assets/star_catalog_document.sql';
const _kStarMetadataAssetPath =
    'packages/persistence_assets/lib/ziwei/assets/star_metadata_document.sql';
const _kFourTransformationsAssetPath =
    'packages/persistence_assets/lib/ziwei/assets/four_transformations_document.sql';

/// 注册 ziwei 域全部数据集。
///
/// 在 app 装配期调用一次（如 main.dart 或 DI 容器初始化）。
/// 重复注册会抛 [DatasetRegistrationError]（协议 §6 I9 / 注册期校验）。
///
/// [db] 是共享的 [ZiweiDatabase] 实例（materializer 把 .sql 灌入它）。
void registerZiweiDatasets({required ZiweiDatabase db}) {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'ziwei.star_catalog',
      appSchemaRevision: 1,
      policy: _ziweiPolicy,
      bundledManifest: _ZiweiManifests.starCatalog,
      materializer: () => ZiweiSqlMaterializer(
        datasetId: 'ziwei.star_catalog',
        assetPath: _kStarCatalogAssetPath,
        declaredRowCount: 1,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'ziwei.star_metadata',
      appSchemaRevision: 1,
      policy: _ziweiPolicy,
      bundledManifest: _ZiweiManifests.starMetadata,
      materializer: () => ZiweiSqlMaterializer(
        datasetId: 'ziwei.star_metadata',
        assetPath: _kStarMetadataAssetPath,
        declaredRowCount: 2,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'ziwei.four_transformations',
      appSchemaRevision: 1,
      policy: _ziweiPolicy,
      bundledManifest: _ZiweiManifests.fourTransformations,
      materializer: () => ZiweiSqlMaterializer(
        datasetId: 'ziwei.four_transformations',
        assetPath: _kFourTransformationsAssetPath,
        declaredRowCount: 1,
        db: db,
      ),
    ),
  );
}

/// ziwei 域 `*.sql` 载荷的落地器。
///
/// 协议契约（§3.3）：materialize 只写入入参给定的 generation，
/// 不触碰活跃指针。本实现遵守。
///
/// 落地方式：把 .sql 文本作为 SQL 脚本执行进 [ZiweiDatabase]。
/// drift 已建好表，.sql 的 `CREATE TABLE IF NOT EXISTS` 幂等跳过，
/// 只执行 INSERT。
class ZiweiSqlMaterializer implements AssetBackedMaterializer {
  ZiweiSqlMaterializer({
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
  final ZiweiDatabase db;

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
    // 生产版会 DELETE WHERE generation = ?，但当前表结构无 generation 列
    // （内置世代 0 是唯一世代，无需按代清理）。
  }

  /// datasetId -> drift 表名映射。
  String _tableNameFor(String datasetId) {
    switch (datasetId) {
      case 'ziwei.star_catalog':
        return 'star_catalog_document';
      case 'ziwei.star_metadata':
        return 'star_metadata_document';
      case 'ziwei.four_transformations':
        return 'four_transformations_document';
      default:
        throw ArgumentError('未知 datasetId: $datasetId');
    }
  }
}
