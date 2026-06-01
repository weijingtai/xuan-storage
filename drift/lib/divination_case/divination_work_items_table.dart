import 'package:drift/drift.dart';

class DivinationWorkItems extends Table {
  @override
  String get tableName => 't_divination_work_items';

  TextColumn get uuid => text().named('uuid')();
  TextColumn get caseUuid => text().named('case_uuid')();
  TextColumn get parentWorkItemUuid => text().nullable().named('parent_work_item_uuid')();
  TextColumn get title => text().named('title')();
  TextColumn get purpose => text().named('purpose')();
  TextColumn get methodGroup => text().named('method_group')();
  IntColumn get order => integer().named('order_index')();
  TextColumn get status => text().named('status')();
  TextColumn get summary => text().nullable().named('summary')();
  TextColumn get conclusion => text().nullable().named('conclusion')();

  @override
  Set<Column> get primaryKey => {uuid};
}
