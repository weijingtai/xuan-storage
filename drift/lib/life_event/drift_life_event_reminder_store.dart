// ACT-12：提醒、调度与投递记录 Drift 持久化适配器。
//
// 实现冻结端口 LifeEventReminderStore 的六个方法（definition / channel /
// aggregate / schedule / delivery / 租约领取），另加适配器自有的 typed 读方法
// loadOwnerState，供 ACT-16 装配时构造 calendar 的 ReminderCoordinatorSnapshot
// 并 hydrate（persistence_drift 不得依赖 calendar，依赖方向红线）。
//
// 纪律：
// - 每一次端口调用是一个覆盖其全部行（主行 + 子行）的事务，任何校验失败整体
//   回滚，零写入；
// - 所有读写都带 ownerScope 谓词（LEC-039），recipient 恒为 ownerScope，
//   不退化为 subjectId；
// - 引用完整性在同一事务内校验，失败抛 DriftReminderStoreRejected；
// - 租约领取用条件更新（CAS）保证同一条 schedule 在租约有效期内只属于一个
//   claimToken；nowUtc 由调用方注入，实现不读系统时钟；
// - 不调用任何平台 Notification 插件，也不解释用户规则。
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';

import 'life_event_database.dart';

/// 提醒写入被拒绝（零写入，事务已回滚）。
final class DriftReminderStoreRejected implements Exception {
  /// 稳定失败语义，只取 [SaveReminderOutcome.saved] 之外的四个值。
  final SaveReminderOutcome outcome;

  /// 被拒对象的 id。
  final String id;

  /// 人类可读原因（不进入稳定契约）。
  final String message;

  const DriftReminderStoreRejected({
    required this.outcome,
    required this.id,
    required this.message,
  });

  @override
  String toString() =>
      'DriftReminderStoreRejected(${outcome.name}, $id): $message';
}

/// 一个 ownerScope 下提醒中心的全部持久化状态。
///
/// 字段与 calendar 的 `ReminderCoordinatorSnapshot` 一一对应；ACT-16 装配时据此
/// 构造 Snapshot 后调用 `ReminderCoordinator.hydrate`，reopen 走 coordinator 的
/// 真实恢复入口而不是直查表。
final class ReminderOwnerState {
  final List<ReminderDefinition> definitions;
  final List<ReminderChannel> channels;
  final List<AggregateReminder> aggregates;
  final List<ScheduledNotification> schedules;

  /// 该 owner 的 schedule 中存在 `DeliveryRecord.outcome == 'delivered'` 的
  /// scheduleId，去重后升序；投递去重键是 scheduleId 而不是 claimToken。
  final List<String> deliveredScheduleIds;

  const ReminderOwnerState({
    required this.definitions,
    required this.channels,
    required this.aggregates,
    required this.schedules,
    required this.deliveredScheduleIds,
  });
}

// 通道选择器 kind 标签（与 life_event_reminder_tables.dart 的列语义表对应）。
const String _kSubject = 'subject';
const String _kProfile = 'profile';
const String _kDivination = 'divination';
const String _kEventType = 'eventType';
const String _kDirection = 'direction';
const String _kSourceSeverity = 'sourceSeverity';
const String _kUserImportance = 'userImportance';
const String _kNotificationPriority = 'notificationPriority';

// ReminderSelectionRef 的 JSON kind 标签。
const String _kOccurrenceSelectionRef = 'occurrenceSelection';
const String _kPatternRuleRef = 'patternRule';

/// 投递成功的稳定 outcome 文本（Design §14.4 去重键语义）。
const String _deliveredOutcome = 'delivered';

/// 并发领取遇到 SQLite 锁竞争时的重试上限。
const int _claimMaxAttempts = 8;

/// Drift 提醒存储实现。
final class DriftLifeEventReminderStore implements LifeEventReminderStore {
  final LifeEventDatabase _db;

  DriftLifeEventReminderStore(this._db);

  // =====================================================================
  // ReminderDefinition
  // =====================================================================

  @override
  Future<String> saveDefinition(ReminderDefinition value, int expectedRevision) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.lifeEventReminderDefinitions)
            ..where((t) => t.reminderId.equals(value.reminderId)))
          .getSingleOrNull();
      _guardRevision(
        id: value.reminderId,
        storedOwnerScopeId: existing?.ownerScopeId,
        storedRevision: existing?.revision,
        valueOwnerScopeId: value.ownerScopeId,
        valueRevision: value.revision,
        expectedRevision: expectedRevision,
      );

      // 主行先落库，再校验并重写子行：任何一步失败都靠事务回滚主行，
      // 使"失败零写入"是真回滚而不是前置拦截。
      await _db.into(_db.lifeEventReminderDefinitions).insertOnConflictUpdate(
            LifeEventReminderDefinitionRow(
              reminderId: value.reminderId,
              ownerScopeId: value.ownerScopeId,
              selectionRefJson: jsonEncode(_selectionRefToJson(value.selectionRef)),
              notificationTitleOverride: value.notificationTitleOverride,
              notificationBodyOverride: value.notificationBodyOverride,
              priorityOwnerScopeId: value.notificationPriorityRef.ownerScopeId,
              priorityCatalogId: value.notificationPriorityRef.catalogId,
              priorityCatalogRevision:
                  value.notificationPriorityRef.catalogRevision,
              priorityId: value.notificationPriorityRef.priorityId,
              leadTimesMsJson: jsonEncode(
                [for (final d in value.leadTimes) d.inMilliseconds],
              ),
              repeatPolicy: value.repeatPolicy,
              mergePolicy: value.mergePolicy,
              enabled: value.enabled,
              revision: value.revision,
            ),
          );

      await (_db.delete(_db.lifeEventReminderDefinitionChannels)
            ..where((t) => t.reminderId.equals(value.reminderId)))
          .go();
      for (var i = 0; i < value.channelIds.length; i++) {
        final channelId = value.channelIds[i];
        final channel = await (_db.select(_db.lifeEventReminderChannels)
              ..where((t) => t.channelId.equals(channelId)))
            .getSingleOrNull();
        if (channel == null || channel.ownerScopeId != value.ownerScopeId) {
          throw DriftReminderStoreRejected(
            outcome: SaveReminderOutcome.ownerScopeMismatch,
            id: value.reminderId,
            message:
                'channelId $channelId 不存在或不属于 ownerScope ${value.ownerScopeId}',
          );
        }
        await _db.into(_db.lifeEventReminderDefinitionChannels).insert(
              LifeEventReminderDefinitionChannelRow(
                reminderId: value.reminderId,
                position: i,
                channelId: channelId,
              ),
            );
      }

      await _guardSelectionRef(value);
      return value.reminderId;
    });
  }

  // =====================================================================
  // ReminderChannel
  // =====================================================================

  @override
  Future<String> saveChannel(ReminderChannel value, int expectedRevision) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.lifeEventReminderChannels)
            ..where((t) => t.channelId.equals(value.channelId)))
          .getSingleOrNull();
      _guardRevision(
        id: value.channelId,
        storedOwnerScopeId: existing?.ownerScopeId,
        storedRevision: existing?.revision,
        valueOwnerScopeId: value.ownerScopeId,
        valueRevision: value.revision,
        expectedRevision: expectedRevision,
      );

      final policy = value.deliveryPolicy;
      await _db.into(_db.lifeEventReminderChannels).insertOnConflictUpdate(
            LifeEventReminderChannelRow(
              channelId: value.channelId,
              ownerScopeId: value.ownerScopeId,
              name: value.name,
              enabled: value.enabled,
              policyLeadTimesMsJson: jsonEncode(
                [for (final d in policy.leadTimes) d.inMilliseconds],
              ),
              policyQuietHours: policy.quietHours,
              policyMergeWindowMs: policy.mergeWindow.inMilliseconds,
              policyDeliveryMode: policy.deliveryMode.name,
              policyGroupingMode: policy.groupingMode.name,
              revision: value.revision,
            ),
          );

      // selectors 整体替换（先删子行再写），与主行同一事务。
      await (_db.delete(_db.lifeEventReminderChannelSelectors)
            ..where((t) => t.channelId.equals(value.channelId)))
          .go();
      await _db.batch((b) {
        b.insertAll(
          _db.lifeEventReminderChannelSelectors,
          _selectorRows(value),
        );
      });

      return value.channelId;
    });
  }

  // =====================================================================
  // AggregateReminder
  // =====================================================================

  @override
  Future<String> saveAggregate(AggregateReminder value) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.lifeEventReminderAggregates)
            ..where((t) => t.aggregateId.equals(value.aggregateId)))
          .getSingleOrNull();
      if (existing != null && existing.ownerScopeId != value.ownerScopeId) {
        throw DriftReminderStoreRejected(
          outcome: SaveReminderOutcome.ownerScopeMismatch,
          id: value.aggregateId,
          message:
              'aggregate ${value.aggregateId} 已属于 ${existing.ownerScopeId}，'
              '不得改挂到 ${value.ownerScopeId}',
        );
      }

      // 重复保存同 aggregateId 时整体替换：先删子行再写，仍在一个事务内。
      await (_db.delete(_db.lifeEventReminderAggregateDirections)
            ..where((t) => t.aggregateId.equals(value.aggregateId)))
          .go();
      await (_db.delete(_db.lifeEventReminderAggregateContributors)
            ..where((t) => t.aggregateId.equals(value.aggregateId)))
          .go();

      await _db.into(_db.lifeEventReminderAggregates).insertOnConflictUpdate(
            LifeEventReminderAggregateRow(
              aggregateId: value.aggregateId,
              ownerScopeId: value.ownerScopeId,
              subjectId: value.subjectId,
              windowStartMs:
                  value.displayTimeWindow.startInclusiveUtc.millisecondsSinceEpoch,
              windowEndMs:
                  value.displayTimeWindow.endExclusiveUtc.millisecondsSinceEpoch,
              priorityOwnerScopeId:
                  value.effectiveNotificationPriorityRef.ownerScopeId,
              priorityCatalogId: value.effectiveNotificationPriorityRef.catalogId,
              priorityCatalogRevision:
                  value.effectiveNotificationPriorityRef.catalogRevision,
              priorityId: value.effectiveNotificationPriorityRef.priorityId,
              displayTitle: value.displayTitle,
              userInterpretation: value.userInterpretation,
            ),
          );

      for (var i = 0; i < value.directionIds.length; i++) {
        await _db.into(_db.lifeEventReminderAggregateDirections).insert(
              LifeEventReminderAggregateDirectionRow(
                aggregateId: value.aggregateId,
                position: i,
                directionId: value.directionIds[i],
              ),
            );
      }

      for (var i = 0; i < value.contributors.length; i++) {
        final c = value.contributors[i];
        final definition = await (_db.select(_db.lifeEventReminderDefinitions)
              ..where((t) => t.reminderId.equals(c.reminderId)))
            .getSingleOrNull();
        if (definition == null ||
            definition.ownerScopeId != value.ownerScopeId) {
          throw DriftReminderStoreRejected(
            outcome: SaveReminderOutcome.ownerScopeMismatch,
            id: value.aggregateId,
            message: 'contributor 引用的 reminderId ${c.reminderId} 不存在或'
                '不属于 ownerScope ${value.ownerScopeId}',
          );
        }
        await _db.into(_db.lifeEventReminderAggregateContributors).insert(
              LifeEventReminderAggregateContributorRow(
                aggregateId: value.aggregateId,
                position: i,
                providerId: c.providerId,
                divinationTypeKey: c.divinationTypeKey,
                subDivinationTypeKey: c.subDivinationTypeKey,
                profileId: c.profileId,
                chartSnapshotId: c.chartSnapshotId,
                sourceEventId: c.sourceEventId,
                eventRevision: c.eventRevision,
                eventTypeId: c.eventTypeId,
                factSummary: c.factSummary,
                evidenceRef: c.evidenceRef,
                severityProviderId: c.sourceSeverityRef?.providerId,
                severitySchemeId: c.sourceSeverityRef?.schemeId,
                severitySchemeVersion: c.sourceSeverityRef?.schemeVersion,
                severityCode: c.sourceSeverityRef?.code,
                providerVersion: c.sourceVersions.providerVersion,
                algorithmVersion: c.sourceVersions.algorithmVersion,
                ruleVersion: c.sourceVersions.ruleVersion,
                dataVersion: c.sourceVersions.dataVersion,
                annotationRef: c.annotationRef,
                directionIdsJson: jsonEncode(c.directionIds),
                importanceOwnerScopeId: c.userImportanceRef?.ownerScopeId,
                importanceCatalogId: c.userImportanceRef?.catalogId,
                importanceCatalogRevision: c.userImportanceRef?.catalogRevision,
                importanceLevelId: c.userImportanceRef?.levelId,
                reminderId: c.reminderId,
              ),
            );
      }

      return value.aggregateId;
    });
  }

  // =====================================================================
  // ScheduledNotification
  // =====================================================================

  @override
  Future<String> saveSchedule(ScheduledNotification value) {
    return _db.transaction(() async {
      final invalid = value.validateTarget();
      if (invalid != null) {
        throw DriftReminderStoreRejected(
          outcome: invalid,
          id: value.scheduleId,
          message: 'reminderId 与 aggregateId 必须恰好一个非空',
        );
      }

      // 返工 F5(a)：status=claimed 时 leaseExpiresAtUtc 与 claimToken 必须
      // 同时非空，否则会产生"claimed 但永久不可被 claimDue 回收"的脏行。
      if (value.status == ScheduleStatus.claimed &&
          (value.leaseExpiresAtUtc == null || value.claimToken == null)) {
        throw DriftReminderStoreRejected(
          outcome: SaveReminderOutcome.invalidScheduleTarget,
          id: value.scheduleId,
          message: 'status=claimed 时 leaseExpiresAtUtc 与 claimToken 不得为 null',
        );
      }

      final existing = await (_db.select(_db.lifeEventReminderSchedules)
            ..where((t) => t.scheduleId.equals(value.scheduleId)))
          .getSingleOrNull();
      if (existing != null && existing.ownerScopeId != value.ownerScopeId) {
        throw DriftReminderStoreRejected(
          outcome: SaveReminderOutcome.ownerScopeMismatch,
          id: value.scheduleId,
          message: 'schedule ${value.scheduleId} 已属于 ${existing.ownerScopeId}',
        );
      }

      final reminderId = value.reminderId;
      if (reminderId != null) {
        final definition = await (_db.select(_db.lifeEventReminderDefinitions)
              ..where((t) => t.reminderId.equals(reminderId)))
            .getSingleOrNull();
        if (definition == null ||
            definition.ownerScopeId != value.ownerScopeId) {
          throw DriftReminderStoreRejected(
            outcome: SaveReminderOutcome.ownerScopeMismatch,
            id: value.scheduleId,
            message: 'schedule 指向的 reminderId $reminderId 不存在或'
                '不属于 ownerScope ${value.ownerScopeId}',
          );
        }
      } else {
        final aggregateId = value.aggregateId!;
        final aggregate = await (_db.select(_db.lifeEventReminderAggregates)
              ..where((t) => t.aggregateId.equals(aggregateId)))
            .getSingleOrNull();
        if (aggregate == null || aggregate.ownerScopeId != value.ownerScopeId) {
          throw DriftReminderStoreRejected(
            outcome: SaveReminderOutcome.ownerScopeMismatch,
            id: value.scheduleId,
            message: 'schedule 指向的 aggregateId $aggregateId 不存在或'
                '不属于 ownerScope ${value.ownerScopeId}',
          );
        }
      }

      await _db.into(_db.lifeEventReminderSchedules).insertOnConflictUpdate(
            LifeEventReminderScheduleRow(
              scheduleId: value.scheduleId,
              ownerScopeId: value.ownerScopeId,
              reminderId: value.reminderId,
              aggregateId: value.aggregateId,
              fireAtMs: value.fireAtUtc.millisecondsSinceEpoch,
              displayTimezoneId: value.displayTimezoneId,
              channelRevision: value.channelRevision,
              sourceRevisionFingerprint: value.sourceRevisionFingerprint,
              status: value.status.name,
              claimToken: value.claimToken,
              leaseExpiresAtMs: value.leaseExpiresAtUtc?.millisecondsSinceEpoch,
            ),
          );
      return value.scheduleId;
    });
  }

  // =====================================================================
  // DeliveryRecord
  // =====================================================================

  @override
  Future<String> saveDelivery(DeliveryRecord value) {
    return _db.transaction(() async {
      final schedule = await (_db.select(_db.lifeEventReminderSchedules)
            ..where((t) => t.scheduleId.equals(value.scheduleId)))
          .getSingleOrNull();
      if (schedule == null) {
        throw DriftReminderStoreRejected(
          outcome: SaveReminderOutcome.invalidScheduleTarget,
          id: value.deliveryId,
          message: 'delivery 指向的 scheduleId ${value.scheduleId} 不存在',
        );
      }

      // 返工 F3（Ruling 9）：deliveryId 由 calendar 侧用
      // 'delivery-{scheduleId}-{attemptedAt 微秒}' 生成，天然唯一，重复只
      // 可能是重放。字段完全一致 → 幂等无操作；任一字段不一致 → 拒绝，
      // 不得静默改写投递审计记录（例如把 delivered 悄悄改成 failed）。
      final existing = await (_db.select(_db.lifeEventReminderDeliveries)
            ..where((t) => t.deliveryId.equals(value.deliveryId)))
          .getSingleOrNull();
      if (existing != null) {
        final sameFields = existing.scheduleId == value.scheduleId &&
            existing.attemptedAtMs == value.attemptedAt.millisecondsSinceEpoch &&
            existing.outcome == value.outcome &&
            existing.stableErrorCode == value.stableErrorCode;
        if (sameFields) {
          return value.deliveryId;
        }
        throw DriftReminderStoreRejected(
          outcome: SaveReminderOutcome.revisionConflict,
          id: value.deliveryId,
          message: 'deliveryId ${value.deliveryId} 已存在但字段不一致，'
              '拒绝静默改写投递审计记录',
        );
      }

      await _db.into(_db.lifeEventReminderDeliveries).insert(
            LifeEventReminderDeliveryRow(
              deliveryId: value.deliveryId,
              scheduleId: value.scheduleId,
              attemptedAtMs: value.attemptedAt.millisecondsSinceEpoch,
              outcome: value.outcome,
              stableErrorCode: value.stableErrorCode,
            ),
          );
      return value.deliveryId;
    });
  }

  // =====================================================================
  // 租约领取（Design §14.4）
  // =====================================================================

  @override
  Future<ClaimDueSchedulesResult> claimDue(ClaimDueSchedulesRequest request) async {
    final nowMs = request.nowUtc.millisecondsSinceEpoch;
    final leaseExpiresMs = nowMs + request.leaseDuration.inMilliseconds;

    // 候选筛选用 autocommit 读，不持有读快照；随后每条候选的条件更新（CAS）
    // 各自在一个只含写语句的事务里执行。
    //
    // 为什么不把"读 + 全部更新"包进一个大事务：多连接同库时那会变成
    // "读快照内升级为写"，SQLite 对这种场景直接返回 SQLITE_BUSY(5) /
    // SQLITE_BUSY_SNAPSHOT(517) 且不调用 busy handler；失败方的读快照被钉住，
    // 重试与退避都无法恢复（已实测 8 次重试全部 517）。拆成"写事务"后，
    // 第一条语句就取写锁，busy_timeout 正常生效。
    //
    // 原子性与独占性不依赖外层事务，而是由条件更新的 WHERE 子句保证：
    // 只有 status 仍可领取的行会被更新，更新计数为 1 才算领到，
    // 因此一条 schedule 在租约有效期内只属于一个 claimToken。
    final candidates = await _dueCandidates(request, nowMs);

    final claimed = <ScheduledNotification>[];
    for (final row in candidates) {
      // 返工 F2：不得用候选 select 时的 row.* 构造返回 DTO——CAS 的 WHERE
      // 只校验 status/lease，不校验行内容未变；协调者可能在候选读取之后、
      // CAS 提交之前改写了该行的 fireAtUtc / sourceRevisionFingerprint 等字段
      // （LEC-037/038 改时与调度器领取交叠场景）。CAS 成功后必须在同一个
      // 写事务内重读该行，用重读结果构造返回值。
      final won = await _claimOne(
        row.scheduleId,
        request.claimToken,
        nowMs,
        leaseExpiresMs,
      );
      if (won != null) {
        claimed.add(
          ScheduledNotification(
            scheduleId: won.scheduleId,
            ownerScopeId: won.ownerScopeId,
            reminderId: won.reminderId,
            aggregateId: won.aggregateId,
            fireAtUtc: _utc(won.fireAtMs),
            displayTimezoneId: won.displayTimezoneId,
            channelRevision: won.channelRevision,
            sourceRevisionFingerprint: won.sourceRevisionFingerprint,
            status: ScheduleStatus.values.byName(won.status),
            claimToken: won.claimToken,
            leaseExpiresAtUtc:
                won.leaseExpiresAtMs == null ? null : _utc(won.leaseExpiresAtMs!),
          ),
        );
      }
    }

    return ClaimDueSchedulesResult(
      claimed: claimed,
      claimToken: request.claimToken,
      claimedAt: request.nowUtc,
    );
  }

  /// 到期候选：owner 相同、`fireAt <= now`，且 status 为 scheduled 或
  /// （claimed 且租约已过期）；按 (fireAtUtc, scheduleId) 升序取 maxCount。
  Future<List<LifeEventReminderScheduleRow>> _dueCandidates(
    ClaimDueSchedulesRequest request,
    int nowMs,
  ) {
    return (_db.select(_db.lifeEventReminderSchedules)
          ..where(
            (t) =>
                t.ownerScopeId.equals(request.ownerScopeId) &
                t.fireAtMs.isSmallerOrEqualValue(nowMs) &
                _claimableStatus(t, nowMs),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.fireAtMs),
            (t) => OrderingTerm.asc(t.scheduleId),
          ])
          ..limit(request.maxCount))
        .get();
  }

  /// 条件更新一条 schedule；CAS 成功后在同一事务内重读该行并返回（返工
  /// F2），未领到（更新计数不为 1）返回 null。
  Future<LifeEventReminderScheduleRow?> _claimOne(
    String scheduleId,
    String claimToken,
    int nowMs,
    int leaseExpiresMs,
  ) async {
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        return await _db.transaction(() async {
          final updatedRows = await (_db.update(_db.lifeEventReminderSchedules)
                ..where(
                  (t) =>
                      t.scheduleId.equals(scheduleId) &
                      _claimableStatus(t, nowMs),
                ))
              .write(
            LifeEventReminderSchedulesCompanion(
              status: Value(ScheduleStatus.claimed.name),
              claimToken: Value(claimToken),
              leaseExpiresAtMs: Value(leaseExpiresMs),
            ),
          );
          if (updatedRows != 1) {
            return null;
          }
          // 同一写事务内重读：返回值必须反映 CAS 之后的最新持久化状态。
          return (_db.select(_db.lifeEventReminderSchedules)
                ..where((t) => t.scheduleId.equals(scheduleId)))
              .getSingle();
        });
      } catch (error) {
        if (attempt >= _claimMaxAttempts || !_isLockContention(error)) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 20 * attempt));
      }
    }
  }

  /// 可领取谓词：status == scheduled，或 status == claimed 且（租约已过期，
  /// 或 lease_expires_at_ms 为 NULL）。
  ///
  /// 返工 F5(b)：正常写入路径下 status=claimed 必然带非空租约
  /// （saveSchedule 的 F5(a) guard 保证），这里的 `isNull()` 分支是安全网，
  /// 用于回收"万一存在"的脏行（例如更早版本代码或外部数据写入产生），
  /// 否则这类行会永久卡在 claimed 状态、无法再被任何调度器领取。
  Expression<bool> _claimableStatus(
    $LifeEventReminderSchedulesTable t,
    int nowMs,
  ) =>
      t.status.equals(ScheduleStatus.scheduled.name) |
      (t.status.equals(ScheduleStatus.claimed.name) &
          (t.leaseExpiresAtMs.isSmallerOrEqualValue(nowMs) |
              t.leaseExpiresAtMs.isNull()));

  // =====================================================================
  // 适配器自有 typed 读方法（Ruling 1）
  // =====================================================================

  /// 读取一个 ownerScope 下提醒中心的全部持久化状态。
  ///
  /// 排序确定：definitions 按 reminderId、channels 按 channelId、aggregates 按
  /// aggregateId（contributors 与 directionIds 按写入时的 position）、schedules
  /// 按 scheduleId，deliveredScheduleIds 去重后升序。只返回该 ownerScopeId 的数据。
  Future<ReminderOwnerState> loadOwnerState(String ownerScopeId) async {
    final definitionRows = await (_db.select(_db.lifeEventReminderDefinitions)
          ..where((t) => t.ownerScopeId.equals(ownerScopeId))
          ..orderBy([(t) => OrderingTerm.asc(t.reminderId)]))
        .get();
    final definitions = <ReminderDefinition>[];
    for (final row in definitionRows) {
      final channelRows = await (_db
              .select(_db.lifeEventReminderDefinitionChannels)
            ..where((t) => t.reminderId.equals(row.reminderId))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      definitions.add(
        ReminderDefinition(
          reminderId: row.reminderId,
          ownerScopeId: row.ownerScopeId,
          selectionRef: _selectionRefFromJson(
            jsonDecode(row.selectionRefJson) as Map<String, dynamic>,
          ),
          notificationTitleOverride: row.notificationTitleOverride,
          notificationBodyOverride: row.notificationBodyOverride,
          notificationPriorityRef: NotificationPriorityRef(
            ownerScopeId: row.priorityOwnerScopeId,
            catalogId: row.priorityCatalogId,
            catalogRevision: row.priorityCatalogRevision,
            priorityId: row.priorityId,
          ),
          channelIds: [for (final c in channelRows) c.channelId],
          leadTimes: _durations(row.leadTimesMsJson),
          repeatPolicy: row.repeatPolicy,
          mergePolicy: row.mergePolicy,
          enabled: row.enabled,
          revision: row.revision,
        ),
      );
    }

    final channelRows = await (_db.select(_db.lifeEventReminderChannels)
          ..where((t) => t.ownerScopeId.equals(ownerScopeId))
          ..orderBy([(t) => OrderingTerm.asc(t.channelId)]))
        .get();
    final channels = <ReminderChannel>[];
    for (final row in channelRows) {
      final selectorRows = await (_db
              .select(_db.lifeEventReminderChannelSelectors)
            ..where((t) => t.channelId.equals(row.channelId))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      channels.add(
        ReminderChannel(
          channelId: row.channelId,
          ownerScopeId: row.ownerScopeId,
          name: row.name,
          enabled: row.enabled,
          selectors: _selectors(selectorRows),
          deliveryPolicy: ReminderDeliveryPolicy(
            leadTimes: _durations(row.policyLeadTimesMsJson),
            quietHours: row.policyQuietHours,
            mergeWindow: Duration(milliseconds: row.policyMergeWindowMs),
            deliveryMode: DeliveryMode.values.byName(row.policyDeliveryMode),
            groupingMode: GroupingMode.values.byName(row.policyGroupingMode),
          ),
          revision: row.revision,
        ),
      );
    }

    final aggregateRows = await (_db.select(_db.lifeEventReminderAggregates)
          ..where((t) => t.ownerScopeId.equals(ownerScopeId))
          ..orderBy([(t) => OrderingTerm.asc(t.aggregateId)]))
        .get();
    final aggregates = <AggregateReminder>[];
    for (final row in aggregateRows) {
      final directionRows = await (_db
              .select(_db.lifeEventReminderAggregateDirections)
            ..where((t) => t.aggregateId.equals(row.aggregateId))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      final contributorRows = await (_db
              .select(_db.lifeEventReminderAggregateContributors)
            ..where((t) => t.aggregateId.equals(row.aggregateId))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      aggregates.add(
        AggregateReminder(
          aggregateId: row.aggregateId,
          ownerScopeId: row.ownerScopeId,
          subjectId: row.subjectId,
          displayTimeWindow: TimeRange(
            startInclusiveUtc: _utc(row.windowStartMs),
            endExclusiveUtc: _utc(row.windowEndMs),
          ),
          directionIds: [for (final d in directionRows) d.directionId],
          effectiveNotificationPriorityRef: NotificationPriorityRef(
            ownerScopeId: row.priorityOwnerScopeId,
            catalogId: row.priorityCatalogId,
            catalogRevision: row.priorityCatalogRevision,
            priorityId: row.priorityId,
          ),
          displayTitle: row.displayTitle,
          userInterpretation: row.userInterpretation,
          contributors: [for (final c in contributorRows) _contributor(c)],
        ),
      );
    }

    final scheduleRows = await (_db.select(_db.lifeEventReminderSchedules)
          ..where((t) => t.ownerScopeId.equals(ownerScopeId))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduleId)]))
        .get();
    final schedules = [
      for (final row in scheduleRows)
        ScheduledNotification(
          scheduleId: row.scheduleId,
          ownerScopeId: row.ownerScopeId,
          reminderId: row.reminderId,
          aggregateId: row.aggregateId,
          fireAtUtc: _utc(row.fireAtMs),
          displayTimezoneId: row.displayTimezoneId,
          channelRevision: row.channelRevision,
          sourceRevisionFingerprint: row.sourceRevisionFingerprint,
          status: ScheduleStatus.values.byName(row.status),
          claimToken: row.claimToken,
          leaseExpiresAtUtc:
              row.leaseExpiresAtMs == null ? null : _utc(row.leaseExpiresAtMs!),
        ),
    ];

    final ownerScheduleIds = [for (final row in scheduleRows) row.scheduleId];
    final deliveredScheduleIds = <String>{};
    if (ownerScheduleIds.isNotEmpty) {
      final deliveryRows = await (_db.select(_db.lifeEventReminderDeliveries)
            ..where(
              (t) =>
                  t.scheduleId.isIn(ownerScheduleIds) &
                  t.outcome.equals(_deliveredOutcome),
            ))
          .get();
      for (final row in deliveryRows) {
        deliveredScheduleIds.add(row.scheduleId);
      }
    }
    final sortedDelivered = deliveredScheduleIds.toList()..sort();

    return ReminderOwnerState(
      definitions: definitions,
      channels: channels,
      aggregates: aggregates,
      schedules: schedules,
      deliveredScheduleIds: sortedDelivered,
    );
  }

  // =====================================================================
  // 私有辅助
  // =====================================================================

  /// Ruling 3：expectedRevision 语义。
  ///
  /// 不存在同 id 行 → 接受（不看 expectedRevision）；存在行 → 仅当
  /// `value.revision > stored.revision` 且 expectedRevision 等于存储值或新值
  /// 时接受，否则 revisionConflict。owner 不得改挂。
  void _guardRevision({
    required String id,
    required String? storedOwnerScopeId,
    required int? storedRevision,
    required String valueOwnerScopeId,
    required int valueRevision,
    required int expectedRevision,
  }) {
    if (storedOwnerScopeId == null || storedRevision == null) {
      return;
    }
    if (storedOwnerScopeId != valueOwnerScopeId) {
      throw DriftReminderStoreRejected(
        outcome: SaveReminderOutcome.ownerScopeMismatch,
        id: id,
        message: '$id 已属于 $storedOwnerScopeId，不得改挂到 $valueOwnerScopeId',
      );
    }
    final revisionAdvances = valueRevision > storedRevision;
    final expectationMatches =
        expectedRevision == storedRevision || expectedRevision == valueRevision;
    if (!revisionAdvances || !expectationMatches) {
      throw DriftReminderStoreRejected(
        outcome: SaveReminderOutcome.revisionConflict,
        id: id,
        message: '$id 存储 revision=$storedRevision，'
            '写入 revision=$valueRevision，expectedRevision=$expectedRevision',
      );
    }
  }

  /// Ruling 6：selectionRef 必须指向同 owner 的已保存 selection / pattern。
  ///
  /// revision 是否匹配由 coordinator 负责，存储层不校验 revision 相等。
  Future<void> _guardSelectionRef(ReminderDefinition value) async {
    switch (value.selectionRef) {
      case OccurrenceSelectionRef(:final selectionId):
        final row = await (_db.select(_db.lifeEventOccurrenceSelections)
              ..where((t) => t.selectionId.equals(selectionId)))
            .getSingleOrNull();
        if (row == null || row.ownerScopeId != value.ownerScopeId) {
          throw DriftReminderStoreRejected(
            outcome: SaveReminderOutcome.danglingSelectionRef,
            id: value.reminderId,
            message: 'occurrence selection $selectionId 不存在或'
                '不属于 ownerScope ${value.ownerScopeId}',
          );
        }
      case PatternRuleRef(:final savedPatternId):
        final row = await (_db.select(_db.lifeEventPatternRules)
              ..where((t) => t.savedPatternId.equals(savedPatternId)))
            .getSingleOrNull();
        if (row == null || row.ownerScopeId != value.ownerScopeId) {
          throw DriftReminderStoreRejected(
            outcome: SaveReminderOutcome.danglingSelectionRef,
            id: value.reminderId,
            message: 'pattern rule $savedPatternId 不存在或'
                '不属于 ownerScope ${value.ownerScopeId}',
          );
        }
    }
  }

  List<LifeEventReminderChannelSelectorRow> _selectorRows(ReminderChannel c) {
    final s = c.selectors;
    final rows = <LifeEventReminderChannelSelectorRow>[];
    void add(
      String kind,
      int position, {
      String? a,
      String? b,
      String? cc,
      String? d,
      int? i,
    }) {
      rows.add(
        LifeEventReminderChannelSelectorRow(
          channelId: c.channelId,
          kind: kind,
          position: position,
          valueA: a,
          valueB: b,
          valueC: cc,
          valueD: d,
          valueInt: i,
        ),
      );
    }

    for (var i = 0; i < s.subjectIds.length; i++) {
      add(_kSubject, i, a: s.subjectIds[i]);
    }
    for (var i = 0; i < s.profileIds.length; i++) {
      add(_kProfile, i, a: s.profileIds[i]);
    }
    for (var i = 0; i < s.divinationSelectors.length; i++) {
      final d = s.divinationSelectors[i];
      add(
        _kDivination,
        i,
        a: d.providerId,
        b: d.divinationTypeKey,
        cc: d.subDivinationTypeKey,
      );
    }
    for (var i = 0; i < s.eventTypeIds.length; i++) {
      add(_kEventType, i, a: s.eventTypeIds[i]);
    }
    for (var i = 0; i < s.directionIds.length; i++) {
      add(_kDirection, i, a: s.directionIds[i]);
    }
    for (var i = 0; i < s.sourceSeverityRefs.length; i++) {
      final r = s.sourceSeverityRefs[i];
      add(
        _kSourceSeverity,
        i,
        a: r.providerId,
        b: r.schemeId,
        cc: r.schemeVersion,
        d: r.code,
      );
    }
    for (var i = 0; i < s.userImportanceRefs.length; i++) {
      final r = s.userImportanceRefs[i];
      add(
        _kUserImportance,
        i,
        a: r.ownerScopeId,
        b: r.catalogId,
        cc: r.levelId,
        i: r.catalogRevision,
      );
    }
    for (var i = 0; i < s.notificationPriorityRefs.length; i++) {
      final r = s.notificationPriorityRefs[i];
      add(
        _kNotificationPriority,
        i,
        a: r.ownerScopeId,
        b: r.catalogId,
        cc: r.priorityId,
        i: r.catalogRevision,
      );
    }
    return rows;
  }

  ReminderChannelSelectors _selectors(
    List<LifeEventReminderChannelSelectorRow> rows,
  ) {
    // 入参已按 position 升序；按 kind 分桶后各自保持写入顺序。
    List<LifeEventReminderChannelSelectorRow> of(String kind) =>
        [for (final r in rows) if (r.kind == kind) r];

    return ReminderChannelSelectors(
      subjectIds: [for (final r in of(_kSubject)) r.valueA!],
      profileIds: [for (final r in of(_kProfile)) r.valueA!],
      divinationSelectors: [
        for (final r in of(_kDivination))
          ReminderDivinationSelector(
            providerId: r.valueA,
            divinationTypeKey: r.valueB,
            subDivinationTypeKey: r.valueC,
          ),
      ],
      eventTypeIds: [for (final r in of(_kEventType)) r.valueA!],
      directionIds: [for (final r in of(_kDirection)) r.valueA!],
      sourceSeverityRefs: [
        for (final r in of(_kSourceSeverity))
          SourceSeverityRef(
            providerId: r.valueA!,
            schemeId: r.valueB!,
            schemeVersion: r.valueC!,
            code: r.valueD!,
          ),
      ],
      userImportanceRefs: [
        for (final r in of(_kUserImportance))
          UserImportanceRef(
            ownerScopeId: r.valueA!,
            catalogId: r.valueB!,
            catalogRevision: r.valueInt!,
            levelId: r.valueC!,
          ),
      ],
      notificationPriorityRefs: [
        for (final r in of(_kNotificationPriority))
          NotificationPriorityRef(
            ownerScopeId: r.valueA!,
            catalogId: r.valueB!,
            catalogRevision: r.valueInt!,
            priorityId: r.valueC!,
          ),
      ],
    );
  }

  AggregateReminderContributor _contributor(
    LifeEventReminderAggregateContributorRow r,
  ) {
    SourceSeverityRef? severity;
    if (r.severityProviderId != null &&
        r.severitySchemeId != null &&
        r.severitySchemeVersion != null &&
        r.severityCode != null) {
      severity = SourceSeverityRef(
        providerId: r.severityProviderId!,
        schemeId: r.severitySchemeId!,
        schemeVersion: r.severitySchemeVersion!,
        code: r.severityCode!,
      );
    }
    UserImportanceRef? importance;
    if (r.importanceOwnerScopeId != null &&
        r.importanceCatalogId != null &&
        r.importanceCatalogRevision != null &&
        r.importanceLevelId != null) {
      importance = UserImportanceRef(
        ownerScopeId: r.importanceOwnerScopeId!,
        catalogId: r.importanceCatalogId!,
        catalogRevision: r.importanceCatalogRevision!,
        levelId: r.importanceLevelId!,
      );
    }
    return AggregateReminderContributor(
      providerId: r.providerId,
      divinationTypeKey: r.divinationTypeKey,
      subDivinationTypeKey: r.subDivinationTypeKey,
      profileId: r.profileId,
      chartSnapshotId: r.chartSnapshotId,
      sourceEventId: r.sourceEventId,
      eventRevision: r.eventRevision,
      eventTypeId: r.eventTypeId,
      factSummary: r.factSummary,
      evidenceRef: r.evidenceRef,
      sourceSeverityRef: severity,
      sourceVersions: SourceVersions(
        providerVersion: r.providerVersion,
        algorithmVersion: r.algorithmVersion,
        ruleVersion: r.ruleVersion,
        dataVersion: r.dataVersion,
      ),
      annotationRef: r.annotationRef,
      directionIds:
          (jsonDecode(r.directionIdsJson) as List<dynamic>).cast<String>(),
      userImportanceRef: importance,
      reminderId: r.reminderId,
    );
  }

  List<Duration> _durations(String json) => [
        for (final ms in jsonDecode(json) as List<dynamic>)
          Duration(milliseconds: ms as int),
      ];

  DateTime _utc(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  Map<String, dynamic> _selectionRefToJson(ReminderSelectionRef ref) =>
      switch (ref) {
        OccurrenceSelectionRef() => {
            'kind': _kOccurrenceSelectionRef,
            'selectionId': ref.selectionId,
            'revision': ref.revision,
          },
        PatternRuleRef() => {
            'kind': _kPatternRuleRef,
            'savedPatternId': ref.savedPatternId,
            'revision': ref.revision,
          },
      };

  ReminderSelectionRef _selectionRefFromJson(Map<String, dynamic> m) =>
      switch (m['kind'] as String) {
        _kPatternRuleRef => PatternRuleRef(
            savedPatternId: m['savedPatternId'] as String,
            revision: m['revision'] as int,
          ),
        _ => OccurrenceSelectionRef(
            selectionId: m['selectionId'] as String,
            revision: m['revision'] as int,
          ),
      };

  /// SQLite 多连接锁竞争（BUSY / locked / snapshot），可安全重试。
  bool _isLockContention(Object error) {
    if (error is DriftReminderStoreRejected) {
      return false;
    }
    final text = error.toString().toLowerCase();
    return text.contains('sqlite_busy') ||
        text.contains('database is locked') ||
        text.contains('database table is locked') ||
        text.contains('sqlite_locked') ||
        // WAL 下读快照过期后升级为写会返回 SQLITE_BUSY_SNAPSHOT。
        text.contains('snapshot');
  }
}
