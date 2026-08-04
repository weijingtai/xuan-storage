import 'package:drift/drift.dart';

/// 洲表（datasetId: `geo.region`）。
///
/// 源数据：regions.json（6 行），translations 字段为 JSON 字符串。
@DataClassName('RegionEntry')
class Regions extends Table {
  @override
  String get tableName => 'region';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get translationsJson => text().named('translations_json')();
  TextColumn get wikiDataId => text().named('wiki_data_id').withDefault(const Constant(null))();

  @override
  Set<Column> get primaryKey => {id};
}
