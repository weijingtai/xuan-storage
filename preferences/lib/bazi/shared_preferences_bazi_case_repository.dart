import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';

class SharedPreferencesBaziCaseRepository implements BaziCaseRepository {
  final SharedPreferences prefs;
  final String scopeUid;

  SharedPreferencesBaziCaseRepository(this.prefs, this.scopeUid);

  String _keyFor(String scope) => 'bazi.$scope.cases';
  String get _key => _keyFor(scopeUid);

  Future<Map<String, dynamic>> _loadMapForScope(String scope) async {
    final String? jsonStr = prefs.getString(_keyFor(scope));
    if (jsonStr == null || jsonStr.isEmpty) return {};
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveMapForScope(String scope, Map<String, dynamic> map) async {
    await prefs.setString(_keyFor(scope), jsonEncode(map));
  }

  Future<Map<String, dynamic>> _loadMap() async => _loadMapForScope(scopeUid);
  Future<void> _saveMap(Map<String, dynamic> map) async => _saveMapForScope(scopeUid, map);

  BaziCaseContract _fromJson(Map<String, dynamic> json) {
    return BaziCaseContract(
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      mainQuestion: json['mainQuestion'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthLocationJson: json['birthLocationJson'] as String?,
      gender: json['gender'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      finalSummary: json['finalSummary'] as String?,
    );
  }

  Map<String, dynamic> _toJson(BaziCaseContract c) {
    return {
      'uuid': c.uuid,
      'title': c.title,
      'mainQuestion': c.mainQuestion,
      'birthDate': c.birthDate.toIso8601String(),
      'birthLocationJson': c.birthLocationJson,
      'gender': c.gender,
      'createdAt': c.createdAt.toIso8601String(),
      'updatedAt': c.updatedAt.toIso8601String(),
      'deletedAt': c.deletedAt?.toIso8601String(),
      'finalSummary': c.finalSummary,
    };
  }

  // ── 内部：按 ctx.scopeUid 读写，兼容旧 Key 的 scopeUid ──

  @override
  Future<BaziCaseContract?> getCase(String uuid) async {
    final res = await get(uuid, RequestContext(scopeUid: scopeUid));
    return switch (res) {
      Ok(:final value) => value,
      Err() => null,
    };
  }

  @override
  Future<List<BaziCaseContract>> listCases() async {
    final res = await query({}, PageRequest(limit: 10000), RequestContext(scopeUid: scopeUid));
    return switch (res) {
      Ok(:final value) => value.items,
      Err() => const [],
    };
  }

  @override
  Future<void> saveCase(BaziCaseContract case_) async {
    await put(case_, RequestContext(scopeUid: scopeUid));
  }

  @override
  Future<void> deleteCase(String uuid) async {
    await softDelete(uuid, RequestContext(scopeUid: scopeUid));
  }

  @override
  Future<void> restoreCase(String uuid) async {
    await restore(uuid, RequestContext(scopeUid: scopeUid));
  }

  // ── Readable ──
  @override
  Future<Result<BaziCaseContract?>> get(String id, RequestContext ctx) async {
    try {
      final map = await _loadMapForScope(ctx.scopeUid);
      if (map.containsKey(id)) {
        final c = _fromJson(map[id] as Map<String, dynamic>);
        if (c.deletedAt != null) return const Ok(null);
        return Ok(c);
      }
      return const Ok(null);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final r = await get(id, ctx);
    return r.map((v) => v != null);
  }

  @override
  Future<Result<BaziCaseContract?>> getIncludingDeleted(String id, RequestContext ctx) async {
    try {
      final map = await _loadMapForScope(ctx.scopeUid);
      if (map.containsKey(id)) {
        return Ok(_fromJson(map[id] as Map<String, dynamic>));
      }
      return const Ok(null);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }

  // ── Writable ──
  @override
  Future<Result<Rev>> put(BaziCaseContract entity, RequestContext ctx, {Precondition pre = const Unconditional()}) async {
    try {
      final map = await _loadMapForScope(ctx.scopeUid);
      // 前置条件校验
      final existing = map[entity.uuid];
      final state = existing == null
          ? EntityState.absent
          : (_fromJson(existing as Map<String, dynamic>).deletedAt != null ? EntityState.softDeleted : EntityState.live);
      final preResult = evaluatePrecondition(pre, state);
      if (preResult is Err) return Err((preResult as Err<void>).error);
      map[entity.uuid] = _toJson(entity);
      await _saveMapForScope(ctx.scopeUid, map);
      return Ok(Rev(DateTime.now().microsecondsSinceEpoch.toString()));
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }

  // ── SoftDeletable ──
  @override
  Future<Result<void>> softDelete(String id, RequestContext ctx, {Precondition pre = const Unconditional()}) async {
    try {
      final map = await _loadMapForScope(ctx.scopeUid);
      if (!map.containsKey(id)) return const Ok(null);
      final json = map[id] as Map<String, dynamic>;
      final c = _fromJson(json);
      final state = c.deletedAt != null ? EntityState.softDeleted : EntityState.live;
      final preResult = evaluatePrecondition(pre, state);
      if (preResult is Err) return Err((preResult as Err<void>).error);
      json['deletedAt'] = DateTime.now().toIso8601String();
      await _saveMapForScope(ctx.scopeUid, map);
      return const Ok(null);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    try {
      final map = await _loadMapForScope(ctx.scopeUid);
      if (!map.containsKey(id)) {
        return Err(const XuanError(code: ErrorCode.notFound, message: 'case not found'));
      }
      final json = map[id] as Map<String, dynamic>;
      json['deletedAt'] = null;
      await _saveMapForScope(ctx.scopeUid, map);
      return const Ok(null);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }

  // ── Queryable ──
  @override
  Future<Result<Page<BaziCaseContract>>> query(Map<String, Object?> spec, PageRequest page, RequestContext ctx) async {
    try {
      final map = await _loadMapForScope(ctx.scopeUid);
      var cases = map.values
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .where((c) => c.deletedAt == null)
          .toList();
      cases.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      // 游标分页：cursor 为上次最后一条 uuid
      int start = 0;
      if (page.cursor != null) {
        final idx = cases.indexWhere((c) => c.uuid == page.cursor);
        if (idx != -1) start = idx + 1;
      }
      final end = (start + page.limit).clamp(0, cases.length);
      final items = cases.sublist(start, end);
      final nextCursor = end < cases.length ? items.isNotEmpty ? items.last.uuid : null : null;
      return Ok(Page(items: items, nextCursor: nextCursor));
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async {
    final r = await query(spec, PageRequest(limit: 1000), ctx);
    return r.map((p) => p.items.length);
  }

  // ── BatchWritable ──
  @override
  Future<Result<BatchOutcome<String>>> putAll(List<BaziCaseContract> entities, RequestContext ctx) async {
    final results = <({String id, Result<Rev> result})>[];
    for (final e in entities) {
      final r = await put(e, ctx);
      results.add((id: e.uuid, result: r));
    }
    return Ok(BatchOutcome(results));
  }

  // ── Transactional ──
  // 本后端无事务能力，异常时不回滚已发生的写入
  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final v = await body();
      return Ok(v);
    } on XuanError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }
}
