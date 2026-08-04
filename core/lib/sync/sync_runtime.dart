import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:persistence_core/core/sync_coordinator.dart';
import 'package:persistence_core/logging/sync_logger.dart';
import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/sync/peer_registry.dart';

/// A pure-Dart runtime wrapper around [SyncCoordinator].
///
/// Why this exists:
/// - [SyncCoordinator] provides single-run primitives (`pushOnce`, `pullOnce`).
/// - Apps typically need lifecycle + scheduling glue: start/stop, periodic runs,
///   online/offline gating, scope(uid) switching, and a status stream.
/// - This runtime remains framework-agnostic (no Flutter / Provider dependency).
///
/// Integration guidance:
/// - Flutter/app layer should translate lifecycle events into:
///   - [setScopeUid] on login/logout
///   - [setOnline] on connectivity changes
///   - [start]/[stop] on app foreground/background if desired
class SyncRuntime {
  /// Creates a [SyncRuntime].
  ///
  /// Parameters:
  /// - [coordinator]: The core sync engine. Must be configured with the
  ///   appropriate `OutboxStore`, `SyncPeer`, and optionally
  ///   `SyncStateStore` + `LocalApplier` if pull is used.
  /// - [authScopeProvider]: Optional. If provided, [start] can auto-resolve the
  ///   current scope uid by calling it when scope is not set explicitly.
  /// - [pushInterval]: Period between automatic push attempts.
  /// - [pullInterval]: Period between automatic pull attempts (per entityType).
  /// - [minBackoff]: Base delay used after failures before the next attempt.
  /// - [maxBackoff]: Maximum delay cap used after repeated failures.
  /// - [nowUtc]: Clock source used for scheduling/backoff decisions.
  /// - [peerId]: 本对端标识（默认 firestore/cloud）。
  /// - [channel]: 本对端所在通道（§5.4 第一道锁）。默认 cloud。
  /// - [peerRegistry]: 对端集合入口。提供时，runtime 订阅其变更流，
  ///   在 peer 被移除时清理该 peer 的退避分片（§5.2.2）。
  SyncRuntime({
    required SyncCoordinator coordinator,
    AuthScopeProvider? authScopeProvider,
    bool enablePush = true,
    bool enablePushTimer = true,
    Duration pushInterval = const Duration(seconds: 10),
    Duration pullInterval = const Duration(seconds: 30),
    Duration minBackoff = const Duration(seconds: 2),
    Duration maxBackoff = const Duration(minutes: 2),
    DateTime Function()? nowUtc,
    PeerId peerId = const PeerId('firestore'),
    Channel channel = Channel.cloud,
    PeerRegistry? peerRegistry,
    SyncLogger? logger,
  })  : _coordinator = coordinator,
        _authScopeProvider = authScopeProvider,
        _pushEnabled = enablePush,
        _pushTimerEnabled = enablePushTimer,
        _pushInterval = pushInterval,
        _pullInterval = pullInterval,
        _minBackoff = minBackoff,
        _maxBackoff = maxBackoff,
        _logger = logger ?? SyncLogger.noop(),
        _nowUtc = nowUtc ?? DateTime.now().toUtc,
        _peerId = peerId,
        _channel = channel,
        _peerRegistry = peerRegistry;

  final SyncCoordinator _coordinator;
  final AuthScopeProvider? _authScopeProvider;
  final bool _pushEnabled;
  final bool _pushTimerEnabled;
  final Duration _pushInterval;
  final Duration _pullInterval;
  final Duration _minBackoff;
  final Duration _maxBackoff;
  final SyncLogger _logger;
  final DateTime Function() _nowUtc;
  final PeerId _peerId;
  final Channel _channel;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  Timer? _pushTimer;
  Timer? _pullTimer;
  Timer? _pushBackoffTimer;
  DateTime? _pushBackoffFireAtUtc;

  StreamSubscription<int>? _pushBacklogSub;

  Future<void> _serial = Future<void>.value();

  bool _started = false;
  bool _online = true;
  bool _disposed = false;

  String? _scopeUid;
  List<String> _pullEntityTypes = const <String>[];

  /// 每个对端下次允许 push 的时刻。键为对端标识。
  ///
  /// 【per-peer】：某个对端退避【不得】影响其他对端 —— 否则一个不可达的
  /// LAN peer 会把云端 push 一起拖进退避窗口（§5.2.2）。
  final Map<PeerId, DateTime?> _nextPushNotBeforeUtc = <PeerId, DateTime?>{};

  /// 每个对端的连续失败次数。键为对端标识。
  final Map<PeerId, int> _pushFailureCount = <PeerId, int>{};

  /// 每个 (对端, entityType) 的拉取退避时刻。键用 Dart record。
  ///
  /// 【为什么用 record 而非字符串拼接】：peerId 含分隔符时拼字符串会串键。
  final Map<(PeerId, String), DateTime?> _nextPullNotBeforeByEntityType =
      <(PeerId, String), DateTime?>{};

  /// 每个 (对端, entityType) 的拉取连续失败次数。
  final Map<(PeerId, String), int> _pullFailureCountByEntityType =
      <(PeerId, String), int>{};

  final PeerRegistry? _peerRegistry;
  StreamSubscription<Set<PeerId>>? _peerRegistrySub;

  /// A broadcast stream of the latest [SyncStatus].
  ///
  /// Emission points:
  /// - When [start]/[stop] changes runtime state.
  /// - After each push/pull attempt completes (success or error).
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Returns the most recent status snapshot from the underlying coordinator.
  ///
  /// This is a snapshot getter; for reactive UI/logging prefer [statusStream].
  SyncStatus get status => _coordinator.status;

  /// Returns whether the runtime is currently started.
  bool get isStarted => _started;

  /// Returns current online flag used for gating push/pull.
  ///
  /// This does not perform connectivity checks. Use [setOnline] to update.
  bool get isOnline => _online;

  /// Returns the currently configured scope uid.
  ///
  /// Convention:
  /// - `uid` is typically the Firebase Auth uid.
  /// - When null, the runtime will not push/pull.
  String? get scopeUid => _scopeUid;

  /// Returns the entity types configured for automatic pull.
  List<String> get pullEntityTypes =>
      List<String>.unmodifiable(_pullEntityTypes);

  /// Starts periodic scheduling.
  ///
  /// Behavior:
  /// - If [scopeUid] is provided, sets scope immediately.
  /// - Else if no scope is set and [AuthScopeProvider] was provided, resolves it
  ///   once during start.
  /// - Schedules periodic push and pull ticks.
  ///
  /// Idempotency:
  /// - Calling [start] multiple times is safe; it re-arms timers.
  Future<void> start({String? scopeUid}) async {
    await _enqueue(() async {
      _ensureNotDisposed();

      _logger.debug(
        'sync_runtime_start',
        data: <String, Object?>{
          'scopeUidParam': scopeUid,
          'startedBefore': _started,
          'online': _online,
          'pushEnabled': _pushEnabled,
          'pushTimerEnabled': _pushTimerEnabled,
          'pullEntityTypes': List<String>.of(_pullEntityTypes),
        },
      );

      _started = true;
      if (scopeUid != null) _scopeUid = scopeUid;

      if (_scopeUid == null) {
        final provider = _authScopeProvider;
        if (provider != null) {
          _scopeUid = await provider.getScopeUid();
        }
      }

      _armPeerRegistryWatcher();
      _armTimers();
      _emitStatus(_coordinator.status);

      _logger.debug(
        'sync_runtime_started',
        data: <String, Object?>{
          'scopeUid': _scopeUid,
          'online': _online,
          'pushEnabled': _pushEnabled,
          'pushTimerEnabled': _pushTimerEnabled,
          'pullEntityTypes': List<String>.of(_pullEntityTypes),
        },
      );

      if (_pushEnabled) {
        await _maybeRunPush(reason: 'start');
      }
      await _maybeRunPullAll(reason: 'start');
    });
  }

  /// Stops periodic scheduling.
  ///
  /// Behavior:
  /// - Cancels timers.
  /// - Does not clear local state (scope uid, failure counters) by default.
  ///   If you want to clear scope, call [setScopeUid] with null.
  Future<void> stop() async {
    await _enqueue(() async {
      _ensureNotDisposed();

      _logger.debug(
        'sync_runtime_stop',
        data: <String, Object?>{
          'scopeUid': _scopeUid,
          'online': _online,
        },
      );

      _started = false;
      _cancelTimers();

      _emitStatus(
        _coordinator.status.copyWith(
          state: SyncRunState.stopped,
        ),
      );
    });
  }

  /// Disposes internal resources.
  ///
  /// After disposal:
  /// - All timers are cancelled
  /// - [statusStream] is closed
  /// - All public methods will throw [StateError]
  Future<void> dispose() async {
    await _enqueue(() async {
      if (_disposed) return;

      _cancelTimers();
      unawaited(_peerRegistrySub?.cancel());
      _peerRegistrySub = null;
      _disposed = true;
      await _statusController.close();
    });
  }

  /// Sets the online flag used to gate push/pull operations.
  ///
  /// Typical usage:
  /// - App listens to connectivity; call `setOnline(true/false)` accordingly.
  /// - When switching from offline to online, runtime triggers an immediate push
  ///   and pull-all attempt (subject to backoff).
  Future<void> setOnline(bool online) async {
    await _enqueue(() async {
      _ensureNotDisposed();

      final changed = _online != online;
      final before = _online;
      _online = online;

      _logger.debug(
        'sync_runtime_online_set',
        data: <String, Object?>{
          'before': before,
          'after': online,
          'changed': changed,
          'started': _started,
          'scopeUid': _scopeUid,
        },
      );

      _emitStatus(_coordinator.status);

      if (changed && !online) {
        _cancelPushBackoffTimer();
      }

      if (changed && online) {
        if (_pushEnabled) {
          await _maybeRunPush(reason: 'online');
        }
        await _maybeRunPullAll(reason: 'online');
      }
    });
  }

  /// Sets the current scope uid.
  ///
  /// Typical usage:
  /// - Login: `setScopeUid(uid)` then [start] or call [triggerPullAll].
  /// - Logout: `setScopeUid(null)` then [stop] or keep started (it will noop).
  ///
  /// Behavior:
  /// - Updates internal scope.
  /// - Triggers an immediate push and pull-all attempt if started and online.
  Future<void> setScopeUid(String? scopeUid) async {
    await _enqueue(() async {
      _ensureNotDisposed();

      final before = _scopeUid;
      final changed = _scopeUid != scopeUid;
      _scopeUid = scopeUid;

      _logger.debug(
        'sync_runtime_scope_set',
        data: <String, Object?>{
          'before': before,
          'after': scopeUid,
          'changed': changed,
          'started': _started,
          'online': _online,
        },
      );

      if (changed) {
        _resetBackoff();
      }

      _emitStatus(
        _coordinator.status.copyWith(
          scopeUid: scopeUid,
        ),
      );

      if (changed) {
        _armPushBacklogWatcher();
      }

      if (_started && _online && _scopeUid != null) {
        if (_pushEnabled) {
          await _maybeRunPush(reason: 'scope');
        }
        await _maybeRunPullAll(reason: 'scope');
      }
    });
  }

  /// Configures which entity types should be pulled periodically.
  ///
  /// Notes:
  /// - Pull only works if [SyncCoordinator] was created with `syncStateStore`
  ///   and `localApplier`. Otherwise, pull methods will throw.
  /// - Changing the list resets pull backoff per entityType and can optionally
  ///   trigger a pull.
  Future<void> setPullEntityTypes(
    List<String> entityTypes, {
    bool triggerImmediately = true,
  }) async {
    await _enqueue(() async {
      _ensureNotDisposed();

      _pullEntityTypes = List<String>.unmodifiable(
        entityTypes.where((e) => e.trim().isNotEmpty).toSet().toList()..sort(),
      );

      // 键从 entityType 变成 (peerId, entityType)：先清掉不再订阅的 entityType，
      // 再为【每个已知对端】补上新的 (peerId, entityType) 占位。
      _nextPullNotBeforeByEntityType.removeWhere(
        (k, _) => !_pullEntityTypes.contains(k.$2),
      );
      _pullFailureCountByEntityType.removeWhere(
        (k, _) => !_pullEntityTypes.contains(k.$2),
      );

      final knownPeers = _peerRegistry?.peerIds ?? {_peerId};
      for (final peerId in knownPeers) {
        for (final t in _pullEntityTypes) {
          _nextPullNotBeforeByEntityType.putIfAbsent((peerId, t), () => null);
          _pullFailureCountByEntityType.putIfAbsent((peerId, t), () => 0);
        }
      }

      if (triggerImmediately && _started && _online && _scopeUid != null) {
        await _maybeRunPullAll(reason: 'entityTypes');
      }
    });
  }

  /// Manually triggers a push attempt (subject to gating + backoff).
  Future<void> triggerPush() async {
    await _enqueue(() async {
      _ensureNotDisposed();
      if (!_pushEnabled) return;
      await _maybeRunPush(reason: 'manual');
    });
  }

  /// Manually triggers a pull attempt for one entity type (subject to gating + backoff).
  Future<void> triggerPull(String entityType) async {
    await _enqueue(() async {
      _ensureNotDisposed();
      await _maybeRunPull(entityType: entityType, reason: 'manual');
    });
  }

  /// Manually triggers pull for all configured entity types (subject to gating + backoff).
  Future<void> triggerPullAll() async {
    await _enqueue(() async {
      _ensureNotDisposed();
      await _maybeRunPullAll(reason: 'manual');
    });
  }

  /// Arms periodic timers for push and pull.
  ///
  /// Timers:
  /// - push timer ticks every [_pushInterval]
  /// - pull timer ticks every [_pullInterval]
  void _armTimers() {
    _cancelTimers();

    if (!_started) return;

    if (_pushEnabled && _pushTimerEnabled) {
      _pushTimer = Timer.periodic(_pushInterval, (_) {
        _serial = _serial.then((_) async {
          if (_disposed) return;
          await _maybeRunPush(reason: 'timer');
        });
      });
    }

    _pullTimer = Timer.periodic(_pullInterval, (_) {
      _serial = _serial.then((_) async {
        if (_disposed) return;
        await _maybeRunPullAll(reason: 'timer');
      });
    });

    _armPushBacklogWatcher();
  }

  /// Cancels periodic timers if they exist.
  void _cancelTimers() {
    _pushTimer?.cancel();
    _pullTimer?.cancel();
    _pushBackoffTimer?.cancel();

    _pushTimer = null;
    _pullTimer = null;
    _pushBackoffTimer = null;
    _pushBackoffFireAtUtc = null;

    unawaited(_pushBacklogSub?.cancel());
    _pushBacklogSub = null;
  }

  void _armPushBacklogWatcher() {
    unawaited(_pushBacklogSub?.cancel());
    _pushBacklogSub = null;

    if (!_started) return;
    if (!_pushEnabled) return;
    if (_pushTimerEnabled) return;

    final uid = _scopeUid;
    if (uid == null || uid.isEmpty) return;

    _pushBacklogSub = _coordinator
        .watchBacklogCount(uid, peerId: _peerId, channel: _channel)
        .distinct()
        .listen((count) {
          _serial = _serial.then((_) async {
            if (_disposed) return;
            if (!_started || !_online) return;
            if (_scopeUid != uid) return;


            if (count <= 0) {
              _cancelPushBackoffTimer();
              return;
            }

            await _maybeRunPush(reason: 'outbox');
          });
        }, onError: (e, st) {
          _logger.error(
            'sync_runtime_outbox_watch_error',
            data: <String, Object?>{'scopeUid': uid},
            error: e,
            stackTrace: st,
          );
        });
  }

  void _cancelPushBackoffTimer() {
    _pushBackoffTimer?.cancel();
    _pushBackoffTimer = null;
    _pushBackoffFireAtUtc = null;
  }

  void _schedulePushBackoffTimer() {
    if (_pushTimerEnabled) return;

    if (!_started || !_online) {
      _cancelPushBackoffTimer();
      return;
    }

    final uid = _scopeUid;
    if (uid == null || uid.isEmpty) {
      _cancelPushBackoffTimer();
      return;
    }

    final fireAt = _nextPushNotBeforeUtc.values
        .whereType<DateTime>()
        .fold<DateTime?>(null, (earliest, t) {
      if (earliest == null || t.isBefore(earliest)) return t;
      return earliest;
    });
    if (fireAt == null) {
      _cancelPushBackoffTimer();
      return;
    }

    final now = _nowUtc();
    if (!now.isBefore(fireAt)) {
      _cancelPushBackoffTimer();
      return;
    }

    final existingAt = _pushBackoffFireAtUtc;
    if (existingAt != null && !fireAt.isBefore(existingAt)) {
      return;
    }

    _cancelPushBackoffTimer();
    _pushBackoffFireAtUtc = fireAt;
    _pushBackoffTimer = Timer(fireAt.difference(now), () {
      _serial = _serial.then((_) async {
        if (_disposed) return;
        _cancelPushBackoffTimer();
        await _maybeRunPush(reason: 'backoff');
      });
    });
  }

  /// Runs one push attempt if started, online, scope is set, and not in backoff.
  Future<void> _maybeRunPush({required String reason}) async {
    if (!_started) {
      _logger.trace('sync_runtime_push_skip',
          data: <String, Object?>{'reason': reason, 'skip': 'not_started'});
      return;
    }
    if (!_online) {
      _logger.trace('sync_runtime_push_skip',
          data: <String, Object?>{'reason': reason, 'skip': 'offline'});
      return;
    }
    final uid = _scopeUid;
    if (uid == null) {
      _logger.trace('sync_runtime_push_skip',
          data: <String, Object?>{'reason': reason, 'skip': 'no_scope'});
      return;
    }

    final now = _nowUtc();

    // 逐 peer 判定「是否到点可推」：退避中的 peer 本轮跳过，其余照推（§5.2.2）。
    final knownPeers = _peerRegistry?.peerIds ?? {_peerId};
    final pushable = <PeerId>{};
    for (final peerId in knownPeers) {
      final notBefore = _nextPushNotBeforeUtc[peerId];
      if (notBefore == null || !now.isBefore(notBefore)) {
        pushable.add(peerId);
      }
    }
    if (pushable.isEmpty) {
      _schedulePushBackoffTimer();
      return;
    }

    _logger.debug(
      'sync_runtime_push_attempt',
      data: <String, Object?>{
        'reason': reason,
        'scopeUid': uid,
        'pushablePeers': pushable.map((p) => p.value).toList(),
      },
    );

    final outcomes = await _coordinator.pushOnce(
      scopeUid: uid,
      onlyPeers: pushable,
    );

    var anyFailure = false;
    for (final outcome in outcomes) {
      if (outcome.hasError) {
        anyFailure = true;
        final peerId = outcome.peerId;
        final failures = (_pushFailureCount[peerId] ?? 0) + 1;
        _pushFailureCount[peerId] = failures;
        _nextPushNotBeforeUtc[peerId] =
            now.add(_computeBackoff(failures));
        _schedulePushBackoffTimer();
        _logger.warn(
          'sync_runtime_push_backoff',
          data: <String, Object?>{
            'reason': reason,
            'scopeUid': uid,
            'peerId': peerId.value,
            'failures': failures,
            'notBeforeUtc': _nextPushNotBeforeUtc[peerId]?.toIso8601String(),
            'errorCode': outcome.lastError?.code.name,
          },
          error: outcome.lastError,
        );
      } else {
        final peerId = outcome.peerId;
        _pushFailureCount[peerId] = 0;
        _nextPushNotBeforeUtc[peerId] = null;
        _logger.info(
          'sync_runtime_push_done',
          data: <String, Object?>{
            'reason': reason,
            'scopeUid': uid,
            'peerId': peerId.value,
            'succeeded': outcome.succeeded,
            'failed': outcome.failed,
          },
        );
      }
    }

    if (anyFailure) {
      _schedulePushBackoffTimer();
    } else {
      _cancelPushBackoffTimer();
    }

    _emitStatus(_coordinator.status);
  }

  /// Runs pull for all configured entity types.
  Future<void> _maybeRunPullAll({required String reason}) async {
    if (_pullEntityTypes.isEmpty) return;

    for (final entityType in _pullEntityTypes) {
      await _maybeRunPull(entityType: entityType, reason: reason);
    }
  }

  /// Runs one pull attempt for [entityType] if started, online, scope is set, and not in backoff.
  Future<void> _maybeRunPull({
    required String entityType,
    required String reason,
  }) async {
    if (!_started) {
      _logger.trace('sync_runtime_pull_skip', data: <String, Object?>{
        'reason': reason,
        'entityType': entityType,
        'skip': 'not_started'
      });
      return;
    }
    if (!_online) {
      _logger.trace('sync_runtime_pull_skip', data: <String, Object?>{
        'reason': reason,
        'entityType': entityType,
        'skip': 'offline'
      });
      return;
    }
    final uid = _scopeUid;
    if (uid == null) {
      _logger.trace('sync_runtime_pull_skip', data: <String, Object?>{
        'reason': reason,
        'entityType': entityType,
        'skip': 'no_scope'
      });
      return;
    }

    final normalized = entityType.trim();
    if (normalized.isEmpty) return;

    final now = _nowUtc();

    // 逐 peer 判定拉取退避（§5.2.2）：(peerId, entityType) 在退避窗口内就
    // 跳过该对端，其余照拉。键用 record，不用字符串拼接。
    final knownPeers = _peerRegistry?.peerIds ?? {_peerId};
    for (final peerId in knownPeers) {
      final key = (peerId, normalized);
      final notBefore = _nextPullNotBeforeByEntityType[(peerId, normalized)];
      if (notBefore != null && now.isBefore(notBefore)) continue;

      PullRunResult? result;
      SyncError? error;

      _logger.debug(
        'sync_runtime_pull_attempt',
        data: <String, Object?>{
          'reason': reason,
          'scopeUid': uid,
          'peerId': peerId.value,
          'entityType': normalized,
        },
      );

      try {
        result = await _coordinator.pullOnce(
          scopeUid: uid,
          peerId: peerId,
          entityType: normalized,
        );
        error = result.lastError;
      } on Object catch (e, st) {
        _logger.error(
          'sync_runtime_pull_throw',
          data: <String, Object?>{
            'reason': reason,
            'scopeUid': uid,
            'peerId': peerId.value,
            'entityType': normalized,
          },
          error: e,
          stackTrace: st,
        );
        if (e is SyncError) {
          error = e;
        } else {
          error = SyncError(code: SyncErrorCode.unknown, message: '$e');
        }
      }

      if (error != null) {
        final failures = (_pullFailureCountByEntityType[key] ?? 0) + 1;
        _pullFailureCountByEntityType[key] = failures;
        _nextPullNotBeforeByEntityType[(peerId, normalized)] = now.add(_computeBackoff(failures));

        _logger.warn(
          'sync_runtime_pull_backoff',
          data: <String, Object?>{
            'reason': reason,
            'scopeUid': uid,
            'peerId': peerId.value,
            'entityType': normalized,
            'failures': failures,
            'notBeforeUtc':
                _nextPullNotBeforeByEntityType[(peerId, normalized)]?.toIso8601String(),
            'errorCode': error.code.name,
          },
          error: error,
        );
      } else {
        _pullFailureCountByEntityType[key] = 0;
        _nextPullNotBeforeByEntityType[(peerId, normalized)] = null;

        _logger.info(
          'sync_runtime_pull_done',
          data: <String, Object?>{
            'reason': reason,
            'scopeUid': uid,
            'peerId': peerId.value,
            'entityType': normalized,
            'pages': result?.pages,
            'fetched': result?.fetched,
            'applied': result?.applied,
            'skipped': result?.skipped,
            'advanced': result?.advanced,
          },
        );
      }
    }

    _emitStatus(_coordinator.status);
  }

  /// Computes exponential backoff based on [failureCount], clamped to [_maxBackoff].
  Duration _computeBackoff(int failureCount) {
    if (failureCount <= 0) return Duration.zero;

    var multiplier = 1;
    for (var i = 1; i < failureCount; i += 1) {
      multiplier *= 2;
      if (multiplier >= 1024) break;
    }

    final raw = Duration(
      milliseconds: _minBackoff.inMilliseconds * multiplier,
    );

    if (raw <= _maxBackoff) return raw;
    return _maxBackoff;
  }

  /// Clears internal backoff state.
  void _resetBackoff() {
    _pushFailureCount.clear();
    _nextPushNotBeforeUtc.clear();

    _nextPullNotBeforeByEntityType.clear();
    _pullFailureCountByEntityType.clear();

    final knownPeers = _peerRegistry?.peerIds ?? {_peerId};
    for (final peerId in knownPeers) {
      _nextPushNotBeforeUtc[peerId] = null;
      _pushFailureCount[peerId] = 0;
      for (final t in _pullEntityTypes) {
        _nextPullNotBeforeByEntityType[(peerId, t)] = null;
        _pullFailureCountByEntityType[(peerId, t)] = 0;
      }
    }
  }

  /// 订阅 PeerRegistry 的变更流：对端被移除时清理该对端的退避分片。
  void _armPeerRegistryWatcher() {
    final registry = _peerRegistry;
    if (registry == null) return;

    _peerRegistrySub?.cancel();
    _peerRegistrySub = registry.changes.listen((currentIds) {
      _purgeBackoffForMissingPeers(currentIds);
    });
  }

  /// 清理【已不在 registry 中】的对端留下的退避键（防僵尸键泄漏）。
  void _purgeBackoffForMissingPeers(Set<PeerId> currentIds) {
    _nextPushNotBeforeUtc.removeWhere((k, _) => !currentIds.contains(k));
    _pushFailureCount.removeWhere((k, _) => !currentIds.contains(k));
    _nextPullNotBeforeByEntityType.removeWhere(
      (k, _) => !currentIds.contains(k.$1),
    );
    _pullFailureCountByEntityType.removeWhere(
      (k, _) => !currentIds.contains(k.$1),
    );
  }

  /// Serializes public operations to avoid overlapping start/stop/trigger calls.
  Future<void> _enqueue(Future<void> Function() op) {
    _serial = _serial.then((_) => op());
    return _serial;
  }

  /// Emits [status] to the stream if possible.
  void _emitStatus(SyncStatus status) {
    if (_disposed) return;
    if (_statusController.isClosed) return;
    _statusController.add(status);
  }

  /// 仅供测试观测的只读退避视图：每个对端下次允许 push 的时刻。
  ///
  /// 只读，不可写 —— 写退避状态必须走真实推送路径，否则测试会绕过时序机。
  @visibleForTesting
  Map<PeerId, DateTime?> get debugNextPushNotBefore =>
      Map.unmodifiable(_nextPushNotBeforeUtc);

  /// 仅供测试观测的只读退避视图：每个对端的连续失败次数。
  @visibleForTesting
  Map<PeerId, int> get debugPushFailureCount =>
      Map.unmodifiable(_pushFailureCount);

  /// 仅供测试观测的只读退避视图：(peerId, entityType) 的拉取退避时刻。
  @visibleForTesting
  Map<(PeerId, String), DateTime?> get debugNextPullNotBefore =>
      Map.unmodifiable(_nextPullNotBeforeByEntityType);

  /// Throws if the runtime has been disposed.
  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('SyncRuntime is disposed');
    }
  }
}

class PublicSyncRuntime {
  const PublicSyncRuntime(this.runtime);

  final SyncRuntime runtime;
}
