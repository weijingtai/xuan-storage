/// WebRTC 物理连接实现（S3c-c B 层）。
///
/// 【层级】`Transport` 端口在 `persistence_core`（`core/lib/model/transport.dart`），
/// 本文件是它的第一个生产实现（A 层 `FakeTransport` 之后）。`SyncPeer` 与
/// `BlobGateway` 是 `PeerSession` 之上的两个协议消费者，本类只负责
/// 建立并持有物理连接。
///
/// 【当前状态（S3c-c 步骤 2 · 接真信令后端）】
/// - 已实现：经 `SignalingChannel` 交换 SDP/ICE、建立 `RTCDataChannel` 的
///   握手管道（[establishDataChannel]）；`advertise` 经信令注册（打开以
///   随机 transientServiceId 为会合标识的监听会话，隐私约定不变）；
/// - 未实现（后续步骤）：认证握手（步骤 3 接入 `DevicePairingProtocol` +
///   `enforceChannelBindingMatches`）、`discover` 的发现枚举（由信令后端
///   自身发现通道承载）、TURN（步骤 4）。
///
/// 【裁定丙硬约束】`PeerSession` 是「一条**已认证**连接上的多路复用会话」。
/// 因此 [connect]/[advertise] 在认证接入前**拒绝产出 PeerSession**（抛错），
/// 绝不交出未认证会话。
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/ice_server.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_error.dart';
import 'package:persistence_core/model/transport.dart';

/// 认证握手未接入时 [connect]/[advertise] 抛出的错误。
///
/// 【为什么存在】步骤 1-2 阶段握手管道已通、但认证（channel binding）未接。
/// 裁定丙禁止交出未认证 PeerSession，故这两个入口在认证接入前必须显式失败，
/// 而不是返回一个未认证会话让调用方误用。
final class AuthNotWiredError extends StorageError {
  /// 构造认证未接入错误。
  AuthNotWiredError()
      : super(
          code: 'p2p.auth_not_wired',
          message: '认证握手尚未接入，拒绝产出 PeerSession',
          reason:
              'S3c-c 步骤 3（channel binding）尚未实现；此时交出会话违反裁定丙'
              '（PeerSession = 已认证连接上的会话）',
          suggestion: '等待步骤 3 接入 DevicePairingProtocol + '
              'enforceChannelBindingMatches 后再使用 connect/advertise',
        );
}

/// WebRTC Transport 实现。
///
/// 构造参数：
/// - [signaling]：信令通道（SDP/ICE 交换用）。**只依赖 `SignalingChannel` 端口**，
///   不 import 任何 firebase 包（`p2p/test/s3c_no_firebase_guard_test.dart` 守卫）；
/// - [iceServers]：ICE 服务器提供方（步骤 4 接入 TURN 用，可为 null）。
final class WebRtcTransport implements Transport {
  /// 构造 WebRTC Transport。
  ///
  /// 参数说明：
  /// - [signaling]: 信令通道端口（局域网 `LocalSignaling` / 云端实现均可注入）。
  /// - [iceServers]: ICE 服务器提供方（可选；步骤 4 配 TURN 凭证时注入）。
  // ignore: prefer_initializing_formals
  WebRtcTransport({required SignalingChannel signaling, IceServerProvider? iceServers})
      // ignore: prefer_initializing_formals
      : _signaling = signaling,
        // ignore: prefer_initializing_formals
        _iceServers = iceServers;

  final SignalingChannel _signaling;
  final IceServerProvider? _iceServers;

  /// 广播状态（[advertise] 打开的监听会话；步骤 3 在此接入接听侧认证握手）。
  SignalingSession? _advertiseSession;
  StreamSubscription<SignalingEnvelope>? _advertiseSub;

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
  /// **步骤 1-2 拒绝产出未认证会话（裁定丙硬约束）**：认证握手在步骤 3 接入，
  /// 在此之前调用一律抛 [AuthNotWiredError]，绝不返回未认证 PeerSession。
  @override
  Future<PeerSession> connect(
    DiscoveredPeer peer, {
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  }) async {
    throw AuthNotWiredError();
  }

  // ── 被动侧 ──────────────────────────────────────────────

  /// 开始广播本机存在，使对端的 [discover] 能看见本机。
  ///
  /// 步骤 2 实现：经信令注册 —— 打开一个以随机 `transientServiceId` 为
  /// 会合标识的信令会话并保持监听（`LocalSignaling.open` 会同时广播
  /// bonsoir 服务 + 起 socket 监听；对端 open 同一标识即配对）。
  /// 返回 [AdvertisementHandle]（隐私：只含随机 transient id，不含
  /// scopeUid/用户名/设备名）。
  ///
  /// **仍不产出 PeerSession**：接听侧会话的认证握手在步骤 3 接入
  /// （`incoming` 保持空流），此处只完成「注册/可被连接」。
  @override
  Future<AdvertisementHandle> advertise({
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  }) async {
    final rendezvous = _newTransientServiceId();
    final session = await _signaling.open(rendezvous);
    _advertiseSession = session;
    // 保持会话存活（订阅 incoming；步骤 3 在此接入接听侧认证握手）。
    _advertiseSub = session.incoming.listen((_) {});
    return AdvertisementHandle(
      transientServiceId: rendezvous,
      startedAtUtc: DateTime.now().toUtc(),
      rotateAfter: _rotateAfter,
    );
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
  /// 步骤 1 骨架：认证未接入前不出元素（空流）。步骤 3 接入后，
  /// 只投递握手与认证均通过的会话。
  @override
  Stream<PeerSession> get incoming => const Stream.empty();

  /// 释放本 transport 占用的全部资源。
  ///
  /// 含仍在进行的广播（[stopAdvertising]）与信令会话。
  @override
  Future<void> dispose() async {
    await stopAdvertising();
  }

  // ── 内部握手管道（步骤 1 门禁验证用，步骤 3 接入认证后复用）──

  /// 经 [rendezvous] 建立一条 DataChannel（**不产出 PeerSession**）。
  ///
  /// 【用途】步骤 1 门禁：两个内存端点（共享同一 `SignalingChannel` 织物）
  /// 分别以 [asCaller] true/false 调用本方法，完成 SDP/ICE 交换并建立
  /// DataChannel 互发消息 —— 证明 WebRTC 握手管道通。步骤 3 将在
  /// [connect]/[advertise] 内部复用同样的 SDP/ICE 流程并接认证。
  ///
  /// 【时序约定】
  /// - [asCaller] = true：主动 createOffer 并发送；对端 answer 到达后
  ///   setRemoteDescription；双方候选经 `IceCandidateEnvelope` 交换；
  /// - [asCaller] = false：等 offer，createAnswer 回发；`onDataChannel`
  ///   收到对端建立的数据通道。
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
      // 等待者醒来后从 inbox 里取匹配项 —— 与 pairing 同款单订阅模型，
      // 但修正了一个坑：若信封只投给 completer 而不入 inbox，调用方
      // 之后 `inbox.removeAt(0)` 会越界（RangeError）。
      final sub = session.incoming.listen((e) {
        inbox.add(e);
        if (waiters.isNotEmpty) {
          waiters.removeAt(0).complete();
        }
      });

      // ICE 候选：trickle 式，边收集边经信令发给对端。
      pc.onIceCandidate = (c) async {
        final cand = c.candidate;
        if (cand == null || cand.isEmpty) return;
        await session.send(IceCandidateEnvelope(
          candidate: cand,
          sdpMid: c.sdpMid ?? '',
          sdpMLineIndex: c.sdpMLineIndex ?? 0,
        ));
      };

      // 被动侧：对端主动开的数据通道。
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
        // 主动侧：自建通道 + offer。
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
        // 等对端 answer。
        final answerEnv = await _waitEnvelope(inbox, waiters, session,
            (e) => e is SessionDescriptionEnvelope && e.kind == SdpKind.answer);
        final answer = answerEnv as SessionDescriptionEnvelope;
        await pc.setRemoteDescription(
            RTCSessionDescription(answer.sdp, 'answer'));
      } else {
        // 被动侧：等 offer。
        final offerEnv = await _waitEnvelope(inbox, waiters, session,
            (e) => e is SessionDescriptionEnvelope && e.kind == SdpKind.offer);
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

      // 转发对端 ICE 候选（offer/answer 之后仍可能陆续到达，逐条消费到连接建立）。
      while (!connectedCompleter.isCompleted) {
        SignalingEnvelope env;
        try {
          env = await _waitEnvelope(inbox, waiters, session,
              (e) => e is IceCandidateEnvelope || e is ByeEnvelope,
              timeout: const Duration(seconds: 3));
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

      final channel = await channelCompleter.future.timeout(const Duration(seconds: 10));
      await sub.cancel();
      await session.close();
      return channel;
    } catch (_) {
      await pc.close();
      rethrow;
    }
  }

  /// 构建 RTCConfiguration。
  ///
  /// 步骤 1：无注入 provider 时返回空配置（局域网 host 候选足够）；
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

  /// 等待 inbox 中出现满足 [predicate] 的信封并**返回它**；没有则注册等待者。
  ///
  /// 返回的信封会从 [inbox] 中移除（调用方无需再 `removeAt`）。
  ///
  /// 参数说明：
  /// - [inbox]/[waiters]: 由 [establishDataChannel] 创建的单订阅队列
  ///   （信封总是先入 inbox，等待者只收唤醒信号，醒来后从 inbox 取匹配项）。
  /// - [session]: 信令会话（departed 时等待应失败）。
  /// - [predicate]: 目标信封判定。
  /// - [timeout]: 等待上限（默认 10 秒）。
  Future<SignalingEnvelope> _waitEnvelope(
    List<SignalingEnvelope> inbox,
    List<Completer<void>> waiters,
    SignalingSession session,
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
