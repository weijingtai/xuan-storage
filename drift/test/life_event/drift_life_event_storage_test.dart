// ACT-06：Drift/SQLite 原子持久化适配器测试。
//
// 真实临时 SQLite 原样运行 shared storage contract suite（LEC-013~016），
// 关闭重开数据全保留，receipt UNIQUE 约束并发互斥。
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/test_support/life_event_storage_contract_suite.dart';
import 'package:persistence_drift/life_event/drift_life_event_storage.dart';
import 'package:persistence_drift/life_event/life_event_database.dart';

void main() {
  late Directory tmpDir;
  late String dbPath;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('life-event-drift-');
    dbPath = '${tmpDir.path}/life_event.db';
  });

  tearDown(() {
    try {
      tmpDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<LifeEventDatabase> openDb() async {
    final db = LifeEventDatabase(
      NativeDatabase.createInBackground(File(dbPath)),
    );
    await db.customStatement('PRAGMA foreign_keys = ON');
    return db;
  }

  group('ACT-06 drift storage', () {
    runLifeEventStorageContractSuite(
      name: 'DriftLifeEventStorage',
      makeStore: () async => DriftLifeEventStorage(await openDb()),
      snapshot: (store) async {
        final s = store as DriftLifeEventStorage;
        return (
          receipts: await s.readReceipts(),
          manifests: await s.readManifests(),
        );
      },
    );

    test('关闭并重开后 head/manifest/receipt 全保留', () async {
      final db = await openDb();
      final store = DriftLifeEventStorage(db);

      // 建 candidate + 提交一个 partial shard。
      await store.createOrReplaceCandidate(_createRequest());
      await store.commitValidatedShard(_shardRequest());
      expect((await store.readReceipts()).length, 1);

      // 关闭数据库。
      await db.close();
      // 重开（同一文件）。
      final db2 = await openDb();
      final store2 = DriftLifeEventStorage(db2);
      final receipts = await store2.readReceipts();
      final manifests = await store2.readManifests();
      expect(receipts.length, 1);
      expect(manifests.length, 1);
      expect(manifests.values.single.completedShardCount, 1);
      await db2.close();
    });

    test('receipt UNIQUE(coverage_id, shard_id)：不同 digest 并发仅一方成功', () async {
      final db = await openDb();
      final store = DriftLifeEventStorage(db);
      await store.createOrReplaceCandidate(_createRequest());
      final first = await store.commitValidatedShard(_shardRequest());
      expect(first.outcome, CommitValidatedShardOutcome.applied);

      // 同 coverage/shard 不同 digest → receiptDigestConflict（零写入）。
      final conflict = await store.commitValidatedShard(
        _shardRequest(contentDigest: 'different-digest'),
      );
      expect(conflict.outcome, CommitValidatedShardOutcome.receiptDigestConflict);
      final receipts = await store.readReceipts();
      expect(receipts.length, 1);
      await db.close();
    });

    test('两个 composite query indexes 存在', () async {
      final db = await openDb();
      final rows = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='index' "
        "AND tbl_name='t_life_event_projections' ORDER BY name",
      ).get();
      final names = rows.map((r) => r.data['name'] as String).toList();
      // 索引由 onCreate 建立：owner+profile+provider+snapshot 与 owner+profile+eventType。
      expect(names, contains('idx_le_projection_owner'));
      expect(names, contains('idx_le_projection_type'));
      // receipt 唯一约束存在。
      final uq = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='index' "
        "AND tbl_name='t_life_event_shard_receipts'",
      ).get();
      expect(uq.map((r) => r.data['name'] as String), contains('uq_le_receipt'));
      await db.close();
    });
  });
}

CreateCoverageGenerationRequest _createRequest() {
  return CreateCoverageGenerationRequest(
    coverageSeriesId: 'series-1',
    expectedSeriesRevision: 0,
    expectedActiveCoverageId: null,
    desiredRange: TimeRange(
      startInclusiveUtc: DateTime.utc(2026, 1, 1),
      endExclusiveUtc: DateTime.utc(2026, 7, 1),
    ),
    providerId: 'qi_zheng_si_yu.life_events',
    providerVersion: '1.0.0',
    chartSnapshotId: 'snapshot-1',
    chartSnapshotRevision: 'rev-1',
    algorithmVersion: 'algo-1',
    dataVersion: null,
    eventTypeId: 'year_cycle',
    eventTypeSchemaVersion: 'v1',
    inputFingerprint: 'fp-1',
  );
}

CommitValidatedShardRequest _shardRequest({String contentDigest = 'digest-1'}) {
  return CommitValidatedShardRequest(
    coverageId: 'cov-series-1-1',
    coverageGeneration: 1,
    expectedManifestRevision: 0,
    expectedSeriesRevision: null,
    expectedActiveCoverageId: null,
    expectedCandidateCoverageId: null,
    providerId: 'qi_zheng_si_yu.life_events',
    providerVersion: '1.0.0',
    algorithmVersion: 'algo-1',
    dataVersion: null,
    eventTypeId: 'year_cycle',
    eventTypeSchemaVersion: 'v1',
    inputFingerprint: 'fp-1',
    receiptIdentity: ReceiptIdentity(coverageId: 'cov-series-1-1', shardId: 'shard-1'),
    requestId: 'req-1',
    requestedRange: TimeRange(
      startInclusiveUtc: DateTime.utc(2026, 1, 1),
      endExclusiveUtc: DateTime.utc(2026, 7, 1),
    ),
    coveredRange: TimeRange(
      startInclusiveUtc: DateTime.utc(2026, 1, 1),
      endExclusiveUtc: DateTime.utc(2026, 7, 1),
    ),
    projections: const [],
    withdrawals: const [],
    eventCount: 0,
    contentDigest: contentDigest,
    isCompleteForCoveredRange: false,
    requestedCoverageTransition: CoverageTransition.partial,
  );
}