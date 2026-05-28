import 'package:drift/drift.dart';
import 'package:persistence_drift/tables/auto_incrementing_primary_key.dart';

class PanelSkillClassMappers extends Table with AutoIncrementingPrimaryKey {
  @override
  String get tableName => "t_panel_skill_class_mapper";
  TextColumn get panelUuid =>
      text().named('panel_uuid')();
  TextColumn get skillClassUuid =>
      text().named('skill_class_uuid')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
}