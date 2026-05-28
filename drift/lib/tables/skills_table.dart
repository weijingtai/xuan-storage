import 'package:drift/drift.dart';

@DataClassName('Skill')
class Skills extends Table {
  @override
  String get tableName => "t_skills";
  IntColumn get id => integer().autoIncrement().named('id')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  BoolColumn get isAvailable => boolean().named('is_available')();
  TextColumn get name => text().named('name')();
  TextColumn get descriptions => text().named('descriptions')();
}