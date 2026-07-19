import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';

/// Assets-backed implementation of DaLiuRenOfficialDataRepository.
/// Reads JSON files from the daliuren module's asset bundle.
class AssetsDaLiuRenOfficialDataRepository
    implements DaLiuRenOfficialDataRepository {
  const AssetsDaLiuRenOfficialDataRepository();

  static const String _prefix = 'packages/daliuren/assets/da_liu_ren/';

  @override
  Future<List<dynamic>> loadYuDingData() async {
    final raw = await rootBundle.loadString('${_prefix}御定大六壬.json');
    return json.decode(raw) as List<dynamic>;
  }

  @override
  Future<Map<String, dynamic>> loadJuMapperData() async {
    final raw = await rootBundle.loadString('${_prefix}ju_mapper.json');
    return json.decode(raw) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> loadYangPanData() async {
    final raw = await rootBundle.loadString('${_prefix}甲午庚牛羊_阳.json');
    final list = json.decode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> loadYinPanData() async {
    final raw = await rootBundle.loadString('${_prefix}甲午庚牛羊_阴.json');
    final list = json.decode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}

/// Assets-backed implementation of DaLiuRenKetiRepository.
class AssetsDaLiuRenKetiRepository implements DaLiuRenKetiRepository {
  const AssetsDaLiuRenKetiRepository();

  static const String _prefix = 'packages/daliuren/assets/da_liu_ren/';

  @override
  Future<List<dynamic>> loadKetiData() async {
    final raw = await rootBundle.loadString('${_prefix}keti_data.json');
    return json.decode(raw) as List<dynamic>;
  }
}

/// Assets-backed implementation of DaLiuRenShenShaDataRepository.
/// Reads shen_sha JSON files from the daliuren module's asset bundle.
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

/// Assets-backed implementation of DaLiuRenSchoolDataRepository.
class AssetsDaLiuRenSchoolDataRepository
    implements DaLiuRenSchoolDataRepository {
  const AssetsDaLiuRenSchoolDataRepository();

  @override
  Future<List<SchoolEntryContract>> loadEntries(String schoolId) async {
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
