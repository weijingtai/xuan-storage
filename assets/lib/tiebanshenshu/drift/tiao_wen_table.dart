import 'package:drift/drift.dart';

/// 条文表（datasetId: `tiebanshenshu.tiao_wen`）。
///
/// 源数据：all_tiao_wen_v1.csv（12000 行，无表头），
/// 经 `assets/tool/build_tiebanshenshu_sql.py` 转为 SQL INSERT。
/// set_name 存地支中文（如「子」），age_set1_json 存 JSON 数组（如 `[47]`），
/// 无 ageSet 的行存 NULL（与旧桩 _parseAgeSet 容错逻辑对齐）。
@DataClassName('TiaoWenEntry')
class TiaoWenEntries extends Table {
  @override
  String get tableName => 'tiao_wen';

  IntColumn get id => integer()();
  TextColumn get setName => text().named('set_name')();
  TextColumn get content1 => text()();
  TextColumn get ageSet1Json => text().named('age_set1_json').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
