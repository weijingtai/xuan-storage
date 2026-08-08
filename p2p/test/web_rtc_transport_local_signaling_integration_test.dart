@Tags(['integration'])
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:persistence_p2p/local_signaling.dart';
import 'package:persistence_p2p/web_rtc_transport.dart';

import 'fake_lan_discovery.dart';

/// 步骤 2 门禁：WebRtcTransport 经 **真 LocalSignaling**（真实 loopback
/// socket + 内存发现表）建立 WebRTC DataChannel 互发消息。
///
/// 【与步骤 1 测试的区别】步骤 1 用内存信令织物（纯信封搬运）；本测试用
/// S3c-b 已交付的 `LocalSignaling` —— 信令消息真过 socket 序列化/反序列化，
/// WebRTC 是真握手。这验证「transport 满足真信令后端的假设」（框架计划
/// §步骤2 门禁）。
///
/// 【运行平台】`LocalSignaling` 用 `dart:io` socket + bonsoir，**不能跑在
/// Chrome**；flutter_webrtc 需要平台通道，不能跑在纯 VM。两者交集是
/// **macOS 桌面 / 真机**（需在带 runner 的消费方工程里跑，或用
/// `flutter test -d macos`）：
/// ```bash
/// cd p2p && flutter test -d macos --run-skipped \
///   test/web_rtc_transport_local_signaling_integration_test.dart
/// ```
/// `dart_test.yaml` 默认排除 integration tag，不带 `--run-skipped` 不跑。
void main() {
  test('两个 WebRtcTransport 经 LocalSignaling（真实 socket）建立 DataChannel', () async {
    // 共享发现表（模拟同一网段），连接走真实 loopback socket。
    final fabric = FakeLanFabric();
    final aliceSignaling = LocalSignaling(discovery: FakeLanDiscovery(fabric));
    final bobSignaling = LocalSignaling(discovery: FakeLanDiscovery(fabric));

    final alice = WebRtcTransport(signaling: aliceSignaling);
    final bob = WebRtcTransport(signaling: bobSignaling);

    // 先启动被动侧（等 offer），再启动主动侧（createOffer）。
    final bobChannelFuture =
        bob.establishDataChannel('rv-localsig', asCaller: false);
    final aliceChannel =
        await alice.establishDataChannel('rv-localsig', asCaller: true);
    final bobChannel = await bobChannelFuture;

    expect(aliceChannel.label, 'data');
    expect(bobChannel.label, 'data');

    // alice → bob 互发一条消息。
    final bobGot = Completer<String>();
    bobChannel.onMessage = (msg) {
      if (!bobGot.isCompleted) bobGot.complete(msg.text);
    };
    await aliceChannel.send(RTCDataChannelMessage('hello-over-localsignaling'));
    final received = await bobGot.future.timeout(const Duration(seconds: 5));
    expect(received, 'hello-over-localsignaling');

    // 反向 bob → alice。
    final aliceGot = Completer<String>();
    aliceChannel.onMessage = (msg) {
      if (!aliceGot.isCompleted) aliceGot.complete(msg.text);
    };
    await bobChannel.send(RTCDataChannelMessage('reply-over-localsignaling'));
    final received2 = await aliceGot.future.timeout(const Duration(seconds: 5));
    expect(received2, 'reply-over-localsignaling');

    await aliceChannel.close();
    await bobChannel.close();
    await alice.dispose();
    await bob.dispose();
    await aliceSignaling.dispose();
    await bobSignaling.dispose();
  });
}
