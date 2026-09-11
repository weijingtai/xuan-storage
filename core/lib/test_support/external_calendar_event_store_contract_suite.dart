// ACT-15: 共享 ExternalCalendarEventStore 合同测试套件
// ignore_for_file: depend_on_referenced_packages
library;

import 'dart:async';

import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:test/test.dart';

/// 共享合同套件：In-Memory 与 Drift adapter 都必须原样通过。
/// makeStore 每个用例调用一次并返回全新空存储。
void runExternalCalendarEventStoreContractSuite({
  required FutureOr<ExternalCalendarEventStore> Function() makeStore,
}) {
  group('ExternalCalendarEventStore 共享合同套件', () {
    const ownerA = 'owner-scope-a';
    const ownerB = 'owner-scope-b';

    ExternalCalendarEvent makeEvent({
      String ownerScopeId = ownerA,
      String externalEventId = 'ext-1',
      String revision = 'rev-1',
      ExternalOriginType originType = ExternalOriginType.destinyQuestion,
      String originId = 'origin-1',
      List<String> relatedSubjectIds = const [],
      List<String> usedProfileRefs = const [],
      String divinationTypeKey = 'bazi',
      String? subDivinationTypeKey,
      LifeEventTime? eventTime,
      String factSummary = 'External event summary',
      String? evidenceRef = 'evidence-1',
      String lifecycleStatus = 'active',
    }) {
      return ExternalCalendarEvent(
        ownerScopeId: ownerScopeId,
        externalEventId: externalEventId,
        revision: revision,
        originType: originType,
        originId: originId,
        relatedSubjectIds: relatedSubjectIds,
        usedProfileRefs: usedProfileRefs,
        divinationTypeKey: divinationTypeKey,
        subDivinationTypeKey: subDivinationTypeKey,
        eventTime: eventTime ??
            InstantTime(
              effectiveStartUtc: DateTime.utc(2026, 6, 15, 12),
              instantUtc: DateTime.utc(2026, 6, 15, 12),
              calculationTimezoneId: 'UTC',
              precision: TimePrecision.hour,
            ),
        factSummary: factSummary,
        evidenceRef: evidenceRef,
        lifecycleStatus: lifecycleStatus,
      );
    }

    test('(a) expectedRevision=null 且不存在 → saved 并返回 revision', () async {
      final store = await makeStore();
      final event = makeEvent(externalEventId: 'evt-a', revision: 'rev-1');

      final result = await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: event,
          expectedRevision: null,
        ),
      );

      expect(result.outcome, 'saved');
      expect(result.revision, 'rev-1');

      final page = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(page.items.length, 1);
      expect(page.items.first.externalEventId, 'evt-a');
      expect(page.items.first.revision, 'rev-1');
    });

    test('(b) expectedRevision=null 但已存在 → revisionConflict 零写入', () async {
      final store = await makeStore();
      final event1 = makeEvent(externalEventId: 'evt-b', revision: 'rev-1');
      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: event1,
          expectedRevision: null,
        ),
      );

      final event2 = makeEvent(
        externalEventId: 'evt-b',
        revision: 'rev-2',
        factSummary: 'Updated summary',
      );
      final conflictResult = await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: event2,
          expectedRevision: null,
        ),
      );

      expect(conflictResult.outcome, 'revisionConflict');
      expect(conflictResult.revision, 'rev-1');

      final page = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(page.items.length, 1);
      expect(page.items.first.revision, 'rev-1');
      expect(page.items.first.factSummary, 'External event summary');
    });

    test('(c) expectedRevision == 最新 revision 且新 revision != 旧 → saved，query 只返回新 revision', () async {
      final store = await makeStore();
      final event1 = makeEvent(externalEventId: 'evt-c', revision: 'rev-1');
      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: event1,
          expectedRevision: null,
        ),
      );

      final event2 = makeEvent(
        externalEventId: 'evt-c',
        revision: 'rev-2',
        factSummary: 'Revision 2 fact',
      );
      final updateResult = await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: event2,
          expectedRevision: 'rev-1',
        ),
      );

      expect(updateResult.outcome, 'saved');
      expect(updateResult.revision, 'rev-2');

      final page = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(page.items.length, 1);
      expect(page.items.first.externalEventId, 'evt-c');
      expect(page.items.first.revision, 'rev-2');
      expect(page.items.first.factSummary, 'Revision 2 fact');
    });

    test('(d) expectedRevision 等于更早的旧 revision → revisionConflict 零写入', () async {
      final store = await makeStore();
      final event1 = makeEvent(externalEventId: 'evt-d', revision: 'rev-1');
      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: event1,
          expectedRevision: null,
        ),
      );

      final event2 = makeEvent(externalEventId: 'evt-d', revision: 'rev-2');
      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: event2,
          expectedRevision: 'rev-1',
        ),
      );

      // 尝试以更早的 rev-1 作为 expectedRevision 写入 rev-3
      final event3 = makeEvent(externalEventId: 'evt-d', revision: 'rev-3');
      final conflictResult = await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: event3,
          expectedRevision: 'rev-1',
        ),
      );

      expect(conflictResult.outcome, 'revisionConflict');
      expect(conflictResult.revision, 'rev-2');

      final page = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(page.items.length, 1);
      expect(page.items.first.revision, 'rev-2');
    });

    test('(e) request.ownerScopeId != event.ownerScopeId → 拒绝零写入（outcome ownerScopeMismatch）', () async {
      final store = await makeStore();
      final event = makeEvent(ownerScopeId: ownerB, externalEventId: 'evt-e', revision: 'rev-1');

      final result = await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA, // 不匹配
          event: event,
          expectedRevision: null,
        ),
      );

      expect(result.outcome, 'ownerScopeMismatch');

      // 验证 ownerA 和 ownerB 都没有写入
      final pageA = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(pageA.items, isEmpty);

      final pageB = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerB,
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(pageB.items, isEmpty);
    });

    test('(f) relatedSubjectIds 过滤（交集命中）、originTypes 过滤、timeRange 半开相交', () async {
      final store = await makeStore();

      // 准备多样化事件
      final e1 = makeEvent(
        externalEventId: 'e1',
        revision: 'r1',
        originType: ExternalOriginType.destinyQuestion,
        relatedSubjectIds: ['subj-1', 'subj-2'],
        eventTime: InstantTime(
          effectiveStartUtc: DateTime.utc(2026, 6, 1, 0),
          instantUtc: DateTime.utc(2026, 6, 1, 0),
          calculationTimezoneId: 'UTC',
          precision: TimePrecision.hour,
        ),
      );
      final e2 = makeEvent(
        externalEventId: 'e2',
        revision: 'r1',
        originType: ExternalOriginType.divinationCase,
        relatedSubjectIds: ['subj-2', 'subj-3'],
        eventTime: IntervalTime(
          effectiveStartUtc: DateTime.utc(2026, 5, 20, 0),
          startInclusiveUtc: DateTime.utc(2026, 5, 20, 0),
          endExclusiveUtc: DateTime.utc(2026, 6, 5, 0),
          calculationTimezoneId: 'UTC',
          precision: TimePrecision.day,
        ),
      );
      final e3 = makeEvent(
        externalEventId: 'e3',
        revision: 'r1',
        originType: ExternalOriginType.destinyQuestion,
        relatedSubjectIds: ['subj-4'],
        eventTime: InstantTime(
          effectiveStartUtc: DateTime.utc(2026, 7, 1, 0),
          instantUtc: DateTime.utc(2026, 7, 1, 0),
          calculationTimezoneId: 'UTC',
          precision: TimePrecision.hour,
        ),
      );

      await store.save(SaveExternalEventRequest(ownerScopeId: ownerA, event: e1, expectedRevision: null));
      await store.save(SaveExternalEventRequest(ownerScopeId: ownerA, event: e2, expectedRevision: null));
      await store.save(SaveExternalEventRequest(ownerScopeId: ownerA, event: e3, expectedRevision: null));

      // 1. relatedSubjectIds 交集测试
      final pageSubj = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: ['subj-2'],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(pageSubj.items.map((e) => e.externalEventId).toSet(), {'e1', 'e2'});

      final pageSubjEmpty = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: ['subj-99'],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(pageSubjEmpty.items, isEmpty);

      // 2. originTypes 过滤测试
      final pageOrigin = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: const [],
          originTypes: [ExternalOriginType.divinationCase],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(pageOrigin.items.map((e) => e.externalEventId).toList(), ['e2']);

      // 3. timeRange 半开相交测试：[2026-06-01, 2026-07-01)
      // e1 (instant 2026-06-01 00:00) 位于起界包含点 -> 命中
      // e2 (interval 2026-05-20 ~ 2026-06-05) 与区间相交 -> 命中
      // e3 (instant 2026-07-01 00:00) 位于终界排除点 -> 不命中
      final pageTime = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: TimeRange(
            startInclusiveUtc: DateTime.utc(2026, 6, 1, 0),
            endExclusiveUtc: DateTime.utc(2026, 7, 1, 0),
          ),
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(pageTime.items.map((e) => e.externalEventId).toSet(), {'e1', 'e2'});
    });

    test('(g) 201 条 keyset 五页遍历无重复无遗漏', () async {
      final store = await makeStore();
      final baseTime = DateTime.utc(2026, 1, 1);
      final expectedIds = <String>{};

      for (var i = 0; i < 201; i++) {
        final id = 'evt-${i.toString().padLeft(3, '0')}';
        expectedIds.add(id);
        final event = makeEvent(
          externalEventId: id,
          revision: 'rev-1',
          eventTime: InstantTime(
            effectiveStartUtc: baseTime.add(Duration(hours: i)),
            instantUtc: baseTime.add(Duration(hours: i)),
            calculationTimezoneId: 'UTC',
            precision: TimePrecision.hour,
          ),
        );
        await store.save(
          SaveExternalEventRequest(
            ownerScopeId: ownerA,
            event: event,
            expectedRevision: null,
          ),
        );
      }

      final collectedIds = <String>[];
      String? pageToken;
      var pageCount = 0;

      while (true) {
        final page = await store.query(
          ExternalEventQuery(
            ownerScopeId: ownerA,
            relatedSubjectIds: const [],
            originTypes: const [],
            timeRange: null,
            pageToken: pageToken,
            pageSize: 50,
          ),
        );
        pageCount++;
        collectedIds.addAll(page.items.map((e) => e.externalEventId));

        if (page.nextPageToken == null) {
          break;
        }
        pageToken = page.nextPageToken;
      }

      expect(pageCount, 5, reason: '201条每页50条应恰好5页（50+50+50+50+1）');
      expect(collectedIds.length, 201);
      expect(collectedIds.toSet().length, 201, reason: '无重复');
      expect(collectedIds.toSet(), expectedIds, reason: '无遗漏');
    });

    test('(h) 跨 owner 零泄漏', () async {
      final store = await makeStore();

      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: makeEvent(ownerScopeId: ownerA, externalEventId: 'a-1', revision: 'r1'),
          expectedRevision: null,
        ),
      );
      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerA,
          event: makeEvent(ownerScopeId: ownerA, externalEventId: 'a-2', revision: 'r1'),
          expectedRevision: null,
        ),
      );

      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: ownerB,
          event: makeEvent(ownerScopeId: ownerB, externalEventId: 'b-1', revision: 'r1'),
          expectedRevision: null,
        ),
      );

      final pageA = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerA,
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(pageA.items.map((e) => e.externalEventId).toList(), ['a-1', 'a-2']);
      expect(pageA.items.every((e) => e.ownerScopeId == ownerA), isTrue);

      final pageB = await store.query(
        ExternalEventQuery(
          ownerScopeId: ownerB,
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(pageB.items.map((e) => e.externalEventId).toList(), ['b-1']);
      expect(pageB.items.every((e) => e.ownerScopeId == ownerB), isTrue);

      final pageC = await store.query(
        ExternalEventQuery(
          ownerScopeId: 'owner-non-existent',
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(pageC.items, isEmpty);
    });
  });
}
