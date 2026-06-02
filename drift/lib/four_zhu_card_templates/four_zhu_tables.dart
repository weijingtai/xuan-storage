import 'package:drift/drift.dart';

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}

/// 大运记录表
///
/// 从 xuan-common 迁移至 xuan-four-zhu-card (Task 5.1)。
/// 存储八字命理中大运排盘的记录。
@DataClassName('DaYunRecord')
class DaYunRecords extends Table {
  @override
  String get tableName => 't_da_yun_records';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get sourceUuid => text().named('source_uuid')();

  TextColumn get jieQiType => text().named('jie_qi_type')();
  TextColumn get precision => text().named('precision')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// 太元记录表
///
/// 从 xuan-common 迁移至 xuan-four-zhu-card (Task 5.1)。
/// 存储八字命理中太元排盘的记录。
@DataClassName('TaiYuanRecord')
class TaiYuanRecords extends Table {
  @override
  String get tableName => 't_tai_yuan_records';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get calendarUuid => text().named('calendar_uuid')();

  TextColumn get strategy => text().named('strategy')();
  TextColumn get pillar => text().named('pillar')();
  TextColumn get description => text().nullable().named('description')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('LayoutTemplateRow')
class LayoutTemplates extends Table {
  @override
  String get tableName => 't_layout_templates';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get collectionId =>
      text().withLength(min: 1).named('collection_id')();
  TextColumn get name => text().withLength(min: 1).named('name')();
  TextColumn get description => text().nullable().named('description')();

  TextColumn get templateJson => text().named('template_json')();
  IntColumn get version => integer().named('version')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('CardTemplateMeta')
class CardTemplateMetas extends Table {
  @override
  String get tableName => 't_card_template_meta';

  TextColumn get templateUuid => text().named('template_uuid')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get authorUuid => text().nullable().named('author_uuid')();
  TextColumn get createFromCardUuid =>
      text().nullable().named('create_from_card_uuid')();
  BoolColumn get isCustomized => boolean().nullable().named('is_customized')();

  @override
  Set<Column> get primaryKey => {templateUuid};
}

@DataClassName('CardTemplateSettingRecord')
class CardTemplateSettings extends Table {
  @override
  String get tableName => 't_card_template_setting';

  TextColumn get templateUuid => text().named('template_uuid')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get settingJson => text().named('setting_json')();

  @override
  Set<Column> get primaryKey => {templateUuid};
}

@DataClassName('CardTemplateSkillUsage')
class CardTemplateSkillUsages extends Table with AutoIncrementingPrimaryKey {
  @override
  String get tableName => 't_card_template_skill_usage';

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get queryUuid => text().named('query_uuid')();
  TextColumn get templateUuid => text().named('template_uuid')();
  IntColumn get skillId => integer().named('skill_id')();

  TextColumn get usedAt => text().named('used_at')();

  @override
  List<Index> get indexes => [
        Index(
          'idx_card_template_skill_usage_query_uuid',
          'CREATE INDEX idx_card_template_skill_usage_query_uuid ON t_card_template_skill_usage (query_uuid);',
        ),
        Index(
          'idx_card_template_skill_usage_template_uuid',
          'CREATE INDEX idx_card_template_skill_usage_template_uuid ON t_card_template_skill_usage (template_uuid);',
        ),
        Index(
          'idx_card_template_skill_usage_skill_id',
          'CREATE INDEX idx_card_template_skill_usage_skill_id ON t_card_template_skill_usage (skill_id);',
        ),
      ];
}

@DataClassName('MarketTemplateInstall')
class MarketTemplateInstalls extends Table {
  @override
  String get tableName => 't_market_template_installs';

  TextColumn get localTemplateUuid => text().named('local_template_uuid')();

  TextColumn get marketTemplateId => text().named('market_template_id')();
  TextColumn get marketVersionId => text().named('market_version_id')();

  DateTimeColumn get installedAt => dateTime().named('installed_at')();
  DateTimeColumn get pinnedAt => dateTime().nullable().named('pinned_at')();
  DateTimeColumn get lastCheckedAt =>
      dateTime().nullable().named('last_checked_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {localTemplateUuid};

  @override
  List<Index> get indexes => [
        Index(
          'idx_market_template_installs_market_template_id',
          'CREATE INDEX idx_market_template_installs_market_template_id ON t_market_template_installs (market_template_id);',
        ),
        Index(
          'idx_market_template_installs_market_version_id',
          'CREATE INDEX idx_market_template_installs_market_version_id ON t_market_template_installs (market_version_id);',
        ),
      ];
}
