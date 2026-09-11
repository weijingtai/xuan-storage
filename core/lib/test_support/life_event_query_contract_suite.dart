// ACT-05A-S: 共享 LifeEvent 查询合同测试套件
// ignore_for_file: depend_on_referenced_packages
library;

import 'dart:async';

import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:test/test.dart';

/// 四个 port 聚合访问器。
final class _StoragePorts {
  final LifeEventCoverageGenerationPort coverageGeneration;
  final LifeEventShardCommitPort shardCommit;
  final LifeEventProjectionQueryPort projectionQuery;
  final LifeEventCoverageQueryPort coverageQuery;

  _StoragePorts(Object storage)
      : coverageGeneration = storage as LifeEventCoverageGenerationPort,
        shardCommit = storage as LifeEventShardCommitPort,
        projectionQuery = storage as LifeEventProjectionQueryPort,
        coverageQuery = storage as LifeEventCoverageQueryPort;
}

/// 共享查询合同套件：In-Memory（calendar ACT-05A-C）与 Drift 都必须原样通过。
/// makeStorage 返回同时实现四个 port 的全新空存储；套件自己经 commit port 写入夹具，再经 query port 读回。
void runLifeEventQueryContractSuite({
  required FutureOr<Object> Function() makeStorage,
}) {
  group('LifeEventQuery 合同套件', () {
    const ownerA = 'owner-scope-a';
    const ownerB = 'owner-scope-b';
    const profileA = 'profile-a';
    const profileB = 'profile-b';
    const providerA = 'provider-a';
    const providerB = 'provider-b';
    const eventTypeA = 'type-a';
    const eventTypeB = 'type-b';
    const snapshotA = 'snap-a';
    const snapshotB = 'snap-b';

    final fullRange = TimeRange(
      startInclusiveUtc: DateTime.utc(2026, 1, 1),
      endExclusiveUtc: DateTime.utc(2027, 1, 1),
    );

    EventProjection makeProj({
      required String projectionId,
      String ownerScopeId = ownerA,
      String profileId = profileA,
      String chartSnapshotId = snapshotA,
      String providerId = providerA,
      String eventTypeId = eventTypeA,
      String coverageId = 'cov-1',
      int coverageGeneration = 1,
      required DateTime startUtc,
      DateTime? endUtc,
      TimePrecision precision = TimePrecision.hour,
      ProjectionLifecycleStatus status = ProjectionLifecycleStatus.active,
    }) {
      return EventProjection(
        projectionId: projectionId,
        projectionIdAlgorithmVersion: 'v1',
        coverageId: coverageId,
        coverageGeneration: coverageGeneration,
        sourceRef: SourceRef(
          providerId: providerId,
          sourceEventId: 'evt-$projectionId',
          eventRevision: 'r1',
        ),
        ownerScopeId: ownerScopeId,
        subjectId: 'sub-$ownerScopeId',
        profileId: profileId,
        chartSnapshotId: chartSnapshotId,
        divinationTypeKey: 'div-key',
        subDivinationTypeKey: null,
        eventTypeId: eventTypeId,
        eventTime: endUtc != null
            ? IntervalTime(
                effectiveStartUtc: startUtc,
                startInclusiveUtc: startUtc,
                endExclusiveUtc: endUtc,
                calculationTimezoneId: 'UTC',
                precision: precision,
              )
            : InstantTime(
                effectiveStartUtc: startUtc,
                instantUtc: startUtc,
                calculationTimezoneId: 'UTC',
                precision: precision,
              ),
        projectedParticipants: const [],
        projectedFactValues: const [],
        factSummary: 'Fact $projectionId',
        evidenceRef: 'ev-$projectionId',
        astronomyEventRef: null,
        astronomyEvidenceRef: null,
        profileMatchEvidenceRef: null,
        sourceSeverityRef: null,
        sourceVersions: const SourceVersions(
          providerVersion: '1.0.0',
          algorithmVersion: 'algo-1',
          ruleVersion: null,
          dataVersion: null,
        ),
        projectionLifecycleStatus: status,
        indexedAt: DateTime.utc(2026, 9, 1),
      );
    }

    Future<String> seedCompleteCoverage({
      required _StoragePorts ports,
      required String coverageSeriesId,
      String ownerScopeId = ownerA,
      String profileId = profileA,
      String chartSnapshotId = snapshotA,
      String providerId = providerA,
      String eventTypeId = eventTypeA,
      int expectedSeriesRevision = 0,
      String? expectedActiveCoverageId,
      TimeRange? desiredRange,
      required List<EventProjection> projections,
      List<SourceRef> withdrawals = const [],
    }) async {
      final range = desiredRange ?? fullRange;
      final createRes = await ports.coverageGeneration.createOrReplaceCandidate(
        CreateCoverageGenerationRequest(
          coverageSeriesId: coverageSeriesId,
          expectedSeriesRevision: expectedSeriesRevision,
          expectedActiveCoverageId: expectedActiveCoverageId,
          desiredRange: range,
          providerId: providerId,
          providerVersion: '1.0.0',
          chartSnapshotId: chartSnapshotId,
          chartSnapshotRevision: 'v1',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: eventTypeId,
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-$coverageSeriesId',
        ),
      );
      expect(createRes.outcome, CreateCoverageGenerationOutcome.created);
      final coverageId = createRes.coverageId!;
      final coverageGen = createRes.coverageGeneration!;

      // 修正 projection 的 coverageId 与 generation
      final resolvedProjections = projections
          .map(
            (p) => makeProj(
              projectionId: p.projectionId,
              ownerScopeId: p.ownerScopeId,
              profileId: p.profileId,
              chartSnapshotId: p.chartSnapshotId,
              providerId: p.sourceRef.providerId,
              eventTypeId: p.eventTypeId,
              coverageId: coverageId,
              coverageGeneration: coverageGen,
              startUtc: p.eventTime.effectiveStartUtc,
              endUtc: p.eventTime is IntervalTime
                  ? (p.eventTime as IntervalTime).endExclusiveUtc
                  : null,
              precision: p.eventTime is InstantTime
                  ? (p.eventTime as InstantTime).precision
                  : (p.eventTime as IntervalTime).precision,
              status: p.projectionLifecycleStatus,
            ),
          )
          .toList();

      final commitRes = await ports.shardCommit.commitValidatedShard(
        CommitValidatedShardRequest(
          coverageId: coverageId,
          coverageGeneration: coverageGen,
          expectedManifestRevision: 0,
          expectedSeriesRevision: createRes.seriesRevision,
          expectedActiveCoverageId: expectedActiveCoverageId,
          expectedCandidateCoverageId: coverageId,
          providerId: providerId,
          providerVersion: '1.0.0',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: eventTypeId,
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-$coverageSeriesId',
          receiptIdentity: ReceiptIdentity(coverageId: coverageId, shardId: 'shard-1'),
          requestId: 'req-$coverageId-1',
          requestedRange: range,
          coveredRange: range,
          projections: resolvedProjections,
          withdrawals: withdrawals,
          eventCount: resolvedProjections.length,
          contentDigest: 'digest-$coverageId',
          isCompleteForCoveredRange: true,
          requestedCoverageTransition: CoverageTransition.complete,
        ),
      );
      expect(commitRes.outcome, CommitValidatedShardOutcome.applied);
      return coverageId;
    }

    test('CASE 1: queryProjections 作用域、时间区间与维度交集过滤', () async {
      final ports = _StoragePorts(await makeStorage());

      // 预置 Owner A 数据（包含符合范围与不符合范围、不同 profile/eventType/provider 的投影）
      await seedCompleteCoverage(
        ports: ports,
        coverageSeriesId: 'series-a1',
        ownerScopeId: ownerA,
        profileId: profileA,
        chartSnapshotId: snapshotA,
        providerId: providerA,
        eventTypeId: eventTypeA,
        projections: [
          makeProj(
            projectionId: 'p-in-1',
            ownerScopeId: ownerA,
            profileId: profileA,
            chartSnapshotId: snapshotA,
            providerId: providerA,
            eventTypeId: eventTypeA,
            startUtc: DateTime.utc(2026, 3, 1),
          ),
          makeProj(
            projectionId: 'p-in-2',
            ownerScopeId: ownerA,
            profileId: profileA,
            chartSnapshotId: snapshotA,
            providerId: providerA,
            eventTypeId: eventTypeA,
            startUtc: DateTime.utc(2026, 4, 1),
          ),
          makeProj(
            projectionId: 'p-out-before',
            ownerScopeId: ownerA,
            profileId: profileA,
            chartSnapshotId: snapshotA,
            providerId: providerA,
            eventTypeId: eventTypeA,
            startUtc: DateTime.utc(2025, 12, 31),
          ),
          makeProj(
            projectionId: 'p-out-after',
            ownerScopeId: ownerA,
            profileId: profileA,
            chartSnapshotId: snapshotA,
            providerId: providerA,
            eventTypeId: eventTypeA,
            startUtc: DateTime.utc(2026, 6, 1),
          ),
        ],
      );

      // 预置 Owner A 的另一个 series (profileB, eventTypeB)
      await seedCompleteCoverage(
        ports: ports,
        coverageSeriesId: 'series-a2',
        ownerScopeId: ownerA,
        profileId: profileB,
        chartSnapshotId: snapshotB,
        providerId: providerB,
        eventTypeId: eventTypeB,
        projections: [
          makeProj(
            projectionId: 'p-b-in',
            ownerScopeId: ownerA,
            profileId: profileB,
            chartSnapshotId: snapshotB,
            providerId: providerB,
            eventTypeId: eventTypeB,
            startUtc: DateTime.utc(2026, 3, 15),
          ),
        ],
      );

      // 预置 Owner B 的数据（防泄漏）
      await seedCompleteCoverage(
        ports: ports,
        coverageSeriesId: 'series-b1',
        ownerScopeId: ownerB,
        profileId: profileA,
        chartSnapshotId: snapshotA,
        providerId: providerA,
        eventTypeId: eventTypeA,
        projections: [
          makeProj(
            projectionId: 'p-owner-b',
            ownerScopeId: ownerB,
            profileId: profileA,
            chartSnapshotId: snapshotA,
            providerId: providerA,
            eventTypeId: eventTypeA,
            startUtc: DateTime.utc(2026, 3, 10),
          ),
        ],
      );

      final queryRange = TimeRange(
        startInclusiveUtc: DateTime.utc(2026, 1, 1),
        endExclusiveUtc: DateTime.utc(2026, 6, 1),
      );

      // 1. 无维度过滤：返回 Owner A 在 [2026-01-01, 2026-06-01) 内的所有投影（p-in-1, p-in-2, p-b-in）
      final resAll = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: queryRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      final idsAll = resAll.items.map((e) => e.projectionId).toList();
      expect(idsAll, containsAll(['p-in-1', 'p-in-2', 'p-b-in']));
      expect(idsAll, isNot(contains('p-out-before')));
      expect(idsAll, isNot(contains('p-out-after')));
      expect(idsAll, isNot(contains('p-owner-b')));

      // 2. profileIds 过滤
      final resProfile = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: [profileA],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: queryRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(resProfile.items.map((e) => e.projectionId).toList(), ['p-in-1', 'p-in-2']);

      // 3. eventTypeIds + providerIds 交集过滤
      final resIntersection = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: [providerB],
          eventTypeIds: [eventTypeB],
          range: queryRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(resIntersection.items.map((e) => e.projectionId).toList(), ['p-b-in']);

      // 4. 交集为空的过滤
      final resEmpty = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: [profileA],
          chartSnapshotIds: const [],
          providerIds: [providerB], // mismatch
          eventTypeIds: const [],
          range: queryRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(resEmpty.items, isEmpty);
    });

    test('CASE 2: keyset 分页（201 条、五页遍历、不支持的 sortKey 返回空页、同页重放一致）', () async {
      final ports = _StoragePorts(await makeStorage());

      // 1. sortKey != 'effectiveStart' 返回空页且 nextPageToken = null
      final invalidSortRes = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'unsupportedSort',
          pageToken: null,
          pageSize: 50,
        ),
      );
      expect(invalidSortRes.items, isEmpty);
      expect(invalidSortRes.nextPageToken, isNull);

      // 2. 生成 201 条夹具
      final baseDate = DateTime.utc(2026, 1, 1);
      final projections201 = List.generate(201, (i) {
        // 每条相隔 1 小时
        return makeProj(
          projectionId: 'proj-${i.toString().padLeft(4, '0')}',
          ownerScopeId: ownerA,
          profileId: profileA,
          chartSnapshotId: snapshotA,
          providerId: providerA,
          eventTypeId: eventTypeA,
          startUtc: baseDate.add(Duration(hours: i)),
        );
      });

      await seedCompleteCoverage(
        ports: ports,
        coverageSeriesId: 'series-201',
        ownerScopeId: ownerA,
        profileId: profileA,
        chartSnapshotId: snapshotA,
        providerId: providerA,
        eventTypeId: eventTypeA,
        desiredRange: fullRange,
        projections: projections201,
      );

      // 五页遍历 pageSize = 50
      final allItems = <EventProjection>[];
      final pageCounts = <int>[];
      String? currentToken;

      for (int page = 1; page <= 5; page++) {
        final pageRes = await ports.projectionQuery.queryProjections(
          ProjectionStorageQuery(
            ownerScopeId: ownerA,
            profileIds: const [],
            chartSnapshotIds: const [],
            providerIds: const [],
            eventTypeIds: const [],
            range: fullRange,
            includeWithdrawn: false,
            includeHistoricalGenerations: false,
            sortKey: 'effectiveStart',
            pageToken: currentToken,
            pageSize: 50,
          ),
        );
        pageCounts.add(pageRes.items.length);
        allItems.addAll(pageRes.items);
        currentToken = pageRes.nextPageToken;

        if (page < 5) {
          expect(pageRes.items.length, 50, reason: '第 $page 页必须有 50 条');
          expect(pageRes.nextPageToken, isNotNull, reason: '第 $page 页必须有 nextPageToken');
        } else {
          expect(pageRes.items.length, 1, reason: '第 5 页必须有 1 条');
          expect(pageRes.nextPageToken, isNull, reason: '末页 nextPageToken 必须为 null');
        }
      }

      expect(pageCounts, [50, 50, 50, 50, 1]);
      expect(allItems.length, 201);
      // 无重复、无遗漏
      final allIds = allItems.map((e) => e.projectionId).toList();
      expect(allIds.toSet().length, 201);
      expect(allIds, projections201.map((e) => e.projectionId).toList());

      // 3. 中途插入新行不影响已遍历页的稳定性（同页重放一致）
      // 获取第 1 页的 nextPageToken，读出第 2 页
      final p1 = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 50,
        ),
      );
      final token1 = p1.nextPageToken!;
      final p2Before = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: token1,
          pageSize: 50,
        ),
      );
      expect(p2Before.items.length, 50);

      // 在第 1 页时间范围之前插入一条新投影（通过覆盖追加提交）
      await ports.shardCommit.commitValidatedShard(
        CommitValidatedShardRequest(
          coverageId: 'cov-series-201-1',
          coverageGeneration: 1,
          expectedManifestRevision: 1,
          expectedSeriesRevision: 1,
          expectedActiveCoverageId: 'cov-series-201-1',
          expectedCandidateCoverageId: null,
          providerId: providerA,
          providerVersion: '1.0.0',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: eventTypeA,
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-series-201',
          receiptIdentity: const ReceiptIdentity(coverageId: 'cov-series-201-1', shardId: 'shard-insert'),
          requestId: 'req-insert',
          requestedRange: fullRange,
          coveredRange: fullRange,
          projections: [
            makeProj(
              projectionId: 'proj-inserted-early',
              ownerScopeId: ownerA,
              profileId: profileA,
              chartSnapshotId: snapshotA,
              providerId: providerA,
              eventTypeId: eventTypeA,
              coverageId: 'cov-series-201-1',
              coverageGeneration: 1,
              startUtc: baseDate.subtract(const Duration(minutes: 30)),
            ),
          ],
          withdrawals: const [],
          eventCount: 1,
          contentDigest: 'digest-insert',
          isCompleteForCoveredRange: false,
          requestedCoverageTransition: CoverageTransition.partial,
        ),
      );

      // 用 token1 重新读取第 2 页，断言内容完全一致（不受前面插入新行的影响）
      final p2After = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: token1,
          pageSize: 50,
        ),
      );

      expect(
        p2After.items.map((e) => e.projectionId).toList(),
        equals(p2Before.items.map((e) => e.projectionId).toList()),
      );
    });

    test('CASE 3: includeWithdrawn 过滤与保留状态', () async {
      final ports = _StoragePorts(await makeStorage());

      await seedCompleteCoverage(
        ports: ports,
        coverageSeriesId: 'series-withdrawn',
        ownerScopeId: ownerA,
        profileId: profileA,
        chartSnapshotId: snapshotA,
        providerId: providerA,
        eventTypeId: eventTypeA,
        projections: [
          makeProj(
            projectionId: 'p-active',
            ownerScopeId: ownerA,
            startUtc: DateTime.utc(2026, 2, 1),
            status: ProjectionLifecycleStatus.active,
          ),
          makeProj(
            projectionId: 'p-withdrawn',
            ownerScopeId: ownerA,
            startUtc: DateTime.utc(2026, 2, 2),
            status: ProjectionLifecycleStatus.withdrawn,
          ),
        ],
      );

      // includeWithdrawn = false 排除
      final resFalse = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(resFalse.items.map((e) => e.projectionId).toList(), ['p-active']);

      // includeWithdrawn = true 包含且保留状态
      final resTrue = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: true,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      final withdrawnItem = resTrue.items.firstWhere((e) => e.projectionId == 'p-withdrawn');
      expect(withdrawnItem.projectionLifecycleStatus, ProjectionLifecycleStatus.withdrawn);
      expect(resTrue.items.map((e) => e.projectionId).toSet(), containsAll(['p-active', 'p-withdrawn']));
    });

    test('CASE 4: includeHistoricalGenerations 语义（只查 active vs active+historical，candidate 永不返回）', () async {
      final ports = _StoragePorts(await makeStorage());

      // 1. 创建 Generation 1 并 complete
      final cov1Id = await seedCompleteCoverage(
        ports: ports,
        coverageSeriesId: 'series-hist',
        ownerScopeId: ownerA,
        expectedSeriesRevision: 0,
        projections: [
          makeProj(
            projectionId: 'p-gen1',
            ownerScopeId: ownerA,
            startUtc: DateTime.utc(2026, 2, 1),
          ),
        ],
      );

      // 2. 创建 Candidate Generation 2（提交 partial，不 complete）
      final createGen2 = await ports.coverageGeneration.createOrReplaceCandidate(
        CreateCoverageGenerationRequest(
          coverageSeriesId: 'series-hist',
          expectedSeriesRevision: 1,
          expectedActiveCoverageId: cov1Id,
          desiredRange: fullRange,
          providerId: providerA,
          providerVersion: '1.0.0',
          chartSnapshotId: snapshotA,
          chartSnapshotRevision: 'v1',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: eventTypeA,
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-hist',
        ),
      );
      final cov2Id = createGen2.coverageId!;
      final cov2Gen = createGen2.coverageGeneration!;
      await ports.shardCommit.commitValidatedShard(
        CommitValidatedShardRequest(
          coverageId: cov2Id,
          coverageGeneration: cov2Gen,
          expectedManifestRevision: 0,
          expectedSeriesRevision: null,
          expectedActiveCoverageId: cov1Id,
          expectedCandidateCoverageId: cov2Id,
          providerId: providerA,
          providerVersion: '1.0.0',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: eventTypeA,
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-hist',
          receiptIdentity: ReceiptIdentity(coverageId: cov2Id, shardId: 'shard-candidate'),
          requestId: 'req-cov2-candidate',
          requestedRange: fullRange,
          coveredRange: fullRange,
          projections: [
            makeProj(
              projectionId: 'p-gen2-candidate',
              ownerScopeId: ownerA,
              coverageId: cov2Id,
              coverageGeneration: cov2Gen,
              startUtc: DateTime.utc(2026, 2, 5),
            ),
          ],
          withdrawals: const [],
          eventCount: 1,
          contentDigest: 'digest-cov2',
          isCompleteForCoveredRange: false,
          requestedCoverageTransition: CoverageTransition.partial,
        ),
      );

      // includeHistoricalGenerations = false: 只返回 active (cov1)，candidate (cov2) 不返回
      final resGen1Only = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(resGen1Only.items.map((e) => e.projectionId).toList(), ['p-gen1']);

      // includeHistoricalGenerations = true: 仍不返回 candidate (cov2)
      final resStillGen1Only = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: true,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(resStillGen1Only.items.map((e) => e.projectionId).toList(), ['p-gen1']);

      // 3. 将 Generation 2 complete：cov2 成为 active，cov1 成为 historical
      await ports.shardCommit.commitValidatedShard(
        CommitValidatedShardRequest(
          coverageId: cov2Id,
          coverageGeneration: cov2Gen,
          expectedManifestRevision: 1,
          expectedSeriesRevision: 2,
          expectedActiveCoverageId: cov1Id,
          expectedCandidateCoverageId: cov2Id,
          providerId: providerA,
          providerVersion: '1.0.0',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: eventTypeA,
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-hist',
          receiptIdentity: ReceiptIdentity(coverageId: cov2Id, shardId: 'shard-complete'),
          requestId: 'req-cov2-complete',
          requestedRange: fullRange,
          coveredRange: fullRange,
          projections: [
            makeProj(
              projectionId: 'p-gen2-active',
              ownerScopeId: ownerA,
              coverageId: cov2Id,
              coverageGeneration: cov2Gen,
              startUtc: DateTime.utc(2026, 2, 10),
            ),
          ],
          withdrawals: const [],
          eventCount: 1,
          contentDigest: 'digest-cov2-complete',
          isCompleteForCoveredRange: true,
          requestedCoverageTransition: CoverageTransition.complete,
        ),
      );

      // 创建 Candidate Generation 3（未 complete）
      final createGen3 = await ports.coverageGeneration.createOrReplaceCandidate(
        CreateCoverageGenerationRequest(
          coverageSeriesId: 'series-hist',
          expectedSeriesRevision: 2,
          expectedActiveCoverageId: cov2Id,
          desiredRange: fullRange,
          providerId: providerA,
          providerVersion: '1.0.0',
          chartSnapshotId: snapshotA,
          chartSnapshotRevision: 'v1',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: eventTypeA,
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-hist',
        ),
      );
      final cov3Id = createGen3.coverageId!;
      final cov3Gen = createGen3.coverageGeneration!;
      await ports.shardCommit.commitValidatedShard(
        CommitValidatedShardRequest(
          coverageId: cov3Id,
          coverageGeneration: cov3Gen,
          expectedManifestRevision: 0,
          expectedSeriesRevision: null,
          expectedActiveCoverageId: cov2Id,
          expectedCandidateCoverageId: cov3Id,
          providerId: providerA,
          providerVersion: '1.0.0',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: eventTypeA,
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-hist',
          receiptIdentity: ReceiptIdentity(coverageId: cov3Id, shardId: 'shard-candidate-3'),
          requestId: 'req-cov3-candidate',
          requestedRange: fullRange,
          coveredRange: fullRange,
          projections: [
            makeProj(
              projectionId: 'p-gen3-candidate',
              ownerScopeId: ownerA,
              coverageId: cov3Id,
              coverageGeneration: cov3Gen,
              startUtc: DateTime.utc(2026, 2, 20),
            ),
          ],
          withdrawals: const [],
          eventCount: 1,
          contentDigest: 'digest-cov3',
          isCompleteForCoveredRange: false,
          requestedCoverageTransition: CoverageTransition.partial,
        ),
      );

      // includeHistoricalGenerations = false: 只返回 active (cov2)
      final resActiveOnly = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: false,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      final activeIds = resActiveOnly.items.map((e) => e.projectionId).toList();
      expect(activeIds, contains('p-gen2-active'));
      expect(activeIds, isNot(contains('p-gen1')));
      expect(activeIds, isNot(contains('p-gen3-candidate')));

      // includeHistoricalGenerations = true: 返回 active (cov2) + historical (cov1)，candidate (cov3) 永不返回
      final resWithHist = await ports.projectionQuery.queryProjections(
        ProjectionStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeWithdrawn: false,
          includeHistoricalGenerations: true,
          sortKey: 'effectiveStart',
          pageToken: null,
          pageSize: 10,
        ),
      );
      final withHistIds = resWithHist.items.map((e) => e.projectionId).toList();
      expect(withHistIds, containsAll(['p-gen1', 'p-gen2-active']));
      expect(withHistIds, isNot(contains('p-gen3-candidate')));
    });

    test('CASE 5: queryCoverage（跨 owner 零泄漏、heads/manifests 匹配、includeHistoricalGenerations 语义）', () async {
      final ports = _StoragePorts(await makeStorage());

      // 预置 Owner A 的 Series 1（两代：cov1 历史，cov2 active）
      final cov1Id = await seedCompleteCoverage(
        ports: ports,
        coverageSeriesId: 'series-cov-a1',
        ownerScopeId: ownerA,
        profileId: profileA,
        chartSnapshotId: snapshotA,
        providerId: providerA,
        eventTypeId: eventTypeA,
        expectedSeriesRevision: 0,
        projections: [
          makeProj(projectionId: 'p-a1-1', ownerScopeId: ownerA, startUtc: DateTime.utc(2026, 3, 1)),
        ],
      );

      final cov2Id = await seedCompleteCoverage(
        ports: ports,
        coverageSeriesId: 'series-cov-a1',
        ownerScopeId: ownerA,
        profileId: profileA,
        chartSnapshotId: snapshotA,
        providerId: providerA,
        eventTypeId: eventTypeA,
        expectedSeriesRevision: 1,
        expectedActiveCoverageId: cov1Id,
        projections: [
          makeProj(projectionId: 'p-a1-2', ownerScopeId: ownerA, startUtc: DateTime.utc(2026, 3, 2)),
        ],
      );

      // 预置 Owner B 的 Series
      await seedCompleteCoverage(
        ports: ports,
        coverageSeriesId: 'series-cov-b1',
        ownerScopeId: ownerB,
        profileId: profileA,
        chartSnapshotId: snapshotA,
        providerId: providerA,
        eventTypeId: eventTypeA,
        projections: [
          makeProj(projectionId: 'p-b-1', ownerScopeId: ownerB, startUtc: DateTime.utc(2026, 3, 1)),
        ],
      );

      // 1. 查询 Owner A：跨 owner 零泄漏，includeHistoricalGenerations = false
      final covResActive = await ports.coverageQuery.queryCoverage(
        CoverageStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeHistoricalGenerations: false,
        ),
      );

      expect(covResActive.heads.length, 1);
      expect(covResActive.heads.first.coverageSeriesId, 'series-cov-a1');
      expect(covResActive.heads.first.activeCoverageId, cov2Id);
      expect(covResActive.manifests.length, 1);
      expect(covResActive.manifests.first.coverageId, cov2Id);
      expect(covResActive.manifests.first.servingState, ServingState.active);

      // 2. includeHistoricalGenerations = true：包含 cov2（active）与 cov1（historical）
      final covResWithHist = await ports.coverageQuery.queryCoverage(
        CoverageStorageQuery(
          ownerScopeId: ownerA,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeHistoricalGenerations: true,
        ),
      );

      expect(covResWithHist.heads.length, 1);
      final manifestIds = covResWithHist.manifests.map((m) => m.coverageId).toSet();
      expect(manifestIds, containsAll([cov1Id, cov2Id]));
      expect(covResWithHist.manifests.any((m) => m.servingState == ServingState.historical), isTrue);

      // 3. 查询 Owner B：只返回 Owner B 的 heads 与 manifests
      final covResB = await ports.coverageQuery.queryCoverage(
        CoverageStorageQuery(
          ownerScopeId: ownerB,
          profileIds: const [],
          chartSnapshotIds: const [],
          providerIds: const [],
          eventTypeIds: const [],
          range: fullRange,
          includeHistoricalGenerations: true,
        ),
      );
      expect(covResB.heads.length, 1);
      expect(covResB.heads.first.coverageSeriesId, 'series-cov-b1');
      expect(covResB.manifests.every((m) => m.coverageSeriesId == 'series-cov-b1'), isTrue);
    });
  });
}
