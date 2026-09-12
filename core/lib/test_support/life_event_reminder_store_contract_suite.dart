// ACT-12A: 共享 ReminderStore 合同测试套件
import 'dart:async';

import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:test/test.dart';

/// 共享合同套件：In-Memory 与 Drift adapter 都必须原样通过。
/// makeStore 每个用例调用一次并返回全新空存储；seedSelection 用于满足 danglingSelectionRef 校验的前置（adapter 各自实现）。
void runLifeEventReminderStoreContractSuite({
  required FutureOr<LifeEventReminderStore> Function() makeStore,
  required Future<void> Function(LifeEventReminderStore store, String ownerScopeId, String selectionId, int revision) seedSelection,
}) {
  group('LifeEventReminderStore 合同套件', () {
    const ownerA = 'owner-scope-a';
    const ownerB = 'owner-scope-b';

    ReminderDefinition makeDef({
      String reminderId = 'def-1',
      String ownerScopeId = ownerA,
      String selectionId = 'sel-1',
      int selectionRevision = 1,
      List<String> channelIds = const [],
      int revision = 1,
    }) =>
        ReminderDefinition(
          reminderId: reminderId,
          ownerScopeId: ownerScopeId,
          selectionRef: OccurrenceSelectionRef(
            selectionId: selectionId,
            revision: selectionRevision,
          ),
          notificationTitleOverride: null,
          notificationBodyOverride: null,
          notificationPriorityRef: NotificationPriorityRef(
            ownerScopeId: ownerScopeId,
            catalogId: 'cat-1',
            catalogRevision: 1,
            priorityId: 'prio-1',
          ),
          channelIds: channelIds,
          leadTimes: const [],
          repeatPolicy: null,
          mergePolicy: 'none',
          enabled: true,
          revision: revision,
        );

    ReminderChannel makeChan({
      String channelId = 'ch-1',
      String ownerScopeId = ownerA,
      int revision = 1,
    }) =>
        ReminderChannel(
          channelId: channelId,
          ownerScopeId: ownerScopeId,
          name: 'Channel $channelId',
          enabled: true,
          selectors: const ReminderChannelSelectors(
            subjectIds: [],
            profileIds: [],
            divinationSelectors: [],
            eventTypeIds: [],
            directionIds: [],
            sourceSeverityRefs: [],
            userImportanceRefs: [],
            notificationPriorityRefs: [],
          ),
          deliveryPolicy: const ReminderDeliveryPolicy(
            leadTimes: [Duration(minutes: 15)],
            quietHours: null,
            mergeWindow: Duration(minutes: 30),
            deliveryMode: DeliveryMode.immediate,
            groupingMode: GroupingMode.each,
          ),
          revision: revision,
        );

    ScheduledNotification makeSched({
      String scheduleId = 'sch-1',
      String ownerScopeId = ownerA,
      String? reminderId = 'def-1',
      String? aggregateId,
      DateTime? fireAtUtc,
      ScheduleStatus status = ScheduleStatus.scheduled,
      String? claimToken,
      DateTime? leaseExpiresAtUtc,
    }) =>
        ScheduledNotification(
          scheduleId: scheduleId,
          ownerScopeId: ownerScopeId,
          reminderId: reminderId,
          aggregateId: aggregateId,
          fireAtUtc: fireAtUtc ?? DateTime.utc(2026, 1, 1, 10),
          displayTimezoneId: 'Asia/Shanghai',
          channelRevision: 1,
          sourceRevisionFingerprint: 'fp-1',
          status: status,
          claimToken: claimToken,
          leaseExpiresAtUtc: leaseExpiresAtUtc,
        );

    DeliveryRecord makeDeliv({
      String deliveryId = 'deliv-1',
      String scheduleId = 'sch-1',
      DateTime? attemptedAt,
      String outcome = 'delivered',
      String? stableErrorCode,
    }) =>
        DeliveryRecord(
          deliveryId: deliveryId,
          scheduleId: scheduleId,
          attemptedAt: attemptedAt ?? DateTime.utc(2026, 1, 1, 10, 1),
          outcome: outcome,
          stableErrorCode: stableErrorCode,
        );

    test('saveDefinition / saveChannel: expectedRevision CAS 经典语义与零写入', () async {
      final store = await makeStore();
      await seedSelection(store, ownerA, 'sel-1', 1);

      // 1. 不存在行且 expectedRevision=0 → saved
      final res1 = await store.saveDefinition(makeDef(revision: 1), 0);
      expect(res1.outcome, equals(SaveReminderOutcome.saved));
      expect(res1.id, equals('def-1'));
      expect(res1.revision, equals(1));

      // 2. 存在行且 expectedRevision==stored 且 value.revision==stored+1 → saved 并返回新 revision
      final res2 = await store.saveDefinition(makeDef(revision: 2), 1);
      expect(res2.outcome, equals(SaveReminderOutcome.saved));
      expect(res2.id, equals('def-1'));
      expect(res2.revision, equals(2));

      // 3. expectedRevision != stored → revisionConflict、返回当前 stored revision、零写入
      final resConflict = await store.saveDefinition(makeDef(revision: 3), 1);
      expect(resConflict.outcome, equals(SaveReminderOutcome.revisionConflict));
      expect(resConflict.id, equals('def-1'));
      expect(resConflict.revision, equals(2));

      // 验证零写入：当前 stored revision 仍为 2，用 expectedRevision=2 推进到 3 应成功
      final res3 = await store.saveDefinition(makeDef(revision: 3), 2);
      expect(res3.outcome, equals(SaveReminderOutcome.saved));
      expect(res3.revision, equals(3));

      // 4. value.revision != expectedRevision+1 → revisionConflict 零写入
      final resJump = await store.saveDefinition(makeDef(revision: 5), 3);
      expect(resJump.outcome, equals(SaveReminderOutcome.revisionConflict));
      expect(resJump.id, equals('def-1'));
      expect(resJump.revision, equals(3));

      // 对 saveChannel 同样验证
      final ch1 = await store.saveChannel(makeChan(revision: 1), 0);
      expect(ch1.outcome, equals(SaveReminderOutcome.saved));
      expect(ch1.revision, equals(1));

      final chConflict = await store.saveChannel(makeChan(revision: 2), 99);
      expect(chConflict.outcome, equals(SaveReminderOutcome.revisionConflict));
      expect(chConflict.revision, equals(1));

      final chJump = await store.saveChannel(makeChan(revision: 4), 1);
      expect(chJump.outcome, equals(SaveReminderOutcome.revisionConflict));
      expect(chJump.revision, equals(1));
    });

    test('ownerScopeMismatch、danglingSelectionRef 与零写入', () async {
      final store = await makeStore();
      await seedSelection(store, ownerA, 'sel-1', 1);

      // 先在 ownerB 下建一个 channel
      final chB = await store.saveChannel(makeChan(channelId: 'ch-b', ownerScopeId: ownerB), 0);
      expect(chB.outcome, equals(SaveReminderOutcome.saved));

      // 1. channelIds 跨 owner
      final defCrossChannel = makeDef(
        reminderId: 'def-cross',
        ownerScopeId: ownerA,
        channelIds: const ['ch-b'],
      );
      final resCross = await store.saveDefinition(defCrossChannel, 0);
      expect(resCross.outcome, equals(SaveReminderOutcome.ownerScopeMismatch));
      expect(resCross.id, equals('def-cross'));
      expect(resCross.revision, equals(0));

      // 验证零写入：def-cross 不存在，随后的正确写入可传 expectedRevision=0 成功
      final defValid = makeDef(reminderId: 'def-cross', ownerScopeId: ownerA, channelIds: const []);
      final resValid = await store.saveDefinition(defValid, 0);
      expect(resValid.outcome, equals(SaveReminderOutcome.saved));

      // 2. danglingSelectionRef
      final defDangling = makeDef(reminderId: 'def-dangling', selectionId: 'unseeded-sel');
      final resDangling = await store.saveDefinition(defDangling, 0);
      expect(resDangling.outcome, equals(SaveReminderOutcome.danglingSelectionRef));
      expect(resDangling.id, equals('def-dangling'));
      expect(resDangling.revision, equals(0));

      // 3. schedule 目标跨 owner
      final schedCross = makeSched(
        scheduleId: 'sch-cross',
        ownerScopeId: ownerB, // schedule 是 ownerB，但 reminderId 是 ownerA 的 def-1
        reminderId: 'def-cross',
      );
      final resSchedCross = await store.saveSchedule(schedCross);
      expect(resSchedCross.outcome, equals(SaveReminderOutcome.ownerScopeMismatch));
      expect(resSchedCross.id, equals('sch-cross'));
      expect(resSchedCross.revision, equals(0));

      // 4. contributor.reminderId 跨 owner
      final agg = AggregateReminder(
        aggregateId: 'agg-1',
        ownerScopeId: ownerB, // aggregate 属于 ownerB
        subjectId: 'subj-1',
        displayTimeWindow: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2026, 1, 2),
        ),
        directionIds: const [],
        effectiveNotificationPriorityRef: const NotificationPriorityRef(
          ownerScopeId: ownerB,
          catalogId: 'cat-1',
          catalogRevision: 1,
          priorityId: 'prio-1',
        ),
        displayTitle: 'Agg',
        userInterpretation: null,
        contributors: [
          AggregateReminderContributor(
            providerId: 'prov-1',
            divinationTypeKey: 'bazi',
            subDivinationTypeKey: null,
            profileId: 'prof-1',
            chartSnapshotId: 'snap-1',
            sourceEventId: 'src-1',
            eventRevision: 'v1',
            eventTypeId: 'year_cycle',
            factSummary: 'fact',
            evidenceRef: 'ev-1',
            sourceSeverityRef: null,
            sourceVersions: const SourceVersions(
              providerVersion: '1.0.0',
              algorithmVersion: 'algo-1',
              ruleVersion: 'rule-1',
              dataVersion: null,
            ),
            annotationRef: null,
            directionIds: const [],
            userImportanceRef: null,
            reminderId: 'def-cross', // 属于 ownerA
          ),
        ],
      );
      final resAgg = await store.saveAggregate(agg);
      expect(resAgg.outcome, equals(SaveReminderOutcome.ownerScopeMismatch));
      expect(resAgg.id, equals('agg-1'));
      expect(resAgg.revision, equals(0));
    });

    test('invalidScheduleTarget（双空 / 双非空 / delivery 悬空）与零写入', () async {
      final store = await makeStore();

      // 双空
      final schedBothNull = makeSched(scheduleId: 'sch-both-null', reminderId: null, aggregateId: null);
      final resNull = await store.saveSchedule(schedBothNull);
      expect(resNull.outcome, equals(SaveReminderOutcome.invalidScheduleTarget));
      expect(resNull.id, equals('sch-both-null'));
      expect(resNull.revision, equals(0));

      // 双非空
      final schedBothSet = makeSched(
        scheduleId: 'sch-both-set',
        reminderId: 'rem-1',
        aggregateId: 'agg-1',
      );
      final resBoth = await store.saveSchedule(schedBothSet);
      expect(resBoth.outcome, equals(SaveReminderOutcome.invalidScheduleTarget));
      expect(resBoth.id, equals('sch-both-set'));
      expect(resBoth.revision, equals(0));

      // 验证零写入：claimDue 领不到这两条
      final claimRes = await store.claimDue(
        ClaimDueSchedulesRequest(
          ownerScopeId: ownerA,
          nowUtc: DateTime.utc(2026, 1, 1, 12),
          maxCount: 10,
          claimToken: 'tok-1',
          leaseDuration: const Duration(minutes: 5),
        ),
      );
      expect(claimRes.claimed, isEmpty);

      // delivery 悬空（scheduleId 不存在）
      final deliv = makeDeliv(deliveryId: 'deliv-dangling', scheduleId: 'sch-non-existent');
      final resDeliv = await store.saveDelivery(deliv);
      expect(resDeliv.outcome, equals(SaveReminderOutcome.invalidScheduleTarget));
      expect(resDeliv.id, equals('deliv-dangling'));
      expect(resDeliv.revision, equals(0));
    });

    test('saveDelivery 同 deliveryId 内容一致幂等；内容不一致 revisionConflict 零写入', () async {
      final store = await makeStore();
      await seedSelection(store, ownerA, 'sel-1', 1);

      // 前置：合法保存 definition 与 schedule
      await store.saveDefinition(makeDef(reminderId: 'def-1'), 0);
      await store.saveSchedule(makeSched(scheduleId: 'sch-1', reminderId: 'def-1'));

      final deliv1 = makeDeliv(
        deliveryId: 'deliv-1',
        scheduleId: 'sch-1',
        outcome: 'delivered',
        stableErrorCode: null,
      );
      final res1 = await store.saveDelivery(deliv1);
      expect(res1.outcome, equals(SaveReminderOutcome.saved));
      expect(res1.id, equals('deliv-1'));

      // 相同 deliveryId 内容一致 → 幂等 saved
      final resReplay = await store.saveDelivery(deliv1);
      expect(resReplay.outcome, equals(SaveReminderOutcome.saved));
      expect(resReplay.id, equals('deliv-1'));

      // 相同 deliveryId 内容不一致（例如 outcome 改为 failed）→ revisionConflict 零写入
      final delivConflict = makeDeliv(
        deliveryId: 'deliv-1',
        scheduleId: 'sch-1',
        outcome: 'failed',
        stableErrorCode: 'NETWORK_TIMEOUT',
      );
      final resConflict = await store.saveDelivery(delivConflict);
      expect(resConflict.outcome, equals(SaveReminderOutcome.revisionConflict));
      expect(resConflict.id, equals('deliv-1'));
      expect(resConflict.revision, equals(0));

      // 再次重放原来的 deliv1 仍然一致 saved，证明原记录未被篡改
      final resAfter = await store.saveDelivery(deliv1);
      expect(resAfter.outcome, equals(SaveReminderOutcome.saved));
    });

    test('claimDue 行为（到期领取、租约过期重领、终态不可领）', () async {
      final store = await makeStore();
      await seedSelection(store, ownerA, 'sel-1', 1);
      await store.saveDefinition(makeDef(reminderId: 'def-1'), 0);

      final now = DateTime.utc(2026, 1, 1, 10, 0);

      // 1. 到期可领
      await store.saveSchedule(makeSched(
        scheduleId: 'sch-due',
        fireAtUtc: DateTime.utc(2026, 1, 1, 9, 0),
        status: ScheduleStatus.scheduled,
      ));

      // 2. 未到期不可领
      await store.saveSchedule(makeSched(
        scheduleId: 'sch-future',
        fireAtUtc: DateTime.utc(2026, 1, 1, 11, 0),
        status: ScheduleStatus.scheduled,
      ));

      // 3. 终态不可领 (cancelled / delivered / failed)
      await store.saveSchedule(makeSched(
        scheduleId: 'sch-cancelled',
        fireAtUtc: DateTime.utc(2026, 1, 1, 9, 0),
        status: ScheduleStatus.cancelled,
      ));

      // 4. 租约未过期不可领
      await store.saveSchedule(makeSched(
        scheduleId: 'sch-active-lease',
        fireAtUtc: DateTime.utc(2026, 1, 1, 9, 0),
        status: ScheduleStatus.claimed,
        claimToken: 'other-token',
        leaseExpiresAtUtc: DateTime.utc(2026, 1, 1, 10, 30),
      ));

      // 5. 租约已过期可重领
      await store.saveSchedule(makeSched(
        scheduleId: 'sch-expired-lease',
        fireAtUtc: DateTime.utc(2026, 1, 1, 9, 0),
        status: ScheduleStatus.claimed,
        claimToken: 'stale-token',
        leaseExpiresAtUtc: DateTime.utc(2026, 1, 1, 9, 30),
      ));

      final claimRes = await store.claimDue(
        ClaimDueSchedulesRequest(
          ownerScopeId: ownerA,
          nowUtc: now,
          maxCount: 10,
          claimToken: 'my-token',
          leaseDuration: const Duration(minutes: 5),
        ),
      );

      final claimedIds = claimRes.claimed.map((s) => s.scheduleId).toList();
      expect(claimedIds, contains('sch-due'));
      expect(claimedIds, contains('sch-expired-lease'));
      expect(claimedIds, isNot(contains('sch-future')));
      expect(claimedIds, isNot(contains('sch-cancelled')));
      expect(claimedIds, isNot(contains('sch-active-lease')));
      expect(claimedIds.length, equals(2));

      for (final item in claimRes.claimed) {
        expect(item.claimToken, equals('my-token'));
        expect(item.status, equals(ScheduleStatus.claimed));
        expect(item.leaseExpiresAtUtc, equals(now.add(const Duration(minutes: 5))));
      }
    });
  });
}
