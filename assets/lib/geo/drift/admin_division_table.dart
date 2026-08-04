import 'package:drift/drift.dart';

/// 国内省市县经纬度表（datasetId: `geo.admin_division`）。
///
/// 源数据：province_city_area_lng_lat.json（3515 行），
/// 经 `assets/tool/build_geo_sql.py` 转为 SQL INSERT。
/// 146 条记录的经纬度源数据缺失，落库为 NULL。
@DataClassName('AdminDivisionEntry')
class AdminDivisions extends Table {
  @override
  String get tableName => 'admin_division';

  TextColumn get code => text()();
  TextColumn get parentCode => text().named('parent_code')();
  IntColumn get level => integer()();
  TextColumn get name => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  @override
  Set<Column> get primaryKey => {code};
}
