import 'dart:async';
import 'package:crdt/crdt.dart' show Hlc;

/// 本设备的 HLC 时钟。跨重启持久化，单调不回退。
///
/// 【两条规则】：
/// · 本地写入 [tick]：l = max(旧 l, 物理时间)；l 未变则 c++，c 超过 65535 时物理毫秒进位归零
/// · 收到远端 [observe]：l = max(本地 l, 远端 l, 物理时间)，单调推进并持久化
abstract interface class HlcClock {
  /// 本地发生一次写入，返回新的戳。
  ///
  /// nodeId 一律取 [deviceId]（= DeviceIdentity.deviceId）。
  Future<Hlc> tick();

  /// 观测到一个远端戳，把本地时钟顶上去。
  Future<void> observe(Hlc remote);

  /// 当前戳（只读，不推进）。
  Hlc get current;

  /// 本设备标识，作为 Hlc.nodeId（也是 HLC 相等时的决胜位）。
  String get deviceId;
}

/// 时钟状态的持久化端口。
abstract interface class HlcClockStore {
  /// 读回上次退出时的时钟；从未存过返回 null。
  Future<Hlc?> load();

  /// 落盘当前时钟。
  Future<void> save(Hlc clock);
}

/// 内部异步互斥锁，确保并发 load/tick/observe 严格串行化。
final class _AsyncLock {
  Future<void>? _last;

  Future<T> run<T>(Future<T> Function() action) {
    final previous = _last;
    final completer = Completer<void>();
    _last = completer.future;

    Future<T> execute() async {
      if (previous != null) {
        try {
          await previous;
        } catch (_) {}
      }
      try {
        return await action();
      } finally {
        completer.complete();
      }
    }

    return execute();
  }
}

/// crdt Hlc 的默认时钟实现（带异步互斥与 65535 边界防回卷处理）。
final class HlcClockImpl implements HlcClock {
  HlcClockImpl({
    required this.deviceId,
    required HlcClockStore store,
    DateTime Function()? wallClock,
  })  : _store = store,
        _wallClock = wallClock ?? DateTime.now().toUtc,
        _current = Hlc.zero(deviceId);

  @override
  final String deviceId;
  final HlcClockStore _store;
  final DateTime Function() _wallClock;
  final _AsyncLock _lock = _AsyncLock();

  bool _loaded = false;
  Hlc _current;

  @override
  Hlc get current => _current;

  @override
  Future<Hlc> tick() => _lock.run(() async {
        await _ensureLoaded();
        final wall = _wallClock();
        final wallMillis = wall.millisecondsSinceEpoch;
        final currentMillis = _current.dateTime.millisecondsSinceEpoch;

        int nextMillis;
        int nextCounter;

        if (wallMillis > currentMillis) {
          nextMillis = wallMillis;
          nextCounter = 0;
        } else {
          nextMillis = currentMillis;
          final c = _current.counter + 1;
          if (c > 65535) {
            // 物理毫秒进位，counter 归零，严禁掩码回卷
            nextMillis = currentMillis + 1;
            nextCounter = 0;
          } else {
            nextCounter = c;
          }
        }

        _current = Hlc(
          DateTime.fromMillisecondsSinceEpoch(nextMillis, isUtc: true),
          nextCounter,
          deviceId,
        );
        await _store.save(_current);
        return _current;
      });

  @override
  Future<void> observe(Hlc remote) => _lock.run(() async {
        await _ensureLoaded();
        final wall = _wallClock();
        final wallMillis = wall.millisecondsSinceEpoch;
        final currentMillis = _current.dateTime.millisecondsSinceEpoch;
        final remoteMillis = remote.dateTime.millisecondsSinceEpoch;

        final maxMillis = [wallMillis, currentMillis, remoteMillis]
            .reduce((a, b) => a > b ? a : b);

        int nextCounter;
        int nextMillis = maxMillis;

        if (maxMillis == currentMillis && maxMillis == remoteMillis) {
          final c = (_current.counter > remote.counter
                  ? _current.counter
                  : remote.counter) +
              1;
          if (c > 65535) {
            nextMillis = maxMillis + 1;
            nextCounter = 0;
          } else {
            nextCounter = c;
          }
        } else if (maxMillis == currentMillis) {
          final c = _current.counter + 1;
          if (c > 65535) {
            nextMillis = maxMillis + 1;
            nextCounter = 0;
          } else {
            nextCounter = c;
          }
        } else if (maxMillis == remoteMillis) {
          final c = remote.counter + 1;
          if (c > 65535) {
            nextMillis = maxMillis + 1;
            nextCounter = 0;
          } else {
            nextCounter = c;
          }
        } else {
          nextCounter = 0;
        }

        _current = Hlc(
          DateTime.fromMillisecondsSinceEpoch(nextMillis, isUtc: true),
          nextCounter,
          deviceId,
        );
        await _store.save(_current);
      });

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final persisted = await _store.load();
    if (persisted != null) {
      _current = persisted;
    }
    _loaded = true;
  }
}
