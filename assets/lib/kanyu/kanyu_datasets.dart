/// kanyu 域数据集的 XRAP 接入（照 ziwei_datasets.dart 样板，XRAP §3）。
///
/// 本文件注册 3 个数据集：
/// - `kanyu.rules` - Layer B 规则配置（6 行文档表）
/// - `kanyu.static_data` - Layer A 静态数据（16 行文档表，rules 的 dataRefs 解析需要）
/// - `kanyu.schema` - JSON Schema 校验规格（2 行文档表，validateConfigPackage 需要）
///
/// 内置载荷为构建期产出的 `*.sql`（CREATE TABLE + INSERT + DELETE 幂等），
/// 属 [DatasetPayloadFormat.prebuilt]。非表形 JSON 以「JSON 文档表」落地
/// （协议注册期强制内置 manifest 必须 prebuilt，rawText 会被 DatasetRegistry 拒绝）。
///
/// 全链路：
/// ```
/// 领域 Repository（xrap_kanyu_repositories.dart）
///      │  查询 KanyuDatabase（drift）
///      ▼
/// KanyuDatabase（drift，ResourceDatasetDatabase §9.1）
///      │  启动时由 DatasetInstaller.ensureInstalled 把 *.sql 执行进库
///      ▼
/// *.sql dump（rules_document.sql / static_data_document.sql / schema_document.sql）
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:persistence_core/persistence_core.dart';

import 'drift/kanyu_database.dart';

/// kanyu 域内置载荷的 manifest 真值。
///
/// 这些数字由 `assets/tool/build_kanyu_sql.py` 产出，记录于
/// `assets/lib/kanyu/assets/BUILD-REPORT.md`。改了源 JSON 必须重跑脚本
/// 并更新此处，否则 sha256 校验会失败（不变式 I3）。
class _KanyuManifests {
  static final rules = DatasetManifest(
    datasetId: 'kanyu.rules',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '67c9d5ae693d30f6575b8b200a579fdaa7a49b147bad89c04665f84abc575162',
    payloadBytes: 18532,
    declaredRowCount: 6,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );

  static final staticData = DatasetManifest(
    datasetId: 'kanyu.static_data',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        'e6a26703660517901d554455c224cc0975c8b8b6fc75347da4620d4be18ac56b',
    payloadBytes: 50089,
    declaredRowCount: 16,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );

  static final schema = DatasetManifest(
    datasetId: 'kanyu.schema',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '704e220c7e5bbde681ec5e1c98c9c260618fc72214113fea150d623594fe8842',
    payloadBytes: 7351,
    declaredRowCount: 2,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );
}

/// kanyu 域共用的资源策略。
final _kanyuPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// kanyu 域各数据集的内置 asset 路径（rootBundle 形态）。
const _kRulesAssetPath =
    'packages/persistence_assets/lib/kanyu/assets/rules_document.sql';
const _kStaticDataAssetPath =
    'packages/persistence_assets/lib/kanyu/assets/static_data_document.sql';
const _kSchemaAssetPath =
    'packages/persistence_assets/lib/kanyu/assets/schema_document.sql';

/// 注册 kanyu 域全部数据集。
///
/// 在 app 装配期调用一次（如 main.dart 或 DI 容器初始化）。
/// 重复注册会抛 [DatasetRegistrationError]（协议 §6 I9 / 注册期校验）。
///
/// [db] 是共享的 [KanyuDatabase] 实例（materializer 把 .sql 灌入它）。
void registerKanyuDatasets({required KanyuDatabase db}) {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'kanyu.rules',
      appSchemaRevision: 1,
      policy: _kanyuPolicy,
      bundledManifest: _KanyuManifests.rules,
      materializer: () => KanyuSqlMaterializer(
        datasetId: 'kanyu.rules',
        assetPath: _kRulesAssetPath,
        declaredRowCount: 6,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'kanyu.static_data',
      appSchemaRevision: 1,
      policy: _kanyuPolicy,
      bundledManifest: _KanyuManifests.staticData,
      materializer: () => KanyuSqlMaterializer(
        datasetId: 'kanyu.static_data',
        assetPath: _kStaticDataAssetPath,
        declaredRowCount: 16,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'kanyu.schema',
      appSchemaRevision: 1,
      policy: _kanyuPolicy,
      bundledManifest: _KanyuManifests.schema,
      materializer: () => KanyuSqlMaterializer(
        datasetId: 'kanyu.schema',
        assetPath: _kSchemaAssetPath,
        declaredRowCount: 2,
        db: db,
      ),
    ),
  );
}

/// kanyu 域 `*.sql` 载荷的落地器。
///
/// 协议契约（§3.3）：materialize 只写入入参给定的 generation，
/// 不触碰活跃指针。本实现遵守。
///
/// 落地方式：把 .sql 文本作为 SQL 脚本执行进 [KanyuDatabase]。
/// drift 已建好表，.sql 的 `CREATE TABLE IF NOT EXISTS` 幂等跳过，
/// 只执行 INSERT。
class KanyuSqlMaterializer implements AssetBackedMaterializer {
  KanyuSqlMaterializer({
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
  final KanyuDatabase db;

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
      case 'kanyu.rules':
        return 'rules_document';
      case 'kanyu.static_data':
        return 'static_data_document';
      case 'kanyu.schema':
        return 'schema_document';
      default:
        throw ArgumentError('未知 datasetId: $datasetId');
    }
  }
}
