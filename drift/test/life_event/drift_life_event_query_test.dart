// ACT-05A-S: Drift 查询端口实现测试与索引验证
library;

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:persistence_core/test_support/life_event_query_contract_suite.dart';
import 'package:persistence_drift/life_event/drift_life_event_storage.dart';
import 'package:persistence_drift/life_event/life_event_database.dart';

void main() {
  setUpAll(() {
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('DriftLifeEventStorage 共享合同测试', () {
    runLifeEventQueryContractSuite(
      makeStorage: () async {
        final db = LifeEventDatabase(NativeDatabase.memory());
        return DriftLifeEventStorage(db);
      },
    );
  });

  group('CASE 6: EXPLAIN QUERY PLAN 索引验证', () {
    late LifeEventDatabase db;
    late DriftLifeEventStorage storage;

    setUp(() async {
      db = LifeEventDatabase(NativeDatabase.memory());
      storage = DriftLifeEventStorage(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('CASE 6: Drift 查询必须走 idx_le_projection_owner 或 idx_le_projection_type，禁止 SCAN TABLE', () async {
      // 预置一条数据触发 schema 初始化
      await db.into(db.lifeEventProjections).insert(
            LifeEventProjectionRow(
              projectionId: 'init-proj',
              coverageId: 'cov-1',
              coverageGeneration: 1,
              sourceProviderId: 'provider-1',
              sourceEventId: 'evt-1',
              eventRevision: 'r1',
              ownerScopeId: 'owner-1',
              subjectId: 'sub-1',
              profileId: 'prof-1',
              chartSnapshotId: 'snap-1',
              divinationTypeKey: 'div-key',
              subDivinationTypeKey: null,
              eventTypeId: 'type-1',
              effectiveStartMs: DateTime.utc(2026, 1, 1).millisecondsSinceEpoch,
              precisionRank: 0,
              projectionJson: '{}',
              lifecycleStatus: 0,
            ),
          );

      // 1. 类型查询：匹配 idx_le_projection_type
      final planType = await db.customSelect(
        'EXPLAIN QUERY PLAN '
        'SELECT * FROM t_life_event_projections '
        'WHERE owner_scope_id = ? AND profile_id = ? AND event_type_id = ? '
        'AND effective_start_ms >= ? AND effective_start_ms < ? '
        'AND (effective_start_ms, precision_rank, projection_id) > (?, ?, ?) '
        'ORDER BY effective_start_ms ASC, precision_rank ASC, projection_id ASC '
        'LIMIT 51',
        variables: [
          drift.Variable.withString('owner-1'),
          drift.Variable.withString('prof-1'),
          drift.Variable.withString('type-1'),
          drift.Variable.withInt(1000),
          drift.Variable.withInt(2000),
          drift.Variable.withInt(1000),
          drift.Variable.withInt(0),
          drift.Variable.withString(''),
        ],
      ).get();

      final planTypeStr = planType.map((r) => r.data['detail'] as String).join(' | ');
      expect(planTypeStr, contains('USING INDEX idx_le_projection_type'));
      expect(planTypeStr, isNot(contains('SCAN TABLE')));

      // 2. Owner 综合查询：匹配 idx_le_projection_owner
      final planOwner = await db.customSelect(
        'EXPLAIN QUERY PLAN '
        'SELECT * FROM t_life_event_projections '
        'WHERE owner_scope_id = ? AND profile_id = ? AND source_provider_id = ? AND chart_snapshot_id = ? '
        'AND effective_start_ms >= ? AND effective_start_ms < ? '
        'ORDER BY effective_start_ms ASC, precision_rank ASC, projection_id ASC '
        'LIMIT 51',
        variables: [
          drift.Variable.withString('owner-1'),
          drift.Variable.withString('prof-1'),
          drift.Variable.withString('provider-1'),
          drift.Variable.withString('snap-1'),
          drift.Variable.withInt(1000),
          drift.Variable.withInt(2000),
        ],
      ).get();

      final planOwnerStr = planOwner.map((r) => r.data['detail'] as String).join(' | ');
      expect(planOwnerStr, contains('USING INDEX idx_le_projection_owner'));
      expect(planOwnerStr, isNot(contains('SCAN TABLE')));

      // 3. 基础 owner 查询：走两条索引之一，绝不全表扫描
      final planBase = await db.customSelect(
        'EXPLAIN QUERY PLAN '
        'SELECT * FROM t_life_event_projections '
        'WHERE owner_scope_id = ? '
        'AND effective_start_ms >= ? AND effective_start_ms < ? '
        'ORDER BY effective_start_ms ASC, precision_rank ASC, projection_id ASC '
        'LIMIT 51',
        variables: [
          drift.Variable.withString('owner-1'),
          drift.Variable.withInt(1000),
          drift.Variable.withInt(2000),
        ],
      ).get();

      final planBaseStr = planBase.map((r) => r.data['detail'] as String).join(' | ');
      final usesIndex = planBaseStr.contains('idx_le_projection_type') ||
          planBaseStr.contains('idx_le_projection_owner');
      expect(usesIndex, isTrue, reason: '基础 owner 查询必须命中复合索引之一');
      expect(planBaseStr, isNot(contains('SCAN TABLE')));
    });

    test('Drift 201 条夹具五页遍历计数与无遗漏验证', () async {
      final ownerId = 'owner-201-drift';
      final range = TimeRange(
        startInclusiveUtc: DateTime.utc(2026, 1, 1),
        endExclusiveUtc: DateTime.utc(2027, 1, 1),
      );

      final createRes = await storage.createOrReplaceCandidate(
        CreateCoverageGenerationRequest(
          coverageSeriesId: 'series-drift-201',
          expectedSeriesRevision: 0,
          expectedActiveCoverageId: null,
          desiredRange: range,
          providerId: 'prov-1',
          providerVersion: '1.0.0',
          chartSnapshotId: 'snap-1',
          chartSnapshotRevision: 'v1',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: 'type-1',
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-201',
        ),
      );
      final covId = createRes.coverageId!;
      final covGen = createRes.coverageGeneration!;

      final baseTime = DateTime.utc(2026, 1, 1);
      final projections201 = List.generate(
        201,
        (i) => EventProjection(
          projectionId: 'drift-proj-${i.toString().padLeft(4, '0')}',
          projectionIdAlgorithmVersion: 'v1',
          coverageId: covId,
          coverageGeneration: covGen,
          sourceRef: SourceRef(providerId: 'prov-1', sourceEventId: 'e-$i', eventRevision: 'r1'),
          ownerScopeId: ownerId,
          subjectId: 'sub-1',
          profileId: 'prof-1',
          chartSnapshotId: 'snap-1',
          divinationTypeKey: 'div',
          subDivinationTypeKey: null,
          eventTypeId: 'type-1',
          eventTime: InstantTime(
            effectiveStartUtc: baseTime.add(Duration(hours: i)),
            instantUtc: baseTime.add(Duration(hours: i)),
            calculationTimezoneId: 'UTC',
            precision: TimePrecision.hour,
          ),
          projectedParticipants: const [],
          projectedFactValues: const [],
          factSummary: 'Summary $i',
          evidenceRef: 'ev-$i',
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
          projectionLifecycleStatus: ProjectionLifecycleStatus.active,
          indexedAt: DateTime.utc(2026, 9, 1),
        ),
      );

      await storage.commitValidatedShard(
        CommitValidatedShardRequest(
          coverageId: covId,
          coverageGeneration: covGen,
          expectedManifestRevision: 0,
          expectedSeriesRevision: 1,
          expectedActiveCoverageId: null,
          expectedCandidateCoverageId: covId,
          providerId: 'prov-1',
          providerVersion: '1.0.0',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: 'type-1',
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-201',
          receiptIdentity: ReceiptIdentity(coverageId: covId, shardId: 'shard-201'),
          requestId: 'req-201',
          requestedRange: range,
          coveredRange: range,
          projections: projections201,
          withdrawals: const [],
          eventCount: 201,
          contentDigest: 'digest-201',
          isCompleteForCoveredRange: true,
          requestedCoverageTransition: CoverageTransition.complete,
        ),
      );

      final pageCounts = <int>[];
      final readItems = <EventProjection>[];
      String? token;

      for (int page = 1; page <= 5; page++) {
        final res = await storage.queryProjections(
          ProjectionStorageQuery(
            ownerScopeId: ownerId,
            profileIds: const [],
            chartSnapshotIds: const [],
            providerIds: const [],
            eventTypeIds: const [],
            range: range,
            includeWithdrawn: false,
            includeHistoricalGenerations: false,
            sortKey: 'effectiveStart',
            pageToken: token,
            pageSize: 50,
          ),
        );
        pageCounts.add(res.items.length);
        readItems.addAll(res.items);
        token = res.nextPageToken;

        if (page < 5) {
          expect(res.items.length, 50);
          expect(res.nextPageToken, isNotNull);
        } else {
          expect(res.items.length, 1);
          expect(res.nextPageToken, isNull);
        }
      }

      expect(pageCounts, [50, 50, 50, 50, 1]);
      expect(readItems.length, 201);
      expect(readItems.map((e) => e.projectionId).toList(),
          projections201.map((e) => e.projectionId).toList());
    });
  });
}
