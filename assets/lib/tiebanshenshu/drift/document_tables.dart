import 'package:drift/drift.dart';

/// 非表形数据的 JSON 文档表（file_name + payload_json）。
///
/// 人类裁定 2026-08-07：协议强制内置数据集 payloadFormat 必须 prebuilt，
/// 非表形 JSON（嵌套对象/数组）以文档表落地——构建期生成 SQL（照 geo 样板），
/// 设备侧执行恢复表即零解析，领域 Repository 从本表读整段 JSON 再 decode。
///
/// 两类数据集共用同一表形：
/// - `tiebanshenshu.kao_ke`（21 行）→ kao_ke_document
/// - `tiebanshenshu.formulas`（3 行）→ formulas_document
///
/// shaozishu 的 TXT 用 `payload_text` 列（见 shao_zishu 表定义）。
abstract class _DocumentTable extends Table {
  TextColumn get fileName => text().named('file_name')();
  TextColumn get payloadJson => text().named('payload_json')();

  @override
  Set<Column> get primaryKey => {fileName};
}

@DataClassName('KaoKeDocumentEntry')
class KaoKeDocuments extends _DocumentTable {
  @override
  String get tableName => 'kao_ke_document';
}

@DataClassName('FormulaDocumentEntry')
class FormulaDocuments extends _DocumentTable {
  @override
  String get tableName => 'formulas_document';
}
