import 'package:drift/drift.dart';

import 'dataset_generations_table.dart';
import 'document_tables.dart';

part 'four_zhu_database.g.dart';

/// four_zhu_card 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）。
///
/// 承载 3 个数据集的 drift 表 + 世代状态表：
/// - `default_template_document`（four_zhu.default_template，1 行默认模板）
/// - `market_templates_document`（four_zhu.market_templates，4 行市场模板）
/// - `outbox_templates_document`（four_zhu.outbox_templates，4 行出站模板）
/// - `dataset_generation`（世代状态持久化，§5）
///
/// schemaVersion 从 1 起（XRAP §9.1，各模块独立数据库互不干扰）。
@DriftDatabase(
  tables: [
    FourZhuDefaultTemplateDocuments,
    FourZhuMarketTemplatesDocuments,
    FourZhuOutboxTemplatesDocuments,
    FourZhuDatasetGenerations,
  ],
)
class FourZhuDatabase extends _$FourZhuDatabase {
  FourZhuDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
