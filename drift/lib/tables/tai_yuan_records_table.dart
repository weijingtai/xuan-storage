import 'package:drift/drift.dart';

@DataClassName('TaiYuanRecord')
class TaiYuanRecords extends Table {
  @override
  String get tableName => 't_tai_yuan_records';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get calendarUuid => text().named('calendar_uuid')();

  TextColumn get strategy => text().named('strategy')();
  TextColumn get pillar => text().named('pillar')();
  TextColumn get description => text().nullable().named('description')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}
