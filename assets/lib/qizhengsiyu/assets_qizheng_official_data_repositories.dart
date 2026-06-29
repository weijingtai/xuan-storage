import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

class AssetsQiZhengStarPositionStatusRepository
    implements QiZhengStarPositionStatusRepository {
  final String _assetPath;

  const AssetsQiZhengStarPositionStatusRepository({
    String assetPath = 'assets/qizhengsiyu/star_position_status.json',
  }) : _assetPath = assetPath;

  @override
  Future<List<QiZhengStarPositionStatusContract>> loadStarPositionStatus() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((j) => QiZhengStarPositionStatusContract(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageError('Failed to load star position status from $_assetPath: $e');
    }
  }
}

class AssetsQiZhengHistoricalEphemerisRepository
    implements QiZhengHistoricalEphemerisRepository {
  final String _assetPath;

  const AssetsQiZhengHistoricalEphemerisRepository({
    String assetPath = 'assets/historical_ephemeris/sun_speeds.json',
  }) : _assetPath = assetPath;

  @override
  Future<Map<String, dynamic>> loadHistoricalEphemeris() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageError('Failed to load historical ephemeris from $_assetPath: $e');
    }
  }
}

class AssetsQiZhengEphemerisResourceRepository
    implements QiZhengEphemerisResourceRepository {
  final String _prefix;

  const AssetsQiZhengEphemerisResourceRepository({
    String prefix = 'assets/qizhengsiyu/',
  }) : _prefix = prefix;

  @override
  Future<String> loadEphemerisResource(String resourceName) async {
    final fullPath = '$_prefix$resourceName';
    try {
      return await rootBundle.loadString(fullPath);
    } catch (e) {
      throw StorageError('Failed to load ephemeris resource from $fullPath: $e');
    }
  }
}

class AssetsQiZhengZhouTianModelRepository
    implements QiZhengZhouTianModelRepository {
  final List<String> _assetPaths;

  const AssetsQiZhengZhouTianModelRepository({
    List<String> assetPaths = const [
      'assets/qizhengsiyu/ecliptic_tropical_morden.json',
      'assets/qizhengsiyu/ecliptic_tropical_classical_adjusted.json',
      'assets/qizhengsiyu/ecliptic_tropical_classical.json',
    ],
  }) : _assetPaths = assetPaths;

  @override
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels() async {
    final models = <QiZhengZhouTianModelContract>[];
    for (final path in _assetPaths) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        models.add(QiZhengZhouTianModelContract(jsonMap));
      } catch (e) {
        throw StorageError('Failed to load ZhouTian model from $path: $e');
      }
    }
    return models;
  }
}

class AssetsQiZhengShenShaRepository implements QiZhengShenShaRepository {
  const AssetsQiZhengShenShaRepository();

  Future<List<ShenShaRecordContract>> _loadFromAsset(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final list = json.decode(jsonString) as List;
    return list
        .map((e) => ShenShaRecordContract(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ShenShaRecordContract>> getTianGanShenSha() =>
      _loadFromAsset('assets/shen_sha/74_shensha_tiangan.json');

  @override
  Future<List<ShenShaRecordContract>> getYearDiZhiShenSha() =>
      _loadFromAsset('assets/shen_sha/74_shensha_dizhi_year.json');

  @override
  Future<List<ShenShaRecordContract>> getMonthDiZhiShenSha() =>
      _loadFromAsset('assets/shen_sha/74_shensha_dizhi_month.json');

  @override
  Future<List<ShenShaRecordContract>> getGanZhiShenSha() =>
      _loadFromAsset('assets/shen_sha/74_shensha_ganzhi.json');

  @override
  Future<List<ShenShaRecordContract>> getBundledShenSha() =>
      _loadFromAsset('assets/shen_sha/74_shensha_bundle.json');

  @override
  Future<List<ShenShaRecordContract>> getOtherShenSha() =>
      _loadFromAsset('assets/shen_sha/74_shensha_others.json');
}

class AssetsQiZhengHuaYaoRepository implements QiZhengHuaYaoRepository {
  const AssetsQiZhengHuaYaoRepository();

  Future<List<HuaYaoRecordContract>> _loadFromAsset(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final list = json.decode(jsonString) as List;
    return list
        .map((e) => HuaYaoRecordContract(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<HuaYaoRecordContract>> getTianGanHuaYao() =>
      _loadFromAsset('assets/shen_sha/74_huayao_tiangan.json');

  @override
  Future<List<HuaYaoRecordContract>> getDiZhiHuaYao() =>
      _loadFromAsset('assets/shen_sha/74_huayao_dizhi.json');

  @override
  Future<List<HuaYaoRecordContract>> getOthersHuaYao() =>
      _loadFromAsset('assets/shen_sha/74_huayao_others.json');
}
