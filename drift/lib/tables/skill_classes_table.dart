import 'package:drift/drift.dart';

@DataClassName('SkillClass')
class SkillClasses extends Table {
  @override
  String get tableName => "t_skill_classes";
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  IntColumn get skillId =>
      integer().named('skill_id')();
  TextColumn get name => text().named('name')();
  TextColumn get specification => text().named('specification')();
  TextColumn get feature => text().named('feature')();

  BoolColumn get isCustomized => boolean().named('is_customized')();

  @override
  Set<Column> get primaryKey => {uuid};
}