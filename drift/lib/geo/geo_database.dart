import 'package:drift/drift.dart';

import 'admin_division_table.dart';
import 'region_table.dart';
import 'city_table.dart';

part 'geo_database.g.dart';

/// geo 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）。
///
/// 承载 3 个数据集的 drift 表：
/// - `admin_division`（geo.admin_division，3515 行）
/// - `region`（geo.region，6 行）
/// - `city`（geo.city，337 行）
///
/// schemaVersion 从 1 起（§9.1，与主库 schemaVersion 争抢隔离）。
///
/// 表结构由 drift 表定义管理；数据由 [DatasetMaterializer] 执行
/// `*.sql` 的 INSERT 语句灌入（drift 建表后，.sql 的
/// `CREATE TABLE IF NOT EXISTS` 幂等跳过，只执行 INSERT + INDEX）。
@DriftDatabase(tables: [AdminDivisions, Regions, Cities])
class GeoDatabase extends _$GeoDatabase {
  GeoDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
