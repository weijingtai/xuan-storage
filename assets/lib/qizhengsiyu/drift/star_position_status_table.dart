import 'package:drift/drift.dart';

/// 星位庙旺状态表（datasetId: `qizheng.star_position_status`）。
///
/// 源数据：star_position_status.json（97 行），
/// 经 `assets/tool/build_qizhengsiyu_sql.py` 转为 SQL INSERT。
/// positionList 为数组，落库为 JSON 字符串列，领域层 decode。
@DataClassName('StarPositionStatusEntry')
class StarPositionStatuses extends Table {
  @override
  String get tableName => 'star_position_status';

  IntColumn get id => integer()();
  TextColumn get className => text().named('class_name')();
  TextColumn get star => text()();
  TextColumn get positionStatusType => text().named('position_status_type')();
  TextColumn get positionListJson => text().named('position_list_json')();

  @override
  Set<Column> get primaryKey => {id};
}
