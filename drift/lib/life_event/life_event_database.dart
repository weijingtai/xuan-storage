// ACT-06：Life Event Center Drift 数据库。
//
// 独立小数据库，不混入 PersistenceDriftDatabase 的 schema version 链；
// 生命周期由调用方管理（测试用临时文件，生产由 Shell 装配）。
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'external_calendar_event_table.dart';
import 'life_event_migrations.dart';
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
    LifeEventExternalEvents,
    LifeEventExternalEventSubjects,
  ],
)
class LifeEventDatabase extends _$LifeEventDatabase {
  LifeEventDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => createLifeEventMigrationStrategy(this);

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
}