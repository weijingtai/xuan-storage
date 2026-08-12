import 'package:drift/drift.dart';

/// kanyu 域整份读 JSON 的文档表（file_name + payload_json）。
///
/// 照 taiyishenshu/ziwei 样板：协议强制内置数据集 payloadFormat 必须 prebuilt，
/// 非表形 JSON（整份读）以文档表落地——构建期生成 SQL，设备侧执行恢复表即零解析，
/// 领域 Repository 从本表读整段 JSON 再契约 fromJson。
///
/// 三个数据集共用同一表形：
/// - `kanyu.rules`（6 行：Layer B 规则配置）
/// - `kanyu.static_data`（16 行：Layer A 静态数据）
/// - `kanyu.schema`（2 行：JSON Schema 校验规格）
///
/// 类名带 `Kanyu` 前缀：geo / qizhengsiyu / daliuren / taiyishenshu / ziwei
/// 已声明同形表，barrel 同时导出多个 database 会撞生成符号。
abstract class _KanyuDocumentTable extends Table {
  TextColumn get fileName => text().named('file_name')();
  TextColumn get payloadJson => text().named('payload_json')();

  @override
  Set<Column> get primaryKey => {fileName};
}

@DataClassName('KanyuRuleDocumentEntry')
class KanyuRuleDocuments extends _KanyuDocumentTable {
  @override
  String get tableName => 'rules_document';
}

@DataClassName('KanyuStaticDataDocumentEntry')
class KanyuStaticDataDocuments extends _KanyuDocumentTable {
  @override
  String get tableName => 'static_data_document';
}

@DataClassName('KanyuSchemaDocumentEntry')
class KanyuSchemaDocuments extends _KanyuDocumentTable {
  @override
  String get tableName => 'schema_document';
}
