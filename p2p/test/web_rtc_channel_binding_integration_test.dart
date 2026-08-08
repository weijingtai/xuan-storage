@Tags(['integration'])
library;

import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/pairing.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/transport.dart';
import 'package:persistence_p2p/device_key_store.dart';
import 'package:persistence_p2p/web_rtc_transport.dart';
import 'package:uuid/uuid.dart';

/// 步骤 3 门禁（灵魂）：channel binding 在真 WebRTC 握手内生效。
///
/// 【正向】两个 `WebRtcTransport`（alice 广播 / bob 拨号）经内存信令 +
/// 内存配对织物完成真 WebRTC 握手（真 SDP/ICE/DTLS/getStats）：
/// - `connect`/`advertise` 握手内部先跑 `DevicePairingProtocol` 拿
///   `PairingResult`（人类裁定：声明指纹取配对验签结果）；
/// - DTLS 完成后取观测指纹，与声明一并传入 `enforceChannelBindingMatches`
///   —— 一致 → 产出已认证 `PeerSession`（remote 绑定、channelBinding 就位）。
///
/// 【A5 MITM 负向】攻击者在信令上把声明证书指纹换成攻击者的：bob 侧注入
/// `observedFingerprintOverride` 模拟「B 观测到 M 的证书」—— 声明
/// （alice 真证书指纹，配对验签可信）≠ 观测（攻击者指纹）→
/// `PairingBindingMismatchError`，会话不产出（裁定丙）。
///
/// 【变异自检】临时注释掉 `web_rtc_transport.dart` 里的
/// `enforceChannelBindingMatches(...)` 调用 → 本文件 A5 负向测试必须红
/// （攻击成功而门禁不响）→ 恢复后绿。红在断言（expectLater throwsA），
/// 非编译失败。
///
/// 【运行平台】flutter_webrtc 需要平台通道，须在 Chrome 上跑：
/// ```bash
/// cd p2p && flutter test --platform chrome --run-skipped \
///   test/web_rtc_channel_binding_integration_test.dart
/// ```
void main() {
  test('正向：真 WebRTC 握手内跑配对 + channel binding，产出已认证 PeerSession',
      () async {
    final signaling = _MemorySignalingFabric();
    final pairing = _MemoryPairingFabric();

    final alice = WebRtcTransport(
      signaling: signaling.channel(),
      pairingChannel: pairing.channel(),
    );
    final bob = WebRtcTransport(
      signaling: signaling.channel(),
      pairingChannel: pairing.channel(),
    );

    // 接听侧会话产出在 alice.incoming（advertise 侧）—— 先订阅。
    final inbound = <PeerSession>[];
    final sub = alice.incoming.listen(inbound.add);

    final aliceKeys = _makeStore('alice-device');
    final bobKeys = _makeStore('bob-device');

    final handle = await alice.advertise(keys: aliceKeys);
    final peer = DiscoveredPeer(
      transientServiceId: handle.transientServiceId,
      channel: Channel.webrtc,
    );
    final bobSide = await bob.connect(peer, keys: bobKeys);

    // 已认证：remote 绑定 + channelBinding 就位（SDP a=fingerprint 格式）。
    expect(bobSide.remote.deviceId, 'alice-device');
    expect(bobSide.channelBinding.localCertificateFingerprint,
        startsWith('sha-256 '));

    // alice 接听侧也产出已认证会话（轮询等待：真握手链路含配对 + DTLS，
    // 200ms 固定等待可能不够，用有界轮询）。
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (inbound.isEmpty && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(inbound, hasLength(1), reason: 'advertise 侧必须产出已认证会话');
    expect(inbound.single.remote.deviceId, 'bob-device');

    await bobSide.close();
    await inbound.single.close();
    await sub.cancel();
    await alice.dispose();
    await bob.dispose();
  });

  test('A5 MITM 负向：攻击者换指纹 → bob 抛 PairingBindingMismatchError，会话不产出',
      () async {
    final signaling = _MemorySignalingFabric();
    final pairing = _MemoryPairingFabric();

    final alice = WebRtcTransport(
      signaling: signaling.channel(),
      pairingChannel: pairing.channel(),
    );
    final bob = WebRtcTransport(
      signaling: signaling.channel(),
      pairingChannel: pairing.channel(),
    );

    // 接听侧会话若产出会出现在 alice.incoming（advertise 侧）——
    // 认证失败时这里必须保持空（裁定丙）。
    final inbound = <PeerSession>[];
    final sub = alice.incoming.listen(inbound.add);

    // 攻击者：双方观测到的对端证书指纹都被替换为攻击者证书指纹
    // （攻击者用自己证书替换传输层证书：B 观测到 M、A 声明 X）。
    // 声明（配对验签，可信）≠ 观测（攻击者）→ 双方都必须发现。
    bob.observedFingerprintOverride = (_) => 'sha-256 FA:KE:1A:2B:3C:4D:5E:6F';
    alice.observedFingerprintOverride = (_) => 'sha-256 FA:KE:1A:2B:3C:4D:5E:6F';

    final aliceKeys = _makeStore('alice-device');
    final bobKeys = _makeStore('bob-device');

    final handle = await alice.advertise(keys: aliceKeys);
    final peer = DiscoveredPeer(
      transientServiceId: handle.transientServiceId,
      channel: Channel.webrtc,
    );

    // bob 必须抛 PairingBindingMismatchError（红在断言，非编译失败）。
    await expectLater(
      bob.connect(peer, keys: bobKeys),
      throwsA(isA<PairingBindingMismatchError>()),
      reason: '声明指纹（配对验签）≠ 观测指纹（攻击者）时必须拒绝产出会话',
    );

    // alice 侧超时：握手未完成，不产出会话。
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(inbound, isEmpty, reason: '认证失败时接听侧不得产出会话（裁定丙）');

    await sub.cancel();
    await alice.dispose();
    await bob.dispose();
  });
}

// ── 内存信令织物（同 web_rtc_transport_integration_test 私有副本）────

class _MemorySignalingFabric {
  final Map<RendezvousKey, List<_MemorySession>> _sessions = {};

  SignalingChannel channel() => _MemorySignalingChannel(this);
}

class _MemorySignalingChannel implements SignalingChannel {
  _MemorySignalingChannel(this._fabric);

  final _MemorySignalingFabric _fabric;

  @override
  Future<SignalingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) async {
    final session = _MemorySession(_fabric, rendezvous);
    final list = _fabric._sessions.putIfAbsent(rendezvous, () => []);
    list.add(session);
    if (list.length >= 2) {
      for (final s in list) {
        s._setPresent();
      }
    }
    return session;
  }

  @override
  Future<void> dispose() async {}
}

class _MemorySession implements SignalingSession {
  _MemorySession(this._fabric, this.rendezvous);

  final _MemorySignalingFabric _fabric;

  @override
  final RendezvousKey rendezvous;

  final StreamController<SignalingEnvelope> _incoming =
      StreamController<SignalingEnvelope>.broadcast();
  final StreamController<PeerPresence> _presence =
      StreamController<PeerPresence>.broadcast();

  bool _closed = false;
  bool _present = false;

  void _setPresent() {
    if (!_present) {
      _present = true;
      _presence.add(PeerPresence.present);
    }
  }

  @override
  Stream<SignalingEnvelope> get incoming => _incoming.stream;

  @override
  Stream<PeerPresence> get peerPresence =>
      _presence.stream.map((p) => p).asyncExpand(
        (p) => Stream<PeerPresence>.value(p),
      );

  @override
  Future<void> send(SignalingEnvelope envelope) async {
    if (_closed) {
      throw StateError('对端已离开（本会话已关闭），拒绝发送');
    }
    final peers = _fabric._sessions[rendezvous] ?? const [];
    var delivered = false;
    for (final s in peers) {
      if (!identical(s, this) && !s._closed) {
        s._incoming.add(envelope);
        delivered = true;
      }
    }
    if (!delivered) {
      throw StateError('对端不在线，拒绝发送');
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _incoming.close();
    await _presence.close();
  }
}

// ── 内存配对织物（同 device_pairing_test 私有 fabric 同构）──────

class _MemoryPairingFabric {
  final Map<RendezvousKey, List<_MemoryPairingSession>> _sessions = {};

  PairingChannel channel() => _MemoryPairingChannel(this);
}

class _MemoryPairingChannel implements PairingChannel {
  _MemoryPairingChannel(this._fabric);

  final _MemoryPairingFabric _fabric;

  @override
  Future<PairingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) async {
    final session = _MemoryPairingSession(_fabric, rendezvous);
    final list = _fabric._sessions.putIfAbsent(rendezvous, () => []);
    list.add(session);
    if (list.length >= 2) {
      for (final s in list) {
        s._notifyPeerPresent();
      }
    }
    return session;
  }

  @override
  Future<void> dispose() async {}
}

class _MemoryPairingSession implements PairingSession {
  _MemoryPairingSession(this._fabric, this.rendezvous);

  final _MemoryPairingFabric _fabric;

  @override
  final RendezvousKey rendezvous;

  // 非 broadcast：事件缓冲到首个订阅者（先到者事件不丢）——
  // 与 device_pairing_test 的 fabric 同款，避免「对端 offer 早于本端
  // 订阅到达」的竞态。
  final StreamController<PairingEnvelope> _incoming =
      StreamController<PairingEnvelope>();
  final StreamController<PeerPresence> _presence =
      StreamController<PeerPresence>.broadcast();

  bool _closed = false;
  PeerPresence _current = PeerPresence.awaiting;

  void _notifyPeerPresent() {
    if (_current != PeerPresence.present) {
      _current = PeerPresence.present;
      _presence.add(PeerPresence.present);
    }
  }

  @override
  Stream<PairingEnvelope> get incoming => _incoming.stream;

  @override
  Stream<PeerPresence> get peerPresence => Stream.multi((controller) {
        // 订阅即重放当前状态（契约：订阅后应立即得到当前状态）。
        controller.add(_current);
        final sub = _presence.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Future<void> send(PairingEnvelope envelope) async {
    if (_closed) {
      throw StateError('对端已关闭，拒绝发送');
    }
    final peers = _fabric._sessions[rendezvous] ?? const [];
    var delivered = false;
    for (final s in peers) {
      if (!identical(s, this) && !s._closed) {
        s._incoming.add(envelope);
        delivered = true;
      }
    }
    if (!delivered) {
      throw StateError('对端不在线，拒绝发送');
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _incoming.close();
    await _presence.close();
  }
}

// ── 测试辅助：内存 secure storage + 固定 UUID（与 device_pairing_test
//    私有副本同款）──────────────────────────────────────

PersistentDeviceKeyStore _makeStore(String deviceId) =>
    PersistentDeviceKeyStore(
      storage: _InMemorySecureStorage(),
      uuid: _FixedUuid(deviceId),
    );

class _InMemorySecureStorage implements FlutterSecureStorage {
  final Map<String, String> map = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      map[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      map.remove(key);
    } else {
      map[key] = value;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FixedUuid implements Uuid {
  final String _seed;
  _FixedUuid(this._seed);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #v4) {
      return _seed;
    }
    return super.noSuchMethod(invocation);
  }
}
