// ACT-12：提醒、调度与投递记录 Drift 表定义。
//
// 五个逻辑集合（Design §14）：definitions、channels、aggregates、schedules、
// deliveries。其中 definitions / channels / aggregates 各自带规范化子表，
// 用于承载有序列表与 typed 引用，因此物理表共九张：
//
//   1. t_le_reminder_definitions            提醒定义主行
//   2. t_le_reminder_definition_channels    definition.channelIds（position 定序）
//   3. t_le_reminder_channels               通道主行 + deliveryPolicy 列组
//   4. t_le_reminder_channel_selectors      channel.selectors 八类列表（kind 标签）
//   5. t_le_reminder_aggregates             聚合提醒主行
//   6. t_le_reminder_aggregate_directions   aggregate.directionIds（position 定序）
//   7. t_le_reminder_aggregate_contributors contributors（position 定序，不压平）
//   8. t_le_reminder_schedules              调度任务（租约列）
//   9. t_le_reminder_deliveries             投递记录
//
// 约定（与 ACT-06/ACT-10 一致）：
// - 表名前缀 t_le_reminder_，独立于 t_life_event_ 主链与 t_le_user_ 用户规则链；
// - 时间一律存 UTC 毫秒整数，读回 DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)；
// - Duration 存毫秒整数；
// - typed 引用（NotificationPriorityRef / UserImportanceRef / SourceSeverityRef /
//   SourceVersions / TimeRange / ReminderSelectionRef）用规范化列或带 kind 标签的
//   JSON，禁止无版本裸 blob；
// - 纯标量有序列表（leadTimes、contributor.directionIds）用 JSON 数组列：
//   它们没有引用完整性约束、不参与任何查询谓词，JSON 数组本身即保证顺序，
//   拆子表只会增加无收益的表数量。有引用语义的列表（channelIds、
//   aggregate.directionIds、contributors、selectors）一律落子表。
library;

import 'package:drift/drift.dart';

/// 提醒定义主表（Design §14.1）。
@DataClassName('LifeEventReminderDefinitionRow')
class LifeEventReminderDefinitions extends Table {
  TextColumn get reminderId => text().named('reminder_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();

  /// ReminderSelectionRef 的带 kind 标签 JSON：
  /// {"kind":"occurrenceSelection","selectionId":...,"revision":...}
  /// {"kind":"patternRule","savedPatternId":...,"revision":...}
  TextColumn get selectionRefJson => text().named('selection_ref_json')();

  TextColumn get notificationTitleOverride =>
      text().named('notification_title_override').nullable()();
  TextColumn get notificationBodyOverride =>
      text().named('notification_body_override').nullable()();

  // NotificationPriorityRef（规范化四列，非空）。
  TextColumn get priorityOwnerScopeId => text().named('priority_owner_scope_id')();
  TextColumn get priorityCatalogId => text().named('priority_catalog_id')();
  IntColumn get priorityCatalogRevision =>
      integer().named('priority_catalog_revision')();
  TextColumn get priorityId => text().named('priority_id')();

  /// `List<Duration>` 的毫秒 JSON 数组。
  TextColumn get leadTimesMsJson => text().named('lead_times_ms_json')();

  TextColumn get repeatPolicy => text().named('repeat_policy').nullable()();
  TextColumn get mergePolicy => text().named('merge_policy')();
  BoolColumn get enabled => boolean().named('enabled')();
  IntColumn get revision => integer().named('revision')();

  @override
  Set<Column> get primaryKey => {reminderId};

  @override
  String? get tableName => 't_le_reminder_definitions';
}

/// 提醒定义的通道引用子表（channelIds，position 保证顺序稳定）。
@DataClassName('LifeEventReminderDefinitionChannelRow')
class LifeEventReminderDefinitionChannels extends Table {
  TextColumn get reminderId => text().named('reminder_id')();
  IntColumn get position => integer().named('position')();
  TextColumn get channelId => text().named('channel_id')();

  @override
  Set<Column> get primaryKey => {reminderId, position};

  @override
  String? get tableName => 't_le_reminder_definition_channels';
}

/// 提醒通道主表（Design §14.2，含 deliveryPolicy 列组）。
@DataClassName('LifeEventReminderChannelRow')
class LifeEventReminderChannels extends Table {
  TextColumn get channelId => text().named('channel_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get name => text().named('name')();
  BoolColumn get enabled => boolean().named('enabled')();

  // deliveryPolicy。
  TextColumn get policyLeadTimesMsJson => text().named('policy_lead_times_ms_json')();
  TextColumn get policyQuietHours => text().named('policy_quiet_hours').nullable()();
  IntColumn get policyMergeWindowMs => integer().named('policy_merge_window_ms')();
  TextColumn get policyDeliveryMode => text().named('policy_delivery_mode')();
  TextColumn get policyGroupingMode => text().named('policy_grouping_mode')();

  IntColumn get revision => integer().named('revision')();

  @override
  Set<Column> get primaryKey => {channelId};

  @override
  String? get tableName => 't_le_reminder_channels';
}

/// 通道选择器子表：八类列表共用规范化列，kind 标签区分语义。
///
/// | kind                 | valueA      | valueB           | valueC            | valueD     | valueInt        |
/// |----------------------|-------------|------------------|-------------------|------------|-----------------|
/// | subject              | subjectId   | -                | -                 | -          | -               |
/// | profile              | profileId   | -                | -                 | -          | -               |
/// | divination           | providerId? | divinationTypeKey? | subDivinationTypeKey? | -    | -               |
/// | eventType            | eventTypeId | -                | -                 | -          | -               |
/// | direction            | directionId | -                | -                 | -          | -               |
/// | sourceSeverity       | providerId  | schemeId         | schemeVersion     | code       | -               |
/// | userImportance       | ownerScopeId| catalogId        | levelId           | -          | catalogRevision |
/// | notificationPriority | ownerScopeId| catalogId        | priorityId        | -          | catalogRevision |
@DataClassName('LifeEventReminderChannelSelectorRow')
class LifeEventReminderChannelSelectors extends Table {
  TextColumn get channelId => text().named('channel_id')();
  TextColumn get kind => text().named('kind')();
  IntColumn get position => integer().named('position')();
  TextColumn get valueA => text().named('value_a').nullable()();
  TextColumn get valueB => text().named('value_b').nullable()();
  TextColumn get valueC => text().named('value_c').nullable()();
  TextColumn get valueD => text().named('value_d').nullable()();
  IntColumn get valueInt => integer().named('value_int').nullable()();

  @override
  Set<Column> get primaryKey => {channelId, kind, position};

  @override
  String? get tableName => 't_le_reminder_channel_selectors';
}

/// 聚合提醒主表（Design §14.3）。
@DataClassName('LifeEventReminderAggregateRow')
class LifeEventReminderAggregates extends Table {
  TextColumn get aggregateId => text().named('aggregate_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get subjectId => text().named('subject_id')();

  // TimeRange（半开区间，UTC 毫秒）。
  IntColumn get windowStartMs => integer().named('window_start_ms')();
  IntColumn get windowEndMs => integer().named('window_end_ms')();

  // effectiveNotificationPriorityRef。
  TextColumn get priorityOwnerScopeId => text().named('priority_owner_scope_id')();
  TextColumn get priorityCatalogId => text().named('priority_catalog_id')();
  IntColumn get priorityCatalogRevision =>
      integer().named('priority_catalog_revision')();
  TextColumn get priorityId => text().named('priority_id')();

  TextColumn get displayTitle => text().named('display_title')();
  TextColumn get userInterpretation =>
      text().named('user_interpretation').nullable()();

  @override
  Set<Column> get primaryKey => {aggregateId};

  @override
  String? get tableName => 't_le_reminder_aggregates';
}

/// 聚合提醒顶层方向子表（aggregate.directionIds，position 定序）。
@DataClassName('LifeEventReminderAggregateDirectionRow')
class LifeEventReminderAggregateDirections extends Table {
  TextColumn get aggregateId => text().named('aggregate_id')();
  IntColumn get position => integer().named('position')();
  TextColumn get directionId => text().named('direction_id')();

  @override
  Set<Column> get primaryKey => {aggregateId, position};

  @override
  String? get tableName => 't_le_reminder_aggregate_directions';
}

/// 聚合贡献者子表（不压平：每个 contributor 的技法、档案、事实、证据全保留）。
@DataClassName('LifeEventReminderAggregateContributorRow')
class LifeEventReminderAggregateContributors extends Table {
  TextColumn get aggregateId => text().named('aggregate_id')();
  IntColumn get position => integer().named('position')();

  TextColumn get providerId => text().named('provider_id')();
  TextColumn get divinationTypeKey => text().named('divination_type_key')();
  TextColumn get subDivinationTypeKey =>
      text().named('sub_divination_type_key').nullable()();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get chartSnapshotId => text().named('chart_snapshot_id')();
  TextColumn get sourceEventId => text().named('source_event_id')();
  TextColumn get eventRevision => text().named('event_revision')();
  TextColumn get eventTypeId => text().named('event_type_id')();
  TextColumn get factSummary => text().named('fact_summary')();
  TextColumn get evidenceRef => text().named('evidence_ref')();

  // SourceSeverityRef?（四列同空即为 null）。
  TextColumn get severityProviderId =>
      text().named('severity_provider_id').nullable()();
  TextColumn get severitySchemeId => text().named('severity_scheme_id').nullable()();
  TextColumn get severitySchemeVersion =>
      text().named('severity_scheme_version').nullable()();
  TextColumn get severityCode => text().named('severity_code').nullable()();

  // SourceVersions（非空对象，ruleVersion/dataVersion 可空）。
  TextColumn get providerVersion => text().named('provider_version')();
  TextColumn get algorithmVersion => text().named('algorithm_version')();
  TextColumn get ruleVersion => text().named('rule_version').nullable()();
  TextColumn get dataVersion => text().named('data_version').nullable()();

  TextColumn get annotationRef => text().named('annotation_ref').nullable()();

  /// contributor.directionIds（标量有序列表，JSON 数组）。
  TextColumn get directionIdsJson => text().named('direction_ids_json')();

  // UserImportanceRef?（四列同空即为 null）。
  TextColumn get importanceOwnerScopeId =>
      text().named('importance_owner_scope_id').nullable()();
  TextColumn get importanceCatalogId =>
      text().named('importance_catalog_id').nullable()();
  IntColumn get importanceCatalogRevision =>
      integer().named('importance_catalog_revision').nullable()();
  TextColumn get importanceLevelId =>
      text().named('importance_level_id').nullable()();

  TextColumn get reminderId => text().named('reminder_id')();

  @override
  Set<Column> get primaryKey => {aggregateId, position};

  @override
  String? get tableName => 't_le_reminder_aggregate_contributors';
}

/// 调度任务表（Design §14.4，含租约列）。
@DataClassName('LifeEventReminderScheduleRow')
class LifeEventReminderSchedules extends Table {
  TextColumn get scheduleId => text().named('schedule_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();

  /// reminderId 与 aggregateId 恰好一个非空（写入前 validateTarget 校验）。
  TextColumn get reminderId => text().named('reminder_id').nullable()();
  TextColumn get aggregateId => text().named('aggregate_id').nullable()();

  IntColumn get fireAtMs => integer().named('fire_at_ms')();
  TextColumn get displayTimezoneId => text().named('display_timezone_id')();
  IntColumn get channelRevision => integer().named('channel_revision')();
  TextColumn get sourceRevisionFingerprint =>
      text().named('source_revision_fingerprint')();

  /// ScheduleStatus.name。
  TextColumn get status => text().named('status')();
  TextColumn get claimToken => text().named('claim_token').nullable()();
  IntColumn get leaseExpiresAtMs => integer().named('lease_expires_at_ms').nullable()();

  @override
  Set<Column> get primaryKey => {scheduleId};

  @override
  String? get tableName => 't_le_reminder_schedules';
}

/// 投递记录表（已投递记录保留审计，不随源事件删除）。
@DataClassName('LifeEventReminderDeliveryRow')
class LifeEventReminderDeliveries extends Table {
  TextColumn get deliveryId => text().named('delivery_id')();
  TextColumn get scheduleId => text().named('schedule_id')();
  IntColumn get attemptedAtMs => integer().named('attempted_at_ms')();
  TextColumn get outcome => text().named('outcome')();
  TextColumn get stableErrorCode => text().named('stable_error_code').nullable()();

  @override
  Set<Column> get primaryKey => {deliveryId};

  @override
  String? get tableName => 't_le_reminder_deliveries';
}
