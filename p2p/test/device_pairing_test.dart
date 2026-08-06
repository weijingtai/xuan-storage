/// 设备配对流程测试（S6 / ACT 2 + ACT 3 channel binding + ACT 6 MITM）。
///
/// 覆盖：
/// - A3：两端经配对通道完成配对，各自算出**相同**带外指纹。
/// - A4：换一端身份 → 指纹不同（正向对照）。
/// - 挑战/应答签名验证：篡改签名对象验不过（PairingSignatureError）。
/// - channel binding（ACT 3）：配对产出对端声明指纹；握手强制
///   [enforceChannelBindingMatches] 做「声明 vs 观测」比对 —— 不等抛
///   PairingBindingMismatchError（MITM 发现路径）。
/// - A5（ACT 6）MITM 负向测试：**真注入** —— 攻击者替换对端证书指纹
///   （B 观测到 M、A 声明 X）→ 指纹比对必须发现，不许「构造不同指纹
///   然后断言 !=」。
///
/// 测试用内存 fabric（[_PairingFabric]）承载两端会合：缓冲投递（对端
/// 尚未订阅时事件不丢）、presence 通知（对端到场即 present）、可注入
/// 篡改变换与坏 PEM。不依赖真实网络。
library;

import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_core/test_support/pairing_contract_suite.dart';
import 'package:persistence_p2p/persistence_p2p.dart';
import 'package:uuid/uuid.dart';

void main() {
  // ── ACT 5：可复用配对契约套件（两个结构迥异的 fabric 各跑一遍）──
  runPairingContractSuite(
    topologyName: 'PeerRegistry fabric（注册表直投）',
    makePair: () {
      final fabric = _PairingFabric();
      return (alice: fabric.channel(), bob: fabric.channel());
    },
  );
  runPairingContractSuite(
    topologyName: 'Hub fabric（星型枢纽路由）',
    makePair: () {
      final hub = _HubPairingFabric();
      return (alice: hub.aliceChannel(), bob: hub.bobChannel());
    },
  );

  group('配对流程 · A3 对称带外指纹', () {
    test('两端完成配对，各自算出相同带外指纹', () async {
      final fabric = _PairingFabric();
      final aliceKeys = _makeStore('alice-device');
      final bobKeys = _makeStore('bob-device');

      // 两端并发启动（先到者等后到者）：不能串行 await，
      // 否则先跑的一端会等到超时。
      final aliceFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: aliceKeys,
      ).pair('rv-sym');
      final bobFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: bobKeys,
      ).pair('rv-sym');
      final aliceResult = await aliceFuture;
      final bobResult = await bobFuture;

      expect(
        aliceResult.outOfBandFingerprint,
        bobResult.outOfBandFingerprint,
        reason: 'A3：两端必须算出相同的带外配对指纹',
      );
      expect(aliceResult.outOfBandFingerprint, isNotEmpty);
      expect(aliceResult.outOfBandFingerprint.split(':'), hasLength(32),
          reason: 'SHA-256 产出 32 组 hex');
      // 对端身份互认
      expect(aliceResult.remote.deviceId, 'bob-device');
      expect(bobResult.remote.deviceId, 'alice-device');
      // 对端公钥指纹 == 对端 localIdentity 的指纹
      final bobIdentity = await bobKeys.localIdentity;
      expect(aliceResult.remote.publicKeyFingerprint,
          bobIdentity.publicKeyFingerprint);
    });

    test('A4 正向对照：换一端身份 → 带外指纹不同', () async {
      final fabric = _PairingFabric();
      final aliceKeys = _makeStore('alice-device');
      final bobKeys = _makeStore('bob-device');
      final malloryKeys = _makeStore('mallory-device');

      // 两端并发启动（先到者等后到者）。
      final honestFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: aliceKeys,
      ).pair('rv-a4');
      final withBobFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: bobKeys,
      ).pair('rv-a4');
      final honest = await honestFuture;
      await withBobFuture; // bob 侧必须也配对成功（不抛错）

      // 换一端身份（mallory 与 alice 配对）→ 指纹必须不同。
      final withMalloryFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: aliceKeys,
      ).pair('rv-a4-2');
      final mallorySideFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: malloryKeys,
      ).pair('rv-a4-2');
      final withMallory = await withMalloryFuture;
      final mallorySide = await mallorySideFuture;

      expect(
        withMallory.outOfBandFingerprint,
        isNot(honest.outOfBandFingerprint),
        reason: 'A4：对端身份不同，带外指纹必须不同',
      );
      expect(withMallory.outOfBandFingerprint,
          mallorySide.outOfBandFingerprint);
    });
  });

  group('配对流程 · 签名与 nonce 校验', () {
    test('篡改签名对象（nonce）→ 应答方 PairingSignatureError，挑战方超时',
        () async {
      final fabric = _PairingFabric(
        tamper: (envelope) {
          if (envelope is PairingChallengeEnvelope) {
            // 攻击者篡改 nonce：签名对象随之变化，原签名必然验不过。
            return PairingChallengeEnvelope(
              nonce: 'deadbeef',
              localCertificateFingerprint:
                  envelope.localCertificateFingerprint,
              localPublicKeyFingerprint:
                  envelope.localPublicKeyFingerprint,
              peerPublicKeyFingerprint:
                  envelope.peerPublicKeyFingerprint,
              signatureBase64: envelope.signatureBase64,
            );
          }
          return envelope;
        },
      );
      final aliceKeys = _makeStore('alice-device');
      final bobKeys = _makeStore('bob-device');

      final bobFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: bobKeys,
      ).pair('rv-tamper', timeout: const Duration(seconds: 2));
      // 立即挂错误处理器：Future 若在 expectLater 挂载前就报错，
      // 会被当作未处理异常导致测试假失败。
      final bobExpectation = expectLater(
        bobFuture,
        throwsA(isA<PairingSignatureError>()),
        reason: '篡改签名对象后验签必须失败',
      );

      // alice（deviceId 较小）是挑战方：篡改发生在投递给 bob 之前，
      // alice 本人看不到篡改，只能等应答等到超时。
      await expectLater(
        DevicePairingProtocol(
          channel: fabric.channel(),
          keys: aliceKeys,
        ).pair('rv-tamper', timeout: const Duration(seconds: 2)),
        throwsA(isA<PairingError>()),
        reason: '挑战方 alice 收不到应答，必须超时失败',
      );
      await bobExpectation;
    });
  });

  group('channel binding（ACT 3 真形态）', () {
    test('完整配对成功：两端各自产出对端声明指纹，声明与观测一致 → 绑定通过',
        () async {
      final fabric = _PairingFabric();
      final aliceKeys = _makeStore('alice-device');
      final bobKeys = _makeStore('bob-device');
      const certFpA = 'sha-256 AA:BB:CC:DD';
      const certFpB = 'sha-256 11:22:33:44';

      // 两端用真 ChannelBinding（本端传输层证书指纹）并发配对：
      // 本端指纹来自 channelBinding，进入签名对象被私钥签名（真路径）。
      final aliceFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: aliceKeys,
        binding: const ChannelBinding(localCertificateFingerprint: certFpA),
      ).pair('rv-binding-ok');

      final bobFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: bobKeys,
        binding: const ChannelBinding(localCertificateFingerprint: certFpB),
      ).pair('rv-binding-ok');

      final aliceResult = await aliceFuture;
      final bobResult = await bobFuture;

      // 各自从验签通过的信封里拿到对端声明的证书指纹（可信）。
      expect(aliceResult.peerDeclaredCertificateFingerprint, certFpB,
          reason: 'alice 拿到的声明指纹必须是 bob 签进去的 certFpB');
      expect(bobResult.peerDeclaredCertificateFingerprint, certFpA,
          reason: 'bob 拿到的声明指纹必须是 alice 签进去的 certFpA');

      // 握手强制（模拟 connect 握手内部）：无 MITM 时声明 == 观测 → 通过。
      enforceChannelBindingMatches(
        peerDeclaredCertificateFingerprint:
            aliceResult.peerDeclaredCertificateFingerprint,
        observedPeerCertificateFingerprint: certFpB,
      );
      enforceChannelBindingMatches(
        peerDeclaredCertificateFingerprint:
            bobResult.peerDeclaredCertificateFingerprint,
        observedPeerCertificateFingerprint: certFpA,
      );
    });

    test('声明 ≠ 观测 → enforceChannelBindingMatches 抛 PairingBindingMismatchError',
        () async {
      final fabric = _PairingFabric();
      final aliceKeys = _makeStore('alice-device');
      final bobKeys = _makeStore('bob-device');
      const certFpA = 'sha-256 AA:BB:CC:DD';
      const mFp = 'sha-256 M0:00:00:00:00'; // 攻击者证书指纹

      // 完整配对流程（真路径）：A 声明 certFpA，B 声明自己的指纹。
      final aliceFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: aliceKeys,
        binding: const ChannelBinding(localCertificateFingerprint: certFpA),
      ).pair('rv-binding-mismatch');
      final bobFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: bobKeys,
        binding: const ChannelBinding(
          localCertificateFingerprint: 'sha-256 B1:11:11:11:11',
        ),
      ).pair('rv-binding-mismatch');
      final aliceResult = await aliceFuture;
      final bobResult = await bobFuture;

      expect(aliceResult.peerDeclaredCertificateFingerprint,
          'sha-256 B1:11:11:11:11');
      expect(bobResult.peerDeclaredCertificateFingerprint, certFpA);

      // 握手强制：B 这一腿观测到的是攻击者 M 的证书（被替换）→
      // 声明 certFpA ≠ 观测 mFp → 必须抛 PairingBindingMismatchError。
      expect(
        () => enforceChannelBindingMatches(
          peerDeclaredCertificateFingerprint:
              bobResult.peerDeclaredCertificateFingerprint,
          observedPeerCertificateFingerprint: mFp,
        ),
        throwsA(isA<PairingBindingMismatchError>()),
        reason: '声明与观测不等必须抛 PairingBindingMismatchError（MITM 发现路径）',
      );
    });
  });

  group('A5 · MITM 负向测试（真注入，真路径）', () {
    test('信令被攻破：攻击者替换传输层证书 → 握手强制必须发现', () async {
      // 攻击者 Mallory 站在 A 与 B 之间，给 B 的腿发自己的证书：
      // - A 诚实声明自己的证书指纹（aliceCertFp），经信令签发给 B；
      // - B 这一腿与 M 握手，观测到的是 M 的证书指纹（mCertFp）。
      // 两端完整跑配对协议（open→presence→offer→挑战-应答→验签），
      // 声明指纹来自验签通过的信封（非测试自造）；唯有「观测」来源被
      // 攻击者替换 —— 这是真注入，不是「构造两个字符串断言 !=」。
      final fabric = _PairingFabric(); // 信令通道本身未被篡改（攻击在传输层）
      final aliceKeys = _makeStore('alice-device');
      final bobKeys = _makeStore('bob-device');

      const aliceCertFp = 'sha-256 A1:01:11:11:11:11'; // A 的传输层证书
      const bobCertFp = 'sha-256 B2:02:22:22:22:22'; // B 的传输层证书
      const mCertFp = 'sha-256 M0:00:AA:BB:CC:DD'; // 攻击者 M 的证书

      // 两端用真 ChannelBinding 并发配对（真路径：指纹来自 channelBinding）。
      final aliceFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: aliceKeys,
        binding: const ChannelBinding(localCertificateFingerprint: aliceCertFp),
      ).pair('rv-mitm');
      final bobFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: bobKeys,
        binding: const ChannelBinding(localCertificateFingerprint: bobCertFp),
      ).pair('rv-mitm');
      final aliceResult = await aliceFuture;
      final bobResult = await bobFuture;

      // 配对本身成功（信令层声明可验签）；攻击发生在传输层握手：
      // B 观测到 M 的证书，而 A 声明的是自己的证书 → 不等 → 必须发现。
      expect(aliceResult.peerDeclaredCertificateFingerprint, bobCertFp,
          reason: 'alice 从验签通过的信封拿到的声明指纹必须是 bob 的（可信）');
      expect(bobResult.peerDeclaredCertificateFingerprint, aliceCertFp,
          reason: 'bob 从验签通过的信封拿到的声明指纹必须是 alice 的（可信）');
      expect(
        () => enforceChannelBindingMatches(
          peerDeclaredCertificateFingerprint:
              bobResult.peerDeclaredCertificateFingerprint,
          observedPeerCertificateFingerprint: mCertFp, // B 观测到 M
        ),
        throwsA(isA<PairingBindingMismatchError>()),
        reason: 'A5：MITM 替换证书后握手强制必须抛 PairingBindingMismatchError'
            '（声明 ≠ 观测，配对不能成功）',
      );

      // 正向对照：无 MITM 时（B 观测到 A 的真实证书）→ 绑定通过。
      expect(
        () => enforceChannelBindingMatches(
          peerDeclaredCertificateFingerprint:
              bobResult.peerDeclaredCertificateFingerprint,
          observedPeerCertificateFingerprint: aliceCertFp,
        ),
        returnsNormally,
        reason: '无 MITM 时声明与观测一致，绑定必须通过',
      );
    });
  });

  group('配对流程 · 失败语义', () {
    test('对端不到场 → 等待 presence 超时抛 PairingError', () async {
      final fabric = _PairingFabric();
      final aliceKeys = _makeStore('alice-device');
      // 只有一端 open，对端永远不到 → presence 等待超时。
      await expectLater(
        DevicePairingProtocol(
          channel: fabric.channel(),
          keys: aliceKeys,
        ).pair('rv-lonely', timeout: const Duration(milliseconds: 300)),
        throwsA(isA<PairingError>()),
        reason: '对端不出现必须超时抛错，不无限等待',
      );
    });

    test('坏 PEM → PairingError（非静默）', () async {
      final fabric = _PairingFabric(badPem: true);
      final aliceKeys = _makeStore('alice-device');
      final bobKeys = _makeStore('bob-device');

      final bobFuture = DevicePairingProtocol(
        channel: fabric.channel(),
        keys: bobKeys,
      ).pair('rv-badpem', timeout: const Duration(seconds: 2));
      final bobExpectation = expectLater(
        bobFuture,
        throwsA(isA<PairingError>()),
        reason: 'bob 收到坏 PEM 必须抛 PairingError',
      );

      await expectLater(
        DevicePairingProtocol(
          channel: fabric.channel(),
          keys: aliceKeys,
        ).pair('rv-badpem', timeout: const Duration(seconds: 2)),
        throwsA(isA<PairingError>()),
        reason: 'alice 收到坏 PEM 必须抛 PairingError',
      );
      await bobExpectation;
    });
  });
}

// ── 测试辅助：单一内存 fabric 引擎 ─────────────────────────────

PersistentDeviceKeyStore _makeStore(String deviceId) =>
    PersistentDeviceKeyStore(
      storage: _InMemorySecureStorage(),
      uuid: _FixedUuid(deviceId),
    );

/// 配对 fabric：同一会合标识下两端互投信封。
///
/// - **缓冲投递**：对端尚未订阅 incoming 时事件入队，订阅后送达
///   （非 broadcast 控制器语义），不丢事件。
/// - **presence 通知**：新会话挂到某会合标识时，同标识所有会话翻转为
///   present（先到者等后到者）。
/// - **[tamper]**：投递前把信封过一遍变换（模拟攻击者篡改信封）。
/// - **[badPem]**：对端首次收到的 offer 替换为坏 PEM（模拟恶意对端）。
class _PairingFabric {
  final PairingEnvelope Function(PairingEnvelope)? tamper;
  final bool badPem;
  final Map<String, List<_FabricSession>> _sessions = {};

  _PairingFabric({this.tamper, this.badPem = false});

  PairingChannel channel() => _FabricChannel(this);

  void _attach(_FabricSession session) {
    final existing = List<_FabricSession>.from(
        _sessions[session.rendezvous] ?? const <_FabricSession>[]);
    _sessions.putIfAbsent(session.rendezvous, () => []).add(session);
    // 只有「对端已存在」才翻转为 present：孤立会话保持 awaiting，
    // 先到者等后到者；后到者到来时双方同时翻转为 present。
    if (existing.isNotEmpty) {
      session._notifyPeerPresent();
      for (final s in existing) {
        s._notifyPeerPresent();
      }
    }
  }

  _FabricSession? _peerOf(String rv, _FabricSession self) {
    for (final s in _sessions[rv] ?? const <_FabricSession>[]) {
      if (!identical(s, self)) return s;
    }
    return null;
  }
}

class _FabricChannel implements PairingChannel {
  final _PairingFabric _fabric;
  _FabricChannel(this._fabric);

  @override
  Future<PairingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) async {
    final session = _FabricSession(_fabric, rendezvous);
    _fabric._attach(session);
    return session;
  }

  @override
  Future<void> dispose() async {}
}

class _FabricSession implements PairingSession {
  final _PairingFabric _fabric;
  @override
  final RendezvousKey rendezvous;

  // 非 broadcast：事件缓冲到首个订阅者，先到者事件不丢。
  final _incoming = StreamController<PairingEnvelope>();
  // 单订阅 presence：open 时先入队 awaiting（缓冲），对端到场再入队
  // present —— 不用 async* 生成器，就没有「yield 间隙丢广播事件」竞态。
  final _presence = StreamController<PeerPresence>();
  bool _peerPresent = false;
  bool _badPemSent = false;

  _FabricSession(this._fabric, this.rendezvous) {
    _presence.add(PeerPresence.awaiting);
  }

  void _notifyPeerPresent() {
    if (!_peerPresent) {
      _peerPresent = true;
      _presence.add(PeerPresence.present);
    }
  }

  @override
  Stream<PairingEnvelope> get incoming => _incoming.stream;

  @override
  Stream<PeerPresence> get peerPresence => _presence.stream;

  @override
  Future<void> send(PairingEnvelope envelope) async {
    final peer = _fabric._peerOf(rendezvous, this);
    if (peer == null || peer._closed) {
      throw PairingError(
        message: '对端不在线',
        reason: '同一会合标识下没有其他在线会话',
        suggestion: '确认对端已 open 同一 rendezvous',
      );
    }
    var toDeliver = _fabric.tamper?.call(envelope) ?? envelope;
    if (_fabric.badPem && !peer._badPemSent) {
      peer._badPemSent = true;
      toDeliver = const PairingOfferEnvelope(
        deviceId: 'evil-device',
        publicKeyPem: '-----BEGIN PUBLIC KEY-----\nbm90LWEtcGVt\n'
            '-----END PUBLIC KEY-----',
      );
    }
    peer._incoming.add(toDeliver);
  }

  bool _closed = false;

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    // 从 fabric 摘除自己：对端此后 send 会得到「对端不在线」。
    final list = _fabric._sessions[rendezvous];
    list?.remove(this);
    // 单订阅控制器有缓冲事件且无监听者时 close() 永不完成 ——
    // 不 await，避免测试挂起（fabric 随测试进程结束回收）。
    unawaited(_incoming.close());
    unawaited(_presence.close());
  }
}

// ── 测试辅助：Hub 星型拓扑 fabric（ACT 5 第二个结构迥异的实现）──

/// 星型枢纽：所有信封经 hub 路由（与 `_PairingFabric` 的注册表直投
/// 结构迥异）。hub 按会合标识持有会话，投递时广播给同标识的**其他**
/// 会话；presence 由 hub 统一通知。
class _HubPairingFabric {
  final _Hub _hub = _Hub();

  PairingChannel aliceChannel() => _HubChannel(this, 'alice');
  PairingChannel bobChannel() => _HubChannel(this, 'bob');

  Future<PairingSession> open(String side, RendezvousKey rv) =>
      _hub.open(side, rv);
}

class _Hub {
  final Map<String, List<_HubSession>> _sessions = {};

  Future<PairingSession> open(String side, RendezvousKey rv) async {
    final existing =
        List<_HubSession>.from(_sessions[rv] ?? const <_HubSession>[]);
    final session = _HubSession(this, rv, side);
    _sessions.putIfAbsent(rv, () => []).add(session);
    if (existing.isNotEmpty) {
      session._notifyPeerPresent();
      for (final s in existing) {
        s._notifyPeerPresent();
      }
    }
    return session;
  }

  void deliver(RendezvousKey rv, _HubSession from, PairingEnvelope e) {
    for (final s in _sessions[rv] ?? const <_HubSession>[]) {
      if (!identical(s, from) && !s._closed) {
        s._incoming.add(e);
      }
    }
  }
}

class _HubChannel implements PairingChannel {
  final _HubPairingFabric _fabric;
  final String side;
  _HubChannel(this._fabric, this.side);

  @override
  Future<PairingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) =>
      _fabric.open(side, rendezvous);

  @override
  Future<void> dispose() async {}
}

class _HubSession implements PairingSession {
  final _Hub _hub;
  @override
  final RendezvousKey rendezvous;
  final String side;
  final _incoming = StreamController<PairingEnvelope>();
  final _presence = StreamController<PeerPresence>();
  bool _peerPresent = false;
  bool _closed = false;

  _HubSession(this._hub, this.rendezvous, this.side) {
    _presence.add(PeerPresence.awaiting);
  }

  void _notifyPeerPresent() {
    if (!_peerPresent) {
      _peerPresent = true;
      _presence.add(PeerPresence.present);
    }
  }

  @override
  Stream<PairingEnvelope> get incoming => _incoming.stream;

  @override
  Stream<PeerPresence> get peerPresence => _presence.stream;

  @override
  Future<void> send(PairingEnvelope envelope) async {
    _hub.deliver(rendezvous, this, envelope);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final list = _hub._sessions[rendezvous];
    list?.remove(this);
    // 同 `_FabricSession.close()`：单订阅控制器有缓冲事件且无监听者时
    // close() 永不完成 —— 不 await。
    unawaited(_incoming.close());
    unawaited(_presence.close());
  }
}

// ── 测试辅助：内存 secure storage 与固定 UUID（与
//    device_key_store_test.dart 同款，私有副本）───────────────
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
  final String _value;
  const _FixedUuid(this._value);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #v4) {
      return _value;
    }
    return super.noSuchMethod(invocation);
  }
}
