import 'package:drift/drift.dart';
import 'package:persistence_drift/tables/divinations_table.dart';


@DataClassName('CombinedDivination')
class CombinedDivinations extends Table {
  @override
  String get tableName => "t_combined_divinations";
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  IntColumn get order => integer().named("order")();
  // 一个 CombinedDivination 拥有一个或多个 Divination
  // 如：看完八字命理之后，可以针对命运中的突发情况进行“化解”或通过“堪舆”调整。
  TextColumn get divinationUuid =>
      text().named("divination_uuid").references(Divinations, #uuid)();

  @override
  Set<Column> get primaryKey => {uuid};
}