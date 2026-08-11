/// XRAP 版 taiyishenshu 领域 Repository（照 xrap_daliuren_repositories.dart）。
///
/// 走 XRAP 协议 + drift 持久化：数据是预构建的 *.sql，启动时由
/// [DatasetInstaller.ensureInstalled] 灌进 [TaiyishenshuDatabase]，查询走 SQLite。
///
/// 实现 `repository-interface-taiyishenshu` 的端口（consuming side）：
/// - [SchoolRepository]（taiyi.schools + taiyi.deities）
/// - [MingGuaRepository]（taiyi.minggua，人类裁定迁入）
///
/// 与旧桩 `OfficialJsonSchoolRepository` 的差异：本实现不依赖
/// `package:taiyishenshu` 领域模型，直接用契约类的 fromJson 解析
/// （契约仓自带 freezed fromJson），保持 storage 包零模型耦合。
library;

import 'dart:convert';

import 'package:persistence_core/persistence_core.dart' hide StorageError;
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

import 'drift/taiyishenshu_database.dart';

/// 单个数据集安装的幂等守卫封装。
///
/// 首次调用走 ensureInstalled，之后空操作（照 geo/qizhengsiyu/daliuren 的 _ensure 模式）。
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

/// camelCase id -> kebab-case 文件名（照旧桩 `_toKebabCase` 的行为：
/// shell 传 47 个 camelCase deityIds，deities/ 文件为 kebab 命名）。
String _toKebab(String id) {
  return id
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (m) => '${m.group(1)}-${m.group(2)!.toLowerCase()}',
      )
      .toLowerCase();
}

/// XRAP 版官方学派 + 神将 Repository（8 方法合一，照契约 SchoolRepository）。
class XrapTaiyiSchoolRepository implements SchoolRepository {
  XrapTaiyiSchoolRepository({
    required this.db,
    required this.installer,
  })  : _schoolsEnsure = _DatasetEnsurer(installer, 'taiyi.schools'),
        _deitiesEnsure = _DatasetEnsurer(installer, 'taiyi.deities');

  final TaiyishenshuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _schoolsEnsure;
  final _DatasetEnsurer _deitiesEnsure;

  // -------------------------------------------------------------------------
  // schools（taiyi.schools）
  // -------------------------------------------------------------------------

  @override
  Future<List<TaiYiSchoolContract>> loadAllSchools() async {
    await _schoolsEnsure.ensure();
    final rows = await db.select(db.taiyiSchoolDocuments).get();
    return rows
        .map((r) => TaiYiSchoolContract.fromJson(jsonDecode(r.payloadJson)))
        .toList();
  }

  @override
  Future<TaiYiSchoolContract?> loadSchool(String id) async {
    await _schoolsEnsure.ensure();
    final row = await (db.select(db.taiyiSchoolDocuments)
          ..where((t) => t.fileName.equals('${_toKebab(id)}.json')))
        .getSingleOrNull();
    if (row == null) return null;
    return TaiYiSchoolContract.fromJson(jsonDecode(row.payloadJson));
  }

  // -------------------------------------------------------------------------
  // deities（taiyi.deities）
  // -------------------------------------------------------------------------

  @override
  Future<List<DeityDefinitionContract>> loadAllDeities() async {
    await _deitiesEnsure.ensure();
    final rows = await db.select(db.taiyiDeityDocuments).get();
    return rows
        .map((r) => DeityDefinitionContract.fromJson(jsonDecode(r.payloadJson)))
        .toList();
  }

  @override
  Future<DeityDefinitionContract?> loadDeity(String id) async {
    await _deitiesEnsure.ensure();
    final row = await (db.select(db.taiyiDeityDocuments)
          ..where((t) => t.fileName.equals('${_toKebab(id)}.json')))
        .getSingleOrNull();
    if (row == null) return null;
    return DeityDefinitionContract.fromJson(jsonDecode(row.payloadJson));
  }

  // -------------------------------------------------------------------------
  // 只读：官方资源库不支持写（照旧桩 throw UnsupportedError）
  // -------------------------------------------------------------------------

  @override
  Future<void> saveSchool(TaiYiSchoolContract school) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> saveDeity(DeityDefinitionContract deity) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> deleteSchool(String id) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> deleteDeity(String id) =>
      throw UnsupportedError('Official repository is read-only');
}

/// XRAP 版太乙命卦配置 Repository（taiyi.minggua，人类裁定迁入）。
class XrapTaiyiMingGuaRepository implements MingGuaRepository {
  XrapTaiyiMingGuaRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'taiyi.minggua');

  final TaiyishenshuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  static const _kFileName = 'tong_zong_sequence.json';

  @override
  Future<List<MingGuaConfigContract>> loadAllConfigs() async {
    await _ensure.ensure();
    final row = await (db.select(db.taiyiMingGuaDocuments)
          ..where((t) => t.fileName.equals(_kFileName)))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFound('tong_zong_sequence.json');
    }
    final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    return [MingGuaConfigContract.fromJson(json)];
  }

  @override
  Future<MingGuaConfigContract?> loadConfig(String id) async {
    final configs = await loadAllConfigs();
    for (final c in configs) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> saveConfig(MingGuaConfigContract config) =>
      throw UnsupportedError('Official configs are read-only');

  @override
  Future<void> deleteConfig(String id) =>
      throw UnsupportedError('Official configs are read-only');
}
