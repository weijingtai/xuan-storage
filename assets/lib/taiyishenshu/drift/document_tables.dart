import 'package:drift/drift.dart';

/// taiyishenshu 域非表形数据的 JSON 文档表（file_name + payload_json）。
///
/// 人类裁定 2026-08-11：协议强制内置数据集 payloadFormat 必须 prebuilt，
/// 非表形 JSON（整份读）以文档表落地——构建期生成 SQL（照 daliuren），
/// 设备侧执行恢复表即零解析，领域 Repository 从本表读整段 JSON 再契约 fromJson。
///
/// 三类数据集共用同一表形：
/// - `taiyi.schools`（3 行）→ schools_document
/// - `taiyi.deities`（47 行）→ deities_document
/// - `taiyi.minggua`（1 行）→ minggua_document
///
/// 类名带 `Taiyi` 前缀：geo / qizhengsiyu / daliuren 已声明同形表，
/// barrel 同时导出多个 database 会撞生成符号。
abstract class _TaiyiDocumentTable extends Table {
  TextColumn get fileName => text().named('file_name')();
  TextColumn get payloadJson => text().named('payload_json')();

  @override
  Set<Column> get primaryKey => {fileName};
}

@DataClassName('TaiyiSchoolDocumentEntry')
class TaiyiSchoolDocuments extends _TaiyiDocumentTable {
  @override
  String get tableName => 'schools_document';
}

@DataClassName('TaiyiDeityDocumentEntry')
class TaiyiDeityDocuments extends _TaiyiDocumentTable {
  @override
  String get tableName => 'deities_document';
}

@DataClassName('TaiyiMingGuaDocumentEntry')
class TaiyiMingGuaDocuments extends _TaiyiDocumentTable {
  @override
  String get tableName => 'minggua_document';
}
