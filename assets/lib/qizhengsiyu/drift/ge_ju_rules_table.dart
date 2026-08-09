import 'package:drift/drift.dart';

/// 格局规则表（datasetId: `qizheng.ge_ju`，ge_ju.sql 5 表之一）。
///
/// id 为 AUTOINCREMENT（源库语义），保留显式 id 保持行级稳定。
@DataClassName('GeJuRuleEntry')
class GeJuRules extends Table {
  @override
  String get tableName => 'ge_ju_rules';

  IntColumn get id => integer()();
  TextColumn get patternId => text().named('pattern_id')();
  TextColumn get schoolId => text().named('school_id')();
  TextColumn get jixiong => text()();
  TextColumn get geJuType => text().named('ge_ju_type')();
  TextColumn get scope => text()();
  TextColumn get coordinateSystem => text().named('coordinate_system').nullable()();
  TextColumn get conditions => text().nullable()();
  TextColumn get assertion => text().nullable()();
  TextColumn get brief => text().nullable()();
  TextColumn get chapter => text().nullable()();
  TextColumn get originalText => text().named('original_text').nullable()();
  TextColumn get explanation => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get version => text()();
  TextColumn get versionRemark => text().named('version_remark').nullable()();
  IntColumn get isActive => integer().named('is_active')();
  IntColumn get isVerified => integer().named('is_verified')();
  IntColumn get priority => integer()();
  IntColumn get viewCount => integer().named('view_count')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
