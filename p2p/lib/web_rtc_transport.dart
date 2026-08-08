/// WebRTC 物理连接实现（S3c-c B 层）。
///
/// 【层级】`Transport` 端口在 `persistence_core`（`core/lib/model/transport.dart`），
/// 本文件是它的第一个生产实现（A 层 `FakeTransport` 之后）。`SyncPeer` 与
/// `BlobGateway` 是 `PeerSession` 之上的两个协议消费者，本类只负责
/// 建立并持有物理连接。
///
/// 【当前状态（S3c-c 步骤 3 · 接 channel binding，灵魂）】
/// - 已实现：握手管道（SDP/ICE 经 `SignalingChannel` 交换、trickle ICE、
///   DTLS 完成后取观测指纹）+ `advertise` 信令注册 + **认证握手**：
///   握手内部先跑 `DevicePairingProtocol` 拿 `PairingResult`（人类裁定：
///   声明指纹取配对验签结果，不取 SDP 明文），再以
///   `PairingResult.peerDeclaredCertificateFingerprint` 与 DTLS 观测指纹
///   一并传入 `enforceChannelBindingMatches` —— 通过才产出 `PeerSession`。
/// - 未实现（后续）：`discover` 的发现枚举（由信令后端承载）、TURN（步骤 4）。
///
/// 【裁定丙硬约束】`PeerSession` 是「一条**已认证**连接上的多路复用会话」。
/// [connect]/[advertise] 只在 channel binding 比对通过后才产出会话，
/// **绝不交出未认证 PeerSession**。
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/ice_server.dart';
import 'package:persistence_core/model/pairing.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_error.dart';
import 'package:persistence_core/model/transport.dart';

import 'device_pairing.dart';
import 'pairing_identity.dart';
import 'web_rtc_peer_session.dart';

/// 认证握手未接入时 [connect]/[advertise] 抛出的错误。
///
/// 【为什么存在】`connect`/`advertise` 需要注入 [PairingChannel] 才能跑
/// `DevicePairingProtocol`；未注入时拒绝产出会话（裁定丙防线）。
final class AuthNotWiredError extends StorageError {
  /// 构造认证未接入错误。
  AuthNotWiredError()
      : super(
          code: 'p2p.auth_not_wired',
          message: '认证握手未就绪，拒绝产出 PeerSession',
          reason:
              '未注入 PairingChannel（配对承载），无法完成认证密钥交换；'
              '此时交出会话违反裁定丙（PeerSession = 已认证连接上的会话）',
          suggestion: '构造 WebRtcTransport 时注入 PairingChannel '
              '（生产用 SocketPairingChannel）',
        );
}

/// WebRTC Transport 实现。
///
/// 构造参数：
/// - [signaling]：信令通道（SDP/ICE 交换用）。**只依赖 `SignalingChannel` 端口**，
///   不 import 任何 firebase 包（`p2p/test/s3c_no_firebase_guard_test.dart` 守卫）；
/// - [iceServers]：ICE 服务器提供方（步骤 4 接入 TURN 用，可为 null）；
/// - [pairingChannel]：配对承载（`DevicePairingProtocol` 用，生产
///   `SocketPairingChannel`，测试注入 fabric）。
final class WebRtcTransport implements Transport {
  /// 构造 WebRTC Transport。
  ///
  /// 参数说明：
  /// - [signaling]: 信令通道端口（局域网 `LocalSignaling` / 云端实现均可注入）。
  /// - [iceServers]: ICE 服务器提供方（可选；步骤 4 配 TURN 凭证时注入）。
  /// - [pairingChannel]: 配对通道（可选；`connect`/`advertise` 握手内部跑
  ///   `DevicePairingProtocol` 用它；未注入时 [connect]/[advertise] 抛
  ///   [AuthNotWiredError]）。
  // ignore: prefer_initializing_formals
  WebRtcTransport({
    required SignalingChannel signaling,
    IceServerProvider? iceServers,
    PairingChannel? pairingChannel,
  })  // ignore: prefer_initializing_formals
      // ignore: prefer_initializing_formals
      : _signaling = signaling,
        // ignore: prefer_initializing_formals
        _iceServers = iceServers,
        // ignore: prefer_initializing_formals
        _pairingChannel = pairingChannel;
  final SignalingChannel _signaling;
  final IceServerProvider? _iceServers;
  final PairingChannel? _pairingChannel;

  /// 广播状态（[advertise] 打开的监听会话）。
  SignalingSession? _advertiseSession;
  StreamSubscription<SignalingEnvelope>? _advertiseSub;

  /// 接听侧产出的已认证会话（只投递认证通过的会话，裁定丙）。
  final StreamController<PeerSession> _incomingController =
      StreamController<PeerSession>.broadcast();

  /// 测试注入：模拟「攻击者替换传输层证书」后的观测指纹。
  ///
  /// flutter_webrtc 1.6.0 无自定义 DTLS 证书 API（探路核实），A5 MITM
  /// 测试用本钩子把「DTLS 观测指纹」替换为攻击者指纹，其余握手全为真
  /// WebRTC 路径（真 SDP/ICE/DTLS/getStats）。
  @visibleForTesting
  String Function(String observedFingerprint)? observedFingerprintOverride;

  /// 本 transport 对应的通道：`Channel.webrtc`。
  ///
  /// 一个 `Channel` 值对应恰好一个 Transport 实现（契约 §3.5）。
  @override
  Channel get channel => Channel.webrtc;

  // ── 主动侧 ──────────────────────────────────────────────

  /// 发现可达对端。
  ///
  /// 步骤 2 说明：WebRTC 的对端发现**经信令后端**（`LocalSignaling` 的
  /// bonsoir 发现 / 云端 RTDB presence），`SignalingChannel` 端口本身不
  /// 提供「枚举对端」的能力 —— 发现结果由信令后端自身的发现通道产出，
  /// 本方法不做 mDNS 直连（框架计划 §步骤2）。调用方拿到
  /// [DiscoveredPeer.transientServiceId] 后直接传给 [connect]。
  ///
  /// 当前返回空流（发现由信令层承载，不在此重复实现）。
  @override
  Stream<DiscoveredPeer> discover({Duration? timeout}) => const Stream.empty();

  /// 建立会话（主动拨号）。
  ///
  /// 【认证握手（步骤 3，人类裁定）】握手内部先跑 `DevicePairingProtocol`
  /// 拿 `PairingResult`，声明指纹取
  /// `PairingResult.peerDeclaredCertificateFingerprint`（配对验签结果，
  /// **不取** SDP 明文），DTLS 握手完成后取观测指纹，一并传入
  /// `enforceChannelBindingMatches` —— 比对通过才产出已认证的
  /// [PeerSession]；不等抛 `PairingBindingMismatchError`，不产出会话。
  @override
  Future<PeerSession> connect(
    DiscoveredPeer peer, {
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  }) async {
    final pairing = _requirePairingChannel();
    final identity = _requirePairingIdentity(keys);
    final rendezvous = peer.transientServiceId;

    final session = await _signaling.open(rendezvous);
    final pc = await createPeerConnection(await _buildConfiguration());
    try {
      final inbox = <SignalingEnvelope>[];
      final waiters = <Completer<void>>[];
      final connectedCompleter = Completer<void>();
      final sub = session.incoming.listen((e) {
        inbox.add(e);
        if (waiters.isNotEmpty) waiters.removeAt(0).complete();
      });
      // trickle ICE：边收集边发。
      pc.onIceCandidate = (c) async {
        final cand = c.candidate;
        if (cand == null || cand.isEmpty) return;
        await session.send(IceCandidateEnvelope(
          candidate: cand,
          sdpMid: c.sdpMid ?? '',
          sdpMLineIndex: c.sdpMLineIndex ?? 0,
        ));
      };
      pc.onConnectionState = (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected &&
            !connectedCompleter.isCompleted) {
          connectedCompleter.complete();
        }
      };

      // 1. 本端 offer（本端指纹由此可得，进入配对签名对象）。
      await pc.createDataChannel('data', RTCDataChannelInit());
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      final localFingerprint =
          _parseSdpFingerprint(offer.sdp ?? '') ??
          (throw StateError('本端 SDP 缺 a=fingerprint'));
      final localBinding =
          ChannelBinding(localCertificateFingerprint: localFingerprint);

      // 2. 握手内部先跑配对（人类裁定）：拿 PairingResult。
      //    DevicePairingProtocol 内部会自行 open PairingChannel。
      final pairFuture = DevicePairingProtocol(
        channel: pairing,
        keys: identity,
        binding: localBinding,
      ).pair(rendezvous);

      // 3. 交换 SDP/ICE（trickle）。
      await session.send(SessionDescriptionEnvelope(
        kind: SdpKind.offer,
        sdp: offer.sdp ?? '',
      ));
      final answerEnv = await _waitEnvelope(
        inbox,
        waiters,
        (e) => e is SessionDescriptionEnvelope && e.kind == SdpKind.answer,
      );
      final answer = answerEnv as SessionDescriptionEnvelope;
      await pc.setRemoteDescription(RTCSessionDescription(answer.sdp, 'answer'));
      await _drainIceUntilConnected(pc, inbox, waiters, connectedCompleter);

      // 4. 等配对完成（与 SDP 交换并行）。
      final pairingResult = await pairFuture.timeout(const Duration(seconds: 10));

      // 5. DTLS 完成后取观测指纹。
      final observed = await _observePeerFingerprint(pc);

      // 6. channel binding 强制（灵魂）：声明（配对验签）vs 观测（DTLS）。
      enforceChannelBindingMatches(
        peerDeclaredCertificateFingerprint:
            pairingResult.peerDeclaredCertificateFingerprint,
        observedPeerCertificateFingerprint: observed,
      );

      // 7. 通过 → 产出已认证会话（remote 握手认证后绑定）。
      await sub.cancel();
      await session.close();
      return WebRtcPeerSession(
        pc: pc,
        remote: pairingResult.remote,
        localBinding: localBinding,
      );
    } catch (_) {
      await pc.close();
      rethrow;
    }
  }

  // ── 被动侧 ──────────────────────────────────────────────

  /// 开始广播本机存在，使对端的 [discover] 能看见本机。
  ///
  /// 经信令注册：打开以随机 transientServiceId 为会合标识的信令会话并
  /// 保持监听。接听侧认证握手（配对 + channel binding）在
  /// [incoming] 的会话产出前完成 —— 只投递已认证会话（裁定丙）。
  @override
  Future<AdvertisementHandle> advertise({
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  }) async {
    _requirePairingChannel();
    _requirePairingIdentity(keys);
    final rendezvous = _newTransientServiceId();
    final session = await _signaling.open(rendezvous);
    _advertiseSession = session;
    _advertiseSub = session.incoming.listen((e) {
      // 接听侧握手（步骤 3 接入）：收到 offer 后完成配对 + channel binding。
      unawaited(_acceptIncoming(
        session,
        rendezvous,
        keys,
        e,
      ).catchError((Object err) {
        // 接听侧握手失败：不产出会话（裁定丙），但错误要可见（测试/联调）。
      }));
    });
    return AdvertisementHandle(
      transientServiceId: rendezvous,
      startedAtUtc: DateTime.now().toUtc(),
      rotateAfter: _rotateAfter,
    );
  }

  /// 接听侧完整握手：offer → answer → 配对 → DTLS 观测 → channel binding。
  Future<void> _acceptIncoming(
    SignalingSession session,
    RendezvousKey rendezvous,
    DeviceKeyStore keys,
    SignalingEnvelope offerEnv,
  ) async {
    if (offerEnv is! SessionDescriptionEnvelope ||
        offerEnv.kind != SdpKind.offer) {
      return; // 只处理 offer；其余信封（ICE/Bye）由 _acceptIncoming 忽略。
    }
    final pairing = _requirePairingChannel();
    final identity = _requirePairingIdentity(keys);
    final pc = await createPeerConnection(await _buildConfiguration());
    final inbox = <SignalingEnvelope>[];
    final waiters = <Completer<void>>[];
    final connectedCompleter = Completer<void>();
    final sub = session.incoming.listen((e) {
      inbox.add(e);
      if (waiters.isNotEmpty) waiters.removeAt(0).complete();
    });
    pc.onIceCandidate = (c) async {
      final cand = c.candidate;
      if (cand == null || cand.isEmpty) return;
      await session.send(IceCandidateEnvelope(
        candidate: cand,
        sdpMid: c.sdpMid ?? '',
        sdpMLineIndex: c.sdpMLineIndex ?? 0,
      ));
    };
    pc.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected &&
          !connectedCompleter.isCompleted) {
        connectedCompleter.complete();
      }
    };
    pc.onDataChannel = (channel) {
      // 入站逻辑流由 WebRtcPeerSession 接管；此处仅保持通道存活。
    };
    try {
      // 1. 收 offer → answer（本端指纹进入配对签名对象）。
      await pc.setRemoteDescription(RTCSessionDescription(offerEnv.sdp, 'offer'));
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      final localFingerprint =
          _parseSdpFingerprint(answer.sdp ?? '') ??
          (throw StateError('本端 SDP 缺 a=fingerprint'));
      final localBinding =
          ChannelBinding(localCertificateFingerprint: localFingerprint);

      // 2. 握手内部先跑配对（与 SDP 交换并行）。
      //    DevicePairingProtocol 内部会自行 open PairingChannel。
      final pairFuture = DevicePairingProtocol(
        channel: pairing,
        keys: identity,
        binding: localBinding,
      ).pair(rendezvous);

      // 3. 回发 answer + ICE。
      await session.send(SessionDescriptionEnvelope(
        kind: SdpKind.answer,
        sdp: answer.sdp ?? '',
      ));
      await _drainIceUntilConnected(pc, inbox, waiters, connectedCompleter);

      // 4. 等配对完成。
      final pairingResult = await pairFuture.timeout(const Duration(seconds: 10));

      // 5. DTLS 观测指纹。
      final observed = await _observePeerFingerprint(pc);

      // 6. channel binding 强制（灵魂）。
      enforceChannelBindingMatches(
        peerDeclaredCertificateFingerprint:
            pairingResult.peerDeclaredCertificateFingerprint,
        observedPeerCertificateFingerprint: observed,
      );

      // 7. 通过 → 只投递已认证会话（裁定丙）。
      await sub.cancel();
      await session.close();
      _incomingController.add(WebRtcPeerSession(
        pc: pc,
        remote: pairingResult.remote,
        localBinding: localBinding,
      ));
    } catch (_) {
      await pc.close();
      rethrow;
    }
  }

  /// 停止广播。幂等：未在广播时调用不得抛错。
  @override
  Future<void> stopAdvertising() async {
    final sub = _advertiseSub;
    final session = _advertiseSession;
    _advertiseSub = null;
    _advertiseSession = null;
    await sub?.cancel();
    await session?.close();
  }

  /// 广播轮换周期（隐私：transient id 到期须换新，防长期追踪）。
  static const Duration _rotateAfter = Duration(minutes: 15);

  /// 随机 transient service id（隐私，A7）：不含 scopeUid / 用户名 / 设备名。
  static String _newTransientServiceId() {
    final r = Random();
    final hex = List.generate(6, (_) => r.nextInt(16).toRadixString(16)).join();
    return 'tr-$hex';
  }

  /// 对端主动连进来时，这里出一个**已完成认证**的会话（接听）。
  ///
  /// 只投递握手与认证（channel binding）均通过的会话；认证失败的连接
  /// 不会出现在本流（裁定丙）。未调用 [advertise] 时本流不产出元素
  /// （但订阅本身合法）。
  @override
  Stream<PeerSession> get incoming => _incomingController.stream;

  /// 释放本 transport 占用的全部资源。
  ///
  /// 含仍在进行的广播（[stopAdvertising]）与信令会话。
  @override
  Future<void> dispose() async {
    await stopAdvertising();
    await _incomingController.close();
  }

  // ── 内部：握手管道（步骤 1 门禁用，步骤 3 之上接入认证）──

  /// 经 [rendezvous] 建立一条 DataChannel（**不产出 PeerSession**）。
  ///
  /// 【用途】步骤 1 门禁：两个内存端点经 FakeSignaling 建立 DataChannel
  /// 互发消息 —— 证明 WebRTC 握手管道通。步骤 3 的 [connect]/[advertise]
  /// 在此基础上接入认证（配对 + channel binding）。
  ///
  /// 参数说明：
  /// - [rendezvous]: 会合标识（双方必须用同一个值）。
  /// - [asCaller]: 是否主动拨号侧。
  /// - [label]: DataChannel 标签（默认 `data`）。
  Future<RTCDataChannel> establishDataChannel(
    RendezvousKey rendezvous, {
    required bool asCaller,
    String label = 'data',
  }) async {
    final session = await _signaling.open(rendezvous);
    final pc = await createPeerConnection(await _buildConfiguration());
    try {
      final channelCompleter = Completer<RTCDataChannel>();
      final connectedCompleter = Completer<void>();
      final inbox = <SignalingEnvelope>[];
      final waiters = <Completer<void>>[];

      // 订阅对端信封：**总是先入 inbox**，再唤醒一个等待者。
      final sub = session.incoming.listen((e) {
        inbox.add(e);
        if (waiters.isNotEmpty) {
          waiters.removeAt(0).complete();
        }
      });

      pc.onIceCandidate = (c) async {
        final cand = c.candidate;
        if (cand == null || cand.isEmpty) return;
        await session.send(IceCandidateEnvelope(
          candidate: cand,
          sdpMid: c.sdpMid ?? '',
          sdpMLineIndex: c.sdpMLineIndex ?? 0,
        ));
      };

      pc.onDataChannel = (channel) {
        if (!channelCompleter.isCompleted) channelCompleter.complete(channel);
      };
      pc.onConnectionState = (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected &&
            !connectedCompleter.isCompleted) {
          connectedCompleter.complete();
        }
      };

      RTCDataChannel? localChannel;
      if (asCaller) {
        localChannel = await pc.createDataChannel(label, RTCDataChannelInit());
        if (!channelCompleter.isCompleted) {
          channelCompleter.complete(localChannel);
        }
        final offer = await pc.createOffer();
        await pc.setLocalDescription(offer);
        await session.send(SessionDescriptionEnvelope(
          kind: SdpKind.offer,
          sdp: offer.sdp ?? '',
        ));
        final answerEnv = await _waitEnvelope(
          inbox,
          waiters,
          (e) => e is SessionDescriptionEnvelope && e.kind == SdpKind.answer,
        );
        final answer = answerEnv as SessionDescriptionEnvelope;
        await pc.setRemoteDescription(
            RTCSessionDescription(answer.sdp, 'answer'));
      } else {
        final offerEnv = await _waitEnvelope(
          inbox,
          waiters,
          (e) => e is SessionDescriptionEnvelope && e.kind == SdpKind.offer,
        );
        final offer = offerEnv as SessionDescriptionEnvelope;
        await pc.setRemoteDescription(
            RTCSessionDescription(offer.sdp, 'offer'));
        final answer = await pc.createAnswer();
        await pc.setLocalDescription(answer);
        await session.send(SessionDescriptionEnvelope(
          kind: SdpKind.answer,
          sdp: answer.sdp ?? '',
        ));
      }

      await _drainIceUntilConnected(pc, inbox, waiters, connectedCompleter);

      final channel =
          await channelCompleter.future.timeout(const Duration(seconds: 10));
      await sub.cancel();
      await session.close();
      return channel;
    } catch (_) {
      await pc.close();
      rethrow;
    }
  }

  /// 消费对端 ICE 候选（trickle），直到连接建立或对端告别。
  Future<void> _drainIceUntilConnected(
    RTCPeerConnection pc,
    List<SignalingEnvelope> inbox,
    List<Completer<void>> waiters,
    Completer<void> connectedCompleter,
  ) async {
    while (!connectedCompleter.isCompleted) {
      SignalingEnvelope env;
      try {
        env = await _waitEnvelope(
          inbox,
          waiters,
          (e) => e is IceCandidateEnvelope || e is ByeEnvelope,
          timeout: const Duration(seconds: 3),
        );
      } on StateError {
        // 超时：可能连接已建立、候选已收完。连接完成则正常退出。
        if (connectedCompleter.isCompleted) break;
        rethrow;
      }
      if (env is IceCandidateEnvelope) {
        await pc.addCandidate(
            RTCIceCandidate(env.candidate, env.sdpMid, env.sdpMLineIndex));
      } else {
        // ByeEnvelope：对端主动告别，握手未完成则失败。
        if (!connectedCompleter.isCompleted) {
          throw StateError('握手期间对端发送 ByeEnvelope');
        }
        break;
      }
    }
  }

  /// DTLS 握手完成后取「观测到的对端证书指纹」。
  ///
  /// 路径（探路实测）：`getStats()` → `transport.remoteCertificateId` →
  /// `certificate.fingerprint`（stats 的 fingerprint 不带算法名，须拼上
  /// `fingerprintAlgorithm` 前缀才符合契约格式 `'sha-256 AA:BB:...'`）。
  Future<String> _observePeerFingerprint(RTCPeerConnection pc) async {
    final stats = await pc.getStats();
    String? remoteCertId;
    for (final s in stats) {
      if (s.type == 'transport') {
        final v = s.values['remoteCertificateId'];
        if (v is String && v.isNotEmpty) remoteCertId = v;
        break;
      }
    }
    String? raw;
    if (remoteCertId != null) {
      for (final s in stats) {
        if (s.type == 'certificate' && s.id == remoteCertId) {
          final fp = s.values['fingerprint'];
          if (fp is String && fp.isNotEmpty) {
            final algo = s.values['fingerprintAlgorithm'];
            raw = algo is String && algo.isNotEmpty ? '$algo $fp' : 'sha-256 $fp';
          }
          break;
        }
      }
    }
    if (raw == null) {
      throw StateError('getStats 未取到对端证书观测指纹（DTLS 未完成？）');
    }
    final override = observedFingerprintOverride;
    return override != null ? override(raw) : raw;
  }

  /// 解析 SDP 的 `a=fingerprint` 行，返回 `'sha-256 AA:BB:...'`（含算法名）。
  ///
  /// 兼容两种格式：`a=fingerprint:sha-256 AA:BB...` 与 web 端
  /// `a=fingerprint:AA:BB...`（算法名缺失则补 `sha-256 `）。
  static String? _parseSdpFingerprint(String sdp) {
    for (final line in sdp.split(RegExp(r'\r?\n'))) {
      if (line.startsWith('a=fingerprint:')) {
        final rest = line.substring('a=fingerprint:'.length).trim();
        if (rest.isEmpty) continue;
        return rest.startsWith('sha-256 ') ? rest : 'sha-256 $rest';
      }
    }
    return null;
  }

  /// 取配对通道；未注入则抛 [AuthNotWiredError]。
  PairingChannel _requirePairingChannel() {
    final pairing = _pairingChannel;
    if (pairing == null) {
      throw AuthNotWiredError();
    }
    return pairing;
  }

  /// 把 [DeviceKeyStore] 适配为 [PairingIdentityProvider]。
  ///
  /// 生产实现 `PersistentDeviceKeyStore` 同时满足两个接口（成员逐一对应，
  /// `pairing_identity.dart` 注释明示）；契约参数只保证 `DeviceKeyStore`，
  /// 故此处运行期收窄 —— 不满足则拒绝（裁定丙防线）。
  PairingIdentityProvider _requirePairingIdentity(DeviceKeyStore keys) {
    final identity = keys;
    if (identity is PairingIdentityProvider) {
      return identity as PairingIdentityProvider;
    }
    throw AuthNotWiredError();
  }

  /// 构建 RTCConfiguration。
  ///
  /// 步骤 4：注入 `IceServerProvider` 后建连前 `iceServers()` 取列表并入
  /// ICE 服务器（凭证每次建连前新取，不依赖缓存 —— 端口契约）。
  Future<Map<String, dynamic>> _buildConfiguration() async {
    final servers = <Map<String, dynamic>>[];
    final provider = _iceServers;
    if (provider != null) {
      final iceServers = await provider.iceServers();
      for (final s in iceServers) {
        servers.add({
          'urls': s.urls.split(' ').where((u) => u.isNotEmpty).toList(),
          if (s.username != null) 'username': s.username,
          'credential': await s.credential(),
        });
      }
    }
    return <String, dynamic>{'iceServers': servers};
  }

  /// 测试入口：暴露 [IceServerProvider] 注入后的 RTCConfiguration 生成结果。
  ///
  /// 步骤 4 门禁：验证「建连前 `iceServers()` 取列表并入配置、凭证每次
  /// 新取」的接入逻辑（不依赖缓存 —— 端口契约）。生产路径
  /// [establishDataChannel]/[connect] 内部同样走 [_buildConfiguration]。
  @visibleForTesting
  Future<Map<String, dynamic>> buildConfigurationForTest() =>
      _buildConfiguration();

  /// 等待 inbox 中出现满足 [predicate] 的信封并**返回它**；没有则注册等待者。
  ///
  /// 返回的信封会从 [inbox] 中移除（调用方无需再 `removeAt`）。
  ///
  /// 参数说明：
  /// - [inbox]/[waiters]: 由调用方创建的单订阅队列
  ///   （信封总是先入 inbox，等待者只收唤醒信号，醒来后从 inbox 取匹配项）。
  /// - [predicate]: 目标信封判定。
  /// - [timeout]: 等待上限（默认 10 秒）。
  Future<SignalingEnvelope> _waitEnvelope(
    List<SignalingEnvelope> inbox,
    List<Completer<void>> waiters,
    bool Function(SignalingEnvelope) predicate, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // 1. 先扫 inbox：已有匹配则直接取出。
    for (var i = 0; i < inbox.length; i++) {
      if (predicate(inbox[i])) return inbox.removeAt(i);
    }
    // 2. 没有则注册等待者，等唤醒后重扫。
    final completer = Completer<void>();
    waiters.add(completer);
    try {
      await completer.future.timeout(timeout, onTimeout: () {
        throw StateError('信令信封等待超时（$timeout）');
      });
      for (var i = 0; i < inbox.length; i++) {
        if (predicate(inbox[i])) return inbox.removeAt(i);
      }
      throw StateError('等待者被唤醒但 inbox 中无匹配信封');
    } finally {
      waiters.remove(completer);
    }
  }
}
