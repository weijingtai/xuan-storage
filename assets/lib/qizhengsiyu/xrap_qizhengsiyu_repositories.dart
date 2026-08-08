/// XRAP 版 qizhengsiyu 领域 Repository（照 xrap_geo_location_repository.dart）。
///
/// 走 XRAP 协议 + drift 持久化：数据是预构建的 *.sql，启动时由
/// [DatasetInstaller.ensureInstalled] 灌进 [QizhengsiyuDatabase]，查询走 SQLite。
///
/// 实现 `repository-interface-qizhengsiyu` 的端口（consuming side）：
/// - [QiZhengStarPositionStatusRepository]（qizheng.star_position_status）
/// - [QiZhengZhouTianModelRepository]（qizheng.zhou_tian）
/// - [QiZhengEphemerisResourceRepository]（qizheng.ephemeris）
/// - [QiZhengShenShaRepository]（qizheng.shen_sha）
/// - [QiZhengHuaYaoRepository]（qizheng.hua_yao）
/// - [GeJuBuiltInDataSource]（qizheng.ge_ju_rules / qizheng.ge_ju_content）
///
/// QiZhengHistoricalEphemerisRepository 本期不注册（源数据缺失，人类裁定 2026-08-07），
/// 保留旧实现并标注 deprecated。
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart' hide StorageError;
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

import 'drift/qizhengsiyu_database.dart';

/// 单个数据集安装的幂等守卫封装。
///
/// 首次调用走 ensureInstalled，之后空操作（照 geo 的 _ensure 模式）。
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

/// XRAP 版星位庙旺状态 Repository。
class XrapQiZhengStarPositionStatusRepository
    implements QiZhengStarPositionStatusRepository {
  XrapQiZhengStarPositionStatusRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(
          installer,
          'qizheng.star_position_status',
        );

  final QizhengsiyuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  @override
  Future<List<QiZhengStarPositionStatusContract>> loadStarPositionStatus() async {
    await _ensure.ensure();
    final rows = await (db.select(db.starPositionStatuses)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return rows.map((r) {
      return QiZhengStarPositionStatusContract({
        'id': r.id,
        'className': r.className,
        'star': r.star,
        'starPositionStatusType': r.positionStatusType,
        'positionList': jsonDecode(r.positionListJson),
      });
    }).toList();
  }
}

/// XRAP 版周天模型 Repository。
class XrapQiZhengZhouTianModelRepository
    implements QiZhengZhouTianModelRepository {
  XrapQiZhengZhouTianModelRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'qizheng.zhou_tian');

  final QizhengsiyuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  @override
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels() async {
    await _ensure.ensure();
    final rows = await (db.select(db.zhouTianDocuments)
          ..orderBy([(t) => OrderingTerm(expression: t.fileName)]))
        .get();
    return rows.map((r) {
      final map = jsonDecode(r.payloadJson) as Map<String, dynamic>;
      return QiZhengZhouTianModelContract(map);
    }).toList();
  }
}

/// XRAP 版星历资源 Repository（按文件名取整段 JSON 字符串）。
class XrapQiZhengEphemerisResourceRepository
    implements QiZhengEphemerisResourceRepository {
  XrapQiZhengEphemerisResourceRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'qizheng.ephemeris');

  final QizhengsiyuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  @override
  Future<String> loadEphemerisResource(String resourceName) async {
    await _ensure.ensure();
    final row = await (db.select(db.ephemerisDocuments)
          ..where((t) => t.fileName.equals(resourceName)))
        .getSingleOrNull();
    if (row == null) {
      throw StorageError('ephemeris 资源不存在: $resourceName');
    }
    return row.payloadJson;
  }
}

/// XRAP 版神煞 Repository。
class XrapQiZhengShenShaRepository implements QiZhengShenShaRepository {
  XrapQiZhengShenShaRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'qizheng.shen_sha');

  final QizhengsiyuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  Future<List<ShenShaRecordContract>> _load(String fileName) async {
    await _ensure.ensure();
    final row = await (db.select(db.shenShaDocuments)
          ..where((t) => t.fileName.equals(fileName)))
        .getSingleOrNull();
    if (row == null) {
      throw StorageError('神煞资源不存在: $fileName');
    }
    final list = jsonDecode(row.payloadJson) as List<dynamic>;
    return list
        .map((e) => ShenShaRecordContract(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ShenShaRecordContract>> getTianGanShenSha() =>
      _load('74_shensha_tiangan.json');

  @override
  Future<List<ShenShaRecordContract>> getYearDiZhiShenSha() =>
      _load('74_shensha_dizhi_year.json');

  @override
  Future<List<ShenShaRecordContract>> getMonthDiZhiShenSha() =>
      _load('74_shensha_dizhi_month.json');

  @override
  Future<List<ShenShaRecordContract>> getGanZhiShenSha() =>
      _load('74_shensha_ganzhi.json');

  @override
  Future<List<ShenShaRecordContract>> getBundledShenSha() =>
      _load('74_shensha_bundle.json');

  @override
  Future<List<ShenShaRecordContract>> getOtherShenSha() =>
      _load('74_shensha_others.json');
}

/// XRAP 版化曜 Repository。
class XrapQiZhengHuaYaoRepository implements QiZhengHuaYaoRepository {
  XrapQiZhengHuaYaoRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'qizheng.hua_yao');

  final QizhengsiyuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  Future<List<HuaYaoRecordContract>> _load(String fileName) async {
    await _ensure.ensure();
    final row = await (db.select(db.huaYaoDocuments)
          ..where((t) => t.fileName.equals(fileName)))
        .getSingleOrNull();
    if (row == null) {
      throw StorageError('化曜资源不存在: $fileName');
    }
    final list = jsonDecode(row.payloadJson) as List<dynamic>;
    return list
        .map((e) => HuaYaoRecordContract(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<HuaYaoRecordContract>> getTianGanHuaYao() =>
      _load('74_huayao_tiangan.json');

  @override
  Future<List<HuaYaoRecordContract>> getDiZhiHuaYao() =>
      _load('74_huayao_dizhi.json');

  @override
  Future<List<HuaYaoRecordContract>> getOthersHuaYao() =>
      _load('74_huayao_others.json');
}

/// XRAP 版格局内置数据源（rules/content JSON 文档表）。
///
/// 注：格局 sqlite（qizheng.ge_ju）与 rules/content JSON（qizheng.ge_ju_rules /
/// qizheng.ge_ju_content）可能为同一批数据的两种形态，消费方目前两者都读；
/// 是否冗余待阶段 5 消费方切换时统一判定。
class XrapGeJuBuiltInDataSource implements GeJuBuiltInDataSource {
  XrapGeJuBuiltInDataSource({
    required this.db,
    required this.installer,
  })  : _rulesEnsure = _DatasetEnsurer(installer, 'qizheng.ge_ju_rules'),
        _contentEnsure = _DatasetEnsurer(installer, 'qizheng.ge_ju_content');

  final QizhengsiyuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _rulesEnsure;
  final _DatasetEnsurer _contentEnsure;

  /// 从文档表读整份文件并 decode 为 JSON 数组。
  Future<List<Map<String, dynamic>>> _loadJsonList({
    required _DatasetEnsurer ensure,
    required String fileName,
  }) async {
    await ensure.ensure();
    final row = await (db.select(db.geJuRulesDocuments)
          ..where((t) => t.fileName.equals(fileName)))
        .getSingleOrNull();
    if (row == null) {
      throw StorageError('格局 JSON 资源不存在: $fileName');
    }
    final list = jsonDecode(row.payloadJson) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> loadJsonFromAsset(
    String assetPath,
  ) async {
    // assetPath 形如 'assets/qizhengsiyu/ge_ju/rules/jin_xing_ge_ju_rules.json'
    final fileName = assetPath.split('/').last;
    final isRules = assetPath.contains('/rules/');
    return _loadJsonList(
      ensure: isRules ? _rulesEnsure : _contentEnsure,
      fileName: fileName,
    );
  }

  @override
  Future<List<GeJuRuleContract>> loadBuiltInRules() async {
    await _rulesEnsure.ensure();
    final rows = await (db.select(db.geJuRulesDocuments)
          ..orderBy([(t) => OrderingTerm(expression: t.fileName)]))
        .get();
    final rules = <GeJuRuleContract>[];
    for (final row in rows) {
      final list = jsonDecode(row.payloadJson) as List<dynamic>;
      for (final e in list.cast<Map<String, dynamic>>()) {
        final id = e['id'] as String?;
        if (id == null) continue;
        rules.add(GeJuRuleContract(
          id: id,
          name: e['name'] as String? ?? id,
          raw: e,
        ));
      }
    }
    return rules;
  }

  @override
  Future<List<GeJuConditionSetContract>> loadBuiltInConditionSets() async {
    // 条件集从 rules 文档的 variants[].conditions 字段映射（旧实现语义）。
    final rules = await loadBuiltInRules();
    final sets = <GeJuConditionSetContract>[];
    for (final rule in rules) {
      final variants = rule.raw['variants'];
      if (variants is! List) continue;
      for (var i = 0; i < variants.length; i++) {
        final v = variants[i];
        if (v is! Map<String, dynamic>) continue;
        sets.add(GeJuConditionSetContract(
          id: '${rule.id}.variant.$i',
          ruleId: rule.id,
          authorType: 'builtin',
          raw: v,
        ));
      }
    }
    return sets;
  }

  @override
  Future<List<GeJuAnnotationContract>> loadBuiltInAnnotations() async {
    // 注解从 content 文档的 variants 文字字段映射（旧实现语义）。
    await _contentEnsure.ensure();
    final rows = await (db.select(db.geJuContentDocuments)
          ..orderBy([(t) => OrderingTerm(expression: t.fileName)]))
        .get();
    final anns = <GeJuAnnotationContract>[];
    for (final row in rows) {
      final list = jsonDecode(row.payloadJson) as List<dynamic>;
      for (final e in list.cast<Map<String, dynamic>>()) {
        final id = e['id'] as String?;
        if (id == null) continue;
        final variants = e['variants'];
        if (variants is! List) continue;
        for (var i = 0; i < variants.length; i++) {
          final v = variants[i];
          if (v is! Map<String, dynamic>) continue;
          anns.add(GeJuAnnotationContract(
            id: '$id.annotation.$i',
            ruleId: id,
            authorType: 'builtin',
            raw: v,
          ));
        }
      }
    }
    return anns;
  }
}
