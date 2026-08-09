import 'package:drift/drift.dart';

/// 格局流派表（datasetId: `qizheng.ge_ju`，ge_ju.sql 5 表之一）。
@DataClassName('GeJuSchoolEntry')
class GeJuSchools extends Table {
  @override
  String get tableName => 'ge_ju_schools';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get era => text().nullable()();
  TextColumn get founder => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get isActive => integer().named('is_active')();
  IntColumn get ruleCount => integer().named('rule_count')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
