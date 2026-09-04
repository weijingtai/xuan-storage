import 'package:drift/drift.dart';

@DataClassName('TemplateUsageStatsRow')
class TemplateUsageStats extends Table {
  @override
  String get tableName => 't_template_usage_stats';

  TextColumn get templateUuid => text().named('template_uuid')();
  TextColumn get scopeUid => text().named('scope_uid')();
  IntColumn get useCount =>
      integer().named('use_count').withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime().named('last_used_at')();

  @override
  Set<Column> get primaryKey => {templateUuid};
}
