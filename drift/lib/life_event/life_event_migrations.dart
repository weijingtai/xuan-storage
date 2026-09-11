// ACT-15A：Life Event Center 物理 Schema 迁移策略与表存在性检查（Design §17.5）。
//
// 冻结 SchemaVersion=1，建立 stepwise 迁移骨架；
// beforeOpen 只读查询 sqlite_master 检查必需表集合，
// 缺表时抛带稳定错误码 schemaMismatch 的异常，严格零写入。
library;

import 'package:drift/drift.dart';

/// 稳定错误码常量：当库文件缺失必需表集合时抛出。
const String kLifeEventSchemaMismatchErrorCode = 'schemaMismatch';

/// LifeEventDatabase 必需的 28 张物理表集合（ACT-06 9 张、ACT-10 8 张、ACT-12 9 张、ACT-15 2 张）。
const List<String> kLifeEventRequiredTables = [
  // ACT-06：核心投影与快照
  't_life_event_subjects',
  't_life_event_life_profiles',
  't_life_event_chart_snapshot_refs',
  't_life_event_provider_descriptors',
  't_life_event_event_type_descriptors',
  't_life_event_projections',
  't_life_event_coverage_series_heads',
  't_life_event_coverage_manifests',
  't_life_event_shard_receipts',
  // ACT-10：用户判断与个人规则
  't_le_user_directions',
  't_le_user_annotations',
  't_le_annotation_target_refs',
  't_le_annotation_direction_refs',
  't_le_occurrence_selections',
  't_le_pattern_rules',
  't_le_pattern_target_refs',
  't_le_rule_templates',
  // ACT-12：提醒定义、通道、聚合与调度
  't_le_reminder_definitions',
  't_le_reminder_definition_channels',
  't_le_reminder_channels',
  't_le_reminder_channel_selectors',
  't_le_reminder_aggregates',
  't_le_reminder_aggregate_directions',
  't_le_reminder_aggregate_contributors',
  't_le_reminder_schedules',
  't_le_reminder_deliveries',
  // ACT-15：外部日历事件与关联
  't_le_external_events',
  't_le_external_event_subjects',
];

/// LifeEventDatabase 必需的 10 条自定义索引（ACT-06 3 条、ACT-12 5 条、ACT-15 2 条）。
const List<String> kLifeEventExpectedIndexes = [
  // ACT-06
  'idx_le_projection_owner',
  'idx_le_projection_type',
  'uq_le_receipt',
  // ACT-12
  'idx_le_reminder_schedule_due',
  'idx_le_reminder_delivery_schedule',
  'idx_le_reminder_definition_owner',
  'idx_le_reminder_channel_owner',
  'idx_le_reminder_aggregate_owner',
  // ACT-15
  'idx_le_external_event_query',
  'idx_le_external_event_subject',
];

/// Schema 错配异常：当打开的 SQLite 数据库缺少必需表时抛出。
class LifeEventSchemaMismatchException implements Exception {
  static const String codeConstant = kLifeEventSchemaMismatchErrorCode;

  final String code;
  final String message;
  final List<String> missingTables;

  const LifeEventSchemaMismatchException({
    required this.message,
    this.missingTables = const [],
    this.code = codeConstant,
  });

  @override
  String toString() =>
      'LifeEventSchemaMismatchException(code: $code, message: $message, missingTables: $missingTables)';
}

/// 单步迁移函数签名。
typedef LifeEventMigrationStep = Future<void> Function(Migrator m);

/// 默认 stepwise 迁移步骤注册表。
///
/// 当前 schemaVersion=1，未来版本升级在此按步追加（例如 1 -> 2）。
final Map<int, LifeEventMigrationStep> lifeEventMigrationSteps = {};

/// Stepwise 迁移函数：经 [Migrator] 按照 `from -> to` 逐级执行迁移。
///
/// 当 from == to 时为无操作（例如 v1 -> v1）；
/// 当 from < to 时逐版本查找迁移回调；缺失某步跃迁时抛出 [StateError]。
Future<void> lifeEventStepwiseMigration(
  Migrator m,
  int from,
  int to, {
  Map<int, LifeEventMigrationStep>? steps,
}) async {
  if (from >= to) return;
  final registry = steps ?? lifeEventMigrationSteps;
  for (var current = from; current < to; current++) {
    final step = registry[current];
    if (step == null) {
      throw StateError(
        'Missing stepwise migration step from schema version $current to ${current + 1} '
        '(target version: $to). Design §17.5 requires every bump to provide stepwise migration.',
      );
    }
    await step(m);
  }
}

/// 只读检查当前打开的数据库是否包含所有必需表。
///
/// 仅做 `sqlite_master` 只读 SELECT，发现缺表时立即抛出 [LifeEventSchemaMismatchException]，
/// 保证零写入。
Future<void> validateLifeEventSchema(
  GeneratedDatabase db,
  OpeningDetails details,
) async {
  final rows = await db.customSelect(
    "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%';",
  ).get();
  final existingTables = rows.map((r) => r.read<String>('name')).toSet();
  final expectedTables = db.allTables.isNotEmpty
      ? db.allTables.map((t) => t.actualTableName).toList()
      : kLifeEventRequiredTables;
  final missingTables =
      expectedTables.where((t) => !existingTables.contains(t)).toList();
  if (missingTables.isNotEmpty) {
    throw LifeEventSchemaMismatchException(
      message:
          'Database schema mismatch: missing required tables [${missingTables.join(', ')}]. '
          'Development databases created prior to schema freeze must be deleted and recreated (Design §17.5).',
      missingTables: missingTables,
    );
  }
}

/// 创建 LifeEventDatabase 所需的全部自定义索引。
Future<void> createLifeEventIndexes(GeneratedDatabase db) async {
  // 复合查询索引：(owner, profile, provider, snapshot, start, rank, projectionId)
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_le_projection_owner '
    'ON t_life_event_projections '
    '(owner_scope_id, profile_id, source_provider_id, chart_snapshot_id, '
    'effective_start_ms, precision_rank, projection_id)',
  );
  // 复合查询索引：(owner, profile, eventType, start, rank, projectionId)
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_le_projection_type '
    'ON t_life_event_projections '
    '(owner_scope_id, profile_id, event_type_id, '
    'effective_start_ms, precision_rank, projection_id)',
  );
  // receipt 唯一约束（DB 层兜底并发）。
  await db.customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS uq_le_receipt '
    'ON t_life_event_shard_receipts (coverage_id, shard_id)',
  );
  // ACT-12：租约领取热路径 (owner, status, fireAt)。
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_le_reminder_schedule_due '
    'ON t_le_reminder_schedules (owner_scope_id, status, fire_at_ms)',
  );
  // ACT-12：scheduleId 投递去重查询。
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_le_reminder_delivery_schedule '
    'ON t_le_reminder_deliveries (schedule_id)',
  );
  // ACT-12：owner 分区读取（LEC-039 强制 ownerScope 谓词）。
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_le_reminder_definition_owner '
    'ON t_le_reminder_definitions (owner_scope_id)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_le_reminder_channel_owner '
    'ON t_le_reminder_channels (owner_scope_id)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_le_reminder_aggregate_owner '
    'ON t_le_reminder_aggregates (owner_scope_id)',
  );
  // ACT-15：外部事件查询索引
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_le_external_event_query '
    'ON t_le_external_events (owner_scope_id, is_latest, event_start_ms, external_event_id)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_le_external_event_subject '
    'ON t_le_external_event_subjects (owner_scope_id, subject_id)',
  );
}

/// 构造 LifeEventDatabase 的完整 MigrationStrategy。
MigrationStrategy createLifeEventMigrationStrategy(GeneratedDatabase db) {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await createLifeEventIndexes(db);
    },
    onUpgrade: (m, from, to) async {
      await lifeEventStepwiseMigration(m, from, to);
    },
    beforeOpen: (details) async {
      // 表存在性只读检查先于任何写操作
      await validateLifeEventSchema(db, details);
      // ACT-12：多个调度器实例会用各自的连接打开同一个库文件做租约领取。
      // WAL 让读不阻塞写。
      await db.customStatement('PRAGMA journal_mode = WAL');
    },
  );
}
