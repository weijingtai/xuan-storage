@OnPlatform({'vm': Skip('flutter_webrtc native 需 platform channel，仅 Chrome/真机可跑')})
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_p2p/web_rtc_transport.dart';

/// 步骤 1 门禁：经 FakeSignaling 建立 DataChannel 互发消息（框架计划 §步骤1）。
///
/// 【为什么是真 WebRTC 而非内存 fake】本测试用真 `RTCPeerConnection`
/// （flutter_webrtc），两条连接经**内存信令织物**交换 SDP/ICE —— 管道是
/// 真的（WebRTC 握手 + DTLS + DataChannel），只有「信令搬运」是内存的。
/// 这正是步骤 1 的验证目标：WebRTC 握手管道通。
///
/// 【运行环境】本测试的信令是内存织物（零 mDNS/bonsoir/dart:io），
/// 不需要网络；唯一限制是 flutter_webrtc native factory 需 platform
/// channel，仅 Chrome/真机可跑 —— 故用 `@OnPlatform({'vm': Skip(...)})`
/// 平台限定：**VM 上 skip、Chrome 上默认跑**（无需 `--run-skipped`）。
/// ```bash
/// cd p2p && flutter test -d chrome --platform chrome \
///   test/web_rtc_transport_integration_test.dart
/// ```
void main() {
  test('两个内存端点经 FakeSignaling 建立 DataChannel 互发一条消息', () async {
    final fabric = _MemorySignalingFabric();

    final alice = WebRtcTransport(signaling: fabric.channel());
    final bob = WebRtcTransport(signaling: fabric.channel());

    // 先启动被动侧（等 offer），再启动主动侧（createOffer）。
    final bobChannelFuture = bob.establishDataChannel('rv-step1', asCaller: false);
    final aliceChannel = await alice.establishDataChannel('rv-step1', asCaller: true);
    final bobChannel = await bobChannelFuture;

    expect(aliceChannel.label, 'data');
    expect(bobChannel.label, 'data');

    // 互发一条消息：alice → bob。
    final bobGot = Completer<String>();
    bobChannel.onMessage = (msg) {
      if (!bobGot.isCompleted) bobGot.complete(msg.text);
    };

    await aliceChannel.send(RTCDataChannelMessage('hello-from-alice'));
    final received = await bobGot.future.timeout(const Duration(seconds: 5));
    expect(received, 'hello-from-alice');

    // 反向：bob → alice。
    final aliceGot = Completer<String>();
    aliceChannel.onMessage = (msg) {
      if (!aliceGot.isCompleted) aliceGot.complete(msg.text);
    };
    await bobChannel.send(RTCDataChannelMessage('hello-from-bob'));
    final received2 = await aliceGot.future.timeout(const Duration(seconds: 5));
    expect(received2, 'hello-from-bob');

    await aliceChannel.close();
    await bobChannel.close();
    await alice.dispose();
    await bob.dispose();
  });
}

/// 内存信令织物：多条通道按 rendezvous 匹配，双向投递信封。
///
/// 与 `core/test/signaling_contract_test.dart` 的 `_LanFabricSignaling`
/// 同构（测试私有，p2p 用不到，故本文件自带一份最小实现）：
/// - [open] 不阻塞等待对端（契约：返回的会话此刻可能 awaiting）；
/// - 同一 rendezvous 下两条会话互见，信封按序投递；
/// - [send] 在对端 departed 时抛错（契约：不静默丢弃）。
class _MemorySignalingFabric {
  final Map<RendezvousKey, List<_MemorySession>> _sessions = {};

  /// 建一条通道（每次调用独立，可共享同一织物）。
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
    // 对端到场即 present。
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
    // 找到织物中同 rendezvous 的**其他**会话，投递过去。
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
