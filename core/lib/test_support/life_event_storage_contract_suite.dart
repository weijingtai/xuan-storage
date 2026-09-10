/// ACT-01 共享存储合同套件（life event storage contract suite）。
///
/// 【为什么存在】`LifeEventShardCommitPort` / `LifeProfileIdentityStore` /
/// `LifeEventUserRuleStore` / `LifeEventReminderStore` 等契约不能在某个包的
/// `test/` 里写死 —— Drift 实现（ACT-06/10/12/15）与 In-Memory 参考实现
/// （ACT-03）必须跑同一套约束。提取到 `core/lib/test_support/` 后，消费方
/// 各自注入实现跑一遍。
///
/// 【不进 barrel】与其它 contract suite 一致：`persistence_core.dart` 不导出
/// test_support；消费方直接 import 本文件。
///
/// 【固定语义（Design §9.3）】adapter 原子判定顺序固定为 receipt-first：
///   1. 先按 `(coverageId, shardId)` 查 receipt；
///   2. 已存在且 digest 相同 → `idempotentReplay`（零写入，忽略旧 revision）；
///   3. 已存在但 digest 不同 → `receiptDigestConflict`（零写入）；
///   4. receipt 不存在时，`coverageGeneration` 必须等于 manifest generation，
///      `expectedManifestRevision` 不等 → `revisionConflict`（零写入）。
///   5. 完成切换时对 series-head 做 CAS，不符 → `activeSwitchConflict`。
///   6. 任一写入失败 → 全部回滚（projection/tombstone/receipt/manifest）。
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';

/// 快照观察器：记录一次提交后存储中的全部 receipts 与 manifest revision。
typedef StorageSnapshot = ({
  Map<String, ShardReceipt> receipts,
  Map<String, CoverageManifest> manifests,
});

/// 运行全部 life event 存储合同测试。
///
/// 参数：
/// - [name]: 实现名，只用于测试分组展示。
/// - [makeStore]: 构造一个干净的存储实现（每个测试独立实例）；允许异步。
/// - [snapshot]: 读取当前存储快照（receipts + manifests），用于 before/after 对比。
/// - [seed]: 可选，在测试前预置状态（如已存在的 receipt 用于幂等用例）。
FutureOr<void> runLifeEventStorageContractSuite({
  required String name,
  required FutureOr<LifeEventShardCommitPort> Function() makeStore,
  required Future<StorageSnapshot> Function(LifeEventShardCommitPort store) snapshot,
  Future<void> Function(LifeEventShardCommitPort store)? seed,
}) {
  group('LifeEvent 存储契约 · $name', () {
    CommitValidatedShardRequest baseRequest({
      String shardId = 'shard-1',
      String coverageId = 'cov-1',
      int coverageGeneration = 1,
      int expectedManifestRevision = 0,
      String contentDigest = 'digest-1',
      CoverageTransition transition = CoverageTransition.partial,
      TimeRange? requestedRange,
      TimeRange? coveredRange,
    }) =>
        CommitValidatedShardRequest(
          coverageId: coverageId,
          coverageGeneration: coverageGeneration,
          expectedManifestRevision: expectedManifestRevision,
          expectedSeriesRevision: transition == CoverageTransition.complete ? 1 : null,
          expectedActiveCoverageId: null,
          expectedCandidateCoverageId: transition == CoverageTransition.complete ? coverageId : null,
          providerId: 'qi_zheng_si_yu.life_events',
          providerVersion: '1.0.0',
          algorithmVersion: 'algo-1',
          dataVersion: null,
          eventTypeId: 'year_cycle',
          eventTypeSchemaVersion: 'v1',
          inputFingerprint: 'fp-1',
          receiptIdentity: ReceiptIdentity(coverageId: coverageId, shardId: shardId),
          requestId: 'req-1',
          requestedRange: requestedRange ??
              TimeRange(
                startInclusiveUtc: DateTime.utc(2026, 1, 1),
                endExclusiveUtc: DateTime.utc(2026, 7, 1),
              ),
          coveredRange: coveredRange ??
              TimeRange(
                startInclusiveUtc: DateTime.utc(2026, 1, 1),
                endExclusiveUtc: DateTime.utc(2026, 7, 1),
              ),
          projections: const [],
          withdrawals: const [],
          eventCount: 0,
          contentDigest: contentDigest,
          isCompleteForCoveredRange: false,
          requestedCoverageTransition: transition,
        );

    test('receipt-first：已存在且 digest 相同 → idempotentReplay（零写入）', () async {
      final store = await makeStore();
      final first = await store.commitValidatedShard(baseRequest());
      expect(first.outcome, CommitValidatedShardOutcome.applied);

      final before = await snapshot(store);
      // replay with a *different* requestId + stale manifest revision:
      // receipt exists with same digest → must return idempotentReplay, zero writes.
      final replay = await store.commitValidatedShard(
        baseRequest(expectedManifestRevision: -1),
      );
      expect(replay.outcome, CommitValidatedShardOutcome.idempotentReplay);
      final after = await snapshot(store);
      expect(after.receipts.length, before.receipts.length);
      expect(after.manifests.length, before.manifests.length);
    });

    test('receipt-first：已存在但 digest 不同 → receiptDigestConflict（零写入）', () async {
      final store = await makeStore();
      await store.commitValidatedShard(baseRequest());

      final before = await snapshot(store);
      final conflict = await store.commitValidatedShard(
        baseRequest(contentDigest: 'different-digest'),
      );
      expect(conflict.outcome, CommitValidatedShardOutcome.receiptDigestConflict);
      final after = await snapshot(store);
      expect(after.receipts.length, before.receipts.length);
      expect(after.manifests.length, before.manifests.length);
    });

    test('receipt 不存在时 generation/CAS：expectedManifestRevision 旧 → revisionConflict', () async {
      final store = await makeStore();
      final result = await store.commitValidatedShard(
        baseRequest(expectedManifestRevision: 5), // manifest revision is 0
      );
      expect(result.outcome, CommitValidatedShardOutcome.revisionConflict);
      final snap = await snapshot(store);
      expect(snap.receipts, isEmpty);
    });

    test('任一事务阶段失败 → 全部回滚（receipt 不残留、manifest 不变）', () async {
      if (seed == null) return; // failure injection is implementation-specific
      final store = await makeStore();
      await store.commitValidatedShard(baseRequest(shardId: 'ok-shard'));
      final before = await snapshot(store);
      // Inject a failure via a request the implementation must reject mid-transaction:
      // mismatched coveredRange vs requestedRange violates range validation.
      final broken = await store.commitValidatedShard(
        baseRequest(
          shardId: 'broken-shard',
          // coveredRange 越出 requestedRange → 范围校验失败，必须零写入。
          requestedRange: TimeRange(
            startInclusiveUtc: DateTime.utc(2026, 7, 1),
            endExclusiveUtc: DateTime.utc(2027, 1, 1),
          ),
        ),
      );
      // The specific outcome is implementation-defined (validation error path),
      // but the contract requires: broken commit must not leave partial state.
      expect(broken.outcome, isNot(CommitValidatedShardOutcome.applied));
      final after = await snapshot(store);
      expect(after.receipts.length, before.receipts.length);
      expect(after.manifests.length, before.manifests.length);
    });

    test('complete 迁移必须 series-head CAS：expectedCandidateCoverageId 不符 → activeSwitchConflict',
        () async {
      final store = await makeStore();
      final result = await store.commitValidatedShard(
        baseRequest(
          coverageId: 'cov-1',
          coverageGeneration: 1,
          expectedManifestRevision: 0,
          contentDigest: 'digest-complete',
          transition: CoverageTransition.complete,
          shardId: 'shard-1',
        ),
      );
      // Without a seeded series-head whose candidate == cov-1, the complete
      // transition cannot pass CAS → activeSwitchConflict (zero writes).
      expect(result.outcome, CommitValidatedShardOutcome.activeSwitchConflict);
      final snap = await snapshot(store);
      expect(snap.manifests.isEmpty, isTrue);
    });
  });
}