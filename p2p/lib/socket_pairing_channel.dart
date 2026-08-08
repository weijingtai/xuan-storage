/// `PairingChannel` 的 socket 生产承载（S3c-c 步骤 3 补齐的承载缺口）。
///
/// 【为什么存在】`DevicePairingProtocol`（S6 交付）依赖 `PairingChannel`
/// 端口（`core/lib/model/pairing.dart`），但交付时只有测试 fabric、没有
/// 生产承载。S3c-c 步骤 3 要在握手内部跑配对，必须补上生产承载 ——
/// `pairing.dart` 注释明示「一个实现对应一种承载（……未来可经信令通道
/// 转发或独立 socket —— 属实现细节，不属契约）」，故本文件不违反契约。
///
/// 【为什么独立 socket 而非经信令通道】`SignalingEnvelope` 与
/// `PairingEnvelope` 是两套密封类型（各自穷尽变体），无法互载；给密封
/// 类型加变体属契约变更（禁止）。故配对承载独立建 socket 直连，只传
/// `PairingEnvelope`。
///
/// 【结构】与 `LocalSignaling`（S3c-b）同构：
/// - `open(rendezvous)` 起 `ServerSocket` 监听 + 经 [LanDiscovery] 广播
///   （TXT 含 rv 与类型标记 `kind=pairing`，发现侧据此过滤，避免与
///   信令通道的服务互相串扰）+ 同时 discover；
/// - 连接方向仲裁：transient id 大者主动 connect，小者只等 incoming
///   （与 LocalSignaling 同一约定，杜绝双连）；
/// - socket 上以「行分隔 JSON」交换 `PairingEnvelope`（穷尽三变体）；
/// - presence：socket 接通 → `present`；对端断开（onDone/onError）→
///   **立刻** `departed`，不挂超时推断。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/pairing.dart';
import 'package:persistence_core/model/signaling.dart';

import 'lan_discovery.dart';

/// `PairingChannel` 的 socket 承载实现。
///
/// 构造参数：
/// - [discovery]：局域网发现（可注入 [FakeLanDiscovery] 供单测；缺省用真
///   bonsoir）。与 `LocalSignaling` 同一注入点，测试可复用同一 fabric
///   类型（但建议用独立 fabric 实例，避免信令/配对服务互串）。
final class SocketPairingChannel implements PairingChannel {
  /// 构造配对通道。
  SocketPairingChannel({LanDiscovery? discovery})
      : _discovery = discovery ?? BonsoirLanDiscovery();

  final LanDiscovery _discovery;
  final Map<RendezvousKey, _SocketPairingSession> _sessions = {};

  @override
  Future<PairingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) async {
    // 1. 起 ServerSocket（port 0 = 系统分配随机端口；先到者等待）。
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);

    // 2. 广播自己：service name 只放随机 transient id（隐私 A7 同源），
    //    TXT 含 rendezvous 与类型标记（配对通道专用，不与信令互串）。
    final transientId = _randomServiceId();
    await _discovery.advertise(
      serviceName: transientId,
      txt: {'rv': rendezvous, 'kind': 'pairing'},
      port: server.port,
    );
    await _discovery.startDiscovery();

    // 3. 建会话并启动配对协程（不阻塞 open）。
    final session = _SocketPairingSession(
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

  /// 随机 transient service id（隐私同 A7：不含身份信息）。
  static String _randomServiceId() {
    final r = Random();
    final hex = List.generate(6, (_) => r.nextInt(16).toRadixString(16)).join();
    return 'pair-$hex';
  }
}

/// 一条已打开的 socket 配对会话。
final class _SocketPairingSession implements PairingSession {
  _SocketPairingSession(
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

  final StreamController<PairingEnvelope> _incoming =
      StreamController<PairingEnvelope>.broadcast();
  final StreamController<PeerPresence> _presence =
      StreamController<PeerPresence>.broadcast();

  PeerPresence _current = PeerPresence.awaiting;
  Socket? _socket;
  StreamSubscription<LanDiscoveredService>? _discoverSub;
  bool _paired = false;
  bool _closed = false;
  bool _activeClose = false;

  @override
  Stream<PairingEnvelope> get incoming => _incoming.stream;

  @override
  Stream<PeerPresence> get peerPresence => Stream.multi((controller) {
        controller.add(_current);
        final sub = _presence.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Future<void> send(PairingEnvelope envelope) async {
    if (_current == PeerPresence.departed) {
      throw StateError('对端已 departed，拒绝发送配对信封');
    }
    final s = _socket;
    if (s == null) return; // 未配对：静默（与 LocalSignaling 一致）。
    s.add(utf8.encode('${_encodeEnvelope(envelope)}\n'));
    await s.flush();
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _activeClose = true;
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

  /// 配对协程：discover 到对端则按 id 仲裁直连（id 大者主动），否则等 incoming。
  Future<void> runPairing() async {
    _discoverSub = _discovery.discoveredServices.listen((svc) {
      if (_paired || _closed) return;
      if (svc.txt['rv'] != rendezvous) return;
      if (svc.txt['kind'] != 'pairing') return; // 只收配对通道的服务。
      if (svc.serviceName == myId) return;
      // 连接方向仲裁：id 大者主动 connect，小者只等 incoming。
      if (myId.compareTo(svc.serviceName) < 0) return;
      unawaited(_connectTo(svc));
    });

    // 路 2：server 接受对端连接（先到者等待 / 被动方等待）。
    await for (final socket in _server) {
      if (_paired || _closed || _socket != null) {
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
          // 对端断开（FIN 或 RST）都触发 here（与 LocalSignaling D13 同因）。
          onDone: () => _onSocketGone(socket),
          onError: (Object _) => _onSocketGone(socket),
        );
  }

  void _pairIfReady() {
    if (_paired || _closed) return;
    if (_socket == null) return;
    _paired = true;
    _emit(PeerPresence.present);
    unawaited(_server.close());
  }

  void _onSocketGone(Socket socket) {
    if (_closed || _activeClose) return;
    if (!identical(socket, _socket)) return;
    _socket = null;
    if (!_paired) return; // 未配对时断开：静默，保持 awaiting。
    _emit(PeerPresence.departed);
    unawaited(close());
  }

  void _emit(PeerPresence p) {
    _current = p;
    if (!_presence.isClosed) _presence.add(p);
  }
}

/// 信封 → 行分隔 JSON（穷尽 sealed 三变体）。
String _encodeEnvelope(PairingEnvelope e) => switch (e) {
      PairingOfferEnvelope(:final deviceId, :final publicKeyPem) =>
        jsonEncode({'t': 'offer', 'deviceId': deviceId, 'pem': publicKeyPem}),
      PairingChallengeEnvelope(
        :final nonce,
        :final localCertificateFingerprint,
        :final localPublicKeyFingerprint,
        :final peerPublicKeyFingerprint,
        :final signatureBase64,
      ) =>
        jsonEncode({
          't': 'challenge',
          'nonce': nonce,
          'lcf': localCertificateFingerprint,
          'lpf': localPublicKeyFingerprint,
          'ppf': peerPublicKeyFingerprint,
          'sig': signatureBase64,
        }),
      PairingAnswerEnvelope(
        :final nonce,
        :final localCertificateFingerprint,
        :final localPublicKeyFingerprint,
        :final peerPublicKeyFingerprint,
        :final signatureBase64,
      ) =>
        jsonEncode({
          't': 'answer',
          'nonce': nonce,
          'lcf': localCertificateFingerprint,
          'lpf': localPublicKeyFingerprint,
          'ppf': peerPublicKeyFingerprint,
          'sig': signatureBase64,
        }),
    };

/// 行分隔 JSON → 信封（穷尽 sealed 三变体）。
PairingEnvelope _decodeEnvelope(String line) {
  final m = jsonDecode(line) as Map<String, dynamic>;
  return switch (m['t']) {
    'offer' => PairingOfferEnvelope(
        deviceId: m['deviceId'] as String,
        publicKeyPem: m['pem'] as String,
      ),
    'challenge' => PairingChallengeEnvelope(
        nonce: m['nonce'] as String,
        localCertificateFingerprint: m['lcf'] as String,
        localPublicKeyFingerprint: m['lpf'] as String,
        peerPublicKeyFingerprint: m['ppf'] as String,
        signatureBase64: m['sig'] as String,
      ),
    'answer' => PairingAnswerEnvelope(
        nonce: m['nonce'] as String,
        localCertificateFingerprint: m['lcf'] as String,
        localPublicKeyFingerprint: m['lpf'] as String,
        peerPublicKeyFingerprint: m['ppf'] as String,
        signatureBase64: m['sig'] as String,
      ),
    _ => throw FormatException('未知配对信封类型: ${m['t']}'),
  };
}
