import 'package:drift/drift.dart';

class PanelRefs extends Table {
  @override
  String get tableName => 't_panel_refs';

  TextColumn get uuid => text().named('uuid')();
  TextColumn get module => text().named('module')();
  TextColumn get panelUuid => text().named('panel_uuid')();
  TextColumn get panelType => text().named('panel_type')();
  TextColumn get role => text().named('role')();
  TextColumn get title => text().nullable().named('title')();

  @override
  Set<Column> get primaryKey => {uuid};
}
