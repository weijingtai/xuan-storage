import 'package:drift/drift.dart';

class DivinationCases extends Table {
  @override
  String get tableName => 't_divination_cases';

  TextColumn get uuid => text().named('uuid')();
  TextColumn get title => text().named('title')();
  TextColumn get mainQuestion => text().named('main_question')();
  TextColumn get status => text().named('status')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  TextColumn get finalSummary => text().nullable().named('final_summary')();
  // T1 裁定（2026-07-21）：案例附加展示素材，单键 historyCaseExtras，仅展示用。
  TextColumn get extrasJson => text().nullable().named('extras_json')();

  @override
  Set<Column> get primaryKey => {uuid};
}
