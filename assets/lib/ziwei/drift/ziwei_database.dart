import 'package:drift/drift.dart';

import 'dataset_generations_table.dart';
import 'document_tables.dart';

part 'ziwei_database.g.dart';

/// ziwei 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）。
///
/// 承载 3 个数据集的 drift 表 + 世代状态表：
/// - `star_catalog_document`（ziwei.star_catalog，1 行 CSV 原文）
/// - `star_metadata_document`（ziwei.star_metadata，2 行主辅星）
/// - `four_transformations_document`（ziwei.four_transformations，1 行四化）
/// - `dataset_generation`（世代状态持久化，§5）
///
/// schemaVersion 从 1 起（XRAP §9.1，各模块独立数据库互不干扰）。
@DriftDatabase(
  tables: [
    ZiweiStarCatalogDocuments,
    ZiweiStarMetadataDocuments,
    ZiweiFourTransformationsDocuments,
    ZiweiDatasetGenerations,
  ],
)
class ZiweiDatabase extends _$ZiweiDatabase {
  ZiweiDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
