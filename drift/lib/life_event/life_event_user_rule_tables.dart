// ACT-10：用户判断与个人规则 Drift 表定义。
//
// 八个逻辑集合（ImplementationPlan Task 10）：directions、annotations、
// occurrence selections、pattern rules、templates + 三张规范化引用子表。
// 所有更新使用 revision CAS；ownerScope 是每次读写条件；typed 字段列式保存，
// 禁止无版本 dynamic JSON blob（tags/channelIds/leadTimes 等标量列表除外）。
//
// 表名以 t_le_user_ 为前缀，独立于 t_life_event_ 主链。
library;

import 'package:drift/drift.dart';

/// 用户方向表（LEC-011/LEC-032：零系统默认方向，完全用户自建）。
@DataClassName('LifeEventUserDirectionRow')
class LifeEventUserDirections extends Table {
  TextColumn get directionId => text().named('direction_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get label => text().named('label')();
  TextColumn get color => text().named('color').nullable()();
  IntColumn get sortOrder => integer().named('sort_order')();
  IntColumn get archivedAtMs => integer().named('archived_at_ms').nullable()();

  @override
  Set<Column> get primaryKey => {directionId};

  @override
  String? get tableName => 't_le_user_directions';
}

/// 用户批注主表（结构化方向 + 用户原文；不改写 SourceEventFact）。
@DataClassName('LifeEventUserAnnotationRow')
class LifeEventUserAnnotations extends Table {
  TextColumn get annotationId => text().named('annotation_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get title => text().named('title').nullable()();
  TextColumn get interpretation => text().named('interpretation').nullable()();
  TextColumn get importanceOwnerScopeId =>
      text().named('importance_owner_scope_id').nullable()();
  TextColumn get importanceCatalogId =>
      text().named('importance_catalog_id').nullable()();
  IntColumn get importanceCatalogRevision =>
      integer().named('importance_catalog_revision').nullable()();
  TextColumn get importanceLevelId =>
      text().named('importance_level_id').nullable()();
  TextColumn get tagsJson => text().named('tags_json').withDefault(const Constant('[]'))();
  IntColumn get revision => integer().named('revision')();
  IntColumn get createdAtMs => integer().named('created_at_ms')();
  IntColumn get updatedAtMs => integer().named('updated_at_ms')();

  @override
  Set<Column> get primaryKey => {annotationId};

  @override
  String? get tableName => 't_le_user_annotations';
}

/// 批注目标事件引用子表（targetSourceRefs）。
@DataClassName('LifeEventAnnotationTargetRefRow')
class LifeEventAnnotationTargetRefs extends Table {
  TextColumn get annotationId => text().named('annotation_id')();
  TextColumn get providerId => text().named('provider_id')();
  TextColumn get sourceEventId => text().named('source_event_id')();
  TextColumn get eventRevision => text().named('event_revision')();

  @override
  Set<Column> get primaryKey => {annotationId, providerId, sourceEventId};

  @override
  String? get tableName => 't_le_annotation_target_refs';
}

/// 批注方向引用子表（directionIds）。
@DataClassName('LifeEventAnnotationDirectionRefRow')
class LifeEventAnnotationDirectionRefs extends Table {
  TextColumn get annotationId => text().named('annotation_id')();
  TextColumn get directionId => text().named('direction_id')();

  @override
  Set<Column> get primaryKey => {annotationId, directionId};

  @override
  String? get tableName => 't_le_annotation_direction_refs';
}

/// 单次事件选择表（撤销保留审计版本：revision CAS 递增）。
@DataClassName('LifeEventOccurrenceSelectionRow')
class LifeEventOccurrenceSelections extends Table {
  TextColumn get selectionId => text().named('selection_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  IntColumn get revision => integer().named('revision')();
  TextColumn get sourceProviderId => text().named('source_provider_id')();
  TextColumn get sourceEventId => text().named('source_event_id')();
  TextColumn get sourceEventRevision => text().named('source_event_revision')();
  TextColumn get eventRevision => text().named('event_revision')();
  TextColumn get annotationRef => text().named('annotation_ref').nullable()();

  @override
  Set<Column> get primaryKey => {selectionId};

  @override
  String? get tableName => 't_le_occurrence_selections';
}

/// 持续条件规则表（normalized typed predicate + 三类语义版本）。
@DataClassName('LifeEventPatternRuleRow')
class LifeEventPatternRules extends Table {
  TextColumn get savedPatternId => text().named('saved_pattern_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  IntColumn get revision => integer().named('revision')();
  TextColumn get providerId => text().named('provider_id')();
  TextColumn get eventTypeId => text().named('event_type_id')();
  TextColumn get patternSchemaVersion => text().named('pattern_schema_version')();
  TextColumn get providerDescriptorVersion =>
      text().named('provider_descriptor_version')();
  TextColumn get matcherSemanticVersion =>
      text().named('matcher_semantic_version')();
  TextColumn get normalizedPatternJson =>
      text().named('normalized_pattern_json')();
  TextColumn get patternFingerprint => text().named('pattern_fingerprint')();
  TextColumn get annotationRef => text().named('annotation_ref').nullable()();
  BoolColumn get enabledForMatching => boolean().named('enabled_for_matching')();

  @override
  Set<Column> get primaryKey => {savedPatternId};

  @override
  String? get tableName => 't_le_pattern_rules';
}

/// 条件规则目标子表（targetSubjectIds + targetProfileIds，target_type 区分）。
@DataClassName('LifeEventPatternTargetRefRow')
class LifeEventPatternTargetRefs extends Table {
  TextColumn get savedPatternId => text().named('saved_pattern_id')();
  TextColumn get targetType => text().named('target_type')(); // 'subject' | 'profile'
  TextColumn get targetId => text().named('target_id')();

  @override
  Set<Column> get primaryKey => {savedPatternId, targetType, targetId};

  @override
  String? get tableName => 't_le_pattern_target_refs';
}

/// 个人规则模板表（LEC-033：用户主动保存，可复用可被 profile 覆盖）。
@DataClassName('LifeEventRuleTemplateRow')
class LifeEventRuleTemplates extends Table {
  TextColumn get templateId => text().named('template_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  IntColumn get revision => integer().named('revision')();
  TextColumn get providerPatternJson => text().named('provider_pattern_json')();
  TextColumn get defaultDirectionIdsJson =>
      text().named('default_direction_ids_json')();
  TextColumn get importanceOwnerScopeId =>
      text().named('importance_owner_scope_id').nullable()();
  TextColumn get importanceCatalogId =>
      text().named('importance_catalog_id').nullable()();
  IntColumn get importanceCatalogRevision =>
      integer().named('importance_catalog_revision').nullable()();
  TextColumn get importanceLevelId =>
      text().named('importance_level_id').nullable()();
  TextColumn get priorityOwnerScopeId =>
      text().named('priority_owner_scope_id').nullable()();
  TextColumn get priorityCatalogId =>
      text().named('priority_catalog_id').nullable()();
  IntColumn get priorityCatalogRevision =>
      integer().named('priority_catalog_revision').nullable()();
  TextColumn get priorityId => text().named('priority_id').nullable()();
  TextColumn get defaultChannelIdsJson =>
      text().named('default_channel_ids_json')();
  TextColumn get defaultLeadTimesMsJson =>
      text().named('default_lead_times_ms_json')();

  @override
  Set<Column> get primaryKey => {templateId};

  @override
  String? get tableName => 't_le_rule_templates';
}