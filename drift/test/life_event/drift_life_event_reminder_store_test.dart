// ACT-12：提醒、调度与投递记录 Drift 持久化测试。
//
// 覆盖：
// - LEC-034/035：reminder/channel/aggregate/schedule/delivery 重开后经
//   loadOwnerState 全字段恢复，且引用完整；
// - LEC-036：aggregate contributors typed refs 全量往返且顺序稳定；
// - LEC-037/038：改时/撤销与 schedule 更新在同一事务（失败整体零写入）；
// - LEC-039：所有读写强制 ownerScope，recipient 不允许自动改为 Subject；
// - LEC-040：两个独立连接并发租约领取恰一成功；过期可重领且 scheduleId 去重。
//
// 纪律（主 Agent 裁决 Ruling 1）：提醒数据只经 DriftLifeEventReminderStore 的
// 公开方法读写，本文件不出现 db.select( / db.customSelect( / db.into( /
// db.update( / db.delete( 或任何表 getter。occurrence selection 与 pattern rule
// 是 ACT-10 的前置数据，经 DriftLifeEventUserRuleStore 播种。
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_core/test_support/life_event_reminder_store_contract_suite.dart';
import 'package:persistence_drift/life_event/drift_life_event_reminder_store.dart';
import 'package:persistence_drift/life_event/drift_life_event_user_rule_store.dart';
import 'package:persistence_drift/life_event/life_event_database.dart';

void main() {
  group('ACT-12A contract suite integration', () {
    final dbs = <LifeEventReminderStore, LifeEventDatabase>{};
    final dirs = <Directory>[];

    tearDownAll(() async {
      for (final d in dbs.values) {
        await d.close();
      }
      for (final dir in dirs) {
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    runLifeEventReminderStoreContractSuite(
      makeStore: () async {
        final d = await Directory.systemTemp.createTemp('drift-contract-');
        dirs.add(d);
        final file = File('${d.path}/contract.db');
        final database = LifeEventDatabase(LifeEventDatabase.openNativeFile(file));
        final s = DriftLifeEventReminderStore(database);
        dbs[s] = database;
        return s;
      },
      seedSelection: (s, ownerScopeId, selectionId, revision) async {
        final database = dbs[s]!;
        final rules = DriftLifeEventUserRuleStore(database);
        await rules.saveOccurrenceSelection(
          SaveOccurrenceSelectionRequest(
            ownerScopeId: ownerScopeId,
            selection: SavedOccurrenceSelection(
              selectionId: selectionId,
              ownerScopeId: ownerScopeId,
              revision: revision,
              sourceRef: const SourceRef(
                providerId: 'qizhengsiyu.life_events',
                sourceEventId: 'ev-1',
                eventRevision: '1',
              ),
              eventRevision: '1',
              annotationRef: null,
            ),
            expectedRevision: revision,
          ),
        );
      },
    );
  });
  group('ACT-12 drift reminder store', () {
    late Directory dir;
    late File dbFile;
    late LifeEventDatabase db;
    late DriftLifeEventReminderStore store;
    late DriftLifeEventUserRuleStore userRules;

    // 返工 F1：两个 scheduler 实例 = 两个独立连接打开同一个 SQLite 文件，
    // 必须经受支持的连接工厂打开——busy_timeout 必须在连接 setup 阶段就设好，
    // beforeOpen 对开库竞争太晚（drift 打开库时先读 `PRAGMA user_version`）。
    // 并发用例（见下）正是消费这个工厂的场景。
    LifeEventDatabase openDb() => LifeEventDatabase(LifeEventDatabase.openNativeFile(dbFile));

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('le-reminders-');
      dbFile = File('${dir.path}/reminders.db');
      db = openDb();
      store = DriftLifeEventReminderStore(db);
      userRules = DriftLifeEventUserRuleStore(db);
    });

    tearDown(() async {
      await db.close();
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });

    // -----------------------------------------------------------------
    // 前置数据：ACT-10 的 occurrence selection / pattern rule
    // -----------------------------------------------------------------

    Future<void> seedUserRules({String owner = 'owner-1'}) async {
      await userRules.saveOccurrenceSelection(
        SaveOccurrenceSelectionRequest(
          ownerScopeId: owner,
          selection: SavedOccurrenceSelection(
            selectionId: 'sel-$owner',
            ownerScopeId: owner,
            revision: 1,
            sourceRef: const SourceRef(
              providerId: 'qizhengsiyu.life_events',
              sourceEventId: 'ev-1',
              eventRevision: '1',
            ),
            eventRevision: '1',
            annotationRef: null,
          ),
          expectedRevision: 1,
        ),
      );
      await userRules.savePatternRule(
        SavePatternRuleRequest(
          ownerScopeId: owner,
          rule: SavedPatternRule(
            savedPatternId: 'pat-$owner',
            ownerScopeId: owner,
            revision: 1,
            providerId: 'bazi.life_events',
            eventTypeId: 'liunian_chong',
            patternSchemaVersion: 'life-event.v1',
            providerDescriptorVersion: '1.0.0',
            matcherSemanticVersion: 'bazi-chong.v1',
            normalizedPattern: const [],
            patternFingerprint: 'fp-$owner',
            targetSubjectIds: const [],
            targetProfileIds: const [],
            annotationRef: null,
            enabledForMatching: true,
          ),
          expectedRevision: 1,
        ),
      );
    }

    // -----------------------------------------------------------------
    // DTO 工厂
    // -----------------------------------------------------------------

    NotificationPriorityRef priority({String owner = 'owner-1'}) =>
        NotificationPriorityRef(
          ownerScopeId: owner,
          catalogId: 'catalog-priority',
          catalogRevision: 7,
          priorityId: 'high',
        );

    ReminderChannel channel({
      String id = 'chan-1',
      String owner = 'owner-1',
      int revision = 1,
      String name = '七政通道',
      bool enabled = true,
    }) =>
        ReminderChannel(
          channelId: id,
          ownerScopeId: owner,
          name: name,
          enabled: enabled,
          selectors: ReminderChannelSelectors(
            subjectIds: const ['subject-b', 'subject-a'],
            profileIds: const ['profile-1'],
            divinationSelectors: const [
              ReminderDivinationSelector(
                providerId: 'qizhengsiyu.life_events',
                divinationTypeKey: 'qi_zheng_si_yu',
                subDivinationTypeKey: null,
              ),
              ReminderDivinationSelector(
                providerId: null,
                divinationTypeKey: 'ba_zi',
                subDivinationTypeKey: 'liunian',
              ),
            ],
            eventTypeIds: const ['planet_gong_ingress'],
            directionIds: const ['dir-wealth', 'dir-health'],
            sourceSeverityRefs: const [
              SourceSeverityRef(
                providerId: 'qizhengsiyu.life_events',
                schemeId: 'severity',
                schemeVersion: '1.2',
                code: 'major',
              ),
            ],
            userImportanceRefs: [
              UserImportanceRef(
                ownerScopeId: owner,
                catalogId: 'catalog-importance',
                catalogRevision: 4,
                levelId: 'critical',
              ),
            ],
            notificationPriorityRefs: [priority(owner: owner)],
          ),
          deliveryPolicy: const ReminderDeliveryPolicy(
            leadTimes: [Duration(days: 1), Duration(hours: 2)],
            quietHours: '22:00-07:00',
            mergeWindow: Duration(hours: 6),
            deliveryMode: DeliveryMode.scheduledDigest,
            groupingMode: GroupingMode.bySubject,
          ),
          revision: revision,
        );

    ReminderDefinition definition({
      String id = 'rem-1',
      String owner = 'owner-1',
      ReminderSelectionRef? selectionRef,
      List<String> channelIds = const ['chan-1'],
      int revision = 1,
      bool enabled = true,
    }) =>
        ReminderDefinition(
          reminderId: id,
          ownerScopeId: owner,
          selectionRef: selectionRef ??
              OccurrenceSelectionRef(selectionId: 'sel-$owner', revision: 1),
          notificationTitleOverride: '标题覆盖',
          notificationBodyOverride: null,
          notificationPriorityRef: priority(owner: owner),
          channelIds: channelIds,
          leadTimes: const [Duration(days: 3), Duration(minutes: 30)],
          repeatPolicy: 'none',
          mergePolicy: 'allow-merge',
          enabled: enabled,
          revision: revision,
        );

    AggregateReminderContributor contributor({
      required String reminderId,
      String providerId = 'qizhengsiyu.life_events',
      SourceSeverityRef? severity,
      UserImportanceRef? importance,
      String? annotationRef,
    }) =>
        AggregateReminderContributor(
          providerId: providerId,
          divinationTypeKey: 'qi_zheng_si_yu',
          subDivinationTypeKey: 'liunian',
          profileId: 'profile-1',
          chartSnapshotId: 'snap-1',
          sourceEventId: 'ev-$reminderId',
          eventRevision: '3',
          eventTypeId: 'planet_gong_ingress',
          factSummary: '事实摘要 $reminderId',
          evidenceRef: 'evidence-$reminderId',
          sourceSeverityRef: severity,
          sourceVersions: const SourceVersions(
            providerVersion: '2.0.0',
            algorithmVersion: 'algo-1',
            ruleVersion: null,
            dataVersion: 'data-9',
          ),
          annotationRef: annotationRef,
          directionIds: const ['dir-wealth'],
          userImportanceRef: importance,
          reminderId: reminderId,
        );

    AggregateReminder aggregate({
      String id = 'agg-1',
      String owner = 'owner-1',
      String subjectId = 'subject-a',
      List<AggregateReminderContributor>? contributors,
    }) =>
        AggregateReminder(
          aggregateId: id,
          ownerScopeId: owner,
          subjectId: subjectId,
          displayTimeWindow: TimeRange(
            startInclusiveUtc: DateTime.utc(2026, 3, 1),
            endExclusiveUtc: DateTime.utc(2026, 3, 2),
          ),
          directionIds: const ['dir-wealth', 'dir-health'],
          effectiveNotificationPriorityRef: priority(owner: owner),
          displayTitle: '跨技法合并提醒',
          userInterpretation: '用户自己的解释',
          contributors: contributors ??
              [
                // 顺序刻意非字典序，用于证明 position 顺序稳定。
                contributor(
                  reminderId: 'rem-2',
                  providerId: 'bazi.life_events',
                ),
                contributor(
                  reminderId: 'rem-1',
                  severity: const SourceSeverityRef(
                    providerId: 'qizhengsiyu.life_events',
                    schemeId: 'severity',
                    schemeVersion: '1.2',
                    code: 'major',
                  ),
                  importance: UserImportanceRef(
                    ownerScopeId: owner,
                    catalogId: 'catalog-importance',
                    catalogRevision: 4,
                    levelId: 'critical',
                  ),
                  annotationRef: 'ann-1',
                ),
              ],
        );

    ScheduledNotification schedule({
      String id = 'sch-1',
      String owner = 'owner-1',
      String? reminderId = 'rem-1',
      String? aggregateId,
      DateTime? fireAtUtc,
      ScheduleStatus status = ScheduleStatus.scheduled,
      String? claimToken,
      DateTime? leaseExpiresAtUtc,
      String? sourceRevisionFingerprint,
    }) =>
        ScheduledNotification(
          scheduleId: id,
          ownerScopeId: owner,
          reminderId: reminderId,
          aggregateId: aggregateId,
          fireAtUtc: fireAtUtc ?? DateTime.utc(2026, 3, 1, 8),
          displayTimezoneId: 'Asia/Shanghai',
          channelRevision: 1,
          sourceRevisionFingerprint: sourceRevisionFingerprint ?? 'fp-sched-$id',
          status: status,
          claimToken: claimToken,
          leaseExpiresAtUtc: leaseExpiresAtUtc,
        );

    DeliveryRecord delivery({
      String id = 'del-1',
      String scheduleId = 'sch-1',
      String outcome = 'delivered',
      String? stableErrorCode,
    }) =>
        DeliveryRecord(
          deliveryId: id,
          scheduleId: scheduleId,
          attemptedAt: DateTime.utc(2026, 3, 1, 8, 1),
          outcome: outcome,
          stableErrorCode: stableErrorCode,
        );

    /// 播种一个 owner 的完整提醒中心状态。
    ///
    /// 各类主键是全局唯一的，owner-1 用裸 id，其余 owner 加 owner 后缀，
    /// 以便在同一个库里并存两个 owner 而不撞主键。
    Future<void> seedOwner(String owner) async {
      final p = owner == 'owner-1' ? '' : '-$owner';
      await seedUserRules(owner: owner);
      await store.saveChannel(channel(id: 'chan-1$p', owner: owner), 1);
      await store.saveDefinition(
        definition(id: 'rem-1$p', owner: owner, channelIds: ['chan-1$p']),
        1,
      );
      await store.saveDefinition(
        definition(
          id: 'rem-2$p',
          owner: owner,
          channelIds: ['chan-1$p'],
          selectionRef: PatternRuleRef(savedPatternId: 'pat-$owner', revision: 1),
        ),
        1,
      );
      await store.saveAggregate(
        aggregate(
          id: 'agg-1$p',
          owner: owner,
          contributors: [
            contributor(reminderId: 'rem-2$p', providerId: 'bazi.life_events'),
            contributor(
              reminderId: 'rem-1$p',
              severity: const SourceSeverityRef(
                providerId: 'qizhengsiyu.life_events',
                schemeId: 'severity',
                schemeVersion: '1.2',
                code: 'major',
              ),
              importance: UserImportanceRef(
                ownerScopeId: owner,
                catalogId: 'catalog-importance',
                catalogRevision: 4,
                levelId: 'critical',
              ),
              annotationRef: 'ann-1',
            ),
          ],
        ),
      );
      await store.saveSchedule(
        schedule(id: 'sch-1$p', owner: owner, reminderId: 'rem-1$p'),
      );
      await store.saveSchedule(
        schedule(
          id: 'sch-2$p',
          owner: owner,
          reminderId: null,
          aggregateId: 'agg-1$p',
          fireAtUtc: DateTime.utc(2026, 3, 1, 9),
        ),
      );
      await store.saveDelivery(delivery(id: 'del-1$p', scheduleId: 'sch-1$p'));
      await store.saveDelivery(
        delivery(
          id: 'del-2$p',
          scheduleId: 'sch-2$p',
          outcome: 'failed',
          stableErrorCode: 'platform_denied',
        ),
      );
    }

    // =================================================================
    // LEC-034 / LEC-035：重开恢复
    // =================================================================

    test('五类对象重开后经 loadOwnerState 全字段恢复（LEC-034/035）', () async {
      await seedOwner('owner-1');

      // 真实重开：关闭连接后对同一文件新建实例。
      await db.close();
      db = openDb();
      store = DriftLifeEventReminderStore(db);

      final state = await store.loadOwnerState('owner-1');

      expect(state.definitions.map((d) => d.reminderId), ['rem-1', 'rem-2']);
      expectDefinition(state.definitions[0], definition(id: 'rem-1'));
      expectDefinition(
        state.definitions[1],
        definition(
          id: 'rem-2',
          selectionRef:
              const PatternRuleRef(savedPatternId: 'pat-owner-1', revision: 1),
        ),
      );

      expect(state.channels.map((c) => c.channelId), ['chan-1']);
      expectChannel(state.channels.single, channel());

      expect(state.aggregates.map((a) => a.aggregateId), ['agg-1']);
      expectAggregate(state.aggregates.single, aggregate());

      expect(state.schedules.map((s) => s.scheduleId), ['sch-1', 'sch-2']);
      expectSchedule(state.schedules[0], schedule(id: 'sch-1'));
      expectSchedule(
        state.schedules[1],
        schedule(
          id: 'sch-2',
          reminderId: null,
          aggregateId: 'agg-1',
          fireAtUtc: DateTime.utc(2026, 3, 1, 9),
        ),
      );

      // 只有 outcome == delivered 的 schedule 进入去重键集合。
      expect(state.deliveredScheduleIds, ['sch-1']);
    });

    // =================================================================
    // LEC-036：contributors typed refs 往返与顺序
    // =================================================================

    test('aggregate contributors typed refs 全量往返且顺序稳定（LEC-036）', () async {
      await seedUserRules();
      await store.saveChannel(channel(), 1);
      await store.saveDefinition(definition(id: 'rem-1'), 1);
      await store.saveDefinition(
        definition(
          id: 'rem-2',
          selectionRef:
              const PatternRuleRef(savedPatternId: 'pat-owner-1', revision: 1),
        ),
        1,
      );
      await store.saveDefinition(definition(id: 'rem-3'), 1);

      final expected = aggregate(
        contributors: [
          contributor(reminderId: 'rem-3'),
          contributor(reminderId: 'rem-1', providerId: 'bazi.life_events'),
          contributor(reminderId: 'rem-2'),
        ],
      );
      await store.saveAggregate(expected);

      await db.close();
      db = openDb();
      store = DriftLifeEventReminderStore(db);

      final loaded = (await store.loadOwnerState('owner-1')).aggregates.single;
      expect(
        loaded.contributors.map((c) => c.reminderId),
        ['rem-3', 'rem-1', 'rem-2'],
        reason: 'contributors 顺序必须与写入顺序一致，不得被排序或去重打乱',
      );
      expectAggregate(loaded, expected);

      // 重复保存同 aggregateId 整体替换：旧 contributors 不得残留。
      final replaced = aggregate(
        contributors: [contributor(reminderId: 'rem-2')],
      );
      await store.saveAggregate(replaced);
      final afterReplace =
          (await store.loadOwnerState('owner-1')).aggregates.single;
      expect(afterReplace.contributors.map((c) => c.reminderId), ['rem-2']);
      expectAggregate(afterReplace, replaced);
    });

    // =================================================================
    // LEC-037 / LEC-038：单次端口调用 = 覆盖全部行的事务
    // =================================================================

    test('saveAggregate 单事务：contributor 引用悬空 → 主行与子行整体零写入', () async {
      await seedOwner('owner-1');
      final before = await store.loadOwnerState('owner-1');

      // 故障注入：contributor 引用不存在的 reminderId。
      final res1 = await store.saveAggregate(
        aggregate(
          id: 'agg-2',
          contributors: [
            contributor(reminderId: 'rem-1'),
            contributor(reminderId: 'rem-missing'),
          ],
        ),
      );
      expect(res1.outcome, SaveReminderOutcome.ownerScopeMismatch);

      final after = await store.loadOwnerState('owner-1');
      expect(after.aggregates.map((a) => a.aggregateId), ['agg-1'],
          reason: 'agg-2 主行必须随事务回滚一起消失');
      expectOwnerStateEquals(after, before);

      // 覆盖既有 aggregate 失败时，旧版本必须原样保留（删子行也要回滚）。
      final res2 = await store.saveAggregate(
        aggregate(
          contributors: [contributor(reminderId: 'rem-missing')],
        ),
      );
      expect(res2.outcome, SaveReminderOutcome.ownerScopeMismatch);
      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);
    });

    test('saveDefinition 单事务：channelIds 悬空 → 旧定义原样保留', () async {
      await seedOwner('owner-1');
      final before = await store.loadOwnerState('owner-1');

      final res = await store.saveDefinition(
        definition(id: 'rem-1', channelIds: const ['chan-1', 'chan-missing'], revision: 2),
        1,
      );
      expect(res.outcome, SaveReminderOutcome.ownerScopeMismatch);

      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);
    });

    test('saveSchedule 失败不破坏既有行（改时/撤销路径）', () async {
      await seedOwner('owner-1');
      final before = await store.loadOwnerState('owner-1');

      // 撤销：把既有 schedule 改为 cancelled，但 target 非法 → 整体拒绝。
      final res = await store.saveSchedule(
        schedule(
          id: 'sch-1',
          reminderId: 'rem-1',
          aggregateId: 'agg-1',
          status: ScheduleStatus.cancelled,
        ),
      );
      expect(res.outcome, SaveReminderOutcome.invalidScheduleTarget);
      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);

      // 合法撤销：单行 upsert 生效。
      await store.saveSchedule(
        schedule(id: 'sch-1', status: ScheduleStatus.cancelled),
      );
      final after = await store.loadOwnerState('owner-1');
      expect(after.schedules[0].status, ScheduleStatus.cancelled);
      // 改时：fireAt 变化在同一行上原子更新。
      await store.saveSchedule(
        schedule(id: 'sch-1', fireAtUtc: DateTime.utc(2026, 4, 1, 8)),
      );
      final retimed = await store.loadOwnerState('owner-1');
      expect(retimed.schedules[0].fireAtUtc, DateTime.utc(2026, 4, 1, 8));
      expect(retimed.schedules[0].status, ScheduleStatus.scheduled);
      expect(retimed.schedules.length, 2, reason: 'upsert 不得产生重复行');
    });

    // =================================================================
    // LEC-039：ownerScope 强制
    // =================================================================

    test('ownerScope 强制隔离；recipient 不允许自动改为 Subject（LEC-039）', () async {
      await seedOwner('owner-1');
      await seedOwner('owner-2');

      final s1 = await store.loadOwnerState('owner-1');
      final s2 = await store.loadOwnerState('owner-2');
      for (final d in s1.definitions) {
        expect(d.ownerScopeId, 'owner-1');
      }
      for (final c in s1.channels) {
        expect(c.ownerScopeId, 'owner-1');
      }
      for (final a in s1.aggregates) {
        expect(a.ownerScopeId, 'owner-1');
      }
      for (final s in s1.schedules) {
        expect(s.ownerScopeId, 'owner-1');
      }
      expect(s2.definitions.every((d) => d.ownerScopeId == 'owner-2'), isTrue);
      expect(s1.definitions.length, 2);
      expect(s2.definitions.length, 2);

      // recipient 恒为 ownerScope：subjectId 与另一个 owner 同名也不得串台。
      await store.saveAggregate(
        aggregate(id: 'agg-subject', subjectId: 'owner-2'),
      );
      final s2After = await store.loadOwnerState('owner-2');
      expect(
        s2After.aggregates.map((a) => a.aggregateId),
        ['agg-1-owner-2'],
        reason: 'owner-1 的 aggregate（subjectId=owner-2）不得出现在 owner-2 名下',
      );

      // 跨 owner 引用一律拒绝：owner-2 的 definition 引用 owner-1 的通道。
      final res1 = await store.saveDefinition(
        definition(id: 'rem-x', owner: 'owner-2', channelIds: const ['chan-1']),
        1,
      );
      expect(res1.outcome, SaveReminderOutcome.ownerScopeMismatch);

      // 跨 owner 的 selectionRef 同样拒绝。
      final res2 = await store.saveDefinition(
        definition(
          id: 'rem-y',
          owner: 'owner-2',
          channelIds: const [],
          selectionRef:
              const OccurrenceSelectionRef(selectionId: 'sel-owner-1', revision: 1),
        ),
        1,
      );
      expect(res2.outcome, SaveReminderOutcome.danglingSelectionRef);

      // 跨 owner 的 schedule target 拒绝。
      final res3 = await store.saveSchedule(
        schedule(id: 'sch-x', owner: 'owner-2', reminderId: 'rem-1'),
      );
      expect(res3.outcome, SaveReminderOutcome.ownerScopeMismatch);
      // owner-2 的状态未被上述失败污染。
      expectOwnerStateEquals(await store.loadOwnerState('owner-2'), s2);
    });

    // =================================================================
    // CAS：expectedRevision 语义
    // =================================================================

    test('expectedRevision：重放同 revision 与错配都被拒且零写入，合法递增接受', () async {
      await seedUserRules();

      // 无同 id 行 → 接受（不看 expectedRevision）。
      final c1 = await store.saveChannel(channel(revision: 1), 999);
      expect(c1.outcome, SaveReminderOutcome.saved);
      expect(c1.id, 'chan-1');

      // 合法 CAS：expectedRevision == stored.revision (1) 且 value.revision == stored + 1 (2)。
      final c2 = await store.saveChannel(channel(revision: 2, name: '改名 A'), 1);
      expect(c2.outcome, SaveReminderOutcome.saved);
      expect(c2.id, 'chan-1');

      // 重放同 revision（value.revision 不大于 stored.revision）→ 拒绝。
      final c3 = await store.saveChannel(channel(revision: 2, name: '重放'), 2);
      expect(c3.outcome, SaveReminderOutcome.revisionConflict);

      // expectedRevision 错配 → 拒绝。
      final c4 = await store.saveChannel(channel(revision: 3, name: '错配'), 9);
      expect(c4.outcome, SaveReminderOutcome.revisionConflict);

      final state = await store.loadOwnerState('owner-1');
      expect(state.channels.single.revision, 2);
      expect(state.channels.single.name, '改名 A', reason: '冲突必须零写入');

      // definition 走同一套规则。
      final d1 = await store.saveDefinition(definition(revision: 1), 1);
      expect(d1.outcome, SaveReminderOutcome.saved);

      final d2 = await store.saveDefinition(definition(revision: 1, enabled: false), 1);
      expect(d2.outcome, SaveReminderOutcome.revisionConflict);

      final d3 = await store.saveDefinition(definition(revision: 2, enabled: false), 5);
      expect(d3.outcome, SaveReminderOutcome.revisionConflict);

      expect(
        (await store.loadOwnerState('owner-1')).definitions.single.enabled,
        isTrue,
      );
      // 关闭提醒（revision+1，expectedRevision = 旧 revision）被接受。
      final d4 = await store.saveDefinition(definition(revision: 2, enabled: false), 1);
      expect(d4.outcome, SaveReminderOutcome.saved);
      final disabled = await store.loadOwnerState('owner-1');
      expect(disabled.definitions.single.enabled, isFalse);
      expect(disabled.definitions.single.revision, 2);
    });

    // =================================================================
    // Ruling 6：引用完整性反例（每条规则至少一条）
    // =================================================================

    test('引用完整性反例：五类悬空引用全部拒绝且零写入（LEC-034）', () async {
      await seedOwner('owner-1');
      final before = await store.loadOwnerState('owner-1');

      Future<void> expectRejected(
        Future<SaveReminderResult> action,
        SaveReminderOutcome outcome,
      ) async {
        final res = await action;
        expect(res.outcome, outcome);
        expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);
      }

      // 1. OccurrenceSelectionRef 悬空。
      await expectRejected(
        store.saveDefinition(
          definition(
            id: 'rem-bad-sel',
            selectionRef:
                const OccurrenceSelectionRef(selectionId: 'sel-missing', revision: 1),
          ),
          1,
        ),
        SaveReminderOutcome.danglingSelectionRef,
      );

      // 2. PatternRuleRef 悬空。
      await expectRejected(
        store.saveDefinition(
          definition(
            id: 'rem-bad-pat',
            selectionRef:
                const PatternRuleRef(savedPatternId: 'pat-missing', revision: 1),
          ),
          1,
        ),
        SaveReminderOutcome.danglingSelectionRef,
      );

      // 3. channelIds 悬空。
      await expectRejected(
        store.saveDefinition(
          definition(id: 'rem-bad-chan', channelIds: const ['chan-missing']),
          1,
        ),
        SaveReminderOutcome.ownerScopeMismatch,
      );

      // 4. schedule target 两者同空 / 同非空。
      await expectRejected(
        store.saveSchedule(schedule(id: 'sch-null', reminderId: null)),
        SaveReminderOutcome.invalidScheduleTarget,
      );
      await expectRejected(
        store.saveSchedule(
          schedule(id: 'sch-both', reminderId: 'rem-1', aggregateId: 'agg-1'),
        ),
        SaveReminderOutcome.invalidScheduleTarget,
      );
      // 5. schedule 指向不存在的 reminder / aggregate。
      await expectRejected(
        store.saveSchedule(schedule(id: 'sch-miss', reminderId: 'rem-missing')),
        SaveReminderOutcome.ownerScopeMismatch,
      );
      await expectRejected(
        store.saveSchedule(
          schedule(id: 'sch-miss2', reminderId: null, aggregateId: 'agg-missing'),
        ),
        SaveReminderOutcome.ownerScopeMismatch,
      );

      // 6. delivery 指向不存在的 schedule。
      await expectRejected(
        store.saveDelivery(delivery(id: 'del-bad', scheduleId: 'sch-missing')),
        SaveReminderOutcome.invalidScheduleTarget,
      );
    });

    // =================================================================
    // LEC-040：租约领取
    // =================================================================

    test('两 scheduler 并发租约领取恰一成功（LEC-040）', () async {
      await seedUserRules();
      await store.saveChannel(channel(), 1);
      await store.saveDefinition(definition(), 1);
      await store.saveSchedule(
        schedule(id: 'sch-due', fireAtUtc: DateTime.utc(2026, 3, 1, 8)),
      );
      await db.close();

      final dbA = openDb();
      final dbB = openDb();
      final storeA = DriftLifeEventReminderStore(dbA);
      final storeB = DriftLifeEventReminderStore(dbB);
      final now = DateTime.utc(2026, 3, 1, 9);

      try {
        final results = await Future.wait([
          storeA.claimDue(
            ClaimDueSchedulesRequest(
              ownerScopeId: 'owner-1',
              nowUtc: now,
              maxCount: 10,
              claimToken: 'token-a',
              leaseDuration: const Duration(minutes: 5),
            ),
          ),
          storeB.claimDue(
            ClaimDueSchedulesRequest(
              ownerScopeId: 'owner-1',
              nowUtc: now,
              maxCount: 10,
              claimToken: 'token-b',
              leaseDuration: const Duration(minutes: 5),
            ),
          ),
        ]);

        final winners = results.where((r) => r.claimed.isNotEmpty).toList();
        expect(winners.length, 1, reason: '同一条 due schedule 只能被恰好一个 token 领取');
        final winner = winners.single;
        expect(winner.claimed.single.scheduleId, 'sch-due');
        expect(winner.claimed.single.status, ScheduleStatus.claimed);
        expect(winner.claimed.single.claimToken, winner.claimToken);
        expect(winner.claimedAt, now);
        expect(
          winner.claimed.single.leaseExpiresAtUtc,
          now.add(const Duration(minutes: 5)),
        );

        // 库中持久化的 claimToken 必须是胜者的。
        final persisted =
            (await storeA.loadOwnerState('owner-1')).schedules.single;
        expect(persisted.status, ScheduleStatus.claimed);
        expect(persisted.claimToken, winner.claimToken);
        expect(
          persisted.leaseExpiresAtUtc,
          now.add(const Duration(minutes: 5)),
        );
      } finally {
        await dbA.close();
        await dbB.close();
      }
      db = openDb();
      store = DriftLifeEventReminderStore(db);
    });

    test('租约过期可重领且 scheduleId 去重（LEC-040）', () async {
      await seedUserRules();
      await store.saveChannel(channel(), 1);
      await store.saveDefinition(definition(), 1);
      await store.saveSchedule(
        schedule(id: 'sch-due', fireAtUtc: DateTime.utc(2026, 3, 1, 8)),
      );

      final t0 = DateTime.utc(2026, 3, 1, 9);
      final first = await store.claimDue(
        ClaimDueSchedulesRequest(
          ownerScopeId: 'owner-1',
          nowUtc: t0,
          maxCount: 10,
          claimToken: 'token-a',
          leaseDuration: const Duration(minutes: 5),
        ),
      );
      expect(first.claimed.single.scheduleId, 'sch-due');

      // 租约未过期：其他 token 领不到。
      final blocked = await store.claimDue(
        ClaimDueSchedulesRequest(
          ownerScopeId: 'owner-1',
          nowUtc: t0.add(const Duration(minutes: 1)),
          maxCount: 10,
          claimToken: 'token-b',
          leaseDuration: const Duration(minutes: 5),
        ),
      );
      expect(blocked.claimed, isEmpty);

      // 租约过期：可被另一 token 重领，且仍是同一个 scheduleId（去重键）。
      final reclaimed = await store.claimDue(
        ClaimDueSchedulesRequest(
          ownerScopeId: 'owner-1',
          nowUtc: t0.add(const Duration(minutes: 6)),
          maxCount: 10,
          claimToken: 'token-b',
          leaseDuration: const Duration(minutes: 5),
        ),
      );
      expect(reclaimed.claimed.map((s) => s.scheduleId), ['sch-due']);
      expect(reclaimed.claimed.single.claimToken, 'token-b');
      expect(
        reclaimed.claimed.map((s) => s.scheduleId).toSet().length,
        reclaimed.claimed.length,
        reason: '返回结果内 scheduleId 不得重复',
      );
      final persisted = (await store.loadOwnerState('owner-1')).schedules.single;
      expect(persisted.claimToken, 'token-b');
    });

    test('终态不可领取；未到期不可领取；按 fireAt 升序取 maxCount', () async {
      await seedUserRules();
      await store.saveChannel(channel(), 1);
      await store.saveDefinition(definition(), 1);

      for (final entry in {
        'sch-delivered': ScheduleStatus.delivered,
        'sch-cancelled': ScheduleStatus.cancelled,
        'sch-failed': ScheduleStatus.failed,
      }.entries) {
        await store.saveSchedule(
          schedule(
            id: entry.key,
            status: entry.value,
            fireAtUtc: DateTime.utc(2026, 3, 1, 7),
          ),
        );
      }
      await store.saveSchedule(
        schedule(id: 'sch-c', fireAtUtc: DateTime.utc(2026, 3, 1, 8, 30)),
      );
      await store.saveSchedule(
        schedule(id: 'sch-a', fireAtUtc: DateTime.utc(2026, 3, 1, 8, 10)),
      );
      await store.saveSchedule(
        schedule(id: 'sch-b', fireAtUtc: DateTime.utc(2026, 3, 1, 8, 20)),
      );
      await store.saveSchedule(
        schedule(id: 'sch-future', fireAtUtc: DateTime.utc(2026, 3, 1, 23)),
      );

      final claim = await store.claimDue(
        ClaimDueSchedulesRequest(
          ownerScopeId: 'owner-1',
          nowUtc: DateTime.utc(2026, 3, 1, 9),
          maxCount: 2,
          claimToken: 'token-a',
          leaseDuration: const Duration(minutes: 5),
        ),
      );
      expect(claim.claimed.map((s) => s.scheduleId), ['sch-a', 'sch-b']);

      // 其他 owner 领不到本 owner 的任务。
      final other = await store.claimDue(
        ClaimDueSchedulesRequest(
          ownerScopeId: 'owner-2',
          nowUtc: DateTime.utc(2026, 3, 1, 9),
          maxCount: 10,
          claimToken: 'token-z',
          leaseDuration: const Duration(minutes: 5),
        ),
      );
      expect(other.claimed, isEmpty);

      final state = await store.loadOwnerState('owner-1');
      for (final id in ['sch-delivered', 'sch-cancelled', 'sch-failed']) {
        final row = state.schedules.firstWhere((s) => s.scheduleId == id);
        expect(row.claimToken, isNull, reason: '$id 是终态，不得被领取');
        expect(row.status, isNot(ScheduleStatus.claimed));
      }
      expect(
        state.schedules.firstWhere((s) => s.scheduleId == 'sch-future').status,
        ScheduleStatus.scheduled,
      );
    });

    // =================================================================
    // 返工 G1（F2 重写）：claimDue 返回值不得是 CAS 之前的候选快照
    // =================================================================
    //
    // 上一轮的版本依赖"同一连接上先发 claimDue 再发 saveSchedule 就一定按
    // FIFO 执行"这一假设，复审实测证明不成立（--plain-name "F2" 单独连跑
    // 5 次全部失败、整文件连跑 8 次失败 2 次）。本轮改用主 Agent 裁决
    // Ruling 13 的确定性测试接缝：DriftLifeEventReminderStore.onBeforeClaimCas
    // 钩子，在候选行进入 CAS 写事务之前、由测试同步注入另一连接的改写，
    // 不依赖任何调度器/isolate 时序假设。

    test(
        'claimDue 返回的 DTO 反映 CAS 之后的最新持久化状态，不是候选读取时的旧快照（G1/F2）',
        () async {
      await seedUserRules();
      await store.saveChannel(channel(), 1);
      await store.saveDefinition(definition(), 1);
      await store.saveSchedule(
        schedule(
          id: 'sch-race',
          fireAtUtc: DateTime.utc(2026, 3, 1, 8),
          sourceRevisionFingerprint: 'fp-old',
        ),
      );
      await db.close();

      // 两个独立连接打开同一个文件：storeA 领取，storeB 在钩子里代表"另一
      // 连接在 CAS 之前改写了该行"。
      final dbA = openDb();
      final dbB = openDb();
      final storeA = DriftLifeEventReminderStore(dbA);
      final storeB = DriftLifeEventReminderStore(dbB);
      var hookCallCount = 0;

      try {
        storeA.onBeforeClaimCas = (scheduleId) async {
          hookCallCount++;
          await storeB.saveSchedule(
            schedule(
              id: scheduleId,
              fireAtUtc: DateTime.utc(2026, 3, 1, 10),
              sourceRevisionFingerprint: 'fp-new',
            ),
          );
        };

        final result = await storeA.claimDue(
          ClaimDueSchedulesRequest(
            ownerScopeId: 'owner-1',
            nowUtc: DateTime.utc(2026, 3, 1, 9),
            maxCount: 1,
            claimToken: 'token-a',
            leaseDuration: const Duration(minutes: 5),
          ),
        );

        expect(hookCallCount, 1, reason: '钩子必须恰好在该候选的 CAS 前调用一次');
        expect(result.claimed, hasLength(1));
        final claimed = result.claimed.single;
        expect(claimed.scheduleId, 'sch-race');
        expect(
          claimed.fireAtUtc,
          DateTime.utc(2026, 3, 1, 10),
          reason: '领到的 DTO 必须是 CAS 之后重读的最新值，不能是 CAS 之前的候选快照',
        );
        expect(claimed.sourceRevisionFingerprint, 'fp-new');
        expect(claimed.status, ScheduleStatus.claimed);
        expect(claimed.claimToken, 'token-a');

        // 领到的 DTO 必须与重新 loadOwnerState 读回的同一行逐字段一致。
        final persisted =
            (await storeA.loadOwnerState('owner-1')).schedules.single;
        expectSchedule(claimed, persisted);
      } finally {
        storeA.onBeforeClaimCas = null;
        await dbA.close();
        await dbB.close();
      }
      db = openDb();
      store = DriftLifeEventReminderStore(db);
    });

    // =================================================================
    // 返工 F3（Ruling 9）：saveDelivery 不得静默改写审计记录
    // =================================================================

    test('saveDelivery 同 deliveryId 重放：字段完全一致时幂等无操作（F3）', () async {
      await seedOwner('owner-1');
      final before = await store.loadOwnerState('owner-1');

      final result = await store.saveDelivery(delivery(id: 'del-1'));
      expect(result.outcome, SaveReminderOutcome.saved);
      expect(result.id, 'del-1');

      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);
    });

    test('saveDelivery 同 deliveryId 但字段不一致：拒绝且零写入（F3）', () async {
      await seedOwner('owner-1');
      final before = await store.loadOwnerState('owner-1');
      expect(before.deliveredScheduleIds, ['sch-1']);

      // del-1 原本是 sch-1 的 delivered 记录；重放同 deliveryId 但 outcome
      // 改成 failed（试图把已投递的审计记录悄悄改写成失败）。
      final res = await store.saveDelivery(
        delivery(id: 'del-1', outcome: 'failed', stableErrorCode: 'x'),
      );
      expect(res.outcome, SaveReminderOutcome.revisionConflict);

      final after = await store.loadOwnerState('owner-1');
      expectOwnerStateEquals(after, before);
      expect(
        after.deliveredScheduleIds,
        ['sch-1'],
        reason: 'failed 不得覆盖已存在的 delivered 记录，去重键不得凭空消失',
      );
    });

    // =================================================================
    // 返工 F5(a)：claimed 且租约/claimToken 缺失的组合必须被拒绝
    // =================================================================

    test('saveSchedule 拒绝 status=claimed 但 leaseExpiresAtUtc 或 claimToken 为 null（F5a）',
        () async {
      await seedOwner('owner-1');
      final before = await store.loadOwnerState('owner-1');

      // leaseExpiresAtUtc 缺失。
      final res1 = await store.saveSchedule(
        schedule(
          id: 'sch-1',
          status: ScheduleStatus.claimed,
          claimToken: 'tok',
          leaseExpiresAtUtc: null,
        ),
      );
      expect(res1.outcome, SaveReminderOutcome.invalidScheduleTarget);
      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);

      // claimToken 缺失。
      final res2 = await store.saveSchedule(
        schedule(
          id: 'sch-1',
          status: ScheduleStatus.claimed,
          claimToken: null,
          leaseExpiresAtUtc: DateTime.utc(2026, 3, 1, 9),
        ),
      );
      expect(res2.outcome, SaveReminderOutcome.invalidScheduleTarget);
      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);

      // 合法组合（两者都非空）必须被接受。
      await store.saveSchedule(
        schedule(
          id: 'sch-1',
          status: ScheduleStatus.claimed,
          claimToken: 'tok',
          leaseExpiresAtUtc: DateTime.utc(2026, 3, 1, 9),
        ),
      );
      final after = await store.loadOwnerState('owner-1');
      expect(after.schedules[0].status, ScheduleStatus.claimed);
      expect(after.schedules[0].claimToken, 'tok');
    });

    test('returns rejected when expectedRevision mismatch (store unmodified)', () async {
      await seedUserRules();
      final r1 = await store.saveChannel(channel(id: 'chan-cas', revision: 1), 1);
      expect(r1.outcome, SaveReminderOutcome.saved);
      final before = await store.loadOwnerState('owner-1');

      final res = await store.saveChannel(
        channel(id: 'chan-cas', revision: 2),
        99,
      );
      expect(res.outcome, SaveReminderOutcome.revisionConflict);
      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);
    });

    test('returns rejected when occurrence selection ref missing (store unmodified)', () async {
      final before = await store.loadOwnerState('owner-1');

      final res = await store.saveDefinition(
        definition(
          id: 'rem-bad-sel',
          channelIds: const [],
          selectionRef: const OccurrenceSelectionRef(selectionId: 'missing-sel', revision: 1),
        ),
        1,
      );
      expect(res.outcome, SaveReminderOutcome.danglingSelectionRef);
      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);
    });

    test('returns rejected when selection revision mismatch (store unmodified)', () async {
      await seedUserRules();
      final before = await store.loadOwnerState('owner-1');

      final res = await store.saveDefinition(
        definition(
          id: 'rem-bad-rev',
          channelIds: const [],
          selectionRef: const OccurrenceSelectionRef(selectionId: 'sel-owner-1', revision: 99),
        ),
        1,
      );
      expect(res.outcome, SaveReminderOutcome.danglingSelectionRef);
      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);
    });

    test('returns rejected when parent reminder missing on schedule save (store unmodified)', () async {
      final before = await store.loadOwnerState('owner-1');

      final res = await store.saveSchedule(
        schedule(
          id: 'sch-bad-parent',
          reminderId: 'rem-missing-parent',
        ),
      );
      expect(res.outcome, SaveReminderOutcome.ownerScopeMismatch);
      expectOwnerStateEquals(await store.loadOwnerState('owner-1'), before);
    });
  });
}

// ---------------------------------------------------------------------------
// 逐字段比较辅助（DTO 未实现 ==，reopen 断言必须逐字段比较）
// ---------------------------------------------------------------------------

void expectSelectionRef(ReminderSelectionRef actual, ReminderSelectionRef expected) {
  switch (expected) {
    case OccurrenceSelectionRef():
      expect(actual, isA<OccurrenceSelectionRef>());
      final a = actual as OccurrenceSelectionRef;
      expect(a.selectionId, expected.selectionId);
      expect(a.revision, expected.revision);
    case PatternRuleRef():
      expect(actual, isA<PatternRuleRef>());
      final a = actual as PatternRuleRef;
      expect(a.savedPatternId, expected.savedPatternId);
      expect(a.revision, expected.revision);
  }
}

void expectPriority(NotificationPriorityRef a, NotificationPriorityRef b) {
  expect(a.ownerScopeId, b.ownerScopeId);
  expect(a.catalogId, b.catalogId);
  expect(a.catalogRevision, b.catalogRevision);
  expect(a.priorityId, b.priorityId);
}

void expectImportance(UserImportanceRef? a, UserImportanceRef? b) {
  if (b == null) {
    expect(a, isNull);
    return;
  }
  expect(a, isNotNull);
  expect(a!.ownerScopeId, b.ownerScopeId);
  expect(a.catalogId, b.catalogId);
  expect(a.catalogRevision, b.catalogRevision);
  expect(a.levelId, b.levelId);
}

void expectSeverity(SourceSeverityRef? a, SourceSeverityRef? b) {
  if (b == null) {
    expect(a, isNull);
    return;
  }
  expect(a, isNotNull);
  expect(a!.providerId, b.providerId);
  expect(a.schemeId, b.schemeId);
  expect(a.schemeVersion, b.schemeVersion);
  expect(a.code, b.code);
}

void expectDefinition(ReminderDefinition a, ReminderDefinition b) {
  expect(a.reminderId, b.reminderId);
  expect(a.ownerScopeId, b.ownerScopeId);
  expectSelectionRef(a.selectionRef, b.selectionRef);
  expect(a.notificationTitleOverride, b.notificationTitleOverride);
  expect(a.notificationBodyOverride, b.notificationBodyOverride);
  expectPriority(a.notificationPriorityRef, b.notificationPriorityRef);
  expect(a.channelIds, b.channelIds);
  expect(a.leadTimes, b.leadTimes);
  expect(a.repeatPolicy, b.repeatPolicy);
  expect(a.mergePolicy, b.mergePolicy);
  expect(a.enabled, b.enabled);
  expect(a.revision, b.revision);
}

void expectChannel(ReminderChannel a, ReminderChannel b) {
  expect(a.channelId, b.channelId);
  expect(a.ownerScopeId, b.ownerScopeId);
  expect(a.name, b.name);
  expect(a.enabled, b.enabled);
  expect(a.revision, b.revision);

  final sa = a.selectors;
  final sb = b.selectors;
  expect(sa.subjectIds, sb.subjectIds);
  expect(sa.profileIds, sb.profileIds);
  expect(sa.divinationSelectors.length, sb.divinationSelectors.length);
  for (var i = 0; i < sb.divinationSelectors.length; i++) {
    expect(sa.divinationSelectors[i].providerId, sb.divinationSelectors[i].providerId);
    expect(sa.divinationSelectors[i].divinationTypeKey,
        sb.divinationSelectors[i].divinationTypeKey);
    expect(sa.divinationSelectors[i].subDivinationTypeKey,
        sb.divinationSelectors[i].subDivinationTypeKey);
  }
  expect(sa.eventTypeIds, sb.eventTypeIds);
  expect(sa.directionIds, sb.directionIds);
  expect(sa.sourceSeverityRefs.length, sb.sourceSeverityRefs.length);
  for (var i = 0; i < sb.sourceSeverityRefs.length; i++) {
    expectSeverity(sa.sourceSeverityRefs[i], sb.sourceSeverityRefs[i]);
  }
  expect(sa.userImportanceRefs.length, sb.userImportanceRefs.length);
  for (var i = 0; i < sb.userImportanceRefs.length; i++) {
    expectImportance(sa.userImportanceRefs[i], sb.userImportanceRefs[i]);
  }
  expect(sa.notificationPriorityRefs.length, sb.notificationPriorityRefs.length);
  for (var i = 0; i < sb.notificationPriorityRefs.length; i++) {
    expectPriority(sa.notificationPriorityRefs[i], sb.notificationPriorityRefs[i]);
  }

  final pa = a.deliveryPolicy;
  final pb = b.deliveryPolicy;
  expect(pa.leadTimes, pb.leadTimes);
  expect(pa.quietHours, pb.quietHours);
  expect(pa.mergeWindow, pb.mergeWindow);
  expect(pa.deliveryMode, pb.deliveryMode);
  expect(pa.groupingMode, pb.groupingMode);
}

void expectContributor(
  AggregateReminderContributor a,
  AggregateReminderContributor b,
) {
  expect(a.providerId, b.providerId);
  expect(a.divinationTypeKey, b.divinationTypeKey);
  expect(a.subDivinationTypeKey, b.subDivinationTypeKey);
  expect(a.profileId, b.profileId);
  expect(a.chartSnapshotId, b.chartSnapshotId);
  expect(a.sourceEventId, b.sourceEventId);
  expect(a.eventRevision, b.eventRevision);
  expect(a.eventTypeId, b.eventTypeId);
  expect(a.factSummary, b.factSummary);
  expect(a.evidenceRef, b.evidenceRef);
  expectSeverity(a.sourceSeverityRef, b.sourceSeverityRef);
  expect(a.sourceVersions.providerVersion, b.sourceVersions.providerVersion);
  expect(a.sourceVersions.algorithmVersion, b.sourceVersions.algorithmVersion);
  expect(a.sourceVersions.ruleVersion, b.sourceVersions.ruleVersion);
  expect(a.sourceVersions.dataVersion, b.sourceVersions.dataVersion);
  expect(a.annotationRef, b.annotationRef);
  expect(a.directionIds, b.directionIds);
  expectImportance(a.userImportanceRef, b.userImportanceRef);
  expect(a.reminderId, b.reminderId);
}

void expectAggregate(AggregateReminder a, AggregateReminder b) {
  expect(a.aggregateId, b.aggregateId);
  expect(a.ownerScopeId, b.ownerScopeId);
  expect(a.subjectId, b.subjectId);
  expect(a.displayTimeWindow.startInclusiveUtc, b.displayTimeWindow.startInclusiveUtc);
  expect(a.displayTimeWindow.endExclusiveUtc, b.displayTimeWindow.endExclusiveUtc);
  expect(a.directionIds, b.directionIds);
  expectPriority(
    a.effectiveNotificationPriorityRef,
    b.effectiveNotificationPriorityRef,
  );
  expect(a.displayTitle, b.displayTitle);
  expect(a.userInterpretation, b.userInterpretation);
  expect(a.contributors.length, b.contributors.length);
  for (var i = 0; i < b.contributors.length; i++) {
    expectContributor(a.contributors[i], b.contributors[i]);
  }
}

void expectSchedule(ScheduledNotification a, ScheduledNotification b) {
  expect(a.scheduleId, b.scheduleId);
  expect(a.ownerScopeId, b.ownerScopeId);
  expect(a.reminderId, b.reminderId);
  expect(a.aggregateId, b.aggregateId);
  expect(a.fireAtUtc, b.fireAtUtc);
  expect(a.fireAtUtc.isUtc, isTrue);
  expect(a.displayTimezoneId, b.displayTimezoneId);
  expect(a.channelRevision, b.channelRevision);
  expect(a.sourceRevisionFingerprint, b.sourceRevisionFingerprint);
  expect(a.status, b.status);
  expect(a.claimToken, b.claimToken);
  expect(a.leaseExpiresAtUtc, b.leaseExpiresAtUtc);
}

void expectOwnerStateEquals(ReminderOwnerState a, ReminderOwnerState b) {
  expect(a.definitions.length, b.definitions.length);
  for (var i = 0; i < b.definitions.length; i++) {
    expectDefinition(a.definitions[i], b.definitions[i]);
  }
  expect(a.channels.length, b.channels.length);
  for (var i = 0; i < b.channels.length; i++) {
    expectChannel(a.channels[i], b.channels[i]);
  }
  expect(a.aggregates.length, b.aggregates.length);
  for (var i = 0; i < b.aggregates.length; i++) {
    expectAggregate(a.aggregates[i], b.aggregates[i]);
  }
  expect(a.schedules.length, b.schedules.length);
  for (var i = 0; i < b.schedules.length; i++) {
    expectSchedule(a.schedules[i], b.schedules[i]);
  }
  expect(a.deliveredScheduleIds, b.deliveredScheduleIds);
}
