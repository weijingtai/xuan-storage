import 'package:drift/drift.dart';

@DataClassName('DivinationCalendar')
class DivinationCalendars extends Table {
  @override
  String get tableName => 't_divination_calendars';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get sourceUuid => text().named('source_uuid')();
  // seeker, timing_divination
  TextColumn get sourceType => text().named('source_type')();

  TextColumn get currentTaiYuanUuid =>
      text().nullable().named('current_tai_yuan_uuid')();
  TextColumn get currentDaYunUuid =>
      text().nullable().named('current_da_yun_uuid')();

  @override
  Set<Column> get primaryKey => {uuid};
}