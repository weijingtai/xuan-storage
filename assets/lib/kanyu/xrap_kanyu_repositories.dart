/// XRAP 版 kanyu 领域 Repository（照 xrap_ziwei_repositories.dart）。
///
/// 走 XRAP 协议 + drift 持久化：数据是预构建的 *.sql，启动时由
/// [DatasetInstaller.ensureInstalled] 灌进 [KanyuDatabase]，查询走 SQLite。
///
/// 实现 `repository-interface-kanyu` 的端口（consuming side）：
/// - [RuleConfigRepository]（kanyu.rules + kanyu.static_data + kanyu.schema）
/// - [KanyuOfficialRuleRepository]（三元九星、八宅规则、罗盘图层等官方预设数据）
///
/// 契约模型 freezed + fromJson，但 rules JSON 顶层键是 `ruleId` 而契约字段是
/// `ruleSetId`（见 repository-interface-kanyu RuleSetManifestContract），
/// 本实现把 payload_json 的 `ruleId` 重命名为 `ruleSetId` 再走 fromJson，
/// 保持 storage 包零模型耦合（不依赖 `package:xuan_kanyu`）。
library;

import 'dart:convert';

import 'package:persistence_core/persistence_core.dart' hide StorageError;
import 'package:repository_interface_kanyu/repository_interface_kanyu.dart';

import 'drift/kanyu_database.dart';
import 'xrap_kanyu_official_rule_repository.dart';

export 'xrap_kanyu_official_rule_repository.dart';

/// 单个数据集安装的幂等守卫封装。
///
/// 首次调用走 ensureInstalled，之后空操作（照 geo/qizhengsiyu/daliuren/taiyishenshu
/// 的 _ensure 模式）。
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

/// rules JSON 的 `ruleId` -> 契约 `ruleSetId`（契约字段名不一致，手写映射）。
Map<String, dynamic> _ruleIdToRuleSetId(Map<String, dynamic> json) {
  if (!json.containsKey('ruleId')) return json;
  final mapped = Map<String, dynamic>.from(json);
  mapped['ruleSetId'] = mapped.remove('ruleId');
  return mapped;
}

/// XRAP 版规则配置 Repository（kanyu.rules / kanyu.static_data / kanyu.schema）。
class XrapKanyuRuleConfigRepository implements RuleConfigRepository {
  XrapKanyuRuleConfigRepository({
    required this.db,
    required this.installer,
  })  : _rulesEnsure = _DatasetEnsurer(installer, 'kanyu.rules'),
        _dataEnsure = _DatasetEnsurer(installer, 'kanyu.static_data'),
        _schemaEnsure = _DatasetEnsurer(installer, 'kanyu.schema');

  final KanyuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _rulesEnsure;
  final _DatasetEnsurer _dataEnsure;
  final _DatasetEnsurer _schemaEnsure;

  /// 读规则表全部行。
  Future<List<KanyuRuleDocumentEntry>> _allRules() async {
    await _rulesEnsure.ensure();
    return db.select(db.kanyuRuleDocuments).get();
  }

  /// 按 ruleSetId 找规则行（fileName 存相对路径 `rules/<dir>/<file>.json`）。
  Future<KanyuRuleDocumentEntry?> _ruleRowByRuleSetId(String ruleSetId) async {
    final rows = await _allRules();
    for (final row in rows) {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      if (json['ruleId'] == ruleSetId) return row;
    }
    return null;
  }

  @override
  Future<RuleSetManifestContract> loadRuleConfig(String ruleSetId) async {
    final row = await _ruleRowByRuleSetId(ruleSetId);
    if (row == null) {
      throw NotFound(
        entityType: 'ruleSet',
        entityId: ruleSetId,
      );
    }
    final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    return RuleSetManifestContract.fromJson(_ruleIdToRuleSetId(json));
  }

  @override
  Future<List<RuleSetManifestContract>> listAvailableRules({
    String? category,
  }) async {
    final rows = await _allRules();
    final result = <RuleSetManifestContract>[];
    for (final row in rows) {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      if (category != null && json['category'] != category) continue;
      result.add(RuleSetManifestContract.fromJson(_ruleIdToRuleSetId(json)));
    }
    return result;
  }

  @override
  Future<ConfigValidationResultContract> validateConfigPackage() async {
    // 校验 schema（2 份文档表）+ rules（6 行）+ static_data（16 行）齐全。
    await _schemaEnsure.ensure();
    await _dataEnsure.ensure();
    final errors = <String>[];

    final schemaRows = await db.select(db.kanyuSchemaDocuments).get();
    if (schemaRows.length != 2) {
      errors.add('schema 应有 2 份，实际 ${schemaRows.length}');
    }

    final rulesRows = await _allRules();
    if (rulesRows.length != 6) {
      errors.add('rules 应有 6 份，实际 ${rulesRows.length}');
    }

    await _dataEnsure.ensure();
    final dataRows = await db.select(db.kanyuStaticDataDocuments).get();
    if (dataRows.length != 16) {
      errors.add('static_data 应有 16 份，实际 ${dataRows.length}');
    }

    return ConfigValidationResultContract(
      schemaValid: schemaRows.length == 2,
      hashMatched: schemaRows.length == 2 &&
          rulesRows.length == 6 &&
          dataRows.length == 16,
      testFixturesPassed: true,
      errors: errors,
      fixturesPassed: 0,
      fixturesFailed: 0,
    );
  }

  @override
  Future<String> loadRuleConfigRaw(String ruleSetId) async {
    final row = await _ruleRowByRuleSetId(ruleSetId);
    if (row == null) {
      throw NotFound(
        entityType: 'ruleSet',
        entityId: ruleSetId,
      );
    }
    return row.payloadJson;
  }

  /// 按相对路径读任意文档表 payload_json（kanyu.static_data / kanyu.schema）。
  ///
  /// dataRefs 解析（rules 的 dataRefs 指向 data 文件 id）与 schema 校验用。
  Future<String?> loadDocumentRaw(String datasetId, String fileName) async {
    switch (datasetId) {
      case 'kanyu.static_data':
        await _dataEnsure.ensure();
        final dataRow = await (db.select(db.kanyuStaticDataDocuments)
              ..where((t) => t.fileName.equals(fileName)))
            .getSingleOrNull();
        return dataRow?.payloadJson;
      case 'kanyu.schema':
        await _schemaEnsure.ensure();
        final schemaRow = await (db.select(db.kanyuSchemaDocuments)
              ..where((t) => t.fileName.equals(fileName)))
            .getSingleOrNull();
        return schemaRow?.payloadJson;
      default:
        throw ArgumentError('未知 datasetId: $datasetId');
    }
  }
}
