import 'package:drift/drift.dart';

/// daliuren 域非表形数据的 JSON 文档表（file_name + payload_json）。
///
/// 人类裁定 2026-08-09：协议强制内置数据集 payloadFormat 必须 prebuilt，
/// 非表形 JSON（整份读）以文档表落地——构建期生成 SQL（照 qizhengsiyu），
/// 设备侧执行恢复表即零解析，领域 Repository 从本表读整段 JSON 再 decode。
///
/// 四类数据集共用同一表形：
/// - `daliuren.official_data`（4 行）→ official_data_document
/// - `daliuren.keti`（1 行）→ keti_document
/// - `daliuren.shen_sha`（9 行）→ shen_sha_document
/// - `daliuren.school_dataset`（1 行）→ school_dataset_document
///
/// 类名带 `Daliuren` 前缀：qizhengsiyu 已声明同形表
/// （ShenShaDocuments 等），barrel 同时导出两个 database 会撞生成符号。
abstract class _DaliurenDocumentTable extends Table {
  TextColumn get fileName => text().named('file_name')();
  TextColumn get payloadJson => text().named('payload_json')();

  @override
  Set<Column> get primaryKey => {fileName};
}

@DataClassName('DaliurenOfficialDataDocumentEntry')
class DaliurenOfficialDataDocuments extends _DaliurenDocumentTable {
  @override
  String get tableName => 'official_data_document';
}

@DataClassName('DaliurenKetiDocumentEntry')
class DaliurenKetiDocuments extends _DaliurenDocumentTable {
  @override
  String get tableName => 'keti_document';
}

@DataClassName('DaliurenShenShaDocumentEntry')
class DaliurenShenShaDocuments extends _DaliurenDocumentTable {
  @override
  String get tableName => 'shen_sha_document';
}

@DataClassName('DaliurenSchoolDatasetDocumentEntry')
class DaliurenSchoolDatasetDocuments extends _DaliurenDocumentTable {
  @override
  String get tableName => 'school_dataset_document';
}
