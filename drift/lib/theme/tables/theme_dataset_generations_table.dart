// 包：persistence_drift  文件：drift/lib/theme/tables/theme_dataset_generations_table.dart
// THEME-DRIFT：主题数据集世代状态表（独立库）。
//
// 照 T1 assets/lib/geo/drift/dataset_generations_table.dart 的结构。
// 主题独立库自带一份世代状态表，不跨包引用 assets 的生成代码
// （assets 包的 DatasetGenerations 生成的 companion 属于 GeoDatabase）。
//
// 活跃指针由 status='ready' 隐式表达（一个 dataset 同时只有一个 ready），
// 与 T1 DriftDatasetGenerationStore 的查询语义一致。

import 'package:drift/drift.dart';

/// 主题数据集世代记录表（THEME-DRIFT 独立库）。
///
/// 每个 (datasetId, generation) 唯一标识一个世代。
/// 活跃指针由 `status='ready'` 隐式表达（照 T1）。
@DataClassName('ThemeDatasetGenerationRow')
class ThemeDatasetGenerations extends Table {
  @override
  String get tableName => 't_theme_dataset_generation';

  TextColumn get datasetId => text().named('dataset_id')();
  IntColumn get generation => integer()();
  TextColumn get payloadSha256 => text().named('payload_sha256')();
  IntColumn get payloadBytes => integer().named('payload_bytes')();
  IntColumn get declaredRowCount =>
      integer().named('declared_row_count').nullable()();
  TextColumn get status => text()();
  TextColumn get sourceId => text().named('source_id')();
  DateTimeColumn get installedAtUtc =>
      dateTime().named('installed_at_utc').nullable()();

  @override
  Set<Column> get primaryKey => {datasetId, generation};
}
