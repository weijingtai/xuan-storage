/// 共享信令契约套件（S3c-b 提取自 `core/test/signaling_contract_test.dart`）。
///
/// 【为什么存在】S3c-a 交付的 11 条契约测试原本写死在 `core/test/` 里，
/// `p2p/test/` 导入不到（Dart 的 `test/` 目录不可跨包引用）。提取到这里后，
/// 任何 `SignalingChannel` 实现（本轮的 `LocalSignaling`、以后的
/// `CloudSignaling`）都跑同一套 11 条 —— 契约的约束不会各写各的。
///
/// 【签名为什么是 `makePair` 而不是 `makeChannel`】（决定记录 D1）11 条里有
/// 9 条要求**两端在同一「织物」上相遇**（内存 LAN fake 共享一个 `_LanFabric`；
/// 真实 `LocalSignaling` 共享发现表与 loopback 网段）。单个工厂调两次得到的
/// 是两个互不相干的实例，「两端在同一会合标识下相遇」这条根本写不出来。
///
/// 【为什么 `simulateAbruptDisconnect` 是注入参数】原 `_CrashableSession` 是
/// test-private 接口（靠 cast 使用），提到 `lib/` 后不能再用 `_` 私有名；且
/// 真实实现的「崩溃」是 `socket.destroy()` 而非一次方法调用。
///
/// 【为什么走深路径消费、不进 barrel】（决定记录 D3）barrel 不得含
/// `test_support`（`core/test/s1b_architecture_guard_test.dart:53` 已断言）。
/// 消费方一律 `import 'package:persistence_core/test_support/signaling_contract_suite.dart'`。
///
/// 【等待方式 —— 为什么本文件禁用「事件队列泵送」】（决定记录 D5 / 验收 A11）
/// 旧测试依赖的「队列泵送」语义是「把事件队列转若干圈」：对同步
/// `StreamController` 碰巧成立，对任何真实 I/O 都不成立（字节要过内核）。
/// 这是**等时间 vs 等事件**的区别。裁定的做法：
/// - **正向断言**（断言某事会发生）：`await` 真实可观测量本身 + 显式 timeout，
///   如 `await session.incoming.firstWhere(...).timeout(d)`。
/// - **负向断言**（断言什么都不发生）：唯一真要等时间的地方，用有界宽限期 +
///   具名常量，且该常量**由拓扑注入**（[negativeAssertionGrace]：内存 fake 给
///   几毫秒，socket 给几百毫秒）。
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/signaling.dart';

/// 一对同拓扑的信令通道。
///
/// 两条通道必须能在同一「织物」上相遇（共享发现表 / loopback 网段 /
/// 内存 fabric），否则「两端在同一会合标识下相遇」无法成立。
typedef SignalingChannelPair = ({SignalingChannel alice, SignalingChannel bob});

/// 正向断言的可观测超时：等对端事件到达的上限。
///
/// 取 5 秒：真实 socket 在同一台机器的 loopback 上传播是亚毫秒级，
/// 5 秒只兜「实现坏了」的情况，不会掩盖慢速环境。
const Duration _positiveObservableTimeout = Duration(seconds: 5);

/// 在指定拓扑下运行全部信令契约测试。
///
/// 参数说明：
/// - [topologyName]: 拓扑名，只用于测试分组展示。
/// - [makePair]: 构造一对可在同一织物上相遇的通道。**必须返回共享同一
///   织物的两条通道**，否则 9 条「相遇」类测试无法通过。
/// - [simulateAbruptDisconnect]: 让 [session] 的对端**非正常断开**（不发
///   Bye、不优雅 close）—— 模拟进程被杀 / 断网 / 崩溃。对真实
///   `LocalSignaling` 必须真的 `destroy()` socket，不许发「假装断开」的信号
///   （验收 A3）。
/// - [negativeAssertionGrace]: 负向断言（断言**什么都不发生**）的有界宽限期。
///   **必须按拓扑注入**：内存 fake 给几毫秒（如 50ms），真实 socket 给几百
///   毫秒（如 300ms）—— 太短会假红，太长会拖慢真实拓扑。
FutureOr<void> runSignalingContractSuite({
  required String topologyName,
  required FutureOr<SignalingChannelPair> Function() makePair,
  required FutureOr<void> Function(SignalingSession) simulateAbruptDisconnect,
  Duration negativeAssertionGrace = const Duration(milliseconds: 50),
}) {
  group('契约 · $topologyName', () {
    test('两端在同一会合标识下相遇并双向收发信封', () async {
      final pair = await makePair();
      const rv = 'rv-meet';

      final aliceSession = await pair.alice.open(rv);
      final bobSession = await pair.bob.open(rv);

      final aliceGot = <SignalingEnvelope>[];
      final bobGot = <SignalingEnvelope>[];
      final subA = aliceSession.incoming.listen(aliceGot.add);
      final subB = bobSession.incoming.listen(bobGot.add);

      // 正向：先在触发前订阅可观测量（broadcast 流不回放已发事件），
      // 再 send，最后 await 事件本身 + 显式 timeout。
      final bobOfferSeen = bobSession.incoming
          .firstWhere((e) =>
              e is SessionDescriptionEnvelope && e.kind == SdpKind.offer);
      final aliceAnswerSeen = aliceSession.incoming
          .firstWhere((e) =>
              e is SessionDescriptionEnvelope && e.kind == SdpKind.answer);

      await aliceSession.send(const SessionDescriptionEnvelope(
        kind: SdpKind.offer,
        sdp: 'v=0\r\no=- 1 1 IN IP4 0.0.0.0\r\n',
      ));
      await bobSession.send(const SessionDescriptionEnvelope(
        kind: SdpKind.answer,
        sdp: 'v=0\r\no=- 2 2 IN IP4 0.0.0.0\r\n',
      ));

      await bobOfferSeen.timeout(_positiveObservableTimeout);
      await aliceAnswerSeen.timeout(_positiveObservableTimeout);

      expect(bobGot, hasLength(1), reason: 'bob 必须收到 alice 的 offer');
      expect(aliceGot, hasLength(1), reason: 'alice 必须收到 bob 的 answer');
      expect(
        (bobGot.single as SessionDescriptionEnvelope).kind,
        SdpKind.offer,
      );
      expect(
        (aliceGot.single as SessionDescriptionEnvelope).kind,
        SdpKind.answer,
      );

      await subA.cancel();
      await subB.cancel();
      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    test('incoming 不回显本端自己发出的信封', () async {
      // 契约原文：「只投递对端发来的信封，不回显本端 send 的内容」。
      // 云端拓扑最容易违反这条 —— 会合点是共享存储，天然会把自己写的
      // 也读回来。
      final pair = await makePair();
      const rv = 'rv-no-echo';

      final aliceSession = await pair.alice.open(rv);
      await pair.bob.open(rv);

      final aliceGot = <SignalingEnvelope>[];
      final sub = aliceSession.incoming.listen(aliceGot.add);

      await aliceSession.send(const IceCandidateEnvelope(
        candidate: 'candidate:1 1 udp 2130706431 192.168.0.2 54321 typ host',
        sdpMid: '0',
        sdpMLineIndex: 0,
      ));

      // 负向：什么都不该发生 —— 有界宽限期（由拓扑注入）内不得回显。
      await Future<void>.delayed(negativeAssertionGrace);
      expect(aliceGot, isEmpty, reason: '本端发出的信封不得回显给本端');

      await sub.cancel();
      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    test('trickle ICE：多条 candidate 按序全部送达', () async {
      // SDP 是 offer/answer 各一条，ICE candidate 则陆续到达、条数不定。
      // 这条测试锁住「多条」这个事实 —— 若实现只留最后一条（例如云端
      // fake 用单值键覆盖写），这里会红。
      final pair = await makePair();
      const rv = 'rv-trickle';

      final aliceSession = await pair.alice.open(rv);
      final bobSession = await pair.bob.open(rv);

      final bobGot = <SignalingEnvelope>[];
      final sub = bobSession.incoming.listen(bobGot.add);

      // 正向：先订阅「第 5 条到达」，再发送，最后 await —— 事件到齐才断言。
      final fifthSeen = bobSession.incoming
          .firstWhere((e) =>
              e is IceCandidateEnvelope &&
              e.candidate.startsWith('candidate:4 '));

      for (var i = 0; i < 5; i++) {
        await aliceSession.send(IceCandidateEnvelope(
          candidate: 'candidate:$i 1 udp 2130706431 192.168.0.2 5432$i '
              'typ host',
          sdpMid: '0',
          sdpMLineIndex: 0,
        ));
      }

      await fifthSeen.timeout(_positiveObservableTimeout);

      expect(bobGot, hasLength(5), reason: '5 条 candidate 必须全部送达');
      expect(
        bobGot.map((e) => (e as IceCandidateEnvelope).candidate).toList(),
        [
          for (var i = 0; i < 5; i++)
            'candidate:$i 1 udp 2130706431 192.168.0.2 5432$i typ host',
        ],
        reason: 'candidate 必须按发送顺序送达',
      );

      await sub.cancel();
      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    // ── A4：对端掉线可感知 ──

    test('A4 · 对端尚未到场时是 awaiting，到场后转 present', () async {
      // awaiting 与 departed 必须可区分：前者该继续等，后者该放弃。
      final pair = await makePair();
      const rv = 'rv-presence';

      final aliceSession = await pair.alice.open(rv);
      final seen = <PeerPresence>[];
      final sub = aliceSession.peerPresence.listen(seen.add);

      // 正向：订阅后应立即得到当前状态（await 可观测量本身）。
      await aliceSession.peerPresence.first
          .timeout(_positiveObservableTimeout);
      expect(seen, isNotEmpty,
          reason: '订阅后应立即得到当前状态，不必等下次变化');
      expect(seen.first, PeerPresence.awaiting,
          reason: '对端尚未 open，此刻必须是 awaiting');

      // 正向：先订阅「转 present」，再让对端到场，最后 await。
      final presentSeen = aliceSession.peerPresence
          .firstWhere((p) => p == PeerPresence.present);
      await pair.bob.open(rv);
      await presentSeen.timeout(_positiveObservableTimeout);
      expect(seen.last, PeerPresence.present,
          reason: '对端到场后必须转 present');

      await sub.cancel();
      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    test('A4 · 对端主动 close 后本端观测到 departed', () async {
      final pair = await makePair();
      const rv = 'rv-bye';

      final aliceSession = await pair.alice.open(rv);
      final bobSession = await pair.bob.open(rv);

      final seen = <PeerPresence>[];
      final sub = aliceSession.peerPresence.listen(seen.add);
      // 正向：等配对完成（present）—— 真实实现配对是异步的，`first`
      // 只会拿到重放的 awaiting。
      await aliceSession.peerPresence
          .firstWhere((p) => p == PeerPresence.present)
          .timeout(_positiveObservableTimeout);
      expect(seen.last, PeerPresence.present);

      // 正向：先订阅「转 departed」，再让对端 close，最后 await。
      final departedSeen = aliceSession.peerPresence
          .firstWhere((p) => p == PeerPresence.departed);
      await bobSession.close();
      await departedSeen.timeout(_positiveObservableTimeout);
      expect(seen.last, PeerPresence.departed,
          reason: '对端 close 后必须观测到 departed，不能停在 present');

      await sub.cancel();
      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    test('A4 · 对端非正常断开（未告别）也必须产出 departed', () async {
      // 这条才是「对端掉线可感知」的真正价值：进程被杀、断网、崩溃时
      // 对端来不及发 Bye，后端仍须判定其离开。
      // 契约原文：「不得要求调用方靠超时自行推断」。
      final pair = await makePair();
      const rv = 'rv-crash';

      final aliceSession = await pair.alice.open(rv);
      final bobSession = await pair.bob.open(rv);

      final seen = <PeerPresence>[];
      final sub = aliceSession.peerPresence.listen(seen.add);
      // 正向：等配对完成（present）。
      await aliceSession.peerPresence
          .firstWhere((p) => p == PeerPresence.present)
          .timeout(_positiveObservableTimeout);
      expect(seen.last, PeerPresence.present);

      // 模拟非正常断开：不调用 close()，直接让底层判定其失联。
      // 先订阅「转 departed」，再注入断开，最后 await。
      final departedSeen = aliceSession.peerPresence
          .firstWhere((p) => p == PeerPresence.departed);
      await simulateAbruptDisconnect(bobSession);
      await departedSeen.timeout(_positiveObservableTimeout);
      expect(seen.last, PeerPresence.departed,
          reason: '对端崩溃/断网时后端必须判定 departed，'
              '而不是让调用方靠超时去猜');

      await sub.cancel();
      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    test('A4 · 对端已 departed 时 send 必须抛错，不得静默丢弃', () async {
      final pair = await makePair();
      const rv = 'rv-send-after-departed';

      final aliceSession = await pair.alice.open(rv);
      final bobSession = await pair.bob.open(rv);
      // 正向：等配对完成（present）。
      await aliceSession.peerPresence
          .firstWhere((p) => p == PeerPresence.present)
          .timeout(_positiveObservableTimeout);

      // 正向：先订阅「转 departed」，再让对端 close，最后 await ——
      // 确认对端已离开，再断言 send 抛错。
      final departedSeen = aliceSession.peerPresence
          .firstWhere((p) => p == PeerPresence.departed);
      await bobSession.close();
      await departedSeen.timeout(_positiveObservableTimeout);

      expect(
        () => aliceSession.send(const ByeEnvelope()),
        throwsA(isA<Object>()),
        reason: '对端已离开时发送必须抛错；静默丢弃会让调用方以为发出去了',
      );

      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    test('close 幂等：重复调用不得抛错', () async {
      final pair = await makePair();
      final session = await pair.alice.open('rv-idempotent');
      await session.close();
      await session.close();
      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    test('不同会合标识互不串扰', () async {
      // 会合标识是两种拓扑的唯一公共输入。
      // 若实现把它当摆设，这里会红。
      final pair = await makePair();

      final aliceSession = await pair.alice.open('rv-A');
      final bobSession = await pair.bob.open('rv-B');

      final bobGot = <SignalingEnvelope>[];
      final sub = bobSession.incoming.listen(bobGot.add);

      await aliceSession.send(const ByeEnvelope());

      // 负向：不同会合标识下什么都不该到 —— 有界宽限期。
      await Future<void>.delayed(negativeAssertionGrace);
      expect(bobGot, isEmpty, reason: '不同会合标识下的信封不得串到一起');

      await sub.cancel();
      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    test('rendezvous 如实回报打开时用的标识', () async {
      final pair = await makePair();
      final session = await pair.alice.open('rv-echo-key');
      expect(session.rendezvous, 'rv-echo-key');
      await pair.alice.dispose();
      await pair.bob.dispose();
    });

    // ── A5 样本层：信封载荷不含身份信息 ──

    test('A5 · 握手全过程的信封载荷不含 scopeUid / 用户名 / 设备名',
        () async {
      const scopeUid = 'user-scope-42';
      const deviceName = "alice-macbook";

      final pair = await makePair();
      final aliceSession = await pair.alice.open('rv-privacy');
      final bobSession = await pair.bob.open('rv-privacy');

      final captured = <SignalingEnvelope>[];
      final sub = bobSession.incoming.listen(captured.add);

      // 正向：先订阅「ICE 到达」，再发送，最后 await —— 等第二条也到达，
      // 才断言载荷内容。
      final iceSeen = bobSession.incoming
          .firstWhere((e) => e is IceCandidateEnvelope);

      await aliceSession.send(const SessionDescriptionEnvelope(
        kind: SdpKind.offer,
        sdp: 'v=0\r\na=fingerprint:sha-256 AA:BB\r\n',
      ));
      await aliceSession.send(const IceCandidateEnvelope(
        candidate: 'candidate:1 1 udp 2130706431 192.168.0.2 54321 typ host',
        sdpMid: '0',
        sdpMLineIndex: 0,
      ));

      await iceSeen.timeout(_positiveObservableTimeout);

      expect(captured, hasLength(2));
      for (final e in captured) {
        final text = _serializeForPrivacyCheck(e);
        expect(text, isNot(contains(scopeUid)),
            reason: '信令载荷不得含 scopeUid');
        expect(text, isNot(contains(deviceName)),
            reason: '信令载荷不得含设备名');
      }

      await sub.cancel();
      await pair.alice.dispose();
      await pair.bob.dispose();
    });
  });
}

/// 把信封序列化成文本，供隐私断言扫描。
///
/// 用 switch 穷尽而非 toString()：确保新增变体时这里会变红，
/// 不会有字段悄悄逃过隐私检查。
String _serializeForPrivacyCheck(SignalingEnvelope e) => switch (e) {
      SessionDescriptionEnvelope(:final kind, :final sdp) => '$kind|$sdp',
      IceCandidateEnvelope(
        :final candidate,
        :final sdpMid,
        :final sdpMLineIndex
      ) =>
        '$candidate|$sdpMid|$sdpMLineIndex',
      ByeEnvelope() => 'bye',
    };
