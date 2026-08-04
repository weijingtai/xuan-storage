import 'package:drift/drift.dart';

/// 城市精简表（datasetId: `geo.city`）。
///
/// 源数据：city.min.json（337 行）。与 admin_division 可能存在数据重叠，
/// 待人类裁定是否冗余。
@DataClassName('CityEntry')
class Cities extends Table {
  @override
  String get tableName => 'city';

  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get provinceCode => text().named('province_code')();
  TextColumn get yearCode => text().named('year_code')();

  @override
  Set<Column> get primaryKey => {code};
}
