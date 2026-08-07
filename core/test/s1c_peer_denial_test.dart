import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_core/test_support/in_memory_stores.dart';
import 'package:test/test.dart';

/// S1c A8 契约测试：对端否决权必须真的能发生并被观测到。
///
/// 设计稿 §2.5 定稿：`SyncPeer.listChanges` 返回 [RemoteChangesResult]，
/// 对端可返回 [IncrementalUnavailable] 否决增量。发起方收到后必须：
/// 1. 强制切全量对齐（此处表现为上抛 invalidData 错误，由 SyncRuntime 接管编排）；
/// 2. 【不得推进游标】——这是 §1.1① 静默丢数据的直接防线。
///
/// 本测试保证否决分支真实可达：若有人把 [SyncCoordinator.pullOnce] 里的
/// `IncrementalUnavailable` 分支删掉（把它当普通空页处理），游标会被推进，
/// 本测试会红在「游标未被推进」断言上。
class _DenyingPeer implements SyncPeer {
  _DenyingPeer({required this.denial});

  final IncrementalUnavailable denial;

  @override
  PeerId get peerId => const PeerId('denier');

  @override
  Channel get channel => Channel.cloud;

  @override
  Future<SyncError?> push(OutboxRecord record) async => null;

  @override
  Future<RemoteChangesResult> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    return denial;
  }

  @override
  Future<PeerCapabilities> getCapabilities() async => PeerCapabilities(
        peerId: peerId,
        channel: channel,
        entityVersions: const {'layout_template': 1},
        supportedFeatures: const {'outbox_v1', 'tag_index_v1'},
        protocolVersion: 1,
      );
}

void main() {
  test(
      '对端返回 IncrementalUnavailable：游标不得推进、错误上抛、状态转 error',
      () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final stateStore = InMemorySyncStateStore();
    final coordinator = SyncCoordinator(
      outboxStore: InMemoryOutboxStore(),
      syncStateStore: stateStore,
      remoteGateway: _DenyingPeer(
        denial: const IncrementalUnavailable(
          peerId: PeerId('denier'),
          entityType: entityType,
          requesterCursor: null,
          reason: IncrementalUnavailableReason.behindRetention,
        ),
      ),
      localApplier: _AlwaysApplies(),
      nowUtc: () => now,
      pullBatchSize: 10,
    );

    final r = await coordinator.pullOnce(
      scopeUid: scopeUid,
      peerId: const PeerId('denier'),
      entityType: entityType,
    );

    // 1. 错误必须上抛（让上层切全量），不能静默吞掉。
    expect(r.lastError, isNotNull);
    expect(r.lastError!.code, equals(SyncErrorCode.invalidData));
    expect(r.lastError!.message, contains('full reconciliation required'));

    // 2. 状态必须转 error，而不是 idle。
    expect(coordinator.status.state, equals(SyncRunState.error));

    // 3. 【游标不得推进】——否决不等于"无变更"，推进游标会静默丢数据。
    expect(r.advanced, isFalse);
    final cursor = await stateStore.getCursor(
      scopeUid: scopeUid,
      peerId: const PeerId('denier'),
      entityType: entityType,
    );
    expect(cursor, isNull);
  });

  test('否决后 markPulledAt 不得被调用（lastError != null 时不记成功）', () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final stateStore = _CountingStateStore(InMemorySyncStateStore());
    final coordinator = SyncCoordinator(
      outboxStore: InMemoryOutboxStore(),
      syncStateStore: stateStore,
      remoteGateway: _DenyingPeer(
        denial: const IncrementalUnavailable(
          peerId: PeerId('denier'),
          entityType: entityType,
          requesterCursor: null,
          reason: IncrementalUnavailableReason.compactedAway,
        ),
      ),
      localApplier: _AlwaysApplies(),
      nowUtc: () => now,
      pullBatchSize: 10,
    );

    final r = await coordinator.pullOnce(
      scopeUid: scopeUid,
      peerId: const PeerId('denier'),
      entityType: entityType,
    );

    expect(r.lastError, isNotNull);
    // markPulledAt 只在 lastError == null 时发生（sync_coordinator.dart:468-475）。
    // 否决必带 lastError，故不得把本次当成一次成功拉取。
    expect(stateStore.markedPulledAt, equals(0));
  });
}

/// 计数委托：统计 [SyncStateStore.markPulledAt] 被调用次数。
class _CountingStateStore implements SyncStateStore {
  _CountingStateStore(this._inner);

  final SyncStateStore _inner;
  int markedPulledAt = 0;

  @override
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) {
    return _inner.getCursor(
      scopeUid: scopeUid,
      peerId: peerId,
      entityType: entityType,
    );
  }

  @override
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  }) {
    return _inner.setCursorIfNewer(
      scopeUid: scopeUid,
      peerId: peerId,
      entityType: entityType,
      cursor: cursor,
      atUtc: atUtc,
    );
  }

  @override
  Future<void> clear({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) {
    return _inner.clear(
      scopeUid: scopeUid,
      peerId: peerId,
      entityType: entityType,
    );
  }

  @override
  Future<void> markPulledAt({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required DateTime atUtc,
  }) async {
    markedPulledAt += 1;
    return _inner.markPulledAt(
      scopeUid: scopeUid,
      peerId: peerId,
      entityType: entityType,
      atUtc: atUtc,
    );
  }

  @override
  Future<void> markPushedAt({
    required String scopeUid,
    required PeerId peerId,
    required DateTime atUtc,
  }) {
    return _inner.markPushedAt(
      scopeUid: scopeUid,
      peerId: peerId,
      atUtc: atUtc,
    );
  }
}

/// 永不会到达的 applier —— 否决分支下不应有 apply 发生。
/// 若它真被调用，说明实现对否决当成了普通变更处理，测试应红。
class _AlwaysApplies implements LocalApplier {
  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    fail('对端否决增量时不应调用 applier，但 applyRemoteChanges 被调用了');
  }
}
