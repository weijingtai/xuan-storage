import 'package:drift/drift.dart';

/// 格局模式表（datasetId: `qizheng.ge_ju`，ge_ju.sql 5 表之一）。
@DataClassName('GeJuPatternEntry')
class GeJuPatterns extends Table {
  @override
  String get tableName => 'ge_ju_patterns';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get englishName => text().named('english_name').nullable()();
  TextColumn get pinyin => text().nullable()();
  TextColumn get aliases => text().nullable()();
  TextColumn get categoryId => text().named('category_id')();
  TextColumn get keywords => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get originNotes => text().named('origin_notes').nullable()();
  IntColumn get referenceCount => integer().named('reference_count')();
  IntColumn get ruleCount => integer().named('rule_count')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
