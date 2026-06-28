import 'package:drift/drift.dart';

class TRecordSearchIndex extends Table {
  @override
  String get tableName => 't_record_search_index';

  TextColumn get recordUuid => text().named('record_uuid')();
  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get module => text()();
  TextColumn get indexKey => text().named('index_key')();
  TextColumn get indexValue => text().named('index_value')();
}
