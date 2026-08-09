import 'package:drift/drift.dart';

/// 格局版本历史表（datasetId: `qizheng.ge_ju`，ge_ju.sql 5 表之一，源库为空表）。
@DataClassName('GeJuVersionEntry')
class GeJuVersions extends Table {
  @override
  String get tableName => 'ge_ju_versions';

  IntColumn get id => integer()();
  IntColumn get ruleId => integer().named('rule_id')();
  TextColumn get version => text()();
  TextColumn get versionRemark => text().named('version_remark').nullable()();
  TextColumn get operationType => text().named('operation_type')();
  TextColumn get changedFields => text().named('changed_fields').nullable()();
  TextColumn get snapshot => text()();
  TextColumn get diffFromPrevious => text().named('diff_from_previous').nullable()();
  TextColumn get createdBy => text().named('created_by')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
