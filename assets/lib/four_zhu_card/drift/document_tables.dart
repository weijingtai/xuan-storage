import 'package:drift/drift.dart';

/// four_zhu_card 域整份读 JSON 的文档表（file_name + payload_json）。
///
/// 照 kanyu/taiyishenshu/ziwei 样板：协议强制内置数据集 payloadFormat 必须 prebuilt，
/// 非表形 JSON（整份读）以文档表落地——构建期生成 SQL，设备侧执行恢复表即零解析，
/// 领域 Repository 从本表读整段 JSON 再契约 fromJson/手写映射。
///
/// 三个数据集共用同一表形：
/// - `four_zhu.default_template`（1 行：默认模板，entityType=layout_template）
/// - `four_zhu.market_templates`（4 行：市场模板 market_payload_*，templateId+layoutTemplate）
/// - `four_zhu.outbox_templates`（4 行：出站模板 outbox_payload_*，layout_template 形态）
///
/// 类名带 `FourZhu` 前缀：geo / qizhengsiyu / daliuren / taiyishenshu / ziwei / kanyu
/// 已声明同形表，barrel 同时导出多个 database 会撞生成符号。
abstract class _FourZhuDocumentTable extends Table {
  TextColumn get fileName => text().named('file_name')();
  TextColumn get payloadJson => text().named('payload_json')();

  @override
  Set<Column> get primaryKey => {fileName};
}

@DataClassName('FourZhuDefaultTemplateDocumentEntry')
class FourZhuDefaultTemplateDocuments extends _FourZhuDocumentTable {
  @override
  String get tableName => 'default_template_document';
}

@DataClassName('FourZhuMarketTemplatesDocumentEntry')
class FourZhuMarketTemplatesDocuments extends _FourZhuDocumentTable {
  @override
  String get tableName => 'market_templates_document';
}

@DataClassName('FourZhuOutboxTemplatesDocumentEntry')
class FourZhuOutboxTemplatesDocuments extends _FourZhuDocumentTable {
  @override
  String get tableName => 'outbox_templates_document';
}
