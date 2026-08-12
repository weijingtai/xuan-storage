import 'package:drift/drift.dart';

import 'dataset_generations_table.dart';
import 'document_tables.dart';

part 'kanyu_database.g.dart';

/// kanyu 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）。
///
/// 承载 3 个数据集的 drift 表 + 世代状态表：
/// - `rules_document`（kanyu.rules，6 行规则配置）
/// - `static_data_document`（kanyu.static_data，16 行静态数据）
/// - `schema_document`（kanyu.schema，2 行 Schema 规格）
/// - `dataset_generation`（世代状态持久化，§5）
///
/// schemaVersion 从 1 起（XRAP §9.1，各模块独立数据库互不干扰）。
@DriftDatabase(
  tables: [
    KanyuRuleDocuments,
    KanyuStaticDataDocuments,
    KanyuSchemaDocuments,
    KanyuDatasetGenerations,
  ],
)
class KanyuDatabase extends _$KanyuDatabase {
  KanyuDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
