import 'package:persistence_core/logging/sync_logger.dart';
import 'package:persistence_core/model/peer_eligibility.dart';
import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/routing/peer_fanout_pusher.dart';


/// Coordinates one-off push and pull sync runs.
///
/// 功能说明：
/// - Push：将本地 outbox 的变更推送到远端（见 [pushOnce]）。
/// - Pull：从远端按 cursor 增量拉取变更并回填本地（见 [pullOnce]）。
/// - 状态：通过 [status] 暴露最近一次运行的状态与统计信息（backlog/dead/最近错误等）。
///
/// 约束与集成点：
/// - Push 仅依赖 [OutboxStore] 与 [SyncPeer]。
/// - Pull 需要额外注入 [SyncStateStore]（cursor 存储）与 [LocalApplier]（回填本地）。
/// - 调度/生命周期不在此类处理，应由上层（例如 SyncRuntime）负责。
class SyncCoordinator {
  /// Creates a [SyncCoordinator].
  ///
  /// 参数说明：
  /// - [outboxStore]: outbox 的数据源与状态回写。
  /// - [remoteGateway]: 远端读写网关，push 与 pull 都通过它访问远端。
  /// - [nowUtc]: UTC 时钟函数，用于写入 sync_state 的时间戳与状态时间。
  /// - [syncStateStore]: pull 所需的 cursor 存储（可选；未提供则 pull 不可用）。
  /// - [localApplier]: pull 所需的本地回填器（可选；未提供则 pull 不可用）。
  /// - [pushBatchSize]: 单次 push 的最大 outbox 处理条数。
  /// - [pullBatchSize]: 单次 pull 请求的默认 page size。
  /// - [maxAttemptsBeforeDead]: outbox 单条记录最大尝试次数，超过会标记为 dead。
  /// - [peerId]: 本对端标识。
  /// - [channel]: 本对端所在通道（§5.4 第一道锁）。默认 cloud。
  /// - [peers]: 参与扇出的全部对端（§5.2）。默认 `[remoteGateway]`（单对端回退）。
  ///   [remoteGateway] 仍单独保留，供 pull 与 getCapabilities 使用。
  SyncCoordinator({
    required OutboxStore outboxStore,
    required SyncPeer remoteGateway,
    required DateTime Function() nowUtc,
    SyncStateStore? syncStateStore,
    LocalApplier? localApplier,
    int pushBatchSize = 50,
    int pullBatchSize = 50,
    int maxAttemptsBeforeDead = 10,
    PeerId peerId = const PeerId('firestore'),
    Channel channel = Channel.cloud,
    List<SyncPeer>? peers,
    SyncLogger? logger,
  })  : _outboxStore = outboxStore,
        _syncStateStore = syncStateStore,
        _remoteGateway = remoteGateway,
        _localApplier = localApplier,
        _nowUtc = nowUtc,
        _pullBatchSize = pullBatchSize,
        _pushBatchSize = pushBatchSize,
        _maxAttemptsBeforeDead = maxAttemptsBeforeDead,
        _logger = logger ?? SyncLogger.noop(),
        _peerId = peerId,
        _channel = channel,
        _peers = peers ?? <SyncPeer>[remoteGateway],
        _status = const SyncStatus(
          state: SyncRunState.stopped,
          scopeUid: null,
          backlogCount: null,
          deadCount: null,
          lastSuccessAtUtc: null,
          lastError: null,
        );

  final OutboxStore _outboxStore;
  final SyncStateStore? _syncStateStore;
  final SyncPeer _remoteGateway;
  final LocalApplier? _localApplier;
  final DateTime Function() _nowUtc;
  final int _pullBatchSize;
  final int _pushBatchSize;
  final int _maxAttemptsBeforeDead;
  final SyncLogger _logger;
  final PeerId _peerId;
  final Channel _channel;
  final List<SyncPeer> _peers;
  SyncStatus _status;

  /// 当前参与扇出的对端。
  List<SyncPeer> get peers => List.unmodifiable(_peers);

  /// Returns the latest sync status snapshot.
  ///
  /// 用途：
  /// - UI/日志可以读取该字段以显示最新同步状态。
  /// - 如果需要响应式订阅，建议由上层（如 SyncRuntime）把状态转成 stream/notifier。
  SyncStatus get status => _status;

  /// Watches outbox backlog count (pending + failed) for [scopeUid] and [peerId].
  ///
  /// 用途：
  /// - 供上层 runtime 订阅，在 outbox 发生变化时触发 push。
  Stream<int> watchBacklogCount(
    String scopeUid, {
    required PeerId peerId,
    required Channel channel,
  }) {
    return _outboxStore.watchBacklogCount(
      scopeUid: scopeUid,
      peerId: peerId,
      channel: channel,
    );
  }

  /// Runs a single push pass from local outbox to remote.
  ///
  /// 参数说明：
  /// - [scopeUid]: 当前同步作用域（通常为用户 uid）。
  ///
  /// 返回值：
  /// - [OutboxPushRunResult]：推送过程的统计与最后错误。
  ///
  /// 状态更新规则：
  /// - 运行前：将 [status.state] 置为 syncing，并刷新 backlogCount/deadCount。
  /// - 运行后：
  ///   - 若无错误：state=idle，更新 lastSuccessAtUtc/lastPushAtUtc，并可写入 [SyncStateStore.markPushedAt]。
  ///   - 若有错误：state=error，保留 lastSuccessAtUtc/lastPushAtUtc，填充 lastError。
  Future<OutboxPushRunResult> pushOnce({required String scopeUid}) async {
    final sw = Stopwatch()..start();

    final backlogBefore = await _outboxStore.backlogCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel);
    final deadBefore = await _outboxStore.deadCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel);

    _logger.debug(
      'sync_push_start',
      data: <String, Object?>{
        'scopeUid': scopeUid,
        'backlogBefore': backlogBefore,
        'deadBefore': deadBefore,
      },
    );

    _status = _status.copyWith(
      state: SyncRunState.syncing,
      scopeUid: scopeUid,
      backlogCount: backlogBefore,
      deadCount: deadBefore,
      lastError: null,
    );

    final result = await _runPushPass(scopeUid: scopeUid);

    final backlog = await _outboxStore.backlogCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel);
    final deadCount = await _outboxStore.deadCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel);
    final atUtc = _nowUtc();

    if (!result.hasError) {
      final store = _syncStateStore;
      if (store != null) {
        await store.markPushedAt(
          scopeUid: scopeUid,
          peerId: _peerId,
          atUtc: atUtc,
        );
      }
    }

    _status = _status.copyWith(
      state: result.hasError ? SyncRunState.error : SyncRunState.idle,
      backlogCount: backlog,
      deadCount: deadCount,
      lastSuccessAtUtc: result.hasError ? _status.lastSuccessAtUtc : atUtc,
      lastPushAtUtc: result.hasError ? _status.lastPushAtUtc : atUtc,
      lastError: result.lastError,
    );

    if (result.hasError) {
      _logger.warn(
        'sync_push_fail',
        data: <String, Object?>{
          'scopeUid': scopeUid,
          'processed': result.processed,
          'succeeded': result.succeeded,
          'failed': result.failed,
          'dead': result.dead,
          'errorCode': result.lastError?.code.name,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: result.lastError,
      );
    } else {
      _logger.info(
        'sync_push_ok',
        data: <String, Object?>{
          'scopeUid': scopeUid,
          'processed': result.processed,
          'succeeded': result.succeeded,
          'failed': result.failed,
          'dead': result.dead,
          'backlogAfter': backlog,
          'durationMs': sw.elapsedMilliseconds,
        },
      );
    }

    return result;
  }

  /// 执行一次扇出推送（§5.2.1 阻断点 4/5 拆除后的核心路径）。
  ///
  /// 流程：
  /// 1. 对每个对端分别 peekBatch（该对端尚未 ack 的记录），按 operationId
  ///    合并去重 —— 某条记录对 cloud 已成功但对 lan 仍 pending 时，第二轮
  ///    peekBatch(cloud) 为空、peekBatch(lan) 仍含它，必须并集才不漏推。
  /// 2. 对每条记录用 ACT 05 的单一判定源算合格对端，[PeerFanoutPusher.pushToAll]
  ///    并发推给合格对端。
  /// 3. 逐对端回写 ack：成功 markSuccess，失败 markFailed。
  ///
  /// 规则：
  /// - 合格对端集合用 ACT 05 的单一判定源计算，【不要】在这里重写
  ///   `lookup(...).channels.contains(...)`（ACT 05 有门禁数该表达式次数）。
  /// - markFailed 的 attempt 用 ACT 04 的读取端口（按 operationId + peerId 读）
  ///   读该对端当前的尝试次数再 +1 —— 【不要】用 record.attempt（t_outbox
  ///   全局字段，ACT 04 已明确它不再被更新）。
  Future<OutboxPushRunResult> _runPushPass({required String scopeUid}) async {
    final byOperationId = <String, OutboxRecord>{};
    for (final peer in _peers) {
      final batch = await _outboxStore.peekBatch(
        scopeUid: scopeUid,
        peerId: peer.peerId,
        channel: peer.channel,
        limit: _pushBatchSize,
      );
      for (final r in batch) {
        byOperationId[r.operationId] = r;
      }
    }

    var processed = 0;
    var succeeded = 0;
    var failed = 0;
    var dead = 0;
    SyncError? lastError;

    for (final record in byOperationId.values) {
      final eligible =
          PeerEligibility.eligiblePeers(record.entityType, _peers);
      final results =
          await DefaultPeerFanoutPusher(peers: _peers)
              .pushToAll(record, eligiblePeers: eligible);

      for (final entry in results.entries) {
        final peerId = entry.key;
        final error = entry.value;
        final atUtc = _nowUtc();

        if (error == null) {
          await _outboxStore.markSuccess(
            operationId: record.operationId,
            peerId: peerId,
            atUtc: atUtc,
          );
          succeeded += 1;
        } else {
          lastError = error;
          failed += 1;

          final nextAttempt =
              await _outboxStore.attemptFor(
                operationId: record.operationId,
                peerId: peerId,
              ) +
              1;
          final isDead = nextAttempt >= _maxAttemptsBeforeDead;
          if (isDead) dead += 1;

          await _outboxStore.markFailed(
            operationId: record.operationId,
            peerId: peerId,
            attempt: nextAttempt,
            errorCode: error.code.name,
            errorMessage: error.message,
            atUtc: atUtc,
            isDead: isDead,
          );
        }
      }

      processed += 1;
    }

    return OutboxPushRunResult(
      processed: processed,
      succeeded: succeeded,
      failed: failed,
      dead: dead,
      lastError: lastError,
    );
  }

  /// Counts how many outcomes are [ChangeApplyDecision.skipped].
  ///
  /// 参数说明：
  /// - [outcomes]: 一次 pull 回填过程中产生的逐条决策结果。
  ///
  /// 返回值：
  /// - 被跳过的条数。
  int _countSkipped(List<ChangeApplyOutcome> outcomes) {
    var count = 0;
    for (final o in outcomes) {
      if (o.decision == ChangeApplyDecision.skipped) count += 1;
    }
    return count;
  }

  /// Runs a single pull pass for one entity type.
  ///
  /// 参数说明：
  /// - [scopeUid]: 当前同步作用域（通常为用户 uid）。
  /// - [entityType]: 要拉取的实体类型（例如 layout_template）。
  /// - [limit]: 单次远端请求的条数上限；不传则使用构造时的 [pullBatchSize]。
  /// - [maxPages]: 最大翻页次数，防止极端情况下长时间占用。
  ///
  /// 返回值：
  /// - [PullRunResult]：包含分页数、拉取条数、应用条数、跳过条数、是否推进 cursor，以及最后错误。
  ///
  /// 前置条件：
  /// - 该方法要求注入 [SyncStateStore] 与 [LocalApplier]，否则抛出 [StateError]。
  ///
  /// cursor 推进规则（关键）：
  /// - 只有当 [LocalApplier.applyRemoteChanges] 表示可以推进且无错误时，才会推进 cursor。
  /// - 推进使用 [SyncStateStore.setCursorIfNewer]，以避免倒退。
  /// - 本地回填失败时不得推进 cursor，防止数据丢失。
  Future<PullRunResult> pullOnce({
    required String scopeUid,
    required String entityType,
    int? limit,
    int maxPages = 100,
  }) async {
    final sw = Stopwatch()..start();

    _logger.debug(
      'sync_pull_start',
      data: <String, Object?>{
        'scopeUid': scopeUid,
        'entityType': entityType,
        'limit': limit,
        'maxPages': maxPages,
      },
    );

    final stateStore = _syncStateStore;
    final applier = _localApplier;

    if (stateStore == null || applier == null) {
      throw StateError('Pull requires syncStateStore and localApplier');
    }

    _status = _status.copyWith(
      state: SyncRunState.syncing,
      scopeUid: scopeUid,
      backlogCount: await _outboxStore.backlogCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel),
      deadCount: await _outboxStore.deadCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel),
      lastPullEntityType: entityType,
      lastPullOutcomes: const <ChangeApplyOutcome>[],
      lastError: null,
    );

    var cursor = await stateStore.getCursor(
      scopeUid: scopeUid,
      peerId: _peerId,
      entityType: entityType,
    );

    var pages = 0;
    var fetched = 0;
    var appliedCount = 0;
    var skippedCount = 0;
    var advanced = false;
    final outcomes = <ChangeApplyOutcome>[];
    SyncError? lastError;

    while (pages < maxPages) {
      final page = await _remoteGateway.listChanges(
        scopeUid: scopeUid,
        entityType: entityType,
        sinceCursor: cursor,
        limit: limit ?? _pullBatchSize,
      );

      pages += 1;
      fetched += page.changes.length;

      if (page.changes.isEmpty) break;

      final applyResult = await applier.applyRemoteChanges(
        scopeUid: scopeUid,
        entityType: entityType,
        changes: page.changes,
      );

      appliedCount += applyResult.appliedCount;
      outcomes.addAll(applyResult.outcomes);
      skippedCount += _countSkipped(applyResult.outcomes);

      if (!applyResult.canAdvanceCursor || applyResult.lastError != null) {
        lastError = applyResult.lastError ??
            const SyncError(
              code: SyncErrorCode.invalidData,
              message: 'applyRemoteChanges failed',
            );
        break;
      }

      if (page.nextCursor != null) {
        await stateStore.setCursorIfNewer(
          scopeUid: scopeUid,
          peerId: _peerId,
          entityType: entityType,
          cursor: page.nextCursor!,
          atUtc: _nowUtc(),
        );
        cursor = page.nextCursor;
        advanced = true;
      }

      if (!page.hasMore) break;
    }

    if (lastError == null) {
      await stateStore.markPulledAt(
        scopeUid: scopeUid,
        peerId: _peerId,
        entityType: entityType,
        atUtc: _nowUtc(),
      );
    }

    if (lastError != null) {
      _logger.warn(
        'sync_pull_fail',
        data: <String, Object?>{
          'scopeUid': scopeUid,
          'entityType': entityType,
          'pages': pages,
          'fetched': fetched,
          'applied': appliedCount,
          'skipped': skippedCount,
          'advanced': advanced,
          'errorCode': lastError.code.name,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: lastError,
      );
    } else {
      _logger.info(
        'sync_pull_ok',
        data: <String, Object?>{
          'scopeUid': scopeUid,
          'entityType': entityType,
          'pages': pages,
          'fetched': fetched,
          'applied': appliedCount,
          'skipped': skippedCount,
          'advanced': advanced,
          'durationMs': sw.elapsedMilliseconds,
        },
      );
    }

    final cappedOutcomes = outcomes.length <= 200
        ? outcomes
        : outcomes.sublist(outcomes.length - 200);

    _status = _status.copyWith(
      state: lastError == null ? SyncRunState.idle : SyncRunState.error,
      backlogCount: await _outboxStore.backlogCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel),
      deadCount: await _outboxStore.deadCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel),
      lastSuccessAtUtc:
          lastError == null ? _nowUtc() : _status.lastSuccessAtUtc,
      lastPullAtUtc: lastError == null ? _nowUtc() : _status.lastPullAtUtc,
      lastPullEntityType: entityType,
      lastPullOutcomes: cappedOutcomes,
      lastError: lastError,
    );

    return PullRunResult(
      pages: pages,
      fetched: fetched,
      applied: appliedCount,
      skipped: skippedCount,
      advanced: advanced,
      outcomes: outcomes,
      lastError: lastError,
    );
  }
}
