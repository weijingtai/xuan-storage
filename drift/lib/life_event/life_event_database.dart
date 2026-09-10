// ACT-06：Life Event Center Drift 数据库。
//
// 独立小数据库，不混入 PersistenceDriftDatabase 的 schema version 链；
// 生命周期由调用方管理（测试用临时文件，生产由 Shell 装配）。
library;

import 'package:drift/drift.dart';

import 'life_event_tables.dart';
import 'life_event_user_rule_tables.dart';

part 'life_event_database.g.dart';

/// Life Event Center 数据库（@DriftDatabase 注解集合）。
@DriftDatabase(
  tables: [
    LifeEventSubjects,
    LifeEventLifeProfiles,
    LifeEventChartSnapshotRefs,
    LifeEventProviderDescriptors,
    LifeEventEventTypeDescriptors,
    LifeEventProjections,
    LifeEventCoverageSeriesHeads,
    LifeEventCoverageManifests,
    LifeEventShardReceipts,
    LifeEventUserDirections,
    LifeEventUserAnnotations,
    LifeEventAnnotationTargetRefs,
    LifeEventAnnotationDirectionRefs,
    LifeEventOccurrenceSelections,
    LifeEventPatternRules,
    LifeEventPatternTargetRefs,
    LifeEventRuleTemplates,
  ],
)
class LifeEventDatabase extends _$LifeEventDatabase {
  LifeEventDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
        },
      );

  Future<void> _createIndexes() async {
    // 复合查询索引：(owner, profile, provider, snapshot, start, rank, projectionId)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_le_projection_owner '
      'ON t_life_event_projections '
      '(owner_scope_id, profile_id, source_provider_id, chart_snapshot_id, '
      'effective_start_ms, precision_rank, projection_id)',
    );
    // 复合查询索引：(owner, profile, eventType, start, rank, projectionId)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_le_projection_type '
      'ON t_life_event_projections '
      '(owner_scope_id, profile_id, event_type_id, '
      'effective_start_ms, precision_rank, projection_id)',
    );
    // receipt 唯一约束（DB 层兜底并发）。
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS uq_le_receipt '
      'ON t_life_event_shard_receipts (coverage_id, shard_id)',
    );
  }
}