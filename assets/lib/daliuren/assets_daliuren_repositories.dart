import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';

/// ⚠️ 旧实现（deprecated）：直接 rootBundle 直读 asset JSON，不走 XRAP。
///
/// 大六壬数据资源已迁入 persistence_assets 并按 XRAP 协议注册
/// （见 `daliuren_datasets.dart` + `xrap_daliuren_repositories.dart`）。
/// 本文件保留仅为消费方（xuan-shell）切换过渡期兼容，
/// 消费方应改用 XRAP 版 Repository（XrapDaLiuRen*）。新代码不得引用本文件。
@Deprecated('用 XrapDaLiuRenOfficialDataRepository（XRAP 协议链路）替代，见 daliuren_datasets.dart')
class AssetsDaLiuRenOfficialDataRepository
    implements DaLiuRenOfficialDataRepository {
  const AssetsDaLiuRenOfficialDataRepository();

  static const String _prefix = 'packages/daliuren/assets/da_liu_ren/';

  @override
  Future<dynamic> get(String id) async {
    switch (id) {
      case 'yuding':
        final raw = await rootBundle.loadString('${_prefix}御定大六壬.json');
        return json.decode(raw) as List<dynamic>;
      case 'jumapper':
        final raw = await rootBundle.loadString('${_prefix}ju_mapper.json');
        return json.decode(raw) as Map<String, dynamic>;
      case 'yangpan':
        final raw = await rootBundle.loadString('${_prefix}甲午庚牛羊_阳.json');
        final list = json.decode(raw) as List<dynamic>;
        return list.cast<Map<String, dynamic>>();
      case 'yinpan':
        final raw = await rootBundle.loadString('${_prefix}甲午庚牛羊_阴.json');
        final list = json.decode(raw) as List<dynamic>;
        return list.cast<Map<String, dynamic>>();
      default:
        throw ArgumentError('Unknown id: $id');
    }
  }

  @override
  Future<List<dynamic>> query([Map<String, Object?>? criteria]) async {
    final type = criteria?['type'] as String? ?? 'yuding';
    return get(type) as Future<List<dynamic>>;
  }
}

/// ⚠️ 旧实现（deprecated）：直接 rootBundle 直读 asset JSON，不走 XRAP。
///
/// 大六壬数据资源已迁入 persistence_assets 并按 XRAP 协议注册
/// （见 `daliuren_datasets.dart` + `xrap_daliuren_repositories.dart`）。
/// 消费方应改用 XRAP 版 Repository（XrapDaLiuRenKetiRepository）。
@Deprecated('用 XrapDaLiuRenKetiRepository（XRAP 协议链路）替代，见 daliuren_datasets.dart')
class AssetsDaLiuRenKetiRepository implements DaLiuRenKetiRepository {
  const AssetsDaLiuRenKetiRepository();

  static const String _prefix = 'packages/daliuren/assets/da_liu_ren/';

  @override
  Future<List<dynamic>> query([Map<String, Object?>? criteria]) async {
    final raw = await rootBundle.loadString('${_prefix}keti_data.json');
    return json.decode(raw) as List<dynamic>;
  }
}

/// ⚠️ 旧实现（deprecated）：直接 rootBundle 直读 asset JSON，不走 XRAP。
///
/// 大六壬数据资源已迁入 persistence_assets 并按 XRAP 协议注册
/// （见 `daliuren_datasets.dart` + `xrap_daliuren_repositories.dart`）。
/// 消费方应改用 XRAP 版 Repository（XrapDaLiuRenShenShaDataRepository）。
@Deprecated('用 XrapDaLiuRenShenShaDataRepository（XRAP 协议链路）替代，见 daliuren_datasets.dart')
class AssetsDaLiuRenShenShaDataRepository
    implements DaLiuRenShenShaDataRepository {
  const AssetsDaLiuRenShenShaDataRepository();

  static const String _prefix = 'packages/daliuren/assets/shen_sha/';

  @override
  Future<List<dynamic>> loadGanShenShaRaw() async =>
      _load('${_prefix}6_shensha_gan.json');

  @override
  Future<List<dynamic>> loadYearShenShaRaw() async =>
      _load('${_prefix}6_shensha_year.json');

  @override
  Future<List<dynamic>> loadMonthShenShaRaw() async =>
      _load('${_prefix}6_shensha_month.json');

  @override
  Future<List<dynamic>> loadZhiShenShaRaw() async =>
      _load('${_prefix}6_shensha_zhi.json');

  @override
  Future<List<dynamic>> loadJiShenShaRaw() async =>
      _load('${_prefix}6_shensha_ji.json');

  @override
  Future<List<dynamic>> loadXunShenShaRaw() async =>
      _load('${_prefix}6_shensha_xun.json');

  @override
  Future<List<dynamic>> loadYearGanShenShaRaw() async =>
      _load('${_prefix}6_shensha_year_gan.json');

  @override
  Future<List<dynamic>> loadMonthGanShenShaRaw() async =>
      _load('${_prefix}6_shensha_month_gan.json');

  @override
  Future<List<dynamic>> loadMonthZhiGanShenShaRaw() async =>
      _load('${_prefix}6_shensha_month_zhi_gan.json');

  Future<List<dynamic>> _load(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      return json.decode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }
}

/// ⚠️ 旧实现（deprecated）：直接 rootBundle 直读 asset JSON，不走 XRAP。
///
/// 大六壬数据资源已迁入 persistence_assets 并按 XRAP 协议注册
/// （见 `daliuren_datasets.dart` + `xrap_daliuren_repositories.dart`）。
/// 消费方应改用 XRAP 版 Repository（XrapDaLiuRenSchoolDataRepository）。
@Deprecated('用 XrapDaLiuRenSchoolDataRepository（XRAP 协议链路）替代，见 daliuren_datasets.dart')
class AssetsDaLiuRenSchoolDataRepository
    implements DaLiuRenSchoolDataRepository {
  const AssetsDaLiuRenSchoolDataRepository();

  @override
  Future<List<SchoolEntryContract>> query([Map<String, Object?>? criteria]) async {
    try {
      final raw = await rootBundle.loadString(
        'packages/daliuren/assets/dataset/daliuren_dataset.json',
      );
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => _parseEntry(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  SchoolEntryContract _parseEntry(Map<String, dynamic> json) {
    return SchoolEntryContract(
      schoolId: json['schoolId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dayJiaZi: json['dayJiaZi'] as String? ?? '',
      juName: json['juName'] as String? ?? '',
      juNumber: json['juNumber'] as int? ?? 0,
      keTiNames: (json['keTiNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      meaning: json['meaning'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      prediction: json['prediction'] as String? ?? '',
      details: (json['details'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      bookReferences: (json['bookReferences'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
    );
  }
}
