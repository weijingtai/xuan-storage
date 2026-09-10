// ACT-06：Life Event Center Drift 表定义。
//
// 独立于 PersistenceDriftDatabase 的 schema 版本链；只建本模块所需表，
// 不改写无关 schema。表名以 t_life_event_ 为前缀。
library;

import 'package:drift/drift.dart';

/// 命主表。
@DataClassName('LifeEventSubjectRow')
class LifeEventSubjects extends Table {
  TextColumn get subjectId => text().named('subject_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get displayLabel => text().named('display_label').nullable()();

  @override
  Set<Column> get primaryKey => {subjectId};

  @override
  String? get tableName => 't_life_event_subjects';
}

/// 命理档案表。
@DataClassName('LifeEventLifeProfileRow')
class LifeEventLifeProfiles extends Table {
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get subjectId => text().named('subject_id')();
  TextColumn get displayLabel => text().named('display_label').nullable()();
  IntColumn get revision => integer().named('revision')();

  @override
  Set<Column> get primaryKey => {profileId};

  @override
  String? get tableName => 't_life_event_life_profiles';
}

/// 排盘快照引用表。
@DataClassName('LifeEventChartSnapshotRow')
class LifeEventChartSnapshotRefs extends Table {
  TextColumn get chartSnapshotId => text().named('chart_snapshot_id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get providerId => text().named('provider_id')();
  TextColumn get divinationTypeKey => text().named('divination_type_key')();
  TextColumn get subDivinationTypeKey =>
      text().named('sub_divination_type_key').nullable()();
  TextColumn get snapshotRevision => text().named('snapshot_revision')();
  TextColumn get algorithmVersion => text().named('algorithm_version')();
  TextColumn get inputFingerprint => text().named('input_fingerprint')();
  IntColumn get createdAtMs => integer().named('created_at_ms')();

  @override
  Set<Column> get primaryKey => {chartSnapshotId};

  @override
  String? get tableName => 't_life_event_chart_snapshot_refs';
}

/// Provider descriptor 缓存表。
@DataClassName('LifeEventProviderDescriptorRow')
class LifeEventProviderDescriptors extends Table {
  TextColumn get providerId => text().named('provider_id')();
  TextColumn get providerVersion => text().named('provider_version')();
  TextColumn get algorithmVersion => text().named('algorithm_version')();
  TextColumn get dataVersion => text().named('data_version').nullable()();
  TextColumn get schemaVersion => text().named('schema_version')();
  TextColumn get descriptorJson => text().named('descriptor_json')();
  IntColumn get createdAtMs => integer().named('created_at_ms')();

  @override
  Set<Column> get primaryKey => {providerId};

  @override
  String? get tableName => 't_life_event_provider_descriptors';
}

/// EventType descriptor 缓存表。
@DataClassName('LifeEventEventTypeDescriptorRow')
class LifeEventEventTypeDescriptors extends Table {
  TextColumn get providerId => text().named('provider_id')();
  TextColumn get eventTypeId => text().named('event_type_id')();
  TextColumn get schemaVersion => text().named('schema_version')();
  TextColumn get descriptorJson => text().named('descriptor_json')();

  @override
  Set<Column> get primaryKey => {providerId, eventTypeId};

  @override
  String? get tableName => 't_life_event_event_type_descriptors';
}

/// 事件投影表。
@DataClassName('LifeEventProjectionRow')
class LifeEventProjections extends Table {
  TextColumn get projectionId => text().named('projection_id')();
  TextColumn get coverageId => text().named('coverage_id')();
  IntColumn get coverageGeneration => integer().named('coverage_generation')();
  TextColumn get sourceProviderId => text().named('source_provider_id')();
  TextColumn get sourceEventId => text().named('source_event_id')();
  TextColumn get eventRevision => text().named('event_revision')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get subjectId => text().named('subject_id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get chartSnapshotId => text().named('chart_snapshot_id')();
  TextColumn get divinationTypeKey => text().named('divination_type_key')();
  TextColumn get subDivinationTypeKey =>
      text().named('sub_divination_type_key').nullable()();
  TextColumn get eventTypeId => text().named('event_type_id')();
  IntColumn get effectiveStartMs => integer().named('effective_start_ms')();
  IntColumn get precisionRank => integer().named('precision_rank')();
  TextColumn get projectionJson => text().named('projection_json')();
  IntColumn get lifecycleStatus => integer().named('lifecycle_status')();

  @override
  Set<Column> get primaryKey => {projectionId};

  @override
  String? get tableName => 't_life_event_projections';
}

/// 覆盖系列头表。
@DataClassName('LifeEventCoverageSeriesHeadRow')
class LifeEventCoverageSeriesHeads extends Table {
  TextColumn get coverageSeriesId => text().named('coverage_series_id')();
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get chartSnapshotId => text().named('chart_snapshot_id')();
  TextColumn get providerId => text().named('provider_id')();
  TextColumn get eventTypeId => text().named('event_type_id')();
  IntColumn get seriesRevision => integer().named('series_revision')();
  TextColumn get activeCoverageId =>
      text().named('active_coverage_id').nullable()();
  TextColumn get candidateCoverageId =>
      text().named('candidate_coverage_id').nullable()();
  IntColumn get desiredRangeStartMs => integer().named('desired_range_start_ms')();
  IntColumn get desiredRangeEndMs => integer().named('desired_range_end_ms')();

  @override
  Set<Column> get primaryKey => {coverageSeriesId};

  @override
  String? get tableName => 't_life_event_coverage_series_heads';
}

/// 覆盖清单表。
@DataClassName('LifeEventCoverageManifestRow')
class LifeEventCoverageManifests extends Table {
  TextColumn get coverageId => text().named('coverage_id')();
  TextColumn get coverageSeriesId => text().named('coverage_series_id')();
  IntColumn get coverageGeneration => integer().named('coverage_generation')();
  IntColumn get manifestRevision => integer().named('manifest_revision')();
  IntColumn get servingState => integer().named('serving_state')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get chartSnapshotId => text().named('chart_snapshot_id')();
  TextColumn get chartSnapshotRevision =>
      text().named('chart_snapshot_revision')();
  TextColumn get providerId => text().named('provider_id')();
  TextColumn get providerVersion => text().named('provider_version')();
  TextColumn get algorithmVersion => text().named('algorithm_version')();
  TextColumn get dataVersion => text().named('data_version').nullable()();
  TextColumn get eventTypeId => text().named('event_type_id')();
  TextColumn get eventTypeSchemaVersion =>
      text().named('event_type_schema_version')();
  IntColumn get requestedRangeStartMs =>
      integer().named('requested_range_start_ms')();
  IntColumn get requestedRangeEndMs => integer().named('requested_range_end_ms')();
  TextColumn get coveredRangesJson => text().named('covered_ranges_json')();
  IntColumn get status => integer().named('status')();
  TextColumn get inputFingerprint => text().named('input_fingerprint')();
  IntColumn get expectedShardCount => integer().named('expected_shard_count')();
  IntColumn get completedShardCount => integer().named('completed_shard_count')();
  IntColumn get sourceEventCount => integer().named('source_event_count')();
  TextColumn get outputDigest => text().named('output_digest')();
  IntColumn get startedAtMs => integer().named('started_at_ms')();
  IntColumn get completedAtMs => integer().named('completed_at_ms').nullable()();
  TextColumn get lastErrorCode => text().named('last_error_code').nullable()();

  @override
  Set<Column> get primaryKey => {coverageId};

  @override
  String? get tableName => 't_life_event_coverage_manifests';
}

/// 分片 receipt 表。
@DataClassName('LifeEventShardReceiptRow')
class LifeEventShardReceipts extends Table {
  TextColumn get coverageId => text().named('coverage_id')();
  TextColumn get shardId => text().named('shard_id')();
  IntColumn get coverageGeneration => integer().named('coverage_generation')();
  IntColumn get requestedRangeStartMs => integer().named('requested_range_start_ms')();
  IntColumn get requestedRangeEndMs => integer().named('requested_range_end_ms')();
  IntColumn get coveredRangeStartMs => integer().named('covered_range_start_ms')();
  IntColumn get coveredRangeEndMs => integer().named('covered_range_end_ms')();
  IntColumn get eventCount => integer().named('event_count')();
  TextColumn get contentDigest => text().named('content_digest')();
  IntColumn get persistedCount => integer().named('persisted_count')();
  TextColumn get persistedDigest => text().named('persisted_digest')();
  BoolColumn get isCompleteForCoveredRange =>
      boolean().named('is_complete_for_covered_range')();
  TextColumn get inputFingerprint => text().named('input_fingerprint')();
  IntColumn get committedAtMs => integer().named('committed_at_ms')();

  @override
  Set<Column> get primaryKey => {coverageId, shardId};

  @override
  String? get tableName => 't_life_event_shard_receipts';
}