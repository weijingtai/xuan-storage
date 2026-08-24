import 'dart:convert';
import 'package:drift/drift.dart';
import 'taiyi_database.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart' show TaiYiSchool, DeityDefinition;
import 'drift_user_mapper.dart';

/// 用户流派（School / UserSchool）L0 切片的 Drift 实现。
class DriftUserRepository implements SchoolRepository, UserSchoolRepository {
  DriftUserRepository(this.db, {this.scopeUid});

  final TaiYiDatabase db;
  final String? scopeUid;

  RequestContext get _ctx => RequestContext(scopeUid: scopeUid ?? '');

  // ── 领域便捷方法（非切片成员，保留给既有调用方） ──

  Future<List<TaiYiSchoolContract>> loadUserSchools() async {
    final query = db.select(db.userSchools);
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!));
    }
    final rows = await query.get();
    return rows.map((row) => TaiYiSchool.fromJson(jsonDecode(row.contentJson)).toContract()).toList();
  }

  Future<void> saveUserSchool(TaiYiSchoolContract school) => put(school, _ctx);

  Future<void> deleteUserSchool(String id) async => _hardDeleteSchool(id);

  Future<void> delete(String id) => _hardDeleteSchool(id);

  // ── L0 Readable ──

  @override
  Future<Result<TaiYiSchoolContract?>> get(String id, RequestContext ctx) async {
    final row = await _schoolRowById(id);
    if (row == null) return const Ok(null);
    return Ok(TaiYiSchool.fromJson(jsonDecode(row.contentJson)).toContract());
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final row = await _schoolRowById(id);
    return Ok(row != null);
  }

  // ── L0 Writable ──

  @override
  Future<Result<Rev>> put(
    TaiYiSchoolContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    await db.into(db.userSchools).insertOnConflictUpdate(
      UserSchoolsCompanion(
        id: Value(entity.id),
        name: Value(entity.name),
        source: Value(entity.source),
        contentJson: Value(jsonEncode(entity.toModel().toJson())),
        scopeUid: Value(scopeUid),
      ),
    );
    return Ok(Rev(entity.id));
  }

  // ── L0 Queryable ──

  @override
  Future<Result<Page<TaiYiSchoolContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final all = await loadUserSchools();
    final start = page.cursor == null ? 0 : int.tryParse(page.cursor!) ?? 0;
    final end = (start + page.limit).clamp(0, all.length);
    return Ok(Page<TaiYiSchoolContract>(
      items: all.sublist(start, end),
      nextCursor: end < all.length ? '$end' : null,
    ));
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final query = db.select(db.userSchools);
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!) | t.scopeUid.isNull());
    }
    final rows = await query.get();
    return Ok(rows.length);
  }

  // ── L0 Transactional ──

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final result = await db.transaction(() => body());
      return Ok(result);
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: 'user school transaction failed: $e',
      ));
    }
  }

  // ── 内部工具 ──

  Future<UserSchool?> _schoolRowById(String id) async {
    final query = db.select(db.userSchools)..where((t) => t.id.equals(id));
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!) | t.scopeUid.isNull());
    }
    return query.getSingleOrNull();
  }

  Future<void> _hardDeleteSchool(String id) async {
    final query = db.delete(db.userSchools)..where((t) => t.id.equals(id));
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!));
    }
    await query.go();
  }
}

/// 用户神明（Deity）L0 切片的 Drift 实现。
///
/// 与 [DriftUserRepository] 同库不同表（user_deITIES），按接口拆分独立成类。
class DriftDeityRepository implements DeityRepository {
  DriftDeityRepository(this.db, {this.scopeUid});

  final TaiYiDatabase db;
  final String? scopeUid;

  RequestContext get _ctx => RequestContext(scopeUid: scopeUid ?? '');

  // ── 领域便捷方法（保留给既有调用方） ──

  Future<List<DeityDefinitionContract>> loadAllDeities() async {
    final query = db.select(db.userDeities);
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!) | t.scopeUid.isNull());
    }
    final rows = await query.get();
    return rows.map((row) => DeityDefinition.fromJson(jsonDecode(row.contentJson)).toContract()).toList();
  }

  Future<List<DeityDefinitionContract>> loadUserDeities() async {
    final query = db.select(db.userDeities);
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!));
    }
    final rows = await query.get();
    return rows.map((row) => DeityDefinition.fromJson(jsonDecode(row.contentJson)).toContract()).toList();
  }

  Future<void> saveUserDeity(DeityDefinitionContract deity) => put(deity, _ctx);

  Future<void> deleteDeity(String id) => _hardDeleteDeity(id);

  Future<void> deleteUserDeity(String id) => _hardDeleteDeity(id);

  // ── L0 Readable ──

  @override
  Future<Result<DeityDefinitionContract?>> get(String id, RequestContext ctx) async {
    final row = await _deityRowById(id);
    if (row == null) return const Ok(null);
    return Ok(DeityDefinition.fromJson(jsonDecode(row.contentJson)).toContract());
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final row = await _deityRowById(id);
    return Ok(row != null);
  }

  /// 兼容旧调用：按 id 读取神明定义。
  Future<DeityDefinitionContract?> loadDeity(String id) async {
    final r = await get(id, _ctx);
    return switch (r) {
      Ok(:final value) => value,
      Err() => null,
    };
  }

  // ── L0 Writable ──

  @override
  Future<Result<Rev>> put(
    DeityDefinitionContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    await db.into(db.userDeities).insertOnConflictUpdate(
      UserDeitiesCompanion(
        id: Value(entity.id),
        name: Value(entity.name),
        source: Value(entity.source),
        contentJson: Value(jsonEncode(entity.toModel().toJson())),
        scopeUid: Value(scopeUid),
      ),
    );
    return Ok(Rev(entity.id));
  }

  // ── L0 Queryable ──

  @override
  Future<Result<Page<DeityDefinitionContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final all = await loadUserDeities();
    final start = page.cursor == null ? 0 : int.tryParse(page.cursor!) ?? 0;
    final end = (start + page.limit).clamp(0, all.length);
    return Ok(Page<DeityDefinitionContract>(
      items: all.sublist(start, end),
      nextCursor: end < all.length ? '$end' : null,
    ));
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final all = await loadAllDeities();
    return Ok(all.length);
  }

  // ── L0 Transactional ──

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final result = await db.transaction(() => body());
      return Ok(result);
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: 'deity transaction failed: $e',
      ));
    }
  }

  // ── 内部工具 ──

  Future<UserDeities?> _deityRowById(String id) async {
    final query = db.select(db.userDeities)..where((t) => t.id.equals(id));
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!) | t.scopeUid.isNull());
    }
    return query.getSingleOrNull();
  }

  Future<void> _hardDeleteDeity(String id) async {
    final query = db.delete(db.userDeities)..where((t) => t.id.equals(id));
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!));
    }
    await query.go();
  }
}
