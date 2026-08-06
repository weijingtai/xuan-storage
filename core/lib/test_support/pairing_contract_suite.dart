/// 共享配对通道契约套件（S6 / ACT 5）。
///
/// 【为什么存在】与 `signaling_contract_suite.dart` 同手法：`PairingChannel`
/// 契约测试不能写死在某个包的 `test/` 里（Dart 的 `test/` 目录不可跨包
/// 引用），提取到 `core/lib/test_support/` 后，任何 `PairingChannel` 实现
/// （本轮的两个测试 fabric、未来的信令承载实现）都跑同一套约束。
///
/// 【签名为什么是 `makePair`】与信令套件同因：多条测试要求**两端在同一
/// 会合标识下相遇**（共享 fabric / 同一织物），单个工厂调两次得到的是
/// 两个互不相干的实例，「相遇」写不出来。
///
/// 【不进 barrel】守卫 `core/test/s1b_architecture_guard_test.dart:53`
/// 已断言 barrel 不得导出 `test_support`。消费方一律
/// `import 'package:persistence_core/test_support/pairing_contract_suite.dart'`。
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/pairing.dart';
import 'package:persistence_core/model/signaling.dart';

/// 一对同拓扑的配对通道。
///
/// 两条通道必须能在同一「织物」上相遇，否则「两端在同一会合标识下
/// 相遇」无法成立。
typedef PairingChannelPair = ({PairingChannel alice, PairingChannel bob});

/// 正向断言的可观测超时：等对端事件到达的上限。
const Duration _positiveObservableTimeout = Duration(seconds: 5);

/// 有界轮询等待：直到 [test] 为真或超时。用于「先订阅记录、再等事件
/// 落进记录」的断言 —— 不依赖流可多次监听（单订阅流同一时刻只能有
/// 一个订阅者）。
Future<void> _waitUntil(
  bool Function() test,
  Duration timeout,
  String reason,
) async {
  final deadline = DateTime.now().add(timeout);
  while (!test()) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError('超时：$reason');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

/// 在指定拓扑下运行全部配对通道契约测试。
///
/// 参数说明：
/// - [topologyName]: 拓扑名，只用于测试分组展示。
/// - [makePair]: 构造一对可在同一织物上相遇的通道。**必须返回共享同一
///   织物的两条通道**，否则「相遇」类测试无法通过。
FutureOr<void> runPairingContractSuite({
  required String topologyName,
  required FutureOr<PairingChannelPair> Function() makePair,
}) {
  group('配对契约 · $topologyName', () {
    test('两端在同一会合标识下相遇并双向收发信封', () async {
      final pair = await makePair();
      const rv = 'rv-meet';

      final aliceSession = await pair.alice.open(rv);
      final bobSession = await pair.bob.open(rv);

      final aliceGot = <PairingEnvelope>[];
      final bobGot = <PairingEnvelope>[];
      // 每个会话只建一次订阅，事件落进记录列表后轮询断言。
      final subA = aliceSession.incoming.listen(aliceGot.add);
      final subB = bobSession.incoming.listen(bobGot.add);

      await aliceSession.send(const PairingOfferEnvelope(
        deviceId: 'alice',
        publicKeyPem: '-----BEGIN PUBLIC KEY-----',
      ));
      await bobSession.send(const PairingAnswerEnvelope(
        nonce: 'n1',
        localCertificateFingerprint: 'fp',
        localPublicKeyFingerprint: 'fp',
        peerPublicKeyFingerprint: 'fp',
        signatureBase64: 'sig',
      ));

      await _waitUntil(
        () => bobGot.any((e) => e is PairingOfferEnvelope),
        _positiveObservableTimeout,
        '对端 offer 未送达 bob',
      );
      await _waitUntil(
        () => aliceGot.any((e) => e is PairingAnswerEnvelope),
        _positiveObservableTimeout,
        '对端 answer 未送达 alice',
      );
      await subA.cancel();
      await subB.cancel();
    });

    test('只投递对端信封，不回显本端 send 的内容', () async {
      final pair = await makePair();
      final aliceSession = await pair.alice.open('rv-noecho');
      final bobSession = await pair.bob.open('rv-noecho');

      final aliceGot = <PairingEnvelope>[];
      final subA = aliceSession.incoming.listen(aliceGot.add);

      // alice 只发不收：发 offer 后，自己的 incoming 不得出现任何信封。
      await aliceSession.send(const PairingOfferEnvelope(
        deviceId: 'alice',
        publicKeyPem: 'pem',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(aliceGot, isEmpty,
          reason: 'incoming 只投递对端信封，不得回显本端 send');
      await subA.cancel();
      await aliceSession.close();
      await bobSession.close();
    });

    test('peerPresence：对端到场前 awaiting，到场后 present', () async {
      final pair = await makePair();
      final aliceSession = await pair.alice.open('rv-presence');

      // 单次订阅记录状态序列，轮询断言 awaiting → present 转换。
      final states = <PeerPresence>[];
      final sub = aliceSession.peerPresence.listen(states.add);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(states, contains(PeerPresence.awaiting),
          reason: '对端尚未 open 同一会合标识时必须观测到 awaiting');

      await pair.bob.open('rv-presence');
      await _waitUntil(
        () => states.contains(PeerPresence.present),
        _positiveObservableTimeout,
        '对端到场后未观测到 present',
      );
      await sub.cancel();
      await aliceSession.close();
    });

    test('rendezvous 如实回报打开时用的标识', () async {
      final pair = await makePair();
      final session = await pair.alice.open('rv-echo-id');
      expect(session.rendezvous, 'rv-echo-id');
      await session.close();
    });

    test('close 幂等：重复调用不得抛错', () async {
      final pair = await makePair();
      final session = await pair.alice.open('rv-close');
      await session.close();
      await session.close(); // 第二次不得抛错
    });

    test('不同会合标识互不串扰', () async {
      final pair = await makePair();
      final a1 = await pair.alice.open('rv-x');
      final b1 = await pair.bob.open('rv-x');
      final a2 = await pair.alice.open('rv-y');
      final b2 = await pair.bob.open('rv-y');

      final b1Got = <PairingEnvelope>[];
      final b2Got = <PairingEnvelope>[];
      final sub1 = b1.incoming.listen(b1Got.add);
      final sub2 = b2.incoming.listen(b2Got.add);

      await a1.send(const PairingOfferEnvelope(
        deviceId: 'alice',
        publicKeyPem: 'pem-x',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(b1Got, hasLength(1), reason: 'rv-x 的信封必须到 rv-x 的对端');
      expect(b2Got, isEmpty, reason: 'rv-x 的信封不得串到 rv-y');

      await sub1.cancel();
      await sub2.cancel();
      await a1.close();
      await b1.close();
      await a2.close();
      await b2.close();
    });
  });
}
