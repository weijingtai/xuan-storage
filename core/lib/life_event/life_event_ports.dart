/// ACT-01：冻结 persistence_core 存储边界 ports 与共享合同套件。
///
/// 纯 Dart 存储边界。候选代晋升只能发生在原子 shard commit 内
/// （[LifeEventShardCommitPort.commitValidatedShard]），不提供独立 activate API。
/// 本文件不 import calendar / Flutter / Drift / submodule。
library;

import 'life_event_dtos.dart';

/// 覆盖代生成 port：创建或替换 candidate 覆盖代。
abstract interface class LifeEventCoverageGenerationPort {
  Future<CreateCoverageGenerationResult> createOrReplaceCandidate(
    CreateCoverageGenerationRequest request,
  );
}

/// 已验证分片提交 port：原子写入 projection/tombstone/receipt/manifest，
/// 完成时在同一事务内做 series-head CAS 并切换 active/historical。
abstract interface class LifeEventShardCommitPort {
  Future<CommitValidatedShardResult> commitValidatedShard(
    CommitValidatedShardRequest request,
  );
}

/// 投影存储查询。
final class ProjectionStorageQuery {
  final String ownerScopeId;
  final List<String> profileIds;
  final List<String> chartSnapshotIds;
  final List<String> providerIds;
  final List<String> eventTypeIds;
  final TimeRange range;
  final bool includeWithdrawn;
  final bool includeHistoricalGenerations;
  final String sortKey;
  final String? pageToken;
  final int pageSize;

  const ProjectionStorageQuery({
    required this.ownerScopeId,
    required this.profileIds,
    required this.chartSnapshotIds,
    required this.providerIds,
    required this.eventTypeIds,
    required this.range,
    required this.includeWithdrawn,
    required this.includeHistoricalGenerations,
    required this.sortKey,
    required this.pageToken,
    required this.pageSize,
  });
}

/// 投影查询分页。
final class ProjectionQueryPage {
  final List<EventProjection> items;
  final String? nextPageToken;

  const ProjectionQueryPage({required this.items, required this.nextPageToken});
}

/// 投影查询 port。
abstract interface class LifeEventProjectionQueryPort {
  Future<ProjectionQueryPage> queryProjections(ProjectionStorageQuery request);
}

/// 覆盖存储查询。
final class CoverageStorageQuery {
  final String ownerScopeId;
  final List<String> profileIds;
  final List<String> chartSnapshotIds;
  final List<String> providerIds;
  final List<String> eventTypeIds;
  final TimeRange range;
  final bool includeHistoricalGenerations;

  const CoverageStorageQuery({
    required this.ownerScopeId,
    required this.profileIds,
    required this.chartSnapshotIds,
    required this.providerIds,
    required this.eventTypeIds,
    required this.range,
    required this.includeHistoricalGenerations,
  });
}

/// 覆盖存储分页。
final class CoverageStoragePage {
  final List<CoverageSeriesHead> heads;
  final List<CoverageManifest> manifests;

  const CoverageStoragePage({required this.heads, required this.manifests});
}

/// 覆盖查询 port。
abstract interface class LifeEventCoverageQueryPort {
  Future<CoverageStoragePage> queryCoverage(CoverageStorageQuery request);
}

/// 档案身份存储：LifeProfile 与 ChartSnapshot 分开保存，强制 owner/CAS。
abstract interface class LifeProfileIdentityStore {
  Future<SaveLifeProfileResult> saveLifeProfile(SaveLifeProfileRequest request);

  Future<SaveChartSnapshotResult> saveChartSnapshot(SaveChartSnapshotRequest request);

  Future<LifeProfileIdentityPage> queryIdentity(LifeProfileIdentityQuery request);
}

/// 保存批注请求。
final class SaveAnnotationRequest {
  final String ownerScopeId;
  final UserAnnotation annotation;
  final int expectedRevision;

  const SaveAnnotationRequest({
    required this.ownerScopeId,
    required this.annotation,
    required this.expectedRevision,
  });
}

/// 保存批注结果。
final class SaveAnnotationResult {
  final String outcome;
  final int revision;

  const SaveAnnotationResult({required this.outcome, required this.revision});
}

/// 批注查询。
final class AnnotationQuery {
  final String ownerScopeId;
  final List<SourceRef> targetSourceRefs;
  final String? pageToken;
  final int pageSize;

  const AnnotationQuery({
    required this.ownerScopeId,
    required this.targetSourceRefs,
    required this.pageToken,
    required this.pageSize,
  });
}

/// 批注分页。
final class AnnotationPage {
  final List<UserAnnotation> items;
  final String? nextPageToken;

  const AnnotationPage({required this.items, required this.nextPageToken});
}

/// 保存事件选择请求。
final class SaveOccurrenceSelectionRequest {
  final String ownerScopeId;
  final SavedOccurrenceSelection selection;
  final int expectedRevision;

  const SaveOccurrenceSelectionRequest({
    required this.ownerScopeId,
    required this.selection,
    required this.expectedRevision,
  });
}

/// 保存事件选择结果。
final class SaveOccurrenceSelectionResult {
  final String outcome;
  final int revision;

  const SaveOccurrenceSelectionResult({required this.outcome, required this.revision});
}

/// 事件选择查询。
final class OccurrenceSelectionQuery {
  final String ownerScopeId;
  final List<String> selectionIds;
  final List<SourceRef> sourceRefs;
  final String? pageToken;
  final int pageSize;

  const OccurrenceSelectionQuery({
    required this.ownerScopeId,
    required this.selectionIds,
    required this.sourceRefs,
    required this.pageToken,
    required this.pageSize,
  });
}

/// 事件选择分页。
final class OccurrenceSelectionPage {
  final List<SavedOccurrenceSelection> items;
  final String? nextPageToken;

  const OccurrenceSelectionPage({required this.items, required this.nextPageToken});
}

/// 保存模式规则请求。
final class SavePatternRuleRequest {
  final String ownerScopeId;
  final SavedPatternRule rule;
  final int expectedRevision;

  const SavePatternRuleRequest({
    required this.ownerScopeId,
    required this.rule,
    required this.expectedRevision,
  });
}

/// 保存模式规则结果。
final class SavePatternRuleResult {
  final String outcome;
  final int revision;

  const SavePatternRuleResult({required this.outcome, required this.revision});
}

/// 模式规则查询。
final class PatternRuleQuery {
  final String ownerScopeId;
  final List<String> providerIds;
  final List<String> eventTypeIds;
  final bool? enabledForMatching;
  final String? pageToken;
  final int pageSize;

  const PatternRuleQuery({
    required this.ownerScopeId,
    required this.providerIds,
    required this.eventTypeIds,
    required this.enabledForMatching,
    required this.pageToken,
    required this.pageSize,
  });
}

/// 模式规则分页。
final class PatternRulePage {
  final List<SavedPatternRule> items;
  final String? nextPageToken;

  const PatternRulePage({required this.items, required this.nextPageToken});
}

/// 保存模板请求。
final class SaveTemplateRequest {
  final String ownerScopeId;
  final PersonalRuleTemplate template;
  final int expectedRevision;

  const SaveTemplateRequest({
    required this.ownerScopeId,
    required this.template,
    required this.expectedRevision,
  });
}

/// 保存模板结果。
final class SaveTemplateResult {
  final String outcome;
  final int revision;

  const SaveTemplateResult({required this.outcome, required this.revision});
}

/// 模板查询。
final class TemplateQuery {
  final String ownerScopeId;
  final String? pageToken;
  final int pageSize;

  const TemplateQuery({
    required this.ownerScopeId,
    required this.pageToken,
    required this.pageSize,
  });
}

/// 模板分页。
final class TemplatePage {
  final List<PersonalRuleTemplate> items;
  final String? nextPageToken;

  const TemplatePage({required this.items, required this.nextPageToken});
}

/// 用户规则存储：四类对象四套 typed 方法，不接受通用联合入口
/// （不存在 `save(UserRuleRecord)`）。
abstract interface class LifeEventUserRuleStore {
  Future<SaveAnnotationResult> saveAnnotation(SaveAnnotationRequest request);

  Future<AnnotationPage> queryAnnotations(AnnotationQuery query);

  Future<SaveOccurrenceSelectionResult> saveOccurrenceSelection(
    SaveOccurrenceSelectionRequest request,
  );

  Future<OccurrenceSelectionPage> queryOccurrenceSelections(OccurrenceSelectionQuery query);

  Future<SavePatternRuleResult> savePatternRule(SavePatternRuleRequest request);

  Future<PatternRulePage> queryPatternRules(PatternRuleQuery query);

  Future<SaveTemplateResult> saveTemplate(SaveTemplateRequest request);

  Future<TemplatePage> queryTemplates(TemplateQuery query);
}

/// 领取到期调度请求。
final class ClaimDueSchedulesRequest {
  final String ownerScopeId;
  final DateTime nowUtc;
  final int maxCount;
  final String claimToken;
  final Duration leaseDuration;

  const ClaimDueSchedulesRequest({
    required this.ownerScopeId,
    required this.nowUtc,
    required this.maxCount,
    required this.claimToken,
    required this.leaseDuration,
  });
}

/// 领取到期调度结果。
final class ClaimDueSchedulesResult {
  final List<ScheduledNotification> claimed;
  final String claimToken;
  final DateTime claimedAt;

  const ClaimDueSchedulesResult({
    required this.claimed,
    required this.claimToken,
    required this.claimedAt,
  });
}

/// 提醒存储：definition/channel/aggregate/schedule/delivery + 租约领取。
abstract interface class LifeEventReminderStore {
  /// expectedRevision：调用方认为当前已存储的 revision；对象不存在时不校验（约定传 0）；
  /// 存在且不等 → revisionConflict 零写入；value.revision 必须等于 expectedRevision + 1（Design §14.1）。
  Future<SaveReminderResult> saveDefinition(ReminderDefinition value, int expectedRevision);

  Future<SaveReminderResult> saveChannel(ReminderChannel value, int expectedRevision);

  Future<SaveReminderResult> saveAggregate(AggregateReminder value);

  Future<SaveReminderResult> saveSchedule(ScheduledNotification value);

  Future<ClaimDueSchedulesResult> claimDue(ClaimDueSchedulesRequest request);

  Future<SaveReminderResult> saveDelivery(DeliveryRecord value);
}

/// 保存外部事件请求。
final class SaveExternalEventRequest {
  final String ownerScopeId;
  final ExternalCalendarEvent event;
  final String? expectedRevision;

  const SaveExternalEventRequest({
    required this.ownerScopeId,
    required this.event,
    required this.expectedRevision,
  });
}

/// 保存外部事件结果。
final class SaveExternalEventResult {
  final String outcome;
  final String revision;

  const SaveExternalEventResult({required this.outcome, required this.revision});
}

/// 外部事件查询。
final class ExternalEventQuery {
  final String ownerScopeId;
  final List<String> relatedSubjectIds;
  final List<ExternalOriginType> originTypes;
  final TimeRange? timeRange;
  final String? pageToken;
  final int pageSize;

  const ExternalEventQuery({
    required this.ownerScopeId,
    required this.relatedSubjectIds,
    required this.originTypes,
    required this.timeRange,
    required this.pageToken,
    required this.pageSize,
  });
}

/// 外部事件分页。
final class ExternalEventPage {
  final List<ExternalCalendarEvent> items;
  final String? nextPageToken;

  const ExternalEventPage({required this.items, required this.nextPageToken});
}

/// 外部日历事件存储。
abstract interface class ExternalCalendarEventStore {
  Future<SaveExternalEventResult> save(SaveExternalEventRequest request);

  Future<ExternalEventPage> query(ExternalEventQuery query);
}