import 'package:drift/drift.dart';

class WorkItemPanelRefs extends Table {
  @override
  String get tableName => 't_work_item_panel_refs';

  TextColumn get uuid => text().named('uuid')();
  TextColumn get workItemUuid => text().named('work_item_uuid')();
  TextColumn get panelRefUuid => text().named('panel_ref_uuid')();
  TextColumn get role => text().named('role')();
  IntColumn get order => integer().named('order_index')();

  @override
  Set<Column> get primaryKey => {uuid};
}
