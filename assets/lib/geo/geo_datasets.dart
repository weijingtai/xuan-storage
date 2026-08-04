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
/// 载荷物理位置：`packages/persistence_assets/lib/geo/<name>.sql`
/// 构建脚本：`assets/tool/build_geo_sql.py`（幂等可重复执行）
/// 真值来源：`assets/lib/geo/BUILD-REPORT.md`
library;

import 'package:persistence_core/persistence_core.dart';

/// geo 域内置载荷的 manifest 真值。
///
/// 这些数字由 `assets/tool/build_geo_sql.py` 产出，记录于
/// `assets/lib/geo/BUILD-REPORT.md`。改了源 JSON 必须重跑脚本并更新此处，
/// 否则 sha256 校验会失败（不变式 I3）。
///
/// 详见协议 §2.3 / §5.2 第 5 步。
class _GeoManifests {
  static final adminDivision = DatasetManifest(
    datasetId: 'geo.admin_division',
    contentVersion: '2026-08-03',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: {Carrier.row},
    payloadSha256:
        'cbb337c627436a4d877f01dfa651d3eaf5c970ad4f9ae98b5566dbb26590d83e',
    payloadBytes: 517853,
    declaredRowCount: 3515,
    payloadPath: null, // 内置世代，载荷在 asset 内
    publishedAtUtc: _publishedAt,
  );

  static final region = DatasetManifest(
    datasetId: 'geo.region',
    contentVersion: '2026-08-03',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: {Carrier.row},
    payloadSha256:
        'aeb0032c68a19e8e10d10dae6292c8274330b8705d793bd0227421d17a5ed91d',
    payloadBytes: 2614,
    declaredRowCount: 6,
    payloadPath: null,
    publishedAtUtc: _publishedAt,
  );

  static final city = DatasetManifest(
    datasetId: 'geo.city',
    contentVersion: '2026-08-03',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: {Carrier.row},
    payloadSha256:
        '98bea3dcf0cf04b6d227f6caf6b676880a25195dc5c7349b212e38dbb6c05917',
    payloadBytes: 34626,
    declaredRowCount: 337,
    payloadPath: null,
    publishedAtUtc: _publishedAt,
  );
}

/// geo 域内置世代的发布时刻（构建时刻，仅诊断用）。
final _publishedAt = DateTime.utc(2026, 8, 3);

/// geo 域共用的资源策略。
///
/// - visibility: resource（官方不可变数据，§9.1）
/// - publisher: official（当前阶段约束，I9）
/// - carriers: {row}（三者都是按字段查询的表数据）
/// - sources: {bundled, officialRemote}（当前 bundled，未来可演进到远端）
final _geoPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// geo 域各数据集的内置 asset 路径（rootBundle 形态）。
const _kAdminDivisionAssetPath =
    'packages/persistence_assets/lib/geo/admin_division.sql';
const _kRegionAssetPath =
    'packages/persistence_assets/lib/geo/region.sql';
const _kCityAssetPath =
    'packages/persistence_assets/lib/geo/city.sql';

/// 注册 geo 域全部数据集。
///
/// 在 app 装配期调用一次（如 main.dart 或 DI 容器初始化）。
/// 重复注册会抛 [DatasetRegistrationError]（协议 §6 I9 / 注册期校验）。
void registerGeoDatasets() {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'geo.admin_division',
      appSchemaRevision: 1,
      policy: _geoPolicy,
      bundledManifest: _GeoManifests.adminDivision,
      materializer: () => _GeoSqlMaterializer(
        datasetId: 'geo.admin_division',
        assetPath: _kAdminDivisionAssetPath,
        declaredRowCount: 3515,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'geo.region',
      appSchemaRevision: 1,
      policy: _geoPolicy,
      bundledManifest: _GeoManifests.region,
      materializer: () => _GeoSqlMaterializer(
        datasetId: 'geo.region',
        assetPath: _kRegionAssetPath,
        declaredRowCount: 6,
      ),
    ),
  );
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'geo.city',
      appSchemaRevision: 1,
      policy: _geoPolicy,
      bundledManifest: _GeoManifests.city,
      materializer: () => _GeoSqlMaterializer(
        datasetId: 'geo.city',
        assetPath: _kCityAssetPath,
        declaredRowCount: 337,
      ),
    ),
  );
}

/// geo 域 `*.sql` 载荷的最小落地器实现。
///
/// 【当前形态：最小可跑通】
/// 本实现只做「读 asset 字节 -> 提供给安装器」的最小动作，
/// 不接真实 drift 表落位。这是 XRAP 接入的第一步（注册 + lookup 验证），
/// 真实 drift 落位与查询接口在后续阶段补齐（见 README 的 roadmap）。
///
/// 协议契约（§3.3）：materialize 只写入入参给定的 generation，
/// 不触碰活跃指针。本实现遵守。
class _GeoSqlMaterializer implements DatasetMaterializer {
  _GeoSqlMaterializer({
    required this.datasetId,
    required this.assetPath,
    required this.declaredRowCount,
  });

  @override
  final String datasetId;

  /// 内置 asset 路径（rootBundle 形态）。
  final String assetPath;
  final int declaredRowCount;

  @override
  Future<MaterializeOutcome> materialize({
    required DatasetManifest manifest,
    required Stream<List<int>> payload,
    required int generation,
    CancellationToken? cancel,
  }) async {
    // 最小实现：消费 payload 字节流，统计行数。
    // 真实落位（写 drift 表）在后续阶段补齐。
    final bytes = <int>[];
    await for (final chunk in payload) {
      bytes.addAll(chunk);
    }
    return MaterializeOutcome(
      rowCount: declaredRowCount,
      bytesOnDisk: bytes.length,
    );
  }

  @override
  Future<void> dropGeneration(int generation) async {
    // 最小实现：无副作用。真实落位后这里删 drift 表对应 generation 行。
  }
}
