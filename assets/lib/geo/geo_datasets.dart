/// geo 域数据集的 XRAP 接入（首个接入样板，XRAP §3）。
///
/// 本文件注册 3 个数据集：
/// - `geo.admin_division` - 国内省市县经纬度（3515 行）
/// - `geo.region` - 洲（6 行）
/// - `geo.city` - 城市精简数据（337 行，冗余待确认，见 README）
///
/// 内置载荷为构建期产出的 `*.sql`（CREATE TABLE + INSERT，事务包裹），
/// 属 [DatasetPayloadFormat.prebuilt]（构建期已完成字段映射与表结构设计，
/// 设备侧执行即恢复表，不再做语义解析）。
///
/// 全链路：
/// ```
/// MVVM / Use Case
///      │  调用 GeoRepository 方法（getByCode / listByParent / searchByName）
///      ▼
/// GeoRepository（本文件，领域查询，在 persistence_assets 内）
///      │  查 GeoDatabase（drift）
///      ▼
/// GeoDatabase（drift，ResourceDatasetDatabase §9.1）
///      │  启动时由 DatasetInstaller.ensureInstalled 把 *.sql 执行进库
///      ▼
/// *.sql dump（admin_division.sql / region.sql / city.sql）
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:persistence_core/persistence_core.dart';

import 'drift/geo_database.dart';

/// geo 域内置载荷的 manifest 真值。
///
/// 这些数字由 `assets/tool/build_geo_sql.py` 产出，记录于
/// `assets/lib/geo/BUILD-REPORT.md`。改了源 JSON 必须重跑脚本并更新此处，
/// 否则 sha256 校验会失败（不变式 I3）。
class _GeoManifests {
  static final adminDivision = DatasetManifest(
    datasetId: 'geo.admin_division',
    contentVersion: '2026-08-03',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        'cbb337c627436a4d877f01dfa651d3eaf5c970ad4f9ae98b5566dbb26590d83e',
    payloadBytes: 517853,
    declaredRowCount: 3515,
    publishedAtUtc: DateTime.utc(2026, 8, 3),
  );

  static final region = DatasetManifest(
    datasetId: 'geo.region',
    contentVersion: '2026-08-03',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        'aeb0032c68a19e8e10d10dae6292c8274330b8705d793bd0227421d17a5ed91d',
    payloadBytes: 2614,
    declaredRowCount: 6,
    publishedAtUtc: DateTime.utc(2026, 8, 3),
  );

  static final city = DatasetManifest(
    datasetId: 'geo.city',
    contentVersion: '2026-08-03',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '98bea3dcf0cf04b6d227f6caf6b676880a25195dc5c7349b212e38dbb6c05917',
    payloadBytes: 34626,
    declaredRowCount: 337,
    publishedAtUtc: DateTime.utc(2026, 8, 3),
  );
}

/// geo 域共用的资源策略。
final _geoPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// geo 域各数据集的内置 asset 路径（rootBundle 形态）。
const _kAdminDivisionAssetPath =
    'packages/persistence_assets/lib/geo/admin_division.sql';
const _kRegionAssetPath = 'packages/persistence_assets/lib/geo/region.sql';
const _kCityAssetPath = 'packages/persistence_assets/lib/geo/city.sql';

/// 注册 geo 域全部数据集。
///
/// 在 app 装配期调用一次（如 main.dart 或 DI 容器初始化）。
/// 重复注册会抛 [DatasetRegistrationError]（协议 §6 I9 / 注册期校验）。
///
/// [db] 是共享的 [GeoDatabase] 实例（materializer 把 .sql 灌入它）。
void registerGeoDatasets({required GeoDatabase db}) {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'geo.admin_division',
      appSchemaRevision: 1,
      policy: _geoPolicy,
      bundledManifest: _GeoManifests.adminDivision,
      materializer: () => GeoSqlMaterializer(
        datasetId: 'geo.admin_division',
        assetPath: _kAdminDivisionAssetPath,
        declaredRowCount: 3515,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'geo.region',
      appSchemaRevision: 1,
      policy: _geoPolicy,
      bundledManifest: _GeoManifests.region,
      materializer: () => GeoSqlMaterializer(
        datasetId: 'geo.region',
        assetPath: _kRegionAssetPath,
        declaredRowCount: 6,
        db: db,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'geo.city',
      appSchemaRevision: 1,
      policy: _geoPolicy,
      bundledManifest: _GeoManifests.city,
      materializer: () => GeoSqlMaterializer(
        datasetId: 'geo.city',
        assetPath: _kCityAssetPath,
        declaredRowCount: 337,
        db: db,
      ),
    ),
  );
}

/// geo 域 `*.sql` 载荷的落地器。
///
/// 协议契约（§3.3）：materialize 只写入入参给定的 generation，
/// 不触碰活跃指针。本实现遵守。
///
/// 落地方式：把 .sql 文本作为 SQL 脚本执行进 [GeoDatabase]。
/// drift 已建好表，.sql 的 `CREATE TABLE IF NOT EXISTS` 幂等跳过，
/// 只执行 INSERT + CREATE INDEX。
class GeoSqlMaterializer implements AssetBackedMaterializer {
  GeoSqlMaterializer({
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
  final GeoDatabase db;

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
      case 'geo.admin_division':
        return 'admin_division';
      case 'geo.region':
        return 'region';
      case 'geo.city':
        return 'city';
      default:
        throw ArgumentError('未知 datasetId: $datasetId');
    }
  }
}

/// geo 域领域查询 Repository。
///
/// 上层 MVVM / Use Case 通过本接口查询地理数据。
/// 数据来自 [GeoDatabase]（drift），由 DatasetInstaller 启动时灌入。
///
/// 查询方法对应旧 GeoLocationRepository 的能力（接通设计 §1.2），
/// 但走 XRAP 协议层，不直接读 asset。
class GeoRepository {
  GeoRepository(this._db);

  final GeoDatabase _db;

  /// 按 code 取单条行政区划。
  Future<AdminDivisionEntry?> getAdminDivisionByCode(String code) async {
    final rows = await (_db.select(_db.adminDivisions)
          ..where((t) => t.code.equals(code)))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// 按 parentCode 列出下级行政区划（如列出某市的所有区县）。
  Future<List<AdminDivisionEntry>> listAdminDivisionsByParent(
    String parentCode,
  ) async {
    return (_db.select(_db.adminDivisions)
          ..where((t) => t.parentCode.equals(parentCode))
          ..orderBy([(t) => OrderingTerm(expression: t.code)]))
        .get();
  }

  /// 按 level 列出行政区划（level 1=省, 2=市, 3=区县）。
  Future<List<AdminDivisionEntry>> listAdminDivisionsByLevel(int level) async {
    return (_db.select(_db.adminDivisions)
          ..where((t) => t.level.equals(level))
          ..orderBy([(t) => OrderingTerm(expression: t.code)]))
        .get();
  }

  /// 按名称搜索行政区划（模糊匹配）。
  Future<List<AdminDivisionEntry>> searchAdminDivisionsByName(
    String keyword,
  ) async {
    return (_db.select(_db.adminDivisions)
          ..where((t) => t.name.like('%$keyword%'))
          ..limit(50))
        .get();
  }

  /// 取全部洲。
  Future<List<RegionEntry>> listRegions() async {
    return (_db.select(_db.regions)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
  }

  /// 按 code 取单条城市。
  Future<CityEntry?> getCityByCode(String code) async {
    final rows = await (_db.select(_db.cities)
          ..where((t) => t.code.equals(code)))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// 按省份 code 列出城市。
  Future<List<CityEntry>> listCitiesByProvince(String provinceCode) async {
    return (_db.select(_db.cities)
          ..where((t) => t.provinceCode.equals(provinceCode))
          ..orderBy([(t) => OrderingTerm(expression: t.code)]))
        .get();
  }

  /// 取全部城市。
  Future<List<CityEntry>> listAllCities() async {
    return (_db.select(_db.cities)
          ..orderBy([(t) => OrderingTerm(expression: t.code)]))
        .get();
  }
}
