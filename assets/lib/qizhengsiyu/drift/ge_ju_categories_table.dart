import 'package:drift/drift.dart';

/// 格局分类表（datasetId: `qizheng.ge_ju`，ge_ju.sql 5 表之一）。
@DataClassName('GeJuCategoryEntry')
class GeJuCategories extends Table {
  @override
  String get tableName => 'ge_ju_categories';

  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get order => integer()();
  TextColumn get parentId => text().named('parent_id').nullable()();
  IntColumn get isActive => integer().named('is_active')();
  IntColumn get patternCount => integer().named('pattern_count')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
