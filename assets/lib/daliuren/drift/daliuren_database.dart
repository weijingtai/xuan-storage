import 'package:drift/drift.dart';

import 'dataset_generations_table.dart';
import 'document_tables.dart';

part 'daliuren_database.g.dart';

/// daliuren 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）。
///
/// 承载 4 个数据集的 drift 表 + 世代状态表：
/// - `official_data_document`（daliuren.official_data，4 行）
/// - `keti_document`（daliuren.keti，1 行）
/// - `shen_sha_document`（daliuren.shen_sha，9 行）
/// - `school_dataset_document`（daliuren.school_dataset，1 行）
/// - `dataset_generation`（世代状态持久化，§5）
///
/// schemaVersion 从 1 起（XRAP §9.1，各模块独立数据库互不干扰）。
@DriftDatabase(
  tables: [
    DaliurenOfficialDataDocuments,
    DaliurenKetiDocuments,
    DaliurenShenShaDocuments,
    DaliurenSchoolDatasetDocuments,
    DaliurenDatasetGenerations,
  ],
)
class DaliurenDatabase extends _$DaliurenDatabase {
  DaliurenDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
