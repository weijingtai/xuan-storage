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

  @override
  Set<Column> get primaryKey => {uuid};
}
