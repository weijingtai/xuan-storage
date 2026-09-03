/// qizhengsiyu 域数据集的 XRAP 接入（照 geo_datasets.dart 样板，XRAP §3）。
///
/// 本文件注册 8 个数据集：
/// - `qizheng.star_position_status` - 星位庙旺状态（97 行）
/// - `qizheng.ge_ju` - 格局库（5 表 1005 行，源为预构建 SQLite）
/// - `qizheng.zhou_tian` - 周天模型（3 行 JSON 文档表）
/// - `qizheng.ephemeris` - 星历/黄道/赤道等（20 行 JSON 文档表）
/// - `qizheng.shen_sha` - 神煞（6 行 JSON 文档表）
/// - `qizheng.hua_yao` - 化曜（3 行 JSON 文档表）
/// - `qizheng.ge_ju_rules` - 格局规则 JSON（13 行 JSON 文档表）
/// - `qizheng.ge_ju_content` - 格局内容 JSON（13 行 JSON 文档表）
///
/// 内置载荷为构建期产出的 `*.sql`（CREATE TABLE + INSERT，事务包裹），
/// 属 [DatasetPayloadFormat.prebuilt]。非表形 JSON 按人类裁定 2026-08-07
/// 以「JSON 文档表」落地（协议注册期强制内置 manifest 必须 prebuilt，
/// rawText 会被 DatasetRegistry 拒绝）。
///
/// 全链路：
/// ```
/// 领域 Repository（xrap_qizhengsiyu_repositories.dart）
///      │  查询 QizhengsiyuDatabase（drift）
///      ▼
/// QizhengsiyuDatabase（drift，ResourceDatasetDatabase §9.1）
///      │  启动时由 DatasetInstaller.ensureInstalled 把 *.sql 执行进库
///      ▼
/// *.sql dump（star_position_status.sql / ge_ju.sql / *_document.sql）
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:persistence_core/persistence_core.dart';

import 'drift/qizhengsiyu_database.dart';

/// qizhengsiyu 域内置载荷的 manifest 真值。
///
/// 这些数字由 `assets/tool/build_qizhengsiyu_sql.py` 产出，记录于
/// `assets/lib/qizhengsiyu/assets/BUILD-REPORT.md`。改了源 JSON 必须重跑脚本
/// 并更新此处，否则 sha256 校验会失败（不变式 I3）。
class _QizhengManifests {
  static final starPositionStatus = DatasetManifest(
    datasetId: 'qizheng.star_position_status',
    contentVersion: '2026-08-07',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '7d59428dec52ec814b12cc259f0b3d3c7cdb70dc07fdcdefe5918a36c3b6f5bc',
    payloadBytes: 15608,
    declaredRowCount: 97,
    publishedAtUtc: DateTime.utc(2026, 8, 7),
  );

  static final geJu = DatasetManifest(
    datasetId: 'qizheng.ge_ju',
    contentVersion: '2026-08-07',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        'c265f87b85ba3a2c78b45b4fc89998f75018ddd81d4bb9b9c6f163519cb747f0',
    payloadBytes: 532921,
    declaredRowCount: 1005,
    publishedAtUtc: DateTime.utc(2026, 8, 7),
  );

  static final zhouTian = DatasetManifest(
    datasetId: 'qizheng.zhou_tian',
    contentVersion: '2026-08-07',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '0d9b7831aa4528019f029495f8871155da885ef244c4bf2f02d2e5aa5dd17b4d',
    payloadBytes: 9133,
    declaredRowCount: 3,
    publishedAtUtc: DateTime.utc(2026, 8, 7),
  );

  static final ephemeris = DatasetManifest(
    datasetId: 'qizheng.ephemeris',
    contentVersion: '2026-08-07',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '3d1d2abcd54cf16486201483d57bb26f6e4df76eacb48809bedf338a7b4f1fbb',
    payloadBytes: 61570,
    declaredRowCount: 20,
    publishedAtUtc: DateTime.utc(2026, 8, 7),
  );

  static final shenSha = DatasetManifest(
    datasetId: 'qizheng.shen_sha',
    contentVersion: '2026-08-07',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '0d05ff7d53c78581e711f118ea75fba1e29b13164a7a37a2adb805421a8cc9dd',
    payloadBytes: 48544,
    declaredRowCount: 6,
    publishedAtUtc: DateTime.utc(2026, 8, 7),
  );

  static final huaYao = DatasetManifest(
    datasetId: 'qizheng.hua_yao',
    contentVersion: '2026-08-07',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '7780c48e0f4aa7fb9fb30a83d97cc9fc77cc8ec9f8ad553b914cdadaaeffdb0e',
    payloadBytes: 21594,
    declaredRowCount: 3,
    publishedAtUtc: DateTime.utc(2026, 8, 7),
  );

  static final geJuRules = DatasetManifest(
    datasetId: 'qizheng.ge_ju_rules',
    contentVersion: '2026-08-07',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '2ad683c610b29f816ac1bc36a5426a3cf4c5e79af0f0264bb292540db2deaca1',
    payloadBytes: 235099,
    declaredRowCount: 13,
    publishedAtUtc: DateTime.utc(2026, 8, 7),
  );

  static final geJuContent = DatasetManifest(
    datasetId: 'qizheng.ge_ju_content',
    contentVersion: '2026-08-07',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '70feb55ec2b524459e1f0892fa40a7090a59dad6985f31b9c234383bc388e337',
    payloadBytes: 287867,
    declaredRowCount: 13,
    publishedAtUtc: DateTime.utc(2026, 8, 7),
  );
}

/// qizhengsiyu 域共用的资源策略。
final _qizhengPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// qizhengsiyu 域各数据集的内置 asset 路径（rootBundle 形态）。
const _kStarPositionStatusAssetPath =
    'packages/persistence_assets/lib/qizhengsiyu/assets/star_position_status.sql';
const _kGeJuAssetPath =
    'packages/persistence_assets/lib/qizhengsiyu/assets/ge_ju.sql';
const _kZhouTianAssetPath =
    'packages/persistence_assets/lib/qizhengsiyu/assets/zhou_tian_document.sql';
const _kEphemerisAssetPath =
    'packages/persistence_assets/lib/qizhengsiyu/assets/ephemeris_document.sql';
const _kShenShaAssetPath =
    'packages/persistence_assets/lib/qizhengsiyu/assets/shen_sha_document.sql';
const _kHuaYaoAssetPath =
    'packages/persistence_assets/lib/qizhengsiyu/assets/hua_yao_document.sql';
const _kGeJuRulesAssetPath =
    'packages/persistence_assets/lib/qizhengsiyu/assets/ge_ju_rules_document.sql';
const _kGeJuContentAssetPath =
    'packages/persistence_assets/lib/qizhengsiyu/assets/ge_ju_content_document.sql';

/// 注册 qizhengsiyu 域全部数据集。
///
/// 在 app 装配期调用一次（如 main.dart 或 DI 容器初始化）。
/// 重复注册会抛 [DatasetRegistrationError]（协议 §6 I9 / 注册期校验）。
///
/// [db] 是共享的 [QizhengsiyuDatabase] 实例（materializer 把 .sql 灌入它）。
void registerQizhengDatasets({required QizhengsiyuDatabase db}) {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'qizheng.star_position_status',
      appSchemaRevision: 1,
      policy: _qizhengPolicy,
      bundledManifest: _QizhengManifests.starPositionStatus,
      materializer: () => QizhengSqlMaterializer(
        datasetId: 'qizheng.star_position_status',
        assetPath: _kStarPositionStatusAssetPath,
        declaredRowCount: 97,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'qizheng.ge_ju',
      appSchemaRevision: 1,
      policy: _qizhengPolicy,
      bundledManifest: _QizhengManifests.geJu,
      materializer: () => QizhengSqlMaterializer(
        datasetId: 'qizheng.ge_ju',
        assetPath: _kGeJuAssetPath,
        declaredRowCount: 1005,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'qizheng.zhou_tian',
      appSchemaRevision: 1,
      policy: _qizhengPolicy,
      bundledManifest: _QizhengManifests.zhouTian,
      materializer: () => QizhengSqlMaterializer(
        datasetId: 'qizheng.zhou_tian',
        assetPath: _kZhouTianAssetPath,
        declaredRowCount: 3,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'qizheng.ephemeris',
      appSchemaRevision: 1,
      policy: _qizhengPolicy,
      bundledManifest: _QizhengManifests.ephemeris,
      materializer: () => QizhengSqlMaterializer(
        datasetId: 'qizheng.ephemeris',
        assetPath: _kEphemerisAssetPath,
        declaredRowCount: 20,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'qizheng.shen_sha',
      appSchemaRevision: 1,
      policy: _qizhengPolicy,
      bundledManifest: _QizhengManifests.shenSha,
      materializer: () => QizhengSqlMaterializer(
        datasetId: 'qizheng.shen_sha',
        assetPath: _kShenShaAssetPath,
        declaredRowCount: 6,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'qizheng.hua_yao',
      appSchemaRevision: 1,
      policy: _qizhengPolicy,
      bundledManifest: _QizhengManifests.huaYao,
      materializer: () => QizhengSqlMaterializer(
        datasetId: 'qizheng.hua_yao',
        assetPath: _kHuaYaoAssetPath,
        declaredRowCount: 3,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'qizheng.ge_ju_rules',
      appSchemaRevision: 1,
      policy: _qizhengPolicy,
      bundledManifest: _QizhengManifests.geJuRules,
      materializer: () => QizhengSqlMaterializer(
        datasetId: 'qizheng.ge_ju_rules',
        assetPath: _kGeJuRulesAssetPath,
        declaredRowCount: 13,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'qizheng.ge_ju_content',
      appSchemaRevision: 1,
      policy: _qizhengPolicy,
      bundledManifest: _QizhengManifests.geJuContent,
      materializer: () => QizhengSqlMaterializer(
        datasetId: 'qizheng.ge_ju_content',
        assetPath: _kGeJuContentAssetPath,
        declaredRowCount: 13,
        db: db,
      ),
    ),
  );
}

/// qizhengsiyu 域 `*.sql` 载荷的落地器。
///
/// 协议契约（§3.3）：materialize 只写入入参给定的 generation，
/// 不触碰活跃指针。本实现遵守。
///
/// 落地方式：把 .sql 文本作为 SQL 脚本执行进 [QizhengsiyuDatabase]。
/// drift 已建好表，.sql 的 `CREATE TABLE IF NOT EXISTS` 幂等跳过，
/// 只执行 INSERT + CREATE INDEX。
class QizhengSqlMaterializer implements AssetBackedMaterializer {
  QizhengSqlMaterializer({
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
  final QizhengsiyuDatabase db;

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
    // drift 的 customStatement 支持多语句（事务包裹在 .sql 内）。
    await db.customStatement(sqlText);

    // 统计实际落地行数（I4 自检）。
    final actualRows = await _countRowsFor(datasetId);
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

  /// datasetId -> drift 表名映射。ge_ju 为 5 表合计。
  Future<int> _countRowsFor(String datasetId) async {
    switch (datasetId) {
      case 'qizheng.star_position_status':
        return _count('star_position_status');
      case 'qizheng.ge_ju':
        var total = 0;
        for (final t in const [
          'ge_ju_patterns',
          'ge_ju_schools',
          'ge_ju_categories',
          'ge_ju_rules',
          'ge_ju_versions',
        ]) {
          total += await _count(t);
        }
        return total;
      case 'qizheng.zhou_tian':
        return _count('zhou_tian_document');
      case 'qizheng.ephemeris':
        return _count('ephemeris_document');
      case 'qizheng.shen_sha':
        return _count('shen_sha_document');
      case 'qizheng.hua_yao':
        return _count('hua_yao_document');
      case 'qizheng.ge_ju_rules':
        return _count('ge_ju_rules_document');
      case 'qizheng.ge_ju_content':
        return _count('ge_ju_content_document');
      default:
        throw ArgumentError('未知 datasetId: $datasetId');
    }
  }

  Future<int> _count(String tableName) async {
    final result = await db
        .customSelect('SELECT COUNT(*) AS c FROM "$tableName"')
        .getSingle();
    return result.read<int>('c');
  }
}
