import 'dart:convert';

import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_kanyu/repository_interface_kanyu.dart';

import 'drift/kanyu_database.dart';

/// XRAP 版官方规则配置 Repository 实现（三元九星、八宅规则、罗盘图层）
///
/// 实现 L0 切片: `Readable<dynamic, String>` + `Queryable<dynamic, Map<String, Object?>>`
class XrapKanyuOfficialRuleRepository
    implements
        Readable<dynamic, String>,
        Queryable<dynamic, Map<String, Object?>> {
  XrapKanyuOfficialRuleRepository({
    required this.db,
  });

  final KanyuDatabase db;

  @override
  Future<Result<dynamic>> get(String id, RequestContext ctx) async {
    try {
      final data = await _loadDataById(id);
      if (data == null) {
        return const Ok(null);
      }
      return Ok(data);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: '加载官方规则失败: $id'));
    }
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final result = await get(id, ctx);
    return result.map((v) => v != null);
  }

  @override
  Future<Result<Page<dynamic>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    try {
      final type = spec['type'] as String?;
      if (type == null) {
        return const Err(XuanError(code: ErrorCode.invalidArgument, message: 'query 必须指定 type 字段'));
      }

      final items = await _loadDataByType(type);
      final pagedItems = items.take(page.limit).toList();

      return Ok(Page(
        items: pagedItems,
        nextCursor: pagedItems.length < items.length ? 'cursor' : null,
      ));
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: '查询官方规则失败'));
    }
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    try {
      final type = spec['type'] as String?;
      if (type == null) {
        return const Ok(0);
      }

      final items = await _loadDataByType(type);
      return Ok(items.length);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: '计数官方规则失败'));
    }
  }

  /// 根据 ID 加载数据
  Future<dynamic> _loadDataById(String id) async {
    switch (id) {
      case 'sanyuan_nine_stars':
        return await _loadSanyuanNineStars();
      case 'bazhai_rules':
        return await _loadBazhaiRules();
      default:
        return null;
    }
  }

  /// 根据类型加载数据列表
  Future<List<dynamic>> _loadDataByType(String type) async {
    switch (type) {
      case 'luopan_layer':
        return await _loadLuopanLayers();
      default:
        return [];
    }
  }

  /// 加载三元九星配置
  Future<Map<String, dynamic>> _loadSanyuanNineStars() async {
    final rows = await db.select(db.kanyuStaticDataDocuments).get();
    for (final row in rows) {
      if (row.fileName.contains('nine_yun') || row.fileName.contains('sanyuan')) {
        return jsonDecode(row.payloadJson) as Map<String, dynamic>;
      }
    }
    return const {};
  }

  /// 加载八宅规则
  Future<Map<String, dynamic>> _loadBazhaiRules() async {
    final rows = await db.select(db.kanyuRuleDocuments).get();
    for (final row in rows) {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      if (json['category'] == 'bazhai' || json['ruleId']?.toString().contains('bazhai') == true) {
        return json;
      }
    }
    return const {};
  }

  /// 加载罗盘图层定义
  Future<List<Map<String, dynamic>>> _loadLuopanLayers() async {
    final layers = <Map<String, dynamic>>[];

    // 从 static_data 加载图层数据
    final dataRows = await db.select(db.kanyuStaticDataDocuments).get();
    for (final row in dataRows) {
      if (row.fileName.contains('layer') || row.fileName.contains('luopan')) {
        final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
        layers.add(json);
      }
    }

    // 从 rules 加载图层规则
    final ruleRows = await db.select(db.kanyuRuleDocuments).get();
    for (final row in ruleRows) {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      if (json['type'] == 'luopan_layer' || json['category'] == 'luopan') {
        layers.add(json);
      }
    }

    return layers;
  }
}
