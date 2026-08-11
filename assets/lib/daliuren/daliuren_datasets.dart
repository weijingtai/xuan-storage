/// daliuren 域数据集的 XRAP 接入（照 qizhengsiyu_datasets.dart 样板，XRAP §3）。
///
/// 本文件注册 4 个数据集：
/// - `daliuren.official_data` - 御定大六壬 / ju_mapper / 甲午庚牛羊阳阴盘（4 行 JSON 文档表）
/// - `daliuren.keti` - 64 课体数据（1 行 JSON 文档表）
/// - `daliuren.shen_sha` - 六神煞查询表（9 行 JSON 文档表）
/// - `daliuren.school_dataset` - 天干/地支学校数据集（1 行 JSON 文档表，人类裁定迁入）
///
/// 内置载荷为构建期产出的 `*.sql`（CREATE TABLE + INSERT，事务包裹），
/// 属 [DatasetPayloadFormat.prebuilt]。非表形 JSON 按人类裁定 2026-08-09
/// 以「JSON 文档表」落地（协议注册期强制内置 manifest 必须 prebuilt，
/// rawText 会被 DatasetRegistry 拒绝）。
///
/// 全链路：
/// ```
/// 领域 Repository（xrap_daliuren_repositories.dart）
///      │  查询 DaliurenDatabase（drift）
///      ▼
/// DaliurenDatabase（drift，ResourceDatasetDatabase §9.1）
///      │  启动时由 DatasetInstaller.ensureInstalled 把 *.sql 执行进库
///      ▼
/// *.sql dump（official_data_document.sql / keti_document.sql / ...）
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:persistence_core/persistence_core.dart';

import 'drift/daliuren_database.dart';

/// daliuren 域内置载荷的 manifest 真值。
///
/// 这些数字由 `assets/tool/build_daliuren_sql.py` 产出，记录于
/// `assets/lib/daliuren/assets/BUILD-REPORT.md`。改了源 JSON 必须重跑脚本
/// 并更新此处，否则 sha256 校验会失败（不变式 I3）。
class _DaliurenManifests {
  static final officialData = DatasetManifest(
    datasetId: 'daliuren.official_data',
    contentVersion: '2026-08-09',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        'e436e91bc8282f0cbabe7f688eaa16cd961e6790a7413a9d9e988f86daac79c5',
    payloadBytes: 7228354,
    declaredRowCount: 4,
    publishedAtUtc: DateTime.utc(2026, 8, 9),
  );

  static final keti = DatasetManifest(
    datasetId: 'daliuren.keti',
    contentVersion: '2026-08-09',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '3fb7d328a5a20e4bca9920b38e9a45499604bd444f18e7f8988decb9d20ce5e1',
    payloadBytes: 87321,
    declaredRowCount: 1,
    publishedAtUtc: DateTime.utc(2026, 8, 9),
  );

  static final shenSha = DatasetManifest(
    datasetId: 'daliuren.shen_sha',
    contentVersion: '2026-08-09',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '89522b9a705ceda29fd968e73e8cd802493d858b39ee4298ecb054f3d06e5395',
    payloadBytes: 138273,
    declaredRowCount: 9,
    publishedAtUtc: DateTime.utc(2026, 8, 9),
  );

  static final schoolDataset = DatasetManifest(
    datasetId: 'daliuren.school_dataset',
    contentVersion: '2026-08-09',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '8e75ed2a336341572fcece2418419a52200160151d8e1484640af668be4cd3f1',
    payloadBytes: 584,
    declaredRowCount: 1,
    publishedAtUtc: DateTime.utc(2026, 8, 9),
  );
}

/// daliuren 域共用的资源策略。
final _daliurenPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// daliuren 域各数据集的内置 asset 路径（rootBundle 形态）。
const _kOfficialDataAssetPath =
    'packages/persistence_assets/lib/daliuren/assets/official_data_document.sql';
const _kKetiAssetPath =
    'packages/persistence_assets/lib/daliuren/assets/keti_document.sql';
const _kShenShaAssetPath =
    'packages/persistence_assets/lib/daliuren/assets/shen_sha_document.sql';
const _kSchoolDatasetAssetPath =
    'packages/persistence_assets/lib/daliuren/assets/school_dataset_document.sql';

/// 注册 daliuren 域全部数据集。
///
/// 在 app 装配期调用一次（如 main.dart 或 DI 容器初始化）。
/// 重复注册会抛 [DatasetRegistrationError]（协议 §6 I9 / 注册期校验）。
///
/// [db] 是共享的 [DaliurenDatabase] 实例（materializer 把 .sql 灌入它）。
void registerDaliurenDatasets({required DaliurenDatabase db}) {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'daliuren.official_data',
      appSchemaRevision: 1,
      policy: _daliurenPolicy,
      bundledManifest: _DaliurenManifests.officialData,
      materializer: () => DaliurenSqlMaterializer(
        datasetId: 'daliuren.official_data',
        assetPath: _kOfficialDataAssetPath,
        declaredRowCount: 4,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'daliuren.keti',
      appSchemaRevision: 1,
      policy: _daliurenPolicy,
      bundledManifest: _DaliurenManifests.keti,
      materializer: () => DaliurenSqlMaterializer(
        datasetId: 'daliuren.keti',
        assetPath: _kKetiAssetPath,
        declaredRowCount: 1,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'daliuren.shen_sha',
      appSchemaRevision: 1,
      policy: _daliurenPolicy,
      bundledManifest: _DaliurenManifests.shenSha,
      materializer: () => DaliurenSqlMaterializer(
        datasetId: 'daliuren.shen_sha',
        assetPath: _kShenShaAssetPath,
        declaredRowCount: 9,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'daliuren.school_dataset',
      appSchemaRevision: 1,
      policy: _daliurenPolicy,
      bundledManifest: _DaliurenManifests.schoolDataset,
      materializer: () => DaliurenSqlMaterializer(
        datasetId: 'daliuren.school_dataset',
        assetPath: _kSchoolDatasetAssetPath,
        declaredRowCount: 1,
        db: db,
      ),
    ),
  );
}

/// daliuren 域 `*.sql` 载荷的落地器。
///
/// 协议契约（§3.3）：materialize 只写入入参给定的 generation，
/// 不触碰活跃指针。本实现遵守。
///
/// 落地方式：把 .sql 文本作为 SQL 脚本执行进 [DaliurenDatabase]。
/// drift 已建好表，.sql 的 `CREATE TABLE IF NOT EXISTS` 幂等跳过，
/// 只执行 INSERT。
class DaliurenSqlMaterializer implements AssetBackedMaterializer {
  DaliurenSqlMaterializer({
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
  final DaliurenDatabase db;

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
      case 'daliuren.official_data':
        return 'official_data_document';
      case 'daliuren.keti':
        return 'keti_document';
      case 'daliuren.shen_sha':
        return 'shen_sha_document';
      case 'daliuren.school_dataset':
        return 'school_dataset_document';
      default:
        throw ArgumentError('未知 datasetId: $datasetId');
    }
  }
}
