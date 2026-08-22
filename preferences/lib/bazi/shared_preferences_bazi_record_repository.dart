import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';

class SharedPreferencesBaziRecordRepository implements BaziRecordRepository {
  final SharedPreferences prefs;
  final String scopeUid;

  SharedPreferencesBaziRecordRepository(this.prefs, this.scopeUid);

  String _keyFor(String scope) => 'bazi.$scope.records';
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

  BaziRecordContract _fromJson(Map<String, dynamic> json) {
    return BaziRecordContract(
      uuid: json['uuid'] as String,
      caseUuid: json['caseUuid'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      chartSnapshotJson: json['chartSnapshotJson'] as String?,
      snapshotSchemaVersion: json['snapshotSchemaVersion'] as int? ?? 1,
      // V1 存量兜底：旧记录以 'eightCharsJson' 为 key 落盘，回退读取避免既有排盘记录丢失
      legacyEightCharsJson:
          (json['legacyEightCharsJson'] ?? json['eightCharsJson']) as String?,
      daYunJson: json['daYunJson'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> _toJson(BaziRecordContract r) {
    return {
      'uuid': r.uuid,
      'caseUuid': r.caseUuid,
      'recordDate': r.recordDate.toIso8601String(),
      'chartSnapshotJson': r.chartSnapshotJson,
      'snapshotSchemaVersion': r.snapshotSchemaVersion,
      'legacyEightCharsJson': r.legacyEightCharsJson,
      'daYunJson': r.daYunJson,
      'note': r.note,
      'createdAt': r.createdAt.toIso8601String(),
    };
  }

  // ── Readable ──
  @override
  Future<Result<BaziRecordContract?>> get(String id, RequestContext ctx) async {
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

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final r = await get(id, ctx);
    return r.map((v) => v != null);
  }

  @override
  Future<Result<BaziRecordContract?>> getIncludingDeleted(String id, RequestContext ctx) => get(id, ctx);

  // ── Writable ──
  @override
  Future<Result<Rev>> put(BaziRecordContract entity, RequestContext ctx, {Precondition pre = const Unconditional()}) async {
    try {
      final map = await _loadMapForScope(ctx.scopeUid);
      final state = map.containsKey(entity.uuid) ? EntityState.live : EntityState.absent;
      final preResult = evaluatePrecondition(pre, state);
      if (preResult is Err) return Err((preResult as Err<void>).error);
      map[entity.uuid] = _toJson(entity);
      await _saveMapForScope(ctx.scopeUid, map);
      return Ok(Rev(DateTime.now().microsecondsSinceEpoch.toString()));
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }

  // ── SoftDeletable (BaziRecord 无 deletedAt 字段，软删按硬删处理) ──
  @override
  Future<Result<void>> softDelete(String id, RequestContext ctx, {Precondition pre = const Unconditional()}) async {
    try {
      final map = await _loadMapForScope(ctx.scopeUid);
      if (!map.containsKey(id)) return const Ok(null);
      final state = EntityState.live;
      final preResult = evaluatePrecondition(pre, state);
      if (preResult is Err) return Err((preResult as Err<void>).error);
      map.remove(id);
      await _saveMapForScope(ctx.scopeUid, map);
      return const Ok(null);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: e.toString()));
    }
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    return Err(const XuanError(code: ErrorCode.invalidArgument, message: 'BaziRecord 不支持 restore（无 deletedAt）'));
  }

  // ── Queryable ──
  @override
  Future<Result<Page<BaziRecordContract>>> query(Map<String, Object?> spec, PageRequest page, RequestContext ctx) async {
    try {
      final map = await _loadMapForScope(ctx.scopeUid);
      var records = map.values.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
      // 若 spec 带 caseUuid 则过滤（兼容 listRecords 语义）
      final caseUuid = spec['caseUuid'] ?? spec['case_uuid'];
      if (caseUuid is String && caseUuid.isNotEmpty) {
        records = records.where((r) => r.caseUuid == caseUuid).toList();
      }
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      int start = 0;
      if (page.cursor != null) {
        final idx = records.indexWhere((r) => r.uuid == page.cursor);
        if (idx != -1) start = idx + 1;
      }
      final end = (start + page.limit).clamp(0, records.length);
      final items = records.sublist(start, end);
      final nextCursor = end < records.length ? (items.isNotEmpty ? items.last.uuid : null) : null;
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
  Future<Result<BatchOutcome<String>>> putAll(List<BaziRecordContract> entities, RequestContext ctx) async {
    final results = <({String id, Result<Rev> result})>[];
    for (final e in entities) {
      final r = await put(e, ctx);
      results.add((id: e.uuid, result: r));
    }
    return Ok(BatchOutcome(results));
  }

  // ── Transactional ──
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
