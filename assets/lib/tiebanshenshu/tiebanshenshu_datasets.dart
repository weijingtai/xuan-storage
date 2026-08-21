/// tiebanshenshu 域数据集的 XRAP 接入（照 geo/qizhengsiyu 样板，XRAP §3）。
///
/// 本文件注册 4 个数据集：
/// - `tiebanshenshu.tiao_wen` - 条文库（12000 行，CSV→表）
/// - `tiebanshenshu.kao_ke` - 考课数据（21 行 JSON 文档表）
/// - `tiebanshenshu.shaozishu` - 少子术（12 行 TXT 文档表）
/// - `tiebanshenshu.formulas` - 皇极公式（3 行 JSON 文档表）
///
/// 内置载荷为构建期产出的 `*.sql`（CREATE TABLE + INSERT，事务包裹），
/// 属 [DatasetPayloadFormat.prebuilt]。
///
/// 全链路：
/// ```
/// 领域 Repository（xrap_tiebanshenshu_repositories.dart）
///      │  查询 TiebanshenshuDatabase（drift）
///      ▼
/// TiebanshenshuDatabase（drift，ResourceDatasetDatabase §9.1）
///      │  启动时由 DatasetInstaller.ensureInstalled 把 *.sql 执行进库
///      ▼
/// *.sql dump（tiao_wen.sql / *_document.sql）
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:persistence_core/persistence_core.dart';

import 'drift/tiebanshenshu_database.dart';

/// tiebanshenshu 域内置载荷的 manifest 真值。
///
/// 这些数字由 `assets/tool/build_tiebanshenshu_sql.py` 产出，记录于
/// `assets/lib/tiebanshenshu/assets/BUILD-REPORT.md`。改了源 CSV/JSON 必须重跑脚本
/// 并更新此处，否则 sha256 校验会失败（不变式 I3）。
class _TiebanshenshuManifests {
  static final tiaoWen = DatasetManifest(
    datasetId: 'tiebanshenshu.tiao_wen',
    contentVersion: '2026-08-09',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '83cca60cb50a2c14b7f20358b5c2a26cbd6a484344227b26bd6e3ac1e5fc1e83',
    payloadBytes: 1657509,
    declaredRowCount: 12000,
    publishedAtUtc: DateTime.utc(2026, 8, 9),
  );

  static final kaoKe = DatasetManifest(
    datasetId: 'tiebanshenshu.kao_ke',
    contentVersion: '2026-08-09',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        'df604ae59132849b5b5e8fcb088de22b65ef8137950170eb23a68c7cefb8fa5c',
    payloadBytes: 83033,
    declaredRowCount: 21,
    publishedAtUtc: DateTime.utc(2026, 8, 9),
  );

  static final shaoZiShu = DatasetManifest(
    datasetId: 'tiebanshenshu.shaozishu',
    contentVersion: '2026-08-09',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '02ead379c08f4ab04fb0df4b0ead0b8eedb01aee86d2a35f87fd3789034aeb68',
    payloadBytes: 580131,
    declaredRowCount: 12,
    publishedAtUtc: DateTime.utc(2026, 8, 9),
  );

  static final formulas = DatasetManifest(
    datasetId: 'tiebanshenshu.formulas',
    contentVersion: '2026-08-09',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        'e60cb2e08698eed3f4d769d5e9f2f4bc302fd4ca3686db67a45b7da534533ce3',
    payloadBytes: 30553,
    declaredRowCount: 3,
    publishedAtUtc: DateTime.utc(2026, 8, 9),
  );
}

/// tiebanshenshu 域共用的资源策略。
final _tiebanshenshuPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// tiebanshenshu 域各数据集的内置 asset 路径（rootBundle 形态）。
const _kTiaoWenAssetPath =
    'packages/persistence_assets/lib/tiebanshenshu/assets/tiao_wen.sql';
const _kKaoKeAssetPath =
    'packages/persistence_assets/lib/tiebanshenshu/assets/kao_ke_document.sql';
const _kShaoZiShuAssetPath =
    'packages/persistence_assets/lib/tiebanshenshu/assets/shaozishu_document.sql';
const _kFormulasAssetPath =
    'packages/persistence_assets/lib/tiebanshenshu/assets/formulas_document.sql';

/// 注册 tiebanshenshu 域全部数据集。
///
/// 在 app 装配期调用一次（如 main.dart 或 DI 容器初始化）。
/// 重复注册会抛 [DatasetRegistrationError]（协议 §6 I9 / 注册期校验）。
///
/// [db] 是共享的 [TiebanshenshuDatabase] 实例（materializer 把 .sql 灌入它）。
void registerTiebanshenshuDatasets({required TiebanshenshuDatabase db}) {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'tiebanshenshu.tiao_wen',
      appSchemaRevision: 1,
      policy: _tiebanshenshuPolicy,
      bundledManifest: _TiebanshenshuManifests.tiaoWen,
      materializer: () => TiebanshenshuSqlMaterializer(
        datasetId: 'tiebanshenshu.tiao_wen',
        assetPath: _kTiaoWenAssetPath,
        declaredRowCount: 12000,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'tiebanshenshu.kao_ke',
      appSchemaRevision: 1,
      policy: _tiebanshenshuPolicy,
      bundledManifest: _TiebanshenshuManifests.kaoKe,
      materializer: () => TiebanshenshuSqlMaterializer(
        datasetId: 'tiebanshenshu.kao_ke',
        assetPath: _kKaoKeAssetPath,
        declaredRowCount: 21,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'tiebanshenshu.shaozishu',
      appSchemaRevision: 1,
      policy: _tiebanshenshuPolicy,
      bundledManifest: _TiebanshenshuManifests.shaoZiShu,
      materializer: () => TiebanshenshuSqlMaterializer(
        datasetId: 'tiebanshenshu.shaozishu',
        assetPath: _kShaoZiShuAssetPath,
        declaredRowCount: 12,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'tiebanshenshu.formulas',
      appSchemaRevision: 1,
      policy: _tiebanshenshuPolicy,
      bundledManifest: _TiebanshenshuManifests.formulas,
      materializer: () => TiebanshenshuSqlMaterializer(
        datasetId: 'tiebanshenshu.formulas',
        assetPath: _kFormulasAssetPath,
        declaredRowCount: 3,
        db: db,
      ),
    ),
  );
}

/// tiebanshenshu 域 `*.sql` 载荷的落地器。
///
/// 协议契约（§3.3）：materialize 只写入入参给定的 generation，
/// 不触碰活跃指针。本实现遵守。
///
/// 落地方式：把 .sql 文本作为 SQL 脚本执行进 [TiebanshenshuDatabase]。
/// drift 已建好表，.sql 的 `CREATE TABLE IF NOT EXISTS` 幂等跳过，
/// 只执行 INSERT。
class TiebanshenshuSqlMaterializer implements AssetBackedMaterializer {
  TiebanshenshuSqlMaterializer({
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
  final TiebanshenshuDatabase db;

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

    // 执行 .sql 脚本进 drift 库（事务包裹在 .sql 内）。
    // 注意：WasmDatabase（web）下 SQL 内显式 BEGIN/COMMIT 会与连接事务状态
    // 冲突（cannot start a transaction within a transaction），故 *.sql 不含
    // BEGIN/COMMIT，语句在 autocommit 下逐条落地（见 tool/build_tiebanshenshu_sql.py）。
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
  }

  /// datasetId -> drift 表名映射。
  Future<int> _countRowsFor(String datasetId) async {
    switch (datasetId) {
      case 'tiebanshenshu.tiao_wen':
        return _count('tiao_wen');
      case 'tiebanshenshu.kao_ke':
        return _count('kao_ke_document');
      case 'tiebanshenshu.shaozishu':
        return _count('shaozishu_document');
      case 'tiebanshenshu.formulas':
        return _count('formulas_document');
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
