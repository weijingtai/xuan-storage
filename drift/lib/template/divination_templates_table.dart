import 'package:drift/drift.dart';

@DataClassName('DivinationTemplateRow')
class DivinationTemplates extends Table {
  @override
  String get tableName => 't_divination_templates';

  TextColumn get uuid => text().named('uuid')();
  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get templateId => text().named('template_id')();
  TextColumn get name => text().named('name')();
  TextColumn get category => text().named('category')();
  TextColumn get origin => text().named('origin')();
  TextColumn get derivedFrom => text().nullable().named('derived_from')();
  IntColumn get version => integer().named('version')();
  TextColumn get definitionJson => text().named('definition_json')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}
