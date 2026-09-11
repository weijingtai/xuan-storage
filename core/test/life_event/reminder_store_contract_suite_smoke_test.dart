// ACT-12A: 共享合同套件在纯内存实现上的 smoke 测试
import 'dart:async';

import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:persistence_core/test_support/life_event_reminder_store_contract_suite.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryLifeEventReminderStore smoke', () {
    runLifeEventReminderStoreContractSuite(
      makeStore: () => _InMemoryReminderStore(),
      seedSelection: (store, ownerScopeId, selectionId, revision) async {
        (store as _InMemoryReminderStore).seedSelection(ownerScopeId, selectionId, revision);
      },
    );
  });
}

class _InMemoryReminderStore implements LifeEventReminderStore {
  final Map<String, ReminderDefinition> _definitions = {};
  final Map<String, ReminderChannel> _channels = {};
  final Map<String, AggregateReminder> _aggregates = {};
  final Map<String, ScheduledNotification> _schedules = {};
  final Map<String, DeliveryRecord> _deliveries = {};
  final Set<String> _seededSelections = {};

  void seedSelection(String ownerScopeId, String selectionId, int revision) {
    _seededSelections.add('$ownerScopeId:$selectionId');
  }

  @override
  Future<SaveReminderResult> saveDefinition(ReminderDefinition value, int expectedRevision) async {
    final existing = _definitions[value.reminderId];

    // 检查 selectionRef
    if (value.selectionRef case OccurrenceSelectionRef(:final selectionId)) {
      if (!_seededSelections.contains('${value.ownerScopeId}:$selectionId')) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.danglingSelectionRef,
          id: value.reminderId,
          revision: existing?.revision ?? 0,
        );
      }
    }

    // 检查 channelIds
    for (final chId in value.channelIds) {
      final ch = _channels[chId];
      if (ch == null || ch.ownerScopeId != value.ownerScopeId) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.ownerScopeMismatch,
          id: value.reminderId,
          revision: existing?.revision ?? 0,
        );
      }
    }

    if (existing != null) {
      if (existing.ownerScopeId != value.ownerScopeId) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.ownerScopeMismatch,
          id: value.reminderId,
          revision: existing.revision,
        );
      }
      if (expectedRevision != existing.revision || value.revision != expectedRevision + 1) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.revisionConflict,
          id: value.reminderId,
          revision: existing.revision,
        );
      }
    }

    _definitions[value.reminderId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.reminderId,
      revision: value.revision,
    );
  }

  @override
  Future<SaveReminderResult> saveChannel(ReminderChannel value, int expectedRevision) async {
    final existing = _channels[value.channelId];
    if (existing != null) {
      if (existing.ownerScopeId != value.ownerScopeId) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.ownerScopeMismatch,
          id: value.channelId,
          revision: existing.revision,
        );
      }
      if (expectedRevision != existing.revision || value.revision != expectedRevision + 1) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.revisionConflict,
          id: value.channelId,
          revision: existing.revision,
        );
      }
    }
    _channels[value.channelId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.channelId,
      revision: value.revision,
    );
  }

  @override
  Future<SaveReminderResult> saveAggregate(AggregateReminder value) async {
    for (final c in value.contributors) {
      final def = _definitions[c.reminderId];
      if (def == null || def.ownerScopeId != value.ownerScopeId) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.ownerScopeMismatch,
          id: value.aggregateId,
          revision: 0,
        );
      }
    }
    _aggregates[value.aggregateId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.aggregateId,
      revision: 0,
    );
  }

  @override
  Future<SaveReminderResult> saveSchedule(ScheduledNotification value) async {
    final invalid = value.validateTarget();
    if (invalid != null) {
      return SaveReminderResult(
        outcome: invalid,
        id: value.scheduleId,
        revision: 0,
      );
    }

    if (value.status == ScheduleStatus.claimed &&
        (value.leaseExpiresAtUtc == null || value.claimToken == null)) {
      return SaveReminderResult(
        outcome: SaveReminderOutcome.invalidScheduleTarget,
        id: value.scheduleId,
        revision: 0,
      );
    }

    if (value.reminderId != null) {
      final def = _definitions[value.reminderId];
      if (def == null || def.ownerScopeId != value.ownerScopeId) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.ownerScopeMismatch,
          id: value.scheduleId,
          revision: 0,
        );
      }
    } else {
      final agg = _aggregates[value.aggregateId];
      if (agg == null || agg.ownerScopeId != value.ownerScopeId) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.ownerScopeMismatch,
          id: value.scheduleId,
          revision: 0,
        );
      }
    }

    _schedules[value.scheduleId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.scheduleId,
      revision: 0,
    );
  }

  @override
  Future<ClaimDueSchedulesResult> claimDue(ClaimDueSchedulesRequest request) async {
    final due = _schedules.values.where((s) {
      if (s.ownerScopeId != request.ownerScopeId) return false;
      if (s.fireAtUtc.isAfter(request.nowUtc)) return false;
      if (s.status == ScheduleStatus.scheduled) return true;
      if (s.status == ScheduleStatus.claimed &&
          s.leaseExpiresAtUtc != null &&
          !s.leaseExpiresAtUtc!.isAfter(request.nowUtc)) {
        return true;
      }
      return false;
    }).toList()
      ..sort((a, b) => a.fireAtUtc.compareTo(b.fireAtUtc));

    final selected = due.take(request.maxCount).toList();
    final claimed = <ScheduledNotification>[];
    final expires = request.nowUtc.add(request.leaseDuration);
    for (final item in selected) {
      final updated = ScheduledNotification(
        scheduleId: item.scheduleId,
        ownerScopeId: item.ownerScopeId,
        reminderId: item.reminderId,
        aggregateId: item.aggregateId,
        fireAtUtc: item.fireAtUtc,
        displayTimezoneId: item.displayTimezoneId,
        channelRevision: item.channelRevision,
        sourceRevisionFingerprint: item.sourceRevisionFingerprint,
        status: ScheduleStatus.claimed,
        claimToken: request.claimToken,
        leaseExpiresAtUtc: expires,
      );
      _schedules[item.scheduleId] = updated;
      claimed.add(updated);
    }

    return ClaimDueSchedulesResult(
      claimed: claimed,
      claimToken: request.claimToken,
      claimedAt: request.nowUtc,
    );
  }

  @override
  Future<SaveReminderResult> saveDelivery(DeliveryRecord value) async {
    final sched = _schedules[value.scheduleId];
    if (sched == null) {
      return SaveReminderResult(
        outcome: SaveReminderOutcome.invalidScheduleTarget,
        id: value.deliveryId,
        revision: 0,
      );
    }

    final existing = _deliveries[value.deliveryId];
    if (existing != null) {
      final same = existing.scheduleId == value.scheduleId &&
          existing.attemptedAt == value.attemptedAt &&
          existing.outcome == value.outcome &&
          existing.stableErrorCode == value.stableErrorCode;
      if (same) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.saved,
          id: value.deliveryId,
          revision: 0,
        );
      }
      return SaveReminderResult(
        outcome: SaveReminderOutcome.revisionConflict,
        id: value.deliveryId,
        revision: 0,
      );
    }

    _deliveries[value.deliveryId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.deliveryId,
      revision: 0,
    );
  }
}
