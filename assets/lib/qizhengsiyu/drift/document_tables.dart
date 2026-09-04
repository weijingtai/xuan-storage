import 'package:drift/drift.dart';

/// 非表形数据的 JSON 文档表（file_name + payload_json）。
///
/// 人类裁定 2026-08-07：协议强制内置数据集 payloadFormat 必须 prebuilt，
/// 非表形 JSON（嵌套对象/数组）以文档表落地——构建期生成 SQL（照 geo 样板），
/// 设备侧执行恢复表即零解析，领域 Repository 从本表读整段 JSON 再 decode。
///
/// 六类数据集共用同一表形：
/// - `qizheng.zhou_tian`（3 行）→ zhou_tian_document
/// - `qizheng.ephemeris`（20 行）→ ephemeris_document
/// - `qizheng.shen_sha`（6 行）→ shen_sha_document
/// - `qizheng.hua_yao`（3 行）→ hua_yao_document
/// - `qizheng.ge_ju_rules`（13 行）→ ge_ju_rules_document
/// - `qizheng.ge_ju_content`（13 行）→ ge_ju_content_document
///
/// 表名带 `_document` 后缀：避免与 ge_ju.sql 内 `ge_ju_rules` 等表同名冲突。
abstract class _DocumentTable extends Table {
  TextColumn get fileName => text().named('file_name')();
  TextColumn get payloadJson => text().named('payload_json')();

  @override
  Set<Column> get primaryKey => {fileName};
}

@DataClassName('ZhouTianDocumentEntry')
class ZhouTianDocuments extends _DocumentTable {
  @override
  String get tableName => 'zhou_tian_document';
}

@DataClassName('EphemerisDocumentEntry')
class EphemerisDocuments extends _DocumentTable {
  @override
  String get tableName => 'ephemeris_document';
}

@DataClassName('ShenShaDocumentEntry')
class ShenShaDocuments extends _DocumentTable {
  @override
  String get tableName => 'shen_sha_document';
}

@DataClassName('HuaYaoDocumentEntry')
class HuaYaoDocuments extends _DocumentTable {
  @override
  String get tableName => 'hua_yao_document';
}

@DataClassName('GeJuRulesDocumentEntry')
class GeJuRulesDocuments extends _DocumentTable {
  @override
  String get tableName => 'ge_ju_rules_document';
}

@DataClassName('GeJuContentDocumentEntry')
class GeJuContentDocuments extends _DocumentTable {
  @override
  String get tableName => 'ge_ju_content_document';
}
