/// XRAP 版 GeoLocationRepository 实现。
///
/// 走 XRAP 协议 + drift 持久化：数据是预构建的 *.sql，启动时由
/// [DatasetInstaller.ensureInstalled] 灌进 [GeoDatabase]，查询走 SQLite。
///
/// 替换旧 [AssetGeoLocationRepository]（直接读 asset JSON），
/// 接口签名不变（同 implements [GeoLocationRepository]）。
library;

import 'package:metaphysics_core/datamodel/geo_location.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:xuan_time_location/xuan_time_location.dart';

import 'drift/geo_database.dart';
import 'geo_datasets.dart';

/// XRAP 版 GeoLocationRepository。
///
/// 装配期由 shell 创建：先 [registerGeoDatasets]，再 new 本类，
/// 首次查询时自动 ensureInstalled（幂等，冷启动零网络）。
class XrapGeoLocationRepository implements GeoLocationRepository {
  XrapGeoLocationRepository({
    required this.db,
    required this.installer,
  });

  final GeoDatabase db;
  final DatasetInstaller installer;

  GeoRepository? _repo;
  bool _ensured = false;

  /// 确保数据集已安装（幂等）。首次调用走 ensureInstalled，之后空操作。
  Future<void> _ensure() async {
    if (_ensured) return;
    await installer.ensureInstalled('geo.admin_division');
    _repo = GeoRepository(db);
    _ensured = true;
  }

  @override
  Future<void> loadLocationsFromAssets() async {
    // 兼容旧接口：实际由 _ensure() 触发 XRAP 安装。
    await _ensure();
  }

  @override
  Future<List<GeoLocation>> getAllLocations() async {
    await _ensure();
    final rows = await _repo!.listAdminDivisionsByLevel(1) +
        await _repo!.listAdminDivisionsByLevel(2) +
        await _repo!.listAdminDivisionsByLevel(3);
    return rows.map(_toGeoLocation).toList();
  }

  @override
  Future<List<GeoLocation>> listAllByLevel(GeoLevel level) async {
    await _ensure();
    final rows = await _repo!.listAdminDivisionsByLevel(_levelToInt(level));
    return rows.map(_toGeoLocation).toList();
  }

  @override
  Future<List<GeoLocation>> listCitiesByProvince(String provinceCode) async {
    await _ensure();
    // province 的下级是市（level 2，parentCode = provinceCode）
    final rows = await _repo!.listAdminDivisionsByParent(provinceCode);
    return rows.map(_toGeoLocation).toList();
  }

  @override
  Future<List<GeoLocation>> listCountiesByProvince(String cityCode) async {
    await _ensure();
    final rows = await _repo!.listAdminDivisionsByParent(cityCode);
    return rows.map(_toGeoLocation).toList();
  }

  @override
  Future<GeoLocation?> getLocationByCode(String code) async {
    await _ensure();
    final row = await _repo!.getAdminDivisionByCode(code);
    return row == null ? null : _toGeoLocation(row);
  }

  @override
  Future<List<GeoLocation>> getChildLocations(String parentCode) async {
    await _ensure();
    final rows = await _repo!.listAdminDivisionsByParent(parentCode);
    return rows.map(_toGeoLocation).toList();
  }

  @override
  Future<List<GeoLocation>> searchLocationsByName(String keyword) async {
    await _ensure();
    final rows = await _repo!.searchAdminDivisionsByName(keyword);
    return rows.map(_toGeoLocation).toList();
  }

  @override
  Future<String> getFullAddressPath(String code) async {
    await _ensure();
    final parts = <String>[];
    var currentCode = code;
    for (var i = 0; i < 3; i++) {
      final row = await _repo!.getAdminDivisionByCode(currentCode);
      if (row == null) break;
      parts.insert(0, row.name);
      if (row.level == 1) break; // province
      currentCode = row.parentCode;
    }
    return parts.join(' ');
  }

  GeoLocation _toGeoLocation(AdminDivisionEntry row) {
    return GeoLocation(
      code: row.code,
      parentCode: row.parentCode,
      level: GeoLevel.fromValue(row.level),
      name: row.name,
      latitude: row.latitude ?? 0.0,
      longitude: row.longitude ?? 0.0,
    );
  }

  int _levelToInt(GeoLevel level) {
    switch (level) {
      case GeoLevel.country:
        return 0;
      case GeoLevel.province:
        return 1;
      case GeoLevel.city:
        return 2;
      case GeoLevel.county:
        return 3;
    }
  }
}
