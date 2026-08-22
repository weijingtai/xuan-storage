/// XRAP 版 daliuren 领域 Repository（照 xrap_qizhengsiyu_repositories.dart）。
///
/// 走 XRAP 协议 + drift 持久化：数据是预构建的 *.sql，启动时由
/// [DatasetInstaller.ensureInstalled] 灌进 [DaliurenDatabase]，查询走 SQLite。
///
/// 实现 `repository-interface-daliuren` 的端口（consuming side）：
/// - [DaLiuRenOfficialDataRepository]（daliuren.official_data）
/// - [DaLiuRenKetiRepository]（daliuren.keti）
/// - [DaLiuRenShenShaDataRepository]（daliuren.shen_sha）
/// - [DaLiuRenSchoolDataRepository]（daliuren.school_dataset，
///   按人类裁定 2026-08-09 以「天干 / 地支两个 school」实现）
library;

import 'dart:convert';

import 'package:persistence_core/persistence_core.dart' hide StorageError;
import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';

import 'drift/daliuren_database.dart';

/// 单个数据集安装的幂等守卫封装。
///
/// 首次调用走 ensureInstalled，之后空操作（照 geo/qizhengsiyu 的 _ensure 模式）。
class _DatasetEnsurer {
  _DatasetEnsurer(this._installer, this._datasetId);

  final DatasetInstaller _installer;
  final String _datasetId;
  bool _ensured = false;

  Future<void> ensure() async {
    if (_ensured) return;
    await _installer.ensureInstalled(_datasetId);
    _ensured = true;
  }
}

/// XRAP 版御定大六壬官方数据 Repository。
class XrapDaLiuRenOfficialDataRepository
    implements DaLiuRenOfficialDataRepository {
  XrapDaLiuRenOfficialDataRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'daliuren.official_data');

  final DaliurenDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  @override
  Future<dynamic> get(String id) async {
    switch (id) {
      case 'yuding':
        return jsonDecode(await _loadDocument('御定大六壬.json')) as List<dynamic>;
      case 'jumapper':
        return jsonDecode(await _loadDocument('ju_mapper.json'))
            as Map<String, dynamic>;
      case 'yangpan':
        final list =
            jsonDecode(await _loadDocument('甲午庚牛羊_阳.json')) as List<dynamic>;
        return list.cast<Map<String, dynamic>>();
      case 'yinpan':
        final list =
            jsonDecode(await _loadDocument('甲午庚牛羊_阴.json')) as List<dynamic>;
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

  Future<String> _loadDocument(String fileName) async {
    await _ensure.ensure();
    final row = await (db.select(db.daliurenOfficialDataDocuments)
          ..where((t) => t.fileName.equals(fileName)))
        .getSingleOrNull();
    if (row == null) {
      throw NotFound(fileName);
    }
    return row.payloadJson;
  }
}

/// XRAP 版课体数据 Repository。
class XrapDaLiuRenKetiRepository implements DaLiuRenKetiRepository {
  XrapDaLiuRenKetiRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'daliuren.keti');

  final DaliurenDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  @override
  Future<List<dynamic>> query([Map<String, Object?>? criteria]) async {
    await _ensure.ensure();
    final row = await (db.select(db.daliurenKetiDocuments)
          ..where((t) => t.fileName.equals('keti_data.json')))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFound('keti_data.json');
    }
    return jsonDecode(row.payloadJson) as List<dynamic>;
  }
}

/// XRAP 版神煞查询表 Repository。
class XrapDaLiuRenShenShaDataRepository
    implements DaLiuRenShenShaDataRepository {
  XrapDaLiuRenShenShaDataRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'daliuren.shen_sha');

  final DaliurenDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  @override
  Future<List<dynamic>> loadGanShenShaRaw() async =>
      _load('6_shensha_gan.json');

  @override
  Future<List<dynamic>> loadYearShenShaRaw() async =>
      _load('6_shensha_year.json');

  @override
  Future<List<dynamic>> loadMonthShenShaRaw() async =>
      _load('6_shensha_month.json');

  @override
  Future<List<dynamic>> loadZhiShenShaRaw() async =>
      _load('6_shensha_zhi.json');

  @override
  Future<List<dynamic>> loadJiShenShaRaw() async => _load('6_shensha_ji.json');

  @override
  Future<List<dynamic>> loadXunShenShaRaw() async =>
      _load('6_shensha_xun.json');

  @override
  Future<List<dynamic>> loadYearGanShenShaRaw() async =>
      _load('6_shensha_year_gan.json');

  @override
  Future<List<dynamic>> loadMonthGanShenShaRaw() async =>
      _load('6_shensha_month_gan.json');

  @override
  Future<List<dynamic>> loadMonthZhiGanShenShaRaw() async =>
      _load('6_shensha_month_zhi_gan.json');

  Future<List<dynamic>> _load(String fileName) async {
    await _ensure.ensure();
    final row = await (db.select(db.daliurenShenShaDocuments)
          ..where((t) => t.fileName.equals(fileName)))
        .getSingleOrNull();
    if (row == null) {
      throw NotFound(fileName);
    }
    return jsonDecode(row.payloadJson) as List<dynamic>;
  }
}

/// XRAP 版学校（流派）数据 Repository。
///
/// 人类裁定 2026-08-09：`daliuren_dataset.json` 源数据为天干 10 / 地支 12
/// 列表，形状与 [DaLiuRenSchoolDataRepository.query] 的
/// [SchoolEntryContract] 不对齐。按裁定以「天干 / 地支两个 school」实现：
/// - `query({'schoolId': '天干'})` → 10 条（schoolId='天干'，title=干名）
/// - `query({'schoolId': '地支'})` → 12 条（schoolId='地支'，title=支名）
/// - 其余 schoolId → 空列表
/// 其余字段（dayJiaZi/juName/keTiNames/...）源数据不提供，取默认值。
class XrapDaLiuRenSchoolDataRepository
    implements DaLiuRenSchoolDataRepository {
  XrapDaLiuRenSchoolDataRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'daliuren.school_dataset');

  final DaliurenDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  @override
  Future<List<SchoolEntryContract>> query([Map<String, Object?>? criteria]) async {
    await _ensure.ensure();
    final row = await (db.select(db.daliurenSchoolDatasetDocuments)
          ..where((t) => t.fileName.equals('daliuren_dataset.json')))
        .getSingleOrNull();
    if (row == null) {
      throw NotFound('daliuren_dataset.json');
    }
    final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    final schoolId = criteria?['schoolId'] as String? ?? '天干';
    final List<String> names;
    if (schoolId == '天干') {
      names = (map['天干'] as List<dynamic>).cast<String>();
    } else if (schoolId == '地支') {
      names = (map['地支'] as List<dynamic>).cast<String>();
    } else {
      return const [];
    }
    return names
        .map((name) => SchoolEntryContract(
              schoolId: schoolId,
              title: name,
              dayJiaZi: '',
              juName: '',
              juNumber: 0,
              keTiNames: const [],
              meaning: '',
              explanation: '',
              prediction: '',
              details: const {},
              bookReferences: const {},
            ))
        .toList();
  }
}
