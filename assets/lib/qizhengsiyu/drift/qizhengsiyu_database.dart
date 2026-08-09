import 'package:drift/drift.dart';

import 'dataset_generations_table.dart';
import 'document_tables.dart';
import 'ge_ju_categories_table.dart';
import 'ge_ju_patterns_table.dart';
import 'ge_ju_rules_table.dart';
import 'ge_ju_schools_table.dart';
import 'ge_ju_versions_table.dart';
import 'star_position_status_table.dart';

part 'qizhengsiyu_database.g.dart';

/// qizhengsiyu 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）。
///
/// 承载 8 个数据集的 drift 表 + 世代状态表：
/// - `star_position_status`（qizheng.star_position_status，97 行）
/// - `ge_ju_patterns/schools/categories/rules/versions`（qizheng.ge_ju，5 表 1005 行）
/// - `zhou_tian_document`（qizheng.zhou_tian，3 行）
/// - `ephemeris_document`（qizheng.ephemeris，17 行）
/// - `shen_sha_document`（qizheng.shen_sha，6 行）
/// - `hua_yao_document`（qizheng.hua_yao，3 行）
/// - `ge_ju_rules_document`（qizheng.ge_ju_rules，13 行）
/// - `ge_ju_content_document`（qizheng.ge_ju_content，13 行）
/// - `dataset_generation`（世代状态持久化，§5）
///
/// schemaVersion 从 1 起。
@DriftDatabase(
  tables: [
    StarPositionStatuses,
    GeJuPatterns,
    GeJuSchools,
    GeJuCategories,
    GeJuRules,
    GeJuVersions,
    ZhouTianDocuments,
    EphemerisDocuments,
    ShenShaDocuments,
    HuaYaoDocuments,
    GeJuRulesDocuments,
    GeJuContentDocuments,
    QizhengDatasetGenerations,
  ],
)
class QizhengsiyuDatabase extends _$QizhengsiyuDatabase {
  QizhengsiyuDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
