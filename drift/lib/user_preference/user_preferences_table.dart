import 'package:drift/drift.dart';

class UserPreferences extends Table {
  @override
  String get tableName => 't_user_preferences';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get key => text().named('key')();
  TextColumn get value => text().named('value')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {scopeUid, key};

  @override
  List<Index> get indexes => [
    Index(
      'idx_user_preferences_scope',
      'CREATE INDEX idx_user_preferences_scope ON t_user_preferences(scope_uid);',
    ),
  ];
}
