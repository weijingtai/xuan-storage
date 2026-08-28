/// XRAP 版 four_zhu_card 领域 Repository（照 xrap_kanyu_repositories.dart）。
///
/// 走 XRAP 协议 + drift 持久化：数据是预构建的 *.sql，启动时由
/// [DatasetInstaller.ensureInstalled] 灌进 [FourZhuDatabase]，查询走 SQLite。
///
/// 实现 `repository-interface-four-zhu-card` 的端口（consuming side）：
/// - [FourZhuCardTemplateRepository]（four_zhu.default_template + market_templates + outbox_templates）
/// - [FourZhuCardMarketplaceRepository]（four_zhu.market_templates）
///
/// 契约模型手写 Equatable 无 fromJson（同 ziwei 契约先例），模板 JSON 顶层
/// 键与契约字段不一致（`entityId` vs `uuid`、`template` 嵌套 vs `templateJson`），
/// 本实现手写映射，保持 storage 包零模型耦合（不依赖 `package:xuan_four_zhu_card`）。
library;

import 'dart:convert';

import 'package:persistence_core/persistence_core.dart' hide StorageError;
import 'package:repository_interface_four_zhu_card/repository_interface_four_zhu_card.dart';

import 'drift/four_zhu_database.dart';

/// 单个数据集安装的幂等守卫封装。
///
/// 首次调用走 ensureInstalled，之后空操作（照 kanyu/ziwei 的 _ensure 模式）。
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

/// 模板 JSON（layout_template 形态：entityId + template 嵌套）→ LayoutTemplateContract。
///
/// 覆盖 `default_template.json` 与 `outbox_payload_*.json`（顶层键：
/// schemaVersion / entityType / entityId / collectionId / name / description /
/// template / version / clientUpdatedAt / deletedAt）。
LayoutTemplateContract _layoutTemplateJsonToContract(
  Map<String, dynamic> json,
  String moduleType,
) {
  final template = json['template'] is Map<String, dynamic>
      ? (json['template'] as Map<String, dynamic>)
      : json;
  return LayoutTemplateContract(
    uuid: (json['entityId'] ?? template['id']) as String,
    name: (json['name'] ?? template['name'] ?? '未命名模板') as String,
    description:
        (json['description'] ?? template['description']) as String?,
    moduleType: moduleType,
    collectionId: (json['collectionId'] ?? template['collectionId'] ?? '')
        as String,
    version: (json['version'] ?? template['version'] ?? 1) as int,
    templateJson: jsonEncode(json),
    format: 'json',
    createdAt: DateTime.parse(
      (json['clientUpdatedAt'] ?? json['updatedAt'] ?? '2026-08-11T00:00:00Z')
          as String,
    ),
    updatedAt: DateTime.parse(
      (json['clientUpdatedAt'] ?? json['updatedAt'] ?? '2026-08-11T00:00:00Z')
          as String,
    ),
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );
}

/// 市场模板 JSON（templateId + layoutTemplate 嵌套）→ LayoutTemplateContract。
///
/// 覆盖 `market_payload_*.json`（顶层键：schemaVersion / templateId /
/// versionId / layoutTemplate）。layoutTemplate 内含 id/name/description/
/// collectionId/cardStyle/chartGroups/rowConfigs/editableTheme/version/updatedAt。
LayoutTemplateContract _marketPayloadToContract(
  Map<String, dynamic> json,
) {
  final lt = json['layoutTemplate'] as Map<String, dynamic>;
  return LayoutTemplateContract(
    uuid: lt['id'] as String,
    name: (lt['name'] ?? '未命名模板') as String,
    description: lt['description'] as String?,
    moduleType: 'four_zhu',
    collectionId: (lt['collectionId'] ?? '') as String,
    version: (lt['version'] ?? 1) as int,
    templateJson: jsonEncode(lt),
    format: 'json',
    createdAt: DateTime.parse(
      (lt['updatedAt'] ?? '2026-08-11T00:00:00Z') as String,
    ),
    updatedAt: DateTime.parse(
      (lt['updatedAt'] ?? '2026-08-11T00:00:00Z') as String,
    ),
  );
}

/// XRAP 版四柱卡模板 Repository（four_zhu.default_template / market_templates / outbox_templates）。
class XrapFourZhuTemplateRepository implements FourZhuCardTemplateRepository {
  XrapFourZhuTemplateRepository({
    required this.db,
    required this.installer,
  })  : _defaultEnsure = _DatasetEnsurer(installer, 'four_zhu.default_template'),
        _marketEnsure = _DatasetEnsurer(installer, 'four_zhu.market_templates'),
        _outboxEnsure = _DatasetEnsurer(installer, 'four_zhu.outbox_templates');

  final FourZhuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _defaultEnsure;
  final _DatasetEnsurer _marketEnsure;
  final _DatasetEnsurer _outboxEnsure;

  /// 全部模板行（default 1 + market 4 + outbox 4 = 9）。
  Future<List<LayoutTemplateContract>> _allTemplates() async {
    await _defaultEnsure.ensure();
    await _marketEnsure.ensure();
    await _outboxEnsure.ensure();

    final result = <LayoutTemplateContract>[];

    // default_template.json（entityType=layout_template 形态）。
    for (final row in await db.select(db.fourZhuDefaultTemplateDocuments).get()) {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      result.add(_layoutTemplateJsonToContract(json, 'four_zhu'));
    }

    // market_payload_*.json（templateId + layoutTemplate 形态）。
    for (final row in await db.select(db.fourZhuMarketTemplatesDocuments).get()) {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      result.add(_marketPayloadToContract(json));
    }

    // outbox_payload_*.json（entityType=layout_template 形态）。
    for (final row in await db.select(db.fourZhuOutboxTemplatesDocuments).get()) {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      result.add(_layoutTemplateJsonToContract(json, 'four_zhu'));
    }

    return result;
  }

  @override
  Future<LayoutTemplateContract?> getTemplate(String uuid) => get(uuid);

  @override
  Future<List<LayoutTemplateContract>> listTemplates() => _allTemplates();

  @override
  Future<void> saveTemplate(LayoutTemplateContract template) async {
    await put(template);
  }

  @override
  Future<void> deleteTemplate(String uuid) async {
    await delete(uuid);
  }

  @override
  Future<LayoutTemplateContract?> get(String id) async {
    final all = await _allTemplates();
    for (final t in all) {
      if (t.uuid == id) return t;
    }
    return null;
  }

  @override
  Future<String> put(LayoutTemplateContract template) {
    // 内置数据集只读（prebuilt SQL），不支持写回。抛 StorageError 防误用。
    throw StorageError('four_zhu 模板为内置只读数据集，不支持 put');
  }

  @override
  Future<List<LayoutTemplateContract>> query([Map<String, Object?>? criteria]) async {
    return _allTemplates();
  }

  @override
  Future<bool> delete(String id) {
    throw StorageError('four_zhu 模板为内置只读数据集，不支持 delete');
  }
}

/// XRAP 版四柱卡市场 Repository（four_zhu.market_templates 4 份市场模板）。
class XrapFourZhuMarketplaceRepository
    implements FourZhuCardMarketplaceRepository {
  XrapFourZhuMarketplaceRepository({
    required this.db,
    required this.installer,
  }) : _marketEnsure = _DatasetEnsurer(installer, 'four_zhu.market_templates');

  final FourZhuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _marketEnsure;

  @override
  Future<List<MarketTemplateContract>> listMarketTemplates() async {
    await _marketEnsure.ensure();
    final result = <MarketTemplateContract>[];
    final rows = await db.select(db.fourZhuMarketTemplatesDocuments).get();
    for (final row in rows) {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      final lt = json['layoutTemplate'] as Map<String, dynamic>;
      result.add(
        MarketTemplateContract(
          uuid: lt['id'] as String,
          name: (lt['name'] ?? '未命名模板') as String,
          description: (lt['description'] ?? '') as String,
          author: '内置',
          version: (json['versionId'] ?? 'v1') as String,
          downloadCount: 0,
          createdAt: DateTime.parse(
            (lt['updatedAt'] ?? '2026-08-11T00:00:00Z') as String,
          ),
        ),
      );
    }
    return result;
  }

  @override
  Future<TemplateInstallContract> installTemplate(String uuid) {
    // 内置市场模板免安装（bundled），不支持写本地库。
    throw StorageError('内置市场模板已捆绑，无需 installTemplate');
  }

  @override
  Future<void> uninstallTemplate(String uuid) {
    throw StorageError('内置市场模板已捆绑，不支持 uninstallTemplate');
  }
}
