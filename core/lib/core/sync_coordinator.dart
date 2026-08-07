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
  /// - [onlyPeers]: 【可选】仅推这些对端。SyncRuntime 用它跳过退避中的对端
  ///   （§5.2.2）—— 不在退避窗口的 peer 才参与本轮推送。
  ///
  /// 返回值：
  /// - [List] of [PeerPushOutcome]：每个参与对端一条结果（§5.2.2）。
  ///   不再压成单个聚合结果 —— 调用方（SyncRuntime）据此逐对端记退避。
  ///
  /// 状态更新规则：
  /// - 运行前：将 [status.state] 置为 syncing，并刷新 backlogCount/deadCount。
  /// - 运行后：
  ///   - 若有任一对端失败：state=error，保留 lastSuccessAtUtc，填充 lastError。
  ///   - 若全部成功：state=idle，更新 lastSuccessAtUtc/lastPushAtUtc，
  ///     并可写入 [SyncStateStore.markPushedAt]。
  Future<List<PeerPushOutcome>> pushOnce({
    required String scopeUid,
    Set<PeerId>? onlyPeers,
  }) async {
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

    final outcomes = await _runPushPass(scopeUid: scopeUid, onlyPeers: onlyPeers);

    final backlog = await _outboxStore.backlogCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel);
    final deadCount = await _outboxStore.deadCount(scopeUid: scopeUid, peerId: _peerId, channel: _channel);
    final atUtc = _nowUtc();

    final anyError = outcomes.any((o) => o.hasError);
    SyncError? lastError;
    for (final o in outcomes) {
      final e = o.lastError;
      if (e != null) {
        lastError = e;
        break;
      }
    }

    if (!anyError) {
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
      state: anyError ? SyncRunState.error : SyncRunState.idle,
      backlogCount: backlog,
      deadCount: deadCount,
      lastSuccessAtUtc: anyError ? _status.lastSuccessAtUtc : atUtc,
      lastPushAtUtc: anyError ? _status.lastPushAtUtc : atUtc,
      lastError: lastError,
    );

    if (anyError) {
      _logger.warn(
        'sync_push_fail',
        data: <String, Object?>{
          'scopeUid': scopeUid,
          'outcomes': outcomes.length,
          'errorCode': lastError?.code.name,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: lastError,
      );
    } else {
      _logger.info(
        'sync_push_ok',
        data: <String, Object?>{
          'scopeUid': scopeUid,
          'outcomes': outcomes.length,
          'backlogAfter': backlog,
          'durationMs': sw.elapsedMilliseconds,
        },
      );
    }

    return outcomes;
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
  Future<List<PeerPushOutcome>> _runPushPass({
    required String scopeUid,
    Set<PeerId>? onlyPeers,
  }) async {
    final activePeers = onlyPeers == null
        ? _peers
        : _peers.where((p) => onlyPeers.contains(p.peerId)).toList();

    final byOperationId = <String, OutboxRecord>{};
    for (final peer in activePeers) {
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

    final successByPeer = <PeerId, int>{};
    final failByPeer = <PeerId, int>{};
    final lastErrorByPeer = <PeerId, SyncError>{};

    for (final record in byOperationId.values) {
      final eligible =
          PeerEligibility.eligiblePeers(record.entityType, activePeers);
      final results =
          await DefaultPeerFanoutPusher(peers: activePeers)
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
          successByPeer[peerId] = (successByPeer[peerId] ?? 0) + 1;
        } else {
          lastErrorByPeer[peerId] = error;

          final nextAttempt =
              await _outboxStore.attemptFor(
                operationId: record.operationId,
                peerId: peerId,
              ) +
              1;
          final isDead = nextAttempt >= _maxAttemptsBeforeDead;

          await _outboxStore.markFailed(
            operationId: record.operationId,
            peerId: peerId,
            attempt: nextAttempt,
            errorCode: error.code.name,
            errorMessage: error.message,
            atUtc: atUtc,
            isDead: isDead,
          );
          failByPeer[peerId] = (failByPeer[peerId] ?? 0) + 1;
        }
      }
    }

    return activePeers.map((peer) {
      final peerId = peer.peerId;
      return PeerPushOutcome(
        peerId: peerId,
        succeeded: successByPeer[peerId] ?? 0,
        failed: failByPeer[peerId] ?? 0,
        lastError: lastErrorByPeer[peerId],
      );
    }).toList(growable: false);
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
    required PeerId peerId,
    required String entityType,
    int? limit,
    int maxPages = 100,
  }) async {
    final sw = Stopwatch()..start();

    _logger.debug(
      'sync_pull_start',
      data: <String, Object?>{
        'scopeUid': scopeUid,
        'peerId': peerId.value,
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
      backlogCount: await _outboxStore.backlogCount(scopeUid: scopeUid, peerId: peerId, channel: _channel),
      deadCount: await _outboxStore.deadCount(scopeUid: scopeUid, peerId: peerId, channel: _channel),
      lastPullEntityType: entityType,
      lastPullOutcomes: const <ChangeApplyOutcome>[],
      lastError: null,
    );

    var cursor = await stateStore.getCursor(
      scopeUid: scopeUid,
      peerId: peerId,
      entityType: entityType,
    );

    // 按传入的 peerId 找对应对端的 gateway（§5.2.2 pull 按对端各自的游标拉）。
    // 找不到时回退到 remoteGateway（单对端时代的行为）。
    SyncPeer pullGateway = _remoteGateway;
    for (final p in _peers) {
      if (p.peerId == peerId) {
        pullGateway = p;
        break;
      }
    }

    var pages = 0;
    var fetched = 0;
    var appliedCount = 0;
    var skippedCount = 0;
    var advanced = false;
    final outcomes = <ChangeApplyOutcome>[];
    SyncError? lastError;

    while (pages < maxPages) {
      final result = await pullGateway.listChanges(
        scopeUid: scopeUid,
        entityType: entityType,
        sinceCursor: cursor,
        limit: limit ?? _pullBatchSize,
      );

      // S1c §2.5：对端否决增量时强制切全量对齐，且【不得推进游标】。
      // 空页/正常页会推进游标；IncrementalUnavailable 在这里以 lastError
      // 上抛，由上层（SyncRuntime）决定转全量对齐编排。
      if (result case final IncrementalUnavailable unavailable) {
        lastError = SyncError(
          code: SyncErrorCode.invalidData,
          message:
              'Peer ${unavailable.peerId.value} denied incremental sync '
              'for $entityType (${unavailable.reason.name}); '
              'full reconciliation required',
        );
        break;
      }
      final page = result as RemoteChangesPage;

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
          peerId: peerId,
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
        peerId: peerId,
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
      backlogCount: await _outboxStore.backlogCount(scopeUid: scopeUid, peerId: peerId, channel: _channel),
      deadCount: await _outboxStore.deadCount(scopeUid: scopeUid, peerId: peerId, channel: _channel),
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
