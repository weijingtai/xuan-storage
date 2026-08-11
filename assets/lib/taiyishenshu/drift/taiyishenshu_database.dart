import 'package:drift/drift.dart';

import 'dataset_generations_table.dart';
import 'document_tables.dart';

part 'taiyishenshu_database.g.dart';

/// taiyishenshu 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）。
///
/// 承载 3 个数据集的 drift 表 + 世代状态表：
/// - `schools_document`（taiyi.schools，3 行）
/// - `deities_document`（taiyi.deities，47 行）
/// - `minggua_document`（taiyi.minggua，1 行）
/// - `dataset_generation`（世代状态持久化，§5）
///
/// schemaVersion 从 1 起（XRAP §9.1，各模块独立数据库互不干扰）。
@DriftDatabase(
  tables: [
    TaiyiSchoolDocuments,
    TaiyiDeityDocuments,
    TaiyiMingGuaDocuments,
    TaiyiDatasetGenerations,
  ],
)
class TaiyishenshuDatabase extends _$TaiyishenshuDatabase {
  TaiyishenshuDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
