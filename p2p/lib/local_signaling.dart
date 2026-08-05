import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_core/model/storage_error.dart';

import 'lan_discovery.dart';

/// 对端已离开后仍调用 [SignalingSession.send] 抛出的错误。
///
/// 契约 §3.6「失败一律抛 StorageError 子类」；验收 A5「不静默丢弃」。
final class PeerDepartedError extends StorageError {
  PeerDepartedError()
      : super(
          code: 'p2p.peer_departed',
          message: '对端已离开，拒绝发送',
          reason: '信令会话的对端已 departed，再发信封不会有人接收',
          suggestion: '停止向该会合标识发送信封，等待新的会话',
        );
}

/// 本地局域网信令实现（bonsoir 发现 + socket 直连）—— `SignalingChannel`
/// 的第一个真实实现（裁定 C2 的落地：完全离线的局域网也能交换 SDP/ICE）。
///
/// 【握手时序】`open(rendezvous)` 起 `ServerSocket` 监听 → 经 [LanDiscovery]
/// 广播（service name 只放随机 transient id，TXT 含会合标识）→ 同时 discover。
/// `open` 不阻塞等待对端（契约：返回的会话此刻可能 awaiting），配对异步进行。
///
/// 【连接方向仲裁 —— 为什么不会双连】同一网段两台设备同时打开时双方都可能
/// discover 到对方。约定：**transient id 大者主动 connect，id 小者只等
/// incoming** —— 双方对同一对 id 的字典序判断必然一致，于是**恰好一方主动**，
/// 不存在双方互连的双连问题，也不需要事后丢弃连接。
///
/// 【presence 语义】socket 接通 → `present`；socket `onDone` / `onError`
/// （非本端主动 close）→ **立刻** `departed`，不挂任何超时推断（A3）。
class LocalSignaling implements SignalingChannel {
  /// 构造一个局域网信令实现。
  ///
  /// [discovery] 可注入（单测用 [FakeLanDiscovery]）；缺省用真 bonsoir。
  LocalSignaling({LanDiscovery? discovery})
      : _discovery = discovery ?? BonsoirLanDiscovery();

  final LanDiscovery _discovery;
  final Map<RendezvousKey, _LocalSession> _sessions = {};

  /// 测试钩子（验收 A3）：取指定会合标识会话的底层 socket，**等待配对完成**。
  ///
  /// `simulateAbruptDisconnect` 用它 `destroy()` —— 必须真的关掉 socket，
  /// 不许发「假装断开」的信号。返回的 future 在配对完成（socket 就绪）后
  /// 完成，避免「对端已 present 但本端 socket 尚未收编」的竞态。
  /// 非测试代码不应使用。
  @visibleForTesting
  Future<Socket> debugSocketOf(RendezvousKey rendezvous) async {
    final session = _sessions[rendezvous];
    if (session == null) {
      throw StateError('没有该会合标识的会话: $rendezvous');
    }
    await session._pairedCompleter.future
        .timeout(const Duration(seconds: 5));
    return session._socket!;
  }

  @override
  Future<SignalingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) async {
    // 1. 起 ServerSocket 监听（port 0 = 系统分配随机端口；先到者等待）。
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);

    // 2. 广播自己：service name 只放随机 transient id（A7 隐私），
    //    会合标识放 TXT 记录，对端发现后凭它匹配。
    final transientId = _randomServiceId();
    await _discovery.advertise(
      serviceName: transientId,
      txt: {'rv': rendezvous},
      port: server.port,
    );
    await _discovery.startDiscovery();

    // 3. 建会话并启动配对协程（不阻塞 open）。
    final session = _LocalSession(
      rendezvous,
      transientId,
      server,
      _discovery,
    );
    _sessions[rendezvous] = session;
    unawaited(session.runPairing());
    return session;
  }

  @override
  Future<void> dispose() async {
    for (final s in _sessions.values) {
      await s.close();
    }
    _sessions.clear();
    await _discovery.unadvertise();
    await _discovery.stopDiscovery();
  }

  /// 随机 transient service id（隐私，A7）：无 scopeUid / 用户名 / 设备名，
  /// 且每次 open 换新（可轮换，防长期追踪）。
  static String _randomServiceId() {
    final r = Random();
    final hex = List.generate(6, (_) => r.nextInt(16).toRadixString(16)).join();
    return 'tr-$hex';
  }
}

/// 一条已打开的局域网信令会话。
final class _LocalSession implements SignalingSession {
  /// send 在配对完成前的有界等待：正常配对毫秒级完成；无对端时按此放弃
  /// （静默成功，与内存 fake 一致）。取 200ms —— 长于 loopback 配对耗时，
  /// 短于测试可容忍。
  static const Duration sendPairWait = Duration(milliseconds: 200);

  _LocalSession(
    this.rendezvous,
    this.myId,
    this._server,
    this._discovery,
  );

  @override
  final RendezvousKey rendezvous;

  /// 本端广播用的 transient id（连接方向仲裁）。
  final String myId;

  final ServerSocket _server;
  final LanDiscovery _discovery;

  final StreamController<SignalingEnvelope> _incoming =
      StreamController<SignalingEnvelope>.broadcast();
  final StreamController<PeerPresence> _presence =
      StreamController<PeerPresence>.broadcast();

  PeerPresence _current = PeerPresence.awaiting;

  /// 配对完成后唯一保留的连接（send/close 用它）。
  Socket? _socket;

  /// 配对完成信号（send 在配对完成前等待它；无对端时按 [sendPairWait] 放弃）。
  final Completer<void> _pairedCompleter = Completer<void>();

  StreamSubscription<LanDiscoveredService>? _discoverSub;
  bool _paired = false;
  bool _closed = false;
  bool _activeClose = false;

  @override
  Stream<SignalingEnvelope> get incoming => _incoming.stream;

  @override
  Stream<PeerPresence> get peerPresence => Stream.multi((controller) {
        // 订阅即重放当前状态（契约：订阅后应立即得到当前状态）。
        // 每个订阅者独立重放（D12：broadcast 的 onListen 只服务首个订阅者）。
        controller.add(_current);
        final sub = _presence.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Future<void> send(SignalingEnvelope envelope) async {
    if (_current == PeerPresence.departed) {
      throw PeerDepartedError();
    }
    // 配对完成前等待（真实实现配对是异步的；fake 同步配对不受影响）。
    // 无对端（如不同会合标识）时按有界等待放弃 → 静默成功，与内存 fake
    // 一致（契约只约束「departed 时 send 抛错」）。
    final s = await _waitForSocket();
    if (_current == PeerPresence.departed) {
      throw PeerDepartedError();
    }
    if (s == null) return;
    s.add(utf8.encode('${_encodeEnvelope(envelope)}\n'));
    await s.flush();
  }

  /// 取当前可用 socket；未配对时等配对完成（有界）。
  Future<Socket?> _waitForSocket() async {
    if (_socket != null) return _socket;
    await _pairedCompleter.future.timeout(sendPairWait, onTimeout: () {});
    return _socket;
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    // 尽力先发 ByeEnvelope，使对端能立即 departed（契约约定）。
    final s = _socket;
    if (s != null && _paired) {
      try {
        s.add(utf8.encode('${_encodeEnvelope(const ByeEnvelope())}\n'));
        await s.flush();
      } catch (_) {
        // 对端已断，发不出去就算了 —— close 尽力而为。
      }
    }
    _activeClose = true;
    await _teardown();
  }

  /// 配对协程：discover 到对端则按 id 仲裁直连（id 大者主动），否则等 incoming。
  Future<void> runPairing() async {
    _discoverSub = _discovery.discoveredServices.listen((svc) {
      if (_paired || _closed) return;
      if (svc.txt['rv'] != rendezvous || svc.serviceName == myId) return;
      // 连接方向仲裁：transient id 大者主动 connect，小者只等 incoming。
      // 双方对同一对 id 的判断必然一致 → 恰好一方主动，无双连。
      if (myId.compareTo(svc.serviceName) < 0) return;
      unawaited(_connectTo(svc));
    });

    // 路 2：server 接受对端连接（先到者等待 / 被动方等待）。
    await for (final socket in _server) {
      if (_paired || _closed || _socket != null) {
        // 已配对或已有连接，拒绝多余连接。
        socket.destroy();
        continue;
      }
      _adopt(socket);
      break;
    }
  }

  Future<void> _connectTo(LanDiscoveredService svc) async {
    try {
      final socket = await Socket.connect(svc.host, svc.port);
      if (_paired || _closed || _socket != null) {
        socket.destroy();
        return;
      }
      _adopt(socket);
    } catch (_) {
      // connect 失败（对端已走等）：回退等 incoming，不视为错误。
    }
  }

  void _adopt(Socket socket) {
    _socket = socket;
    _attach(socket);
    _pairIfReady();
  }

  /// 挂接 socket 数据处理：行解码投递信封、断开判定。
  void _attach(Socket socket) {
    socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (_paired && !_closed) {
              _incoming.add(_decodeEnvelope(line));
            }
          },
          // 对端断开：FIN（优雅 close）或 RST（destroy/崩溃）都触发 here。
          // ⚠ 必须用 listen 的 onDone/onError —— `socket.done` 只在本地关闭
          // 时完成，对端断开不会触发它（P6 实测踩坑，见决定记录 D13）。
          onDone: () => _onSocketGone(socket),
          onError: (Object _) => _onSocketGone(socket),
        );
  }

  void _pairIfReady() {
    if (_paired || _closed) return;
    if (_socket == null) return;
    _paired = true;
    _emit(PeerPresence.present);
    if (!_pairedCompleter.isCompleted) _pairedCompleter.complete();
    // 配对完成：不再接受新连接。
    unawaited(_server.close());
  }

  void _onSocketGone(Socket socket) {
    if (_closed || _activeClose) return;
    if (!identical(socket, _socket)) return;
    _socket = null;
    // 未配对时断开（对端握手前消失）：静默，保持 awaiting。
    if (!_paired) return;
    // 已配对的对端断开 → 立刻 departed（A3）。
    _emit(PeerPresence.departed);
    unawaited(_teardown());
  }

  void _emit(PeerPresence p) {
    _current = p;
    if (!_presence.isClosed) _presence.add(p);
  }

  Future<void> _teardown() async {
    await _discoverSub?.cancel();
    _discoverSub = null;
    try {
      await _server.close();
    } catch (_) {}
    final s = _socket;
    _socket = null;
    if (s != null) {
      try {
        await s.close();
      } catch (_) {}
    }
    if (!_incoming.isClosed) await _incoming.close();
    if (!_presence.isClosed) await _presence.close();
  }
}

/// 信封 → 行分隔 JSON（穷尽 sealed 三变体）。
String _encodeEnvelope(SignalingEnvelope e) => switch (e) {
      SessionDescriptionEnvelope(:final kind, :final sdp) =>
        jsonEncode({'t': 'sdp', 'kind': kind.name, 'sdp': sdp}),
      IceCandidateEnvelope(
        :final candidate,
        :final sdpMid,
        :final sdpMLineIndex
      ) =>
        jsonEncode({
          't': 'ice',
          'candidate': candidate,
          'sdpMid': sdpMid,
          'sdpMLineIndex': sdpMLineIndex,
        }),
      ByeEnvelope() => jsonEncode({'t': 'bye'}),
    };

/// 行分隔 JSON → 信封（穷尽 sealed 三变体）。
SignalingEnvelope _decodeEnvelope(String line) {
  final m = jsonDecode(line) as Map<String, dynamic>;
  return switch (m['t']) {
    'sdp' => SessionDescriptionEnvelope(
        kind: SdpKind.values.byName(m['kind'] as String),
        sdp: m['sdp'] as String,
      ),
    'ice' => IceCandidateEnvelope(
        candidate: m['candidate'] as String,
        sdpMid: m['sdpMid'] as String,
        sdpMLineIndex: m['sdpMLineIndex'] as int,
      ),
    'bye' => const ByeEnvelope(),
    _ => throw FormatException('未知信封类型: ${m['t']}'),
  };
}
