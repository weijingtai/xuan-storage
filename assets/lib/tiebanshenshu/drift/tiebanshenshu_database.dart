import 'package:drift/drift.dart';

import 'dataset_generations_table.dart';
import 'document_tables.dart';
import 'shao_zishu_table.dart';
import 'tiao_wen_table.dart';

part 'tiebanshenshu_database.g.dart';

/// tiebanshenshu 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）。
///
/// 承载 4 个数据集的 drift 表 + 世代状态表：
/// - `tiao_wen`（tiebanshenshu.tiao_wen，12000 行）
/// - `kao_ke_document`（tiebanshenshu.kao_ke，21 行 JSON 文档表）
/// - `shaozishu_document`（tiebanshenshu.shaozishu，12 行 TXT 文档表）
/// - `formulas_document`（tiebanshenshu.formulas，3 行 JSON 文档表）
/// - `dataset_generation`（世代状态持久化，§5）
///
/// schemaVersion 从 1 起。
@DriftDatabase(
  tables: [
    TiaoWenEntries,
    KaoKeDocuments,
    ShaoZiShuDocuments,
    FormulaDocuments,
    TiebanshenshuDatasetGenerations,
  ],
)
class TiebanshenshuDatabase extends _$TiebanshenshuDatabase {
  TiebanshenshuDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
