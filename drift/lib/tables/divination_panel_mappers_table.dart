import 'package:drift/drift.dart';
import 'package:persistence_drift/tables/auto_incrementing_primary_key.dart';

class DivinationPanelMappers extends Table with AutoIncrementingPrimaryKey {
  @override
  String get tableName => "t_divination_panel_mappers";
  // 多对多:
  // 每个Divination可以对应多个Panel， 如在“合婚”时，一个query需要同时起男女双方两个盘
  // 每个Panel可以对应多个Divination，如在“运筹”时，需要同时获取求测人“命盘”。
  TextColumn get divinationUuid =>
      text().named('divination_uuid')();
  TextColumn get panelUuid =>
      text().named('panel_uuid')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
}