/// taiyishenshu 域数据集的 XRAP 接入（照 daliuren_datasets.dart 样板，XRAP §3）。
///
/// 本文件注册 3 个数据集：
/// - `taiyi.schools` - 3 份精简学派 JSON（ji-cheng / jing-mirror / tong-zong，3 行文档表）
/// - `taiyi.deities` - 47 份神将 JSON（47 行文档表）
/// - `taiyi.minggua` - 太乙命卦序列（tong_zong_sequence.json，1 行文档表，
///   人类裁定迁入，MingGuaRepository 端口）
///
/// 内置载荷为构建期产出的 `*.sql`（CREATE TABLE + INSERT + DELETE 幂等），
/// 属 [DatasetPayloadFormat.prebuilt]。非表形 JSON 以「JSON 文档表」落地
/// （协议注册期强制内置 manifest 必须 prebuilt，rawText 会被 DatasetRegistry 拒绝）。
///
/// 全链路：
/// ```
/// 领域 Repository（xrap_taiyishenshu_repositories.dart）
///      │  查询 TaiyishenshuDatabase（drift）
///      ▼
/// TaiyishenshuDatabase（drift，ResourceDatasetDatabase §9.1）
///      │  启动时由 DatasetInstaller.ensureInstalled 把 *.sql 执行进库
///      ▼
/// *.sql dump（schools_document.sql / deities_document.sql / minggua_document.sql）
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:persistence_core/persistence_core.dart';

import 'drift/taiyishenshu_database.dart';

/// taiyishenshu 域内置载荷的 manifest 真值。
///
/// 这些数字由 `assets/tool/build_taiyishenshu_sql.py` 产出，记录于
/// `assets/lib/taiyishenshu/assets/BUILD-REPORT.md`。改了源 JSON 必须重跑脚本
/// 并更新此处，否则 sha256 校验会失败（不变式 I3）。
class _TaiyiManifests {
  static final schools = DatasetManifest(
    datasetId: 'taiyi.schools',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        'cfb13ade0c988dbcad650482502cd3007e7369635040995aee974e10476bc343',
    payloadBytes: 3878,
    declaredRowCount: 3,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );

  static final deities = DatasetManifest(
    datasetId: 'taiyi.deities',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '36eeee338abbfcbfab69afc502e5c7ca7cb8fcadee63a00976d7d70558d5ca50',
    payloadBytes: 31609,
    declaredRowCount: 47,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );

  static final minggua = DatasetManifest(
    datasetId: 'taiyi.minggua',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '9fb441277e4f686c15ee7cceaadea3164c9deb9071e5e9cb753348b51877a0fb',
    payloadBytes: 912,
    declaredRowCount: 1,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );
}

/// taiyishenshu 域共用的资源策略。
final _taiyiPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// taiyishenshu 域各数据集的内置 asset 路径（rootBundle 形态）。
const _kSchoolsAssetPath =
    'packages/persistence_assets/lib/taiyishenshu/assets/schools_document.sql';
const _kDeitiesAssetPath =
    'packages/persistence_assets/lib/taiyishenshu/assets/deities_document.sql';
const _kMingGuaAssetPath =
    'packages/persistence_assets/lib/taiyishenshu/assets/minggua_document.sql';

/// 注册 taiyishenshu 域全部数据集。
///
/// 在 app 装配期调用一次（如 main.dart 或 DI 容器初始化）。
/// 重复注册会抛 [DatasetRegistrationError]（协议 §6 I9 / 注册期校验）。
///
/// [db] 是共享的 [TaiyishenshuDatabase] 实例（materializer 把 .sql 灌入它）。
void registerTaiyiDatasets({required TaiyishenshuDatabase db}) {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'taiyi.schools',
      appSchemaRevision: 1,
      policy: _taiyiPolicy,
      bundledManifest: _TaiyiManifests.schools,
      materializer: () => TaiyiSqlMaterializer(
        datasetId: 'taiyi.schools',
        assetPath: _kSchoolsAssetPath,
        declaredRowCount: 3,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'taiyi.deities',
      appSchemaRevision: 1,
      policy: _taiyiPolicy,
      bundledManifest: _TaiyiManifests.deities,
      materializer: () => TaiyiSqlMaterializer(
        datasetId: 'taiyi.deities',
        assetPath: _kDeitiesAssetPath,
        declaredRowCount: 47,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'taiyi.minggua',
      appSchemaRevision: 1,
      policy: _taiyiPolicy,
      bundledManifest: _TaiyiManifests.minggua,
      materializer: () => TaiyiSqlMaterializer(
        datasetId: 'taiyi.minggua',
        assetPath: _kMingGuaAssetPath,
        declaredRowCount: 1,
        db: db,
      ),
    ),
  );
}

/// taiyishenshu 域 `*.sql` 载荷的落地器。
///
/// 协议契约（§3.3）：materialize 只写入入参给定的 generation，
/// 不触碰活跃指针。本实现遵守。
///
/// 落地方式：把 .sql 文本作为 SQL 脚本执行进 [TaiyishenshuDatabase]。
/// drift 已建好表，.sql 的 `CREATE TABLE IF NOT EXISTS` 幂等跳过，
/// 只执行 INSERT。
class TaiyiSqlMaterializer implements AssetBackedMaterializer {
  TaiyiSqlMaterializer({
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
  final TaiyishenshuDatabase db;

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
      case 'taiyi.schools':
        return 'schools_document';
      case 'taiyi.deities':
        return 'deities_document';
      case 'taiyi.minggua':
        return 'minggua_document';
      default:
        throw ArgumentError('未知 datasetId: $datasetId');
    }
  }
}
