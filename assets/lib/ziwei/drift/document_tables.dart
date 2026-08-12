import 'package:drift/drift.dart';

/// ziwei 域非表形数据的 JSON 文档表（file_name + payload_json）。
///
/// 照 taiyishenshu 样板（人类裁定 2026-08-11）：协议强制内置数据集
/// payloadFormat 必须 prebuilt，非表形 JSON（整份读）以文档表落地——
/// 构建期生成 SQL（照 daliuren），设备侧执行恢复表即零解析，
/// 领域 Repository 从本表读整段 JSON 再映射契约模型。
///
/// 三个数据集共用同一表形：
/// - `ziwei.star_catalog`（1 行，payload 为 stars.csv 原文）
/// - `ziwei.star_metadata`（2 行：主星 + 辅星 JSON）
/// - `ziwei.four_transformations`（1 行：四化 JSON）
///
/// 类名带 `Ziwei` 前缀：geo / qizhengsiyu / daliuren / taiyishenshu 已声明
/// 同形表，barrel 同时导出多个 database 会撞生成符号。
abstract class _ZiweiDocumentTable extends Table {
  TextColumn get fileName => text().named('file_name')();
  TextColumn get payloadJson => text().named('payload_json')();

  @override
  Set<Column> get primaryKey => {fileName};
}

@DataClassName('ZiweiStarCatalogEntry')
class ZiweiStarCatalogDocuments extends _ZiweiDocumentTable {
  @override
  String get tableName => 'star_catalog_document';
}

@DataClassName('ZiweiStarMetadataEntry')
class ZiweiStarMetadataDocuments extends _ZiweiDocumentTable {
  @override
  String get tableName => 'star_metadata_document';
}

@DataClassName('ZiweiFourTransformationsEntry')
class ZiweiFourTransformationsDocuments extends _ZiweiDocumentTable {
  @override
  String get tableName => 'four_transformations_document';
}
