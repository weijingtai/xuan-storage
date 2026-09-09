/// ACT-01A：冻结 persistence_core 存储边界使用的不可变 DTO。
///
/// 只定义存储边界 DTO；不定义 Calendar 查询、Provider 或 Coordinator。
/// 全部集合不可变、字段为 final；禁止 `Map<String,dynamic>`。
/// 字段严格对应 Design §4.3/§4.4/§6.2/§6.4/§7/§8/§9/§13–§15。
library;

/// 时间精度。
enum TimePrecision { second, minute, hour, day, month, year }

/// 半开区间 [startInclusiveUtc, endExclusiveUtc).
final class TimeRange {
  final DateTime startInclusiveUtc;
  final DateTime endExclusiveUtc;

  const TimeRange({
    required this.startInclusiveUtc,
    required this.endExclusiveUtc,
  });
}

/// 事件时间基类（tagged shape）。
sealed class LifeEventTime {
  final DateTime effectiveStartUtc;

  const LifeEventTime({required this.effectiveStartUtc});
}

/// 瞬时时间。
final class InstantTime extends LifeEventTime {
  final DateTime instantUtc;
  final String calculationTimezoneId;
  final TimePrecision precision;

  const InstantTime({
    required super.effectiveStartUtc,
    required this.instantUtc,
    required this.calculationTimezoneId,
    required this.precision,
  });
}

/// 半开区间时间。
final class IntervalTime extends LifeEventTime {
  final DateTime startInclusiveUtc;
  final DateTime endExclusiveUtc;
  final String calculationTimezoneId;
  final TimePrecision precision;

  const IntervalTime({
    required super.effectiveStartUtc,
    required this.startInclusiveUtc,
    required this.endExclusiveUtc,
    required this.calculationTimezoneId,
    required this.precision,
  });
}

/// 民用跨度时间（日/月/年粒度，按日历系统表达）。
final class CivilSpanTime extends LifeEventTime {
  final DateTime startCivilInclusive;
  final DateTime endCivilExclusive;
  final String calendarSystem;
  final String? timezoneId;
  final TimePrecision precision;

  const CivilSpanTime({
    required super.effectiveStartUtc,
    required this.startCivilInclusive,
    required this.endCivilExclusive,
    required this.calendarSystem,
    required this.timezoneId,
    required this.precision,
  });
}

/// 出生精度。
enum BirthPrecision { year, month, day, hour, minute, second }

/// 出生日历系统。
enum BirthCalendarSystem { gregorian, julian, chineseLunar }

/// 出生输入（结构化民用时间，禁止压平为字符串）。
final class BirthInput {
  final DateTime civilDateTime;
  final BirthPrecision precision;
  final bool isTimeKnown;
  final BirthCalendarSystem calendarSystem;

  const BirthInput({
    required this.civilDateTime,
    required this.precision,
    required this.isTimeKnown,
    required this.calendarSystem,
  });
}

/// 地理坐标。
final class GeoCoordinates {
  final double latitudeDeg;
  final double longitudeDeg;
  final double? altitudeMeters;
  final String geodeticDatum;

  const GeoCoordinates({
    required this.latitudeDeg,
    required this.longitudeDeg,
    required this.altitudeMeters,
    required this.geodeticDatum,
  });
}

/// 命理档案记录。
final class LifeProfileRecord {
  final String profileId;
  final String ownerScopeId;
  final String subjectId;
  final String displayLabel;
  final BirthInput birthInput;
  final String? placeRef;
  final GeoCoordinates? coordinates;
  final String timezoneId;
  final String timeConversionPolicyId;
  final String dayBoundaryPolicyId;
  final String? rectificationPolicyId;
  final int profileRevision;
  final bool isDefault;
  final String lifecycleStatus;

  const LifeProfileRecord({
    required this.profileId,
    required this.ownerScopeId,
    required this.subjectId,
    required this.displayLabel,
    required this.birthInput,
    required this.placeRef,
    required this.coordinates,
    required this.timezoneId,
    required this.timeConversionPolicyId,
    required this.dayBoundaryPolicyId,
    required this.rectificationPolicyId,
    required this.profileRevision,
    required this.isDefault,
    required this.lifecycleStatus,
  });
}

/// 命盘快照引用（与 LifeProfile 分开保存）。
final class ChartSnapshotRef {
  final String chartSnapshotId;
  final String profileId;
  final String providerId;
  final String divinationTypeKey;
  final String? subDivinationTypeKey;
  final String snapshotRevision;
  final String algorithmVersion;
  final String inputFingerprint;
  final DateTime createdAt;

  const ChartSnapshotRef({
    required this.chartSnapshotId,
    required this.profileId,
    required this.providerId,
    required this.divinationTypeKey,
    required this.subDivinationTypeKey,
    required this.snapshotRevision,
    required this.algorithmVersion,
    required this.inputFingerprint,
    required this.createdAt,
  });
}

/// 保存 LifeProfile 请求（带 expectedProfileRevision CAS）。
final class SaveLifeProfileRequest {
  final String ownerScopeId;
  final LifeProfileRecord profile;
  final int expectedProfileRevision;

  const SaveLifeProfileRequest({
    required this.ownerScopeId,
    required this.profile,
    required this.expectedProfileRevision,
  });
}

/// 保存 LifeProfile 结果。
enum SaveLifeProfileOutcome { saved, revisionConflict, ownerScopeMismatch }

final class SaveLifeProfileResult {
  final SaveLifeProfileOutcome outcome;
  final int profileRevision;

  const SaveLifeProfileResult({
    required this.outcome,
    required this.profileRevision,
  });
}

/// 保存 ChartSnapshot 请求。
final class SaveChartSnapshotRequest {
  final String ownerScopeId;
  final ChartSnapshotRef chartSnapshot;
  final int expectedProfileRevision;

  const SaveChartSnapshotRequest({
    required this.ownerScopeId,
    required this.chartSnapshot,
    required this.expectedProfileRevision,
  });
}

/// 保存 ChartSnapshot 结果。
enum SaveChartSnapshotOutcome { saved, staleProfileRevision, profileMissing, ownerScopeMismatch }

final class SaveChartSnapshotResult {
  final SaveChartSnapshotOutcome outcome;
  final String chartSnapshotId;
  final String snapshotRevision;

  const SaveChartSnapshotResult({
    required this.outcome,
    required this.chartSnapshotId,
    required this.snapshotRevision,
  });
}

/// 档案身份查询。
final class LifeProfileIdentityQuery {
  final String ownerScopeId;
  final List<String> subjectIds;
  final List<String> profileIds;
  final bool defaultOnly;
  final String? pageToken;
  final int pageSize;

  const LifeProfileIdentityQuery({
    required this.ownerScopeId,
    required this.subjectIds,
    required this.profileIds,
    required this.defaultOnly,
    required this.pageToken,
    required this.pageSize,
  });
}

/// 档案身份分页。
final class LifeProfileIdentityPage {
  final List<LifeProfileRecord> profiles;
  final List<ChartSnapshotRef> chartSnapshots;
  final String? nextPageToken;

  const LifeProfileIdentityPage({
    required this.profiles,
    required this.chartSnapshots,
    required this.nextPageToken,
  });
}

/// 类型化标量基类。
sealed class TypedScalar {
  final String fieldId;
  final String schemaVersion;

  const TypedScalar({required this.fieldId, required this.schemaVersion});
}

final class TextScalar extends TypedScalar {
  final String value;

  const TextScalar({required super.fieldId, required super.schemaVersion, required this.value});
}

final class NumberScalar extends TypedScalar {
  final num value;

  const NumberScalar({required super.fieldId, required super.schemaVersion, required this.value});
}

final class BooleanScalar extends TypedScalar {
  final bool value;

  const BooleanScalar({required super.fieldId, required super.schemaVersion, required this.value});
}

final class EnumScalar extends TypedScalar {
  final String code;
  final String catalogVersion;

  const EnumScalar({
    required super.fieldId,
    required super.schemaVersion,
    required this.code,
    required this.catalogVersion,
  });
}

final class MultiEnumScalar extends TypedScalar {
  final List<String> codes;
  final String catalogVersion;

  const MultiEnumScalar({
    required super.fieldId,
    required super.schemaVersion,
    required this.codes,
    required this.catalogVersion,
  });
}

final class UnknownScalar extends TypedScalar {
  final String rawEncoded;

  const UnknownScalar({
    required super.fieldId,
    required super.schemaVersion,
    required this.rawEncoded,
  });
}

/// 过滤算子。
enum FilterOperator { eq, inValues, contains, between }

/// 过滤表达式。
final class FilterExpression {
  final String filterId;
  final String projectionPath;
  final FilterOperator operator;
  final List<TypedScalar> operands;
  final String operandSchemaVersion;

  const FilterExpression({
    required this.filterId,
    required this.projectionPath,
    required this.operator,
    required this.operands,
    required this.operandSchemaVersion,
  });
}

/// 事件参与者。
final class EventParticipant {
  final String roleId;
  final String participantKind;
  final String participantId;
  final String? displayNameKey;
  final List<TypedScalar> attributes;

  const EventParticipant({
    required this.roleId,
    required this.participantKind,
    required this.participantId,
    required this.displayNameKey,
    required this.attributes,
  });
}

/// 来源引用。
final class SourceRef {
  final String providerId;
  final String sourceEventId;
  final String eventRevision;

  const SourceRef({
    required this.providerId,
    required this.sourceEventId,
    required this.eventRevision,
  });
}

/// 全局天象事件引用（typed evidence）。
final class AstronomyEventRef {
  final String astronomyProviderId;
  final String datasetProfileId;
  final String bodyId;
  final String astronomyEventId;
  final String dataVersion;

  const AstronomyEventRef({
    required this.astronomyProviderId,
    required this.datasetProfileId,
    required this.bodyId,
    required this.astronomyEventId,
    required this.dataVersion,
  });
}

/// 天象证据引用（typed evidence）。
final class AstronomyEvidenceRef {
  final String astronomyProviderId;
  final String evidenceId;
  final String evidenceRevision;
  final String evidenceSchemaId;
  final String schemaVersion;

  const AstronomyEvidenceRef({
    required this.astronomyProviderId,
    required this.evidenceId,
    required this.evidenceRevision,
    required this.evidenceSchemaId,
    required this.schemaVersion,
  });
}

/// 档案匹配证据引用（typed evidence）。
final class ProfileMatchEvidenceRef {
  final String providerId;
  final String evidenceId;
  final String evidenceRevision;
  final String evidenceSchemaId;
  final String schemaVersion;

  const ProfileMatchEvidenceRef({
    required this.providerId,
    required this.evidenceId,
    required this.evidenceRevision,
    required this.evidenceSchemaId,
    required this.schemaVersion,
  });
}

/// 来源严重度引用。
final class SourceSeverityRef {
  final String providerId;
  final String schemeId;
  final String schemeVersion;
  final String code;

  const SourceSeverityRef({
    required this.providerId,
    required this.schemeId,
    required this.schemeVersion,
    required this.code,
  });
}

/// 用户重要度引用。
final class UserImportanceRef {
  final String ownerScopeId;
  final String catalogId;
  final int catalogRevision;
  final String levelId;

  const UserImportanceRef({
    required this.ownerScopeId,
    required this.catalogId,
    required this.catalogRevision,
    required this.levelId,
  });
}

/// 通知优先级引用。
final class NotificationPriorityRef {
  final String ownerScopeId;
  final String catalogId;
  final int catalogRevision;
  final String priorityId;

  const NotificationPriorityRef({
    required this.ownerScopeId,
    required this.catalogId,
    required this.catalogRevision,
    required this.priorityId,
  });
}

/// 来源版本信息。
final class SourceVersions {
  final String providerVersion;
  final String algorithmVersion;
  final String? ruleVersion;
  final String? dataVersion;

  const SourceVersions({
    required this.providerVersion,
    required this.algorithmVersion,
    required this.ruleVersion,
    required this.dataVersion,
  });
}

/// 投影生命周期状态。
enum ProjectionLifecycleStatus { discovered, active, stale, superseded, withdrawn }

/// 事件投影。
final class EventProjection {
  final String projectionId;
  final String projectionIdAlgorithmVersion;
  final String coverageId;
  final int coverageGeneration;
  final SourceRef sourceRef;
  final String ownerScopeId;
  final String subjectId;
  final String profileId;
  final String chartSnapshotId;
  final String divinationTypeKey;
  final String? subDivinationTypeKey;
  final String eventTypeId;
  final LifeEventTime eventTime;
  final List<EventParticipant> projectedParticipants;
  final List<TypedScalar> projectedFactValues;
  final String factSummary;
  final String evidenceRef;
  final AstronomyEventRef? astronomyEventRef;
  final AstronomyEvidenceRef? astronomyEvidenceRef;
  final ProfileMatchEvidenceRef? profileMatchEvidenceRef;
  final SourceSeverityRef? sourceSeverityRef;
  final SourceVersions sourceVersions;
  final ProjectionLifecycleStatus projectionLifecycleStatus;
  final DateTime indexedAt;

  const EventProjection({
    required this.projectionId,
    required this.projectionIdAlgorithmVersion,
    required this.coverageId,
    required this.coverageGeneration,
    required this.sourceRef,
    required this.ownerScopeId,
    required this.subjectId,
    required this.profileId,
    required this.chartSnapshotId,
    required this.divinationTypeKey,
    required this.subDivinationTypeKey,
    required this.eventTypeId,
    required this.eventTime,
    required this.projectedParticipants,
    required this.projectedFactValues,
    required this.factSummary,
    required this.evidenceRef,
    required this.astronomyEventRef,
    required this.astronomyEvidenceRef,
    required this.profileMatchEvidenceRef,
    required this.sourceSeverityRef,
    required this.sourceVersions,
    required this.projectionLifecycleStatus,
    required this.indexedAt,
  });
}

/// 覆盖状态。
enum CoverageStatus { notRequested, queued, running, partial, failed, complete, stale }

/// 服务状态。
enum ServingState { candidate, active, historical, superseded }

/// 覆盖系列头。
final class CoverageSeriesHead {
  final String coverageSeriesId;
  final String ownerScopeId;
  final String profileId;
  final String chartSnapshotId;
  final String providerId;
  final String eventTypeId;
  final int seriesRevision;
  final String? activeCoverageId;
  final String? candidateCoverageId;
  final TimeRange desiredRange;

  const CoverageSeriesHead({
    required this.coverageSeriesId,
    required this.ownerScopeId,
    required this.profileId,
    required this.chartSnapshotId,
    required this.providerId,
    required this.eventTypeId,
    required this.seriesRevision,
    required this.activeCoverageId,
    required this.candidateCoverageId,
    required this.desiredRange,
  });
}

/// 覆盖清单。
final class CoverageManifest {
  final String coverageId;
  final String coverageSeriesId;
  final int coverageGeneration;
  final int manifestRevision;
  final ServingState servingState;
  final String profileId;
  final String chartSnapshotId;
  final String chartSnapshotRevision;
  final String providerId;
  final String providerVersion;
  final String algorithmVersion;
  final String? dataVersion;
  final String eventTypeId;
  final String eventTypeSchemaVersion;
  final String capabilityDescriptorVersion;
  final String capabilityDigest;
  final TimeRange requestedRange;
  final List<TimeRange> coveredRanges;
  final CoverageStatus status;
  final String inputFingerprint;
  final int expectedShardCount;
  final int completedShardCount;
  final int sourceEventCount;
  final String outputDigest;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? lastErrorCode;

  const CoverageManifest({
    required this.coverageId,
    required this.coverageSeriesId,
    required this.coverageGeneration,
    required this.manifestRevision,
    required this.servingState,
    required this.profileId,
    required this.chartSnapshotId,
    required this.chartSnapshotRevision,
    required this.providerId,
    required this.providerVersion,
    required this.algorithmVersion,
    required this.dataVersion,
    required this.eventTypeId,
    required this.eventTypeSchemaVersion,
    required this.capabilityDescriptorVersion,
    required this.capabilityDigest,
    required this.requestedRange,
    required this.coveredRanges,
    required this.status,
    required this.inputFingerprint,
    required this.expectedShardCount,
    required this.completedShardCount,
    required this.sourceEventCount,
    required this.outputDigest,
    required this.startedAt,
    required this.completedAt,
    required this.lastErrorCode,
  });
}

/// receipt 身份（canonical key: coverageId + shardId）。
final class ReceiptIdentity {
  final String coverageId;
  final String shardId;

  const ReceiptIdentity({required this.coverageId, required this.shardId});
}

/// 分片 receipt。
final class ShardReceipt {
  final String coverageId;
  final String shardId;
  final int coverageGeneration;
  final TimeRange requestedRange;
  final TimeRange coveredRange;
  final int eventCount;
  final String contentDigest;
  final int persistedCount;
  final String persistedDigest;
  final bool isCompleteForCoveredRange;
  final String inputFingerprint;
  final DateTime committedAt;

  const ShardReceipt({
    required this.coverageId,
    required this.shardId,
    required this.coverageGeneration,
    required this.requestedRange,
    required this.coveredRange,
    required this.eventCount,
    required this.contentDigest,
    required this.persistedCount,
    required this.persistedDigest,
    required this.isCompleteForCoveredRange,
    required this.inputFingerprint,
    required this.committedAt,
  });

  ReceiptIdentity get receiptIdentity =>
      ReceiptIdentity(coverageId: coverageId, shardId: shardId);
}

/// 创建覆盖代请求。
final class CreateCoverageGenerationRequest {
  final String coverageSeriesId;
  final int expectedSeriesRevision;
  final String? expectedActiveCoverageId;
  final TimeRange desiredRange;
  final String providerId;
  final String providerVersion;
  final String chartSnapshotId;
  final String chartSnapshotRevision;
  final String algorithmVersion;
  final String? dataVersion;
  final String eventTypeId;
  final String eventTypeSchemaVersion;
  final String inputFingerprint;

  const CreateCoverageGenerationRequest({
    required this.coverageSeriesId,
    required this.expectedSeriesRevision,
    required this.expectedActiveCoverageId,
    required this.desiredRange,
    required this.providerId,
    required this.providerVersion,
    required this.chartSnapshotId,
    required this.chartSnapshotRevision,
    required this.algorithmVersion,
    required this.dataVersion,
    required this.eventTypeId,
    required this.eventTypeSchemaVersion,
    required this.inputFingerprint,
  });
}

/// 创建覆盖代结果。
enum CreateCoverageGenerationOutcome { created, seriesRevisionConflict, rangeShrinkUnsupported }

final class CreateCoverageGenerationResult {
  final CreateCoverageGenerationOutcome outcome;
  final String? coverageId;
  final int? coverageGeneration;
  final int seriesRevision;
  final String? activeCoverageId;
  final String? candidateCoverageId;
  final TimeRange desiredRange;

  const CreateCoverageGenerationResult({
    required this.outcome,
    required this.coverageId,
    required this.coverageGeneration,
    required this.seriesRevision,
    required this.activeCoverageId,
    required this.candidateCoverageId,
    required this.desiredRange,
  });
}

/// 覆盖代转换。
enum CoverageTransition { running, partial, failed, complete }

/// 提交已验证分片请求。
final class CommitValidatedShardRequest {
  final String coverageId;
  final int coverageGeneration;
  final int expectedManifestRevision;
  final int? expectedSeriesRevision;
  final String? expectedActiveCoverageId;
  final String? expectedCandidateCoverageId;
  final String providerId;
  final String providerVersion;
  final String algorithmVersion;
  final String? dataVersion;
  final String eventTypeId;
  final String eventTypeSchemaVersion;
  final String inputFingerprint;
  final ReceiptIdentity receiptIdentity;
  final String requestId;
  final TimeRange requestedRange;
  final TimeRange coveredRange;
  final List<EventProjection> projections;
  final List<SourceRef> withdrawals;
  final int eventCount;
  final String contentDigest;
  final bool isCompleteForCoveredRange;
  final CoverageTransition requestedCoverageTransition;

  const CommitValidatedShardRequest({
    required this.coverageId,
    required this.coverageGeneration,
    required this.expectedManifestRevision,
    required this.expectedSeriesRevision,
    required this.expectedActiveCoverageId,
    required this.expectedCandidateCoverageId,
    required this.providerId,
    required this.providerVersion,
    required this.algorithmVersion,
    required this.dataVersion,
    required this.eventTypeId,
    required this.eventTypeSchemaVersion,
    required this.inputFingerprint,
    required this.receiptIdentity,
    required this.requestId,
    required this.requestedRange,
    required this.coveredRange,
    required this.projections,
    required this.withdrawals,
    required this.eventCount,
    required this.contentDigest,
    required this.isCompleteForCoveredRange,
    required this.requestedCoverageTransition,
  });
}

/// 提交已验证分片结果。
enum CommitValidatedShardOutcome { applied, idempotentReplay, revisionConflict, receiptDigestConflict, activeSwitchConflict }

final class CommitValidatedShardResult {
  final CommitValidatedShardOutcome outcome;
  final int manifestRevision;
  final int coverageGeneration;
  final int seriesRevision;
  final String? activeCoverageId;
  final ReceiptIdentity receiptIdentity;
  final int persistedCount;
  final String persistedDigest;
  final CoverageStatus coverageStatus;
  final ServingState servingState;
  final int completedShardCount;
  final int expectedShardCount;

  const CommitValidatedShardResult({
    required this.outcome,
    required this.manifestRevision,
    required this.coverageGeneration,
    required this.seriesRevision,
    required this.activeCoverageId,
    required this.receiptIdentity,
    required this.persistedCount,
    required this.persistedDigest,
    required this.coverageStatus,
    required this.servingState,
    required this.completedShardCount,
    required this.expectedShardCount,
  });
}

/// 用户方向。
final class UserDirection {
  final String directionId;
  final String ownerScopeId;
  final String label;
  final String? color;
  final int sortOrder;
  final DateTime? archivedAt;

  const UserDirection({
    required this.directionId,
    required this.ownerScopeId,
    required this.label,
    required this.color,
    required this.sortOrder,
    required this.archivedAt,
  });
}

/// 来源严重度级别。
final class SourceSeverityLevel {
  final String code;
  final String displayNameKey;
  final int sortRank;

  const SourceSeverityLevel({
    required this.code,
    required this.displayNameKey,
    required this.sortRank,
  });
}

/// 来源严重度方案描述符。
final class SourceSeveritySchemeDescriptor {
  final String providerId;
  final String schemeId;
  final String schemeVersion;
  final List<SourceSeverityLevel> levels;

  const SourceSeveritySchemeDescriptor({
    required this.providerId,
    required this.schemeId,
    required this.schemeVersion,
    required this.levels,
  });
}

/// 用户重要度级别。
final class UserImportanceLevel {
  final String levelId;
  final String label;
  final int sortRank;

  const UserImportanceLevel({
    required this.levelId,
    required this.label,
    required this.sortRank,
  });
}

/// 用户重要度目录。
final class UserImportanceCatalog {
  final String ownerScopeId;
  final String catalogId;
  final int catalogRevision;
  final List<UserImportanceLevel> levels;

  const UserImportanceCatalog({
    required this.ownerScopeId,
    required this.catalogId,
    required this.catalogRevision,
    required this.levels,
  });
}

/// 通知优先级级别。
final class NotificationPriorityLevel {
  final String priorityId;
  final String label;
  final int sortRank;
  final int platformPriority;

  const NotificationPriorityLevel({
    required this.priorityId,
    required this.label,
    required this.sortRank,
    required this.platformPriority,
  });
}

/// 通知优先级目录。
final class NotificationPriorityCatalog {
  final String ownerScopeId;
  final String catalogId;
  final int catalogRevision;
  final List<NotificationPriorityLevel> levels;

  const NotificationPriorityCatalog({
    required this.ownerScopeId,
    required this.catalogId,
    required this.catalogRevision,
    required this.levels,
  });
}

/// 等级映射。
final class LevelMapping {
  final String mappingId;
  final String ownerScopeId;
  final int revision;
  final SourceSeverityRef? sourceSeverityRef;
  final UserImportanceRef? userImportanceRef;
  final NotificationPriorityRef? notificationPriorityRef;

  const LevelMapping({
    required this.mappingId,
    required this.ownerScopeId,
    required this.revision,
    required this.sourceSeverityRef,
    required this.userImportanceRef,
    required this.notificationPriorityRef,
  });
}

/// 用户批注。
final class UserAnnotation {
  final String annotationId;
  final String ownerScopeId;
  final List<SourceRef> targetSourceRefs;
  final List<String> directionIds;
  final String? title;
  final String? interpretation;
  final UserImportanceRef? userImportanceRef;
  final List<String> tags;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserAnnotation({
    required this.annotationId,
    required this.ownerScopeId,
    required this.targetSourceRefs,
    required this.directionIds,
    required this.title,
    required this.interpretation,
    required this.userImportanceRef,
    required this.tags,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// 已保存事件选择。
final class SavedOccurrenceSelection {
  final String selectionId;
  final String ownerScopeId;
  final int revision;
  final SourceRef sourceRef;
  final String eventRevision;
  final String? annotationRef;

  const SavedOccurrenceSelection({
    required this.selectionId,
    required this.ownerScopeId,
    required this.revision,
    required this.sourceRef,
    required this.eventRevision,
    required this.annotationRef,
  });
}

/// 已保存模式规则。
final class SavedPatternRule {
  final String savedPatternId;
  final String ownerScopeId;
  final int revision;
  final String providerId;
  final String eventTypeId;
  final String patternSchemaVersion;
  final String providerDescriptorVersion;
  final String matcherSemanticVersion;
  final List<FilterExpression> normalizedPattern;
  final String patternFingerprint;
  final List<String> targetSubjectIds;
  final List<String> targetProfileIds;
  final String? annotationRef;
  final bool enabledForMatching;

  const SavedPatternRule({
    required this.savedPatternId,
    required this.ownerScopeId,
    required this.revision,
    required this.providerId,
    required this.eventTypeId,
    required this.patternSchemaVersion,
    required this.providerDescriptorVersion,
    required this.matcherSemanticVersion,
    required this.normalizedPattern,
    required this.patternFingerprint,
    required this.targetSubjectIds,
    required this.targetProfileIds,
    required this.annotationRef,
    required this.enabledForMatching,
  });
}

/// 个人规则模板。
final class PersonalRuleTemplate {
  final String templateId;
  final String ownerScopeId;
  final List<FilterExpression> providerPattern;
  final List<String> defaultDirectionIds;
  final UserImportanceRef? defaultUserImportanceRef;
  final NotificationPriorityRef? defaultNotificationPriorityRef;
  final List<String> defaultChannelIds;
  final List<Duration> defaultLeadTimes;
  final int revision;

  const PersonalRuleTemplate({
    required this.templateId,
    required this.ownerScopeId,
    required this.providerPattern,
    required this.defaultDirectionIds,
    required this.defaultUserImportanceRef,
    required this.defaultNotificationPriorityRef,
    required this.defaultChannelIds,
    required this.defaultLeadTimes,
    required this.revision,
  });
}

/// 提醒选择引用基类。
sealed class ReminderSelectionRef {
  const ReminderSelectionRef();
}

final class OccurrenceSelectionRef extends ReminderSelectionRef {
  final String selectionId;
  final int revision;

  const OccurrenceSelectionRef({required this.selectionId, required this.revision});
}

final class PatternRuleRef extends ReminderSelectionRef {
  final String savedPatternId;
  final int revision;

  const PatternRuleRef({required this.savedPatternId, required this.revision});
}

/// 提醒定义。
final class ReminderDefinition {
  final String reminderId;
  final String ownerScopeId;
  final ReminderSelectionRef selectionRef;
  final String? notificationTitleOverride;
  final String? notificationBodyOverride;
  final NotificationPriorityRef notificationPriorityRef;
  final List<String> channelIds;
  final List<Duration> leadTimes;
  final String? repeatPolicy;
  final String mergePolicy;
  final bool enabled;
  final int revision;

  const ReminderDefinition({
    required this.reminderId,
    required this.ownerScopeId,
    required this.selectionRef,
    required this.notificationTitleOverride,
    required this.notificationBodyOverride,
    required this.notificationPriorityRef,
    required this.channelIds,
    required this.leadTimes,
    required this.repeatPolicy,
    required this.mergePolicy,
    required this.enabled,
    required this.revision,
  });
}

/// 提醒占卜选择器。
final class ReminderDivinationSelector {
  final String? providerId;
  final String? divinationTypeKey;
  final String? subDivinationTypeKey;

  const ReminderDivinationSelector({
    required this.providerId,
    required this.divinationTypeKey,
    required this.subDivinationTypeKey,
  });
}

/// 提醒通道选择器。
final class ReminderChannelSelectors {
  final List<String> subjectIds;
  final List<String> profileIds;
  final List<ReminderDivinationSelector> divinationSelectors;
  final List<String> eventTypeIds;
  final List<String> directionIds;
  final List<SourceSeverityRef> sourceSeverityRefs;
  final List<UserImportanceRef> userImportanceRefs;
  final List<NotificationPriorityRef> notificationPriorityRefs;

  const ReminderChannelSelectors({
    required this.subjectIds,
    required this.profileIds,
    required this.divinationSelectors,
    required this.eventTypeIds,
    required this.directionIds,
    required this.sourceSeverityRefs,
    required this.userImportanceRefs,
    required this.notificationPriorityRefs,
  });
}

/// 投递模式。
enum DeliveryMode { immediate, scheduledDigest }

/// 分组模式。
enum GroupingMode { each, bySubject, byDirection }

/// 提醒投递策略。
final class ReminderDeliveryPolicy {
  final List<Duration> leadTimes;
  final String? quietHours;
  final Duration mergeWindow;
  final DeliveryMode deliveryMode;
  final GroupingMode groupingMode;

  const ReminderDeliveryPolicy({
    required this.leadTimes,
    required this.quietHours,
    required this.mergeWindow,
    required this.deliveryMode,
    required this.groupingMode,
  });
}

/// 提醒通道。
final class ReminderChannel {
  final String channelId;
  final String ownerScopeId;
  final String name;
  final bool enabled;
  final ReminderChannelSelectors selectors;
  final ReminderDeliveryPolicy deliveryPolicy;
  final int revision;

  const ReminderChannel({
    required this.channelId,
    required this.ownerScopeId,
    required this.name,
    required this.enabled,
    required this.selectors,
    required this.deliveryPolicy,
    required this.revision,
  });
}

/// 聚合提醒贡献者（不压平）。
final class AggregateReminderContributor {
  final String providerId;
  final String divinationTypeKey;
  final String? subDivinationTypeKey;
  final String profileId;
  final String chartSnapshotId;
  final String sourceEventId;
  final String eventRevision;
  final String eventTypeId;
  final String factSummary;
  final String evidenceRef;
  final SourceSeverityRef? sourceSeverityRef;
  final SourceVersions sourceVersions;
  final String? annotationRef;
  final List<String> directionIds;
  final UserImportanceRef? userImportanceRef;
  final String reminderId;

  const AggregateReminderContributor({
    required this.providerId,
    required this.divinationTypeKey,
    required this.subDivinationTypeKey,
    required this.profileId,
    required this.chartSnapshotId,
    required this.sourceEventId,
    required this.eventRevision,
    required this.eventTypeId,
    required this.factSummary,
    required this.evidenceRef,
    required this.sourceSeverityRef,
    required this.sourceVersions,
    required this.annotationRef,
    required this.directionIds,
    required this.userImportanceRef,
    required this.reminderId,
  });
}

/// 聚合提醒。
final class AggregateReminder {
  final String aggregateId;
  final String ownerScopeId;
  final String subjectId;
  final TimeRange displayTimeWindow;
  final List<String> directionIds;
  final NotificationPriorityRef effectiveNotificationPriorityRef;
  final String displayTitle;
  final String? userInterpretation;
  final List<AggregateReminderContributor> contributors;

  const AggregateReminder({
    required this.aggregateId,
    required this.ownerScopeId,
    required this.subjectId,
    required this.displayTimeWindow,
    required this.directionIds,
    required this.effectiveNotificationPriorityRef,
    required this.displayTitle,
    required this.userInterpretation,
    required this.contributors,
  });
}

/// 保存提醒结果。
enum SaveReminderOutcome { saved, revisionConflict, ownerScopeMismatch, danglingSelectionRef, invalidScheduleTarget }

/// 调度状态。
enum ScheduleStatus { scheduled, claimed, delivered, cancelled, failed }

/// 已调度通知。
final class ScheduledNotification {
  final String scheduleId;
  final String ownerScopeId;
  final String? reminderId;
  final String? aggregateId;
  final DateTime fireAtUtc;
  final String displayTimezoneId;
  final int channelRevision;
  final String sourceRevisionFingerprint;
  final ScheduleStatus status;
  final String? claimToken;
  final DateTime? leaseExpiresAtUtc;

  const ScheduledNotification({
    required this.scheduleId,
    required this.ownerScopeId,
    required this.reminderId,
    required this.aggregateId,
    required this.fireAtUtc,
    required this.displayTimezoneId,
    required this.channelRevision,
    required this.sourceRevisionFingerprint,
    required this.status,
    required this.claimToken,
    required this.leaseExpiresAtUtc,
  });

  /// Design §14.4：reminderId 与 aggregateId 必须恰好一个非空。
  /// 同时为空或同时非空返回 [SaveReminderOutcome.invalidScheduleTarget]。
  SaveReminderOutcome? validateTarget() {
    final bothNull = reminderId == null && aggregateId == null;
    final bothSet = reminderId != null && aggregateId != null;
    if (bothNull || bothSet) {
      return SaveReminderOutcome.invalidScheduleTarget;
    }
    return null;
  }
}

/// 投递记录。
final class DeliveryRecord {
  final String deliveryId;
  final String scheduleId;
  final DateTime attemptedAt;
  final String outcome;
  final String? stableErrorCode;

  const DeliveryRecord({
    required this.deliveryId,
    required this.scheduleId,
    required this.attemptedAt,
    required this.outcome,
    required this.stableErrorCode,
  });
}

/// 外部事件来源类型。
enum ExternalOriginType { destinyQuestion, divinationCase }

/// 外部日历事件。
final class ExternalCalendarEvent {
  final String ownerScopeId;
  final String externalEventId;
  final String revision;
  final ExternalOriginType originType;
  final String originId;
  final List<String> relatedSubjectIds;
  final List<String> usedProfileRefs;
  final String divinationTypeKey;
  final String? subDivinationTypeKey;
  final LifeEventTime eventTime;
  final String factSummary;
  final String? evidenceRef;
  final String lifecycleStatus;

  const ExternalCalendarEvent({
    required this.ownerScopeId,
    required this.externalEventId,
    required this.revision,
    required this.originType,
    required this.originId,
    required this.relatedSubjectIds,
    required this.usedProfileRefs,
    required this.divinationTypeKey,
    required this.subDivinationTypeKey,
    required this.eventTime,
    required this.factSummary,
    required this.evidenceRef,
    required this.lifecycleStatus,
  });
}