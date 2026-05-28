import 'package:drift/drift.dart';
import 'package:persistence_drift/tables/divination_types_table.dart';
import 'package:persistence_drift/tables/sub_divination_types_table.dart';
import 'package:persistence_drift/tables/auto_incrementing_primary_key.dart';

@DataClassName('DivinationSubDivinationTypeMapper')
class DivinationSubDivinationTypeMappers extends Table
    with AutoIncrementingPrimaryKey {
  @override
  String get tableName => "t_divination_sub_divination_type_mappers";
  // 一对多 一个query 对应多个 subDivinationType
  TextColumn get typeUuid =>
      text().named('divination_type_uuid').references(DivinationTypes, #uuid)();
  TextColumn get subTypeUuid => text()
      .named('sub_divination_type_uuid')
      .references(SubDivinationTypes, #uuid)();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
}
