import 'package:drift/drift.dart';
import 'package:persistence_drift/tables/auto_incrementing_primary_key.dart';
import 'package:persistence_drift/tables/seekers_table.dart';
import 'package:persistence_drift/tables/divinations_table.dart';


/// @Deprecated: 多对多映射已由 t_record_meta (module='seeker') 替代。
/// 旧数据通过 seeker_uuid + 迁移脚本保留。
@DataClassName('SeekerDivinationMapper')
class SeekerDivinationMappers extends Table with AutoIncrementingPrimaryKey {
  @override
  String get tableName => "t_seeker_divination_mapper";
  // 多对多
  //  一个seeker 可以有多个Divination, 一个求测人求测多个问题
  // 一个query可以有多个seeker, 合盘、合婚等
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get divinationUuid =>
      text().named('divination_uuid').references(Divinations, #uuid)();
  TextColumn get seekerUuid =>
      text().named('seeker_uuid').references(Seekers, #uuid)();
}