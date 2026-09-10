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

import 'package:persistence_core/persistence_core.dart' hide StorageError, XuanError;
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
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
  })  : _schoolsEnsure = _DatasetEnsurer(installer, 'taiyi.schools');

  final TaiyishenshuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _schoolsEnsure;

  // -------------------------------------------------------------------------
  // schools（taiyi.schools）
  // -------------------------------------------------------------------------

  @override
  Future<Result<Page<TaiYiSchoolContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    await _schoolsEnsure.ensure();
    final rows = await db.select(db.taiyiSchoolDocuments).get();
    final items = rows
        .map((r) => TaiYiSchoolContract.fromJson(jsonDecode(r.payloadJson)))
        .toList();
    final paged = items.take(page.limit).toList();
    return Ok(Page(
      items: paged,
      nextCursor: paged.length < items.length ? 'cursor' : null,
    ));
  }

  @override
  Future<Result<TaiYiSchoolContract?>> get(String id, RequestContext ctx) async {
    await _schoolsEnsure.ensure();
    final row = await (db.select(db.taiyiSchoolDocuments)
          ..where((t) => t.fileName.equals('${_toKebab(id)}.json')))
        .getSingleOrNull();
    if (row == null) return const Ok(null);
    return Ok(TaiYiSchoolContract.fromJson(jsonDecode(row.payloadJson)));
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final result = await get(id, ctx);
    return result.map((v) => v != null);
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    await _schoolsEnsure.ensure();
    final rows = await db.select(db.taiyiSchoolDocuments).get();
    return Ok(rows.length);
  }

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
    final res = await get(id, RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => value,
      Err() => null,
    };
  }

  @override
  Future<List<DeityDefinitionContract>> loadAllDeities() async {
    final rows = await db.select(db.taiyiDeityDocuments).get();
    return rows
        .map((r) => DeityDefinitionContract.fromJson(jsonDecode(r.payloadJson)))
        .toList();
  }

  @override
  Future<DeityDefinitionContract?> loadDeity(String id) async {
    final row = await (db.select(db.taiyiDeityDocuments)
          ..where((t) => t.fileName.equals('${_toKebab(id)}.json')))
        .getSingleOrNull();
    if (row == null) return null;
    return DeityDefinitionContract.fromJson(jsonDecode(row.payloadJson));
  }

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

  // -------------------------------------------------------------------------
  // 只读：官方资源库不支持写（照旧桩 throw UnsupportedError）
  // -------------------------------------------------------------------------

  @override
  Future<Result<Rev>> put(TaiYiSchoolContract entity, RequestContext ctx, {Precondition pre = const Unconditional()}) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<Result<void>> delete(String id, RequestContext ctx, {Precondition pre = const Unconditional()}) =>
      throw UnsupportedError('Official repository is read-only');

  // 本后端无事务能力，异常时不回滚已发生的写入
  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      return Ok(await body());
    } on XuanError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: '$e'));
    }
  }
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
    final res = await query({}, PageRequest(limit: 1000), RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => value.items,
      Err() => const [],
    };
  }

  @override
  Future<MingGuaConfigContract?> loadConfig(String id) async {
    final res = await get(id, RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => value,
      Err() => null,
    };
  }

  @override
  Future<void> saveConfig(MingGuaConfigContract config) =>
      throw UnsupportedError('Official configs are read-only');

  @override
  Future<void> deleteConfig(String id) =>
      throw UnsupportedError('Official configs are read-only');

  @override
  Future<Result<Page<MingGuaConfigContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    await _ensure.ensure();
    final row = await (db.select(db.taiyiMingGuaDocuments)
          ..where((t) => t.fileName.equals(_kFileName)))
        .getSingleOrNull();
    if (row == null) {
      return const Ok(Page(items: []));
    }
    final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    final items = [MingGuaConfigContract.fromJson(json)];
    return Ok(Page(items: items));
  }

  @override
  Future<Result<MingGuaConfigContract?>> get(String id, RequestContext ctx) async {
    final result = await query({}, PageRequest(limit: 100), ctx);
    return result.map((page) {
      for (final c in page.items) {
        if (c.id == id) return c;
      }
      return null;
    });
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final result = await get(id, ctx);
    return result.map((v) => v != null);
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final result = await query(spec, PageRequest(limit: 1000), ctx);
    return result.map((page) => page.items.length);
  }

  @override
  Future<Result<Rev>> put(MingGuaConfigContract entity, RequestContext ctx, {Precondition pre = const Unconditional()}) =>
      throw UnsupportedError('Official configs are read-only');

  @override
  Future<Result<void>> delete(String id, RequestContext ctx, {Precondition pre = const Unconditional()}) =>
      throw UnsupportedError('Official configs are read-only');

  // 本后端无事务能力，异常时不回滚已发生的写入
  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      return Ok(await body());
    } on XuanError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: '$e'));
    }
  }
}
