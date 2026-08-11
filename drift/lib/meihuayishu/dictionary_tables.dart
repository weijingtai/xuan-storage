import 'package:drift/drift.dart';

/// 汉字主表
@DataClassName('DictionaryCharacter')
class Characters extends Table {
  @override
  String get tableName => 'characters';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get character => text()();
  TextColumn get definition => text().nullable()();
  TextColumn get radical => text().nullable()();
  TextColumn get decomposition => text().nullable()();
  TextColumn get matchesJson => text().nullable()();
}

/// 拼音表
@DataClassName('DictionaryPinyin')
class Pinyins extends Table {
  @override
  String get tableName => 'pinyin';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get characterId => integer()();
  TextColumn get pinyin => text()();
  TextColumn get pinyinWithToneNumber => text().nullable()();
}

/// 字源表
@DataClassName('DictionaryEtymology')
class Etymologies extends Table {
  @override
  String get tableName => 'etymology';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get characterId => integer()();
  TextColumn get type => text().nullable()();
  TextColumn get hint => text().nullable()();
}

/// XRAP 数据集世代记录（照 daliuren/qizhengsiyu 样板）。
@DataClassName('MeihuaDatasetGenerationEntry')
class MeihuaDatasetGenerations extends Table {
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
