import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';

/// S1c ACT-E 契约测试：ReconciliationTrigger 触发判定。
///
/// 覆盖三种触发条件：
/// 1. 对端否决增量（IncrementalUnavailable）→ 全量。
/// 2. 本地从未拉取过（lastPulledAtUtc=null）→ 全量。
/// 3. 距上次拉取超过 90 天阈值 → 全量。
/// 4. 阈值内正常增量 → 增量。
void main() {
  final now = DateTime.utc(2026, 8, 6);

  test('peer_denies_incremental_forces_full', () {
    const trigger = ReconciliationTrigger();
    final decision = trigger.decide(
      lastPullResult: const IncrementalUnavailable(
        peerId: PeerId('peer'),
        entityType: 'record_meta',
        requesterCursor: null,
        peerRetentionFloorUtc: null,
        reason: IncrementalUnavailableReason.behindRetention,
      ),
      lastPulledAtUtc: now.subtract(const Duration(hours: 1)),
      nowUtc: now,
    );
    expect(decision, ReconciliationDecision.fullReconcile);
  });

  test('never_pulled_forces_full', () {
    const trigger = ReconciliationTrigger();
    final decision = trigger.decide(
      lastPullResult: null,
      lastPulledAtUtc: null,
      nowUtc: now,
    );
    expect(decision, ReconciliationDecision.fullReconcile);
  });

  test('beyond_interval_forces_full', () {
    const trigger = ReconciliationTrigger(
      fullReconcileInterval: Duration(days: 90),
    );
    final decision = trigger.decide(
      lastPullResult: null,
      lastPulledAtUtc: now.subtract(const Duration(days: 91)),
      nowUtc: now,
    );
    expect(decision, ReconciliationDecision.fullReconcile);
  });

  test('within_interval_uses_incremental', () {
    const trigger = ReconciliationTrigger(
      fullReconcileInterval: Duration(days: 90),
    );
    final decision = trigger.decide(
      lastPullResult: null,
      lastPulledAtUtc: now.subtract(const Duration(days: 1)),
      nowUtc: now,
    );
    expect(decision, ReconciliationDecision.incremental);
  });

  test('exactly_at_interval_boundary_uses_incremental', () {
    const trigger = ReconciliationTrigger(
      fullReconcileInterval: Duration(days: 90),
    );
    final decision = trigger.decide(
      lastPullResult: null,
      lastPulledAtUtc: now.subtract(const Duration(days: 90)),
      nowUtc: now,
    );
    expect(decision, ReconciliationDecision.incremental,
        reason: '恰好等于阈值不触发全量（> 才触发）');
  });

  test('successful_pull_within_interval_uses_incremental', () {
    const trigger = ReconciliationTrigger();
    final decision = trigger.decide(
      lastPullResult: RemoteChangesPage(
        changes: const [],
        nextCursor: null,
        hasMore: false,
      ),
      lastPulledAtUtc: now.subtract(const Duration(hours: 2)),
      nowUtc: now,
    );
    expect(decision, ReconciliationDecision.incremental);
  });
}
