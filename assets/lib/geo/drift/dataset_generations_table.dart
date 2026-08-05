import 'package:drift/drift.dart';

/// 数据集世代记录表（XRAP §5 世代状态持久化）。
///
/// 每个 (datasetId, generation) 唯一标识一个世代。
/// 活跃指针由 `status='ready'` 隐式表达（一个 dataset 同时只有一个 ready）。
@DataClassName('DatasetGenerationEntry')
class DatasetGenerations extends Table {
  @override
  String get tableName => 'dataset_generation';

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
