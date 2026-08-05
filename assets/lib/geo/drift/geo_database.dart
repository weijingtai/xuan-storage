import 'package:drift/drift.dart';

import 'admin_division_table.dart';
import 'region_table.dart';
import 'city_table.dart';
import 'dataset_generations_table.dart';

part 'geo_database.g.dart';

/// geo 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）。
///
/// 承载 3 个数据集的 drift 表 + 世代状态表：
/// - `admin_division`（geo.admin_division，3515 行）
/// - `region`（geo.region，6 行）
/// - `city`（geo.city，337 行）
/// - `dataset_generation`（世代状态持久化，§5）
///
/// schemaVersion 从 1 起。
@DriftDatabase(
  tables: [AdminDivisions, Regions, Cities, DatasetGenerations],
)
class GeoDatabase extends _$GeoDatabase {
  GeoDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
