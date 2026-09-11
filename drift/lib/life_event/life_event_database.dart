// ACT-06：Life Event Center Drift 数据库。
//
// 独立小数据库，不混入 PersistenceDriftDatabase 的 schema version 链；
// 生命周期由调用方管理（测试用临时文件，生产由 Shell 装配）。
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'life_event_reminder_tables.dart';
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
    LifeEventReminderDefinitions,
    LifeEventReminderDefinitionChannels,
    LifeEventReminderChannels,
    LifeEventReminderChannelSelectors,
    LifeEventReminderAggregates,
    LifeEventReminderAggregateDirections,
    LifeEventReminderAggregateContributors,
    LifeEventReminderSchedules,
    LifeEventReminderDeliveries,
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
        beforeOpen: (details) async {
          // ACT-12：多个调度器实例会用各自的连接打开同一个库文件做租约领取。
          // WAL 让读不阻塞写；busy_timeout 让写锁竞争等待而不是立刻失败。
          //
          // 返工 F1：这里设置 busy_timeout 对"开库竞争"太晚——drift 打开库
          // 文件时会先读 `PRAGMA user_version` 探测 schema 版本，这一步发生
          // 在 beforeOpen 回调执行之前；多个连接冷启动同时打开同一文件会在
          // 这一步竞争，直接抛 SQLITE_BUSY_RECOVERY(261)，此时 beforeOpen
          // 还没机会设置 busy_timeout。**调用方（生产装配 / 测试）必须经
          // [LifeEventDatabase.openNativeFile] 打开基于文件的数据库，或在
          // 自建的 `NativeDatabase(setup:)` 里提前设置 busy_timeout**，
          // 不能只依赖这里的 beforeOpen。
          //
          // 仍可能出现 BUSY/snapshot，由 DriftLifeEventReminderStore.claimDue
          // 的事务级重试兜底（独占性由条件更新 CAS 保证，重试不会重复领取）。
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA busy_timeout = 5000');
        },
      );

  /// 返工 F1：受支持的连接工厂，打开一个基于文件的 SQLite 数据库。
  ///
  /// 装配方（生产 Shell / 测试）必须经此工厂打开文件型数据库，而不是自行
  /// 直接调用 `NativeDatabase.createInBackground`：busy_timeout 必须在连接
  /// 的 `setup:` 回调里、开库最早期就设好，`beforeOpen` 对开库竞争太晚
  /// （见上方 beforeOpen 注释）。多个调度器实例各自打开同一个库文件做租约
  /// 领取（Design §14.4）时，这一点是并发安全的前提。
  static QueryExecutor openNativeFile(
    File file, {
    Duration busyTimeout = const Duration(seconds: 5),
  }) {
    return NativeDatabase.createInBackground(
      file,
      setup: (raw) =>
          raw.execute('PRAGMA busy_timeout = ${busyTimeout.inMilliseconds};'),
    );
  }

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
    // ACT-12：租约领取热路径 (owner, status, fireAt)。
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_le_reminder_schedule_due '
      'ON t_le_reminder_schedules (owner_scope_id, status, fire_at_ms)',
    );
    // ACT-12：scheduleId 投递去重查询。
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_le_reminder_delivery_schedule '
      'ON t_le_reminder_deliveries (schedule_id)',
    );
    // ACT-12：owner 分区读取（LEC-039 强制 ownerScope 谓词）。
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_le_reminder_definition_owner '
      'ON t_le_reminder_definitions (owner_scope_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_le_reminder_channel_owner '
      'ON t_le_reminder_channels (owner_scope_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_le_reminder_aggregate_owner '
      'ON t_le_reminder_aggregates (owner_scope_id)',
    );
  }
}