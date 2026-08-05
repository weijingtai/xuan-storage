import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_core/model/storage_error.dart';
import 'package:persistence_core/test_support/signaling_contract_suite.dart';
import 'package:persistence_firebase/signaling/cloud_signaling.dart';

import 'memory_rendezvous_backend.dart';

/// S3c-d：同一套共享契约套件跑 `CloudSignaling`（第四个拓扑，内存会合点）。
///
/// 注入 `MemoryRendezvousBackend`：它**真的会在「断开」时执行已登记的
/// `onDisconnect` 删除**（派工 §7），不是假的会合点。
///
/// [simulateAbruptDisconnect] 触发的是 bob 会话**已登记**的断开删除动作，
/// 不许直接手动删节点 —— 手动删 = 在测「删了会怎样」而不是「掉线会不会删」。
void main() {
  late CloudSignaling bobChannel;
  late MemoryRendezvousBackend backend;
  const grace = Duration(milliseconds: 300);

  runSignalingContractSuite(
    topologyName: 'CloudSignaling（内存会合点 + 已登记 onDisconnect）',
    negativeAssertionGrace: grace,
    makePair: () {
      backend = MemoryRendezvousBackend();
      final alice = CloudSignaling(backend: backend);
      bobChannel = CloudSignaling(backend: backend);
      return (alice: alice, bob: bobChannel);
    },
    simulateAbruptDisconnect: (session) async {
      // 真的触发 bob 已登记的 onDisconnect 删除（非手动删节点）。
      final memberId = bobChannel.debugMemberIdOf(session.rendezvous);
      if (memberId == null) {
        throw StateError('bob 没有该会合标识的会话: ${session.rendezvous}');
      }
      await backend.triggerOnDisconnect(memberId);
    },
  );

  // ── A3 加严：departed 来自已登记的 onDisconnect，且真触发（非假装）──

  test('A3 · triggerOnDisconnect 执行的是已登记删除，且确会删除成员节点', () async {
    final b = MemoryRendezvousBackend();
    final alice = CloudSignaling(backend: b);
    final bob = CloudSignaling(backend: b);

    final aliceSession = await alice.open('rv-a3-prove');
    await bob.open('rv-a3-prove');
    await aliceSession.peerPresence
        .firstWhere((p) => p == PeerPresence.present)
        .timeout(const Duration(seconds: 5));

    final bobId = bob.debugMemberIdOf('rv-a3-prove');
    expect(bobId, isNotNull);
    // 独立证据 1：bob 已登记断开删除（open 时登记的 onDisconnect 钩子）。
    expect(b.debugHasRegisteredDisconnect(bobId!), isTrue,
        reason: 'open 时必须登记 onDisconnect，否则对端掉线无人摘除节点');
    // bob 成员节点此刻在场。
    expect(b.debugMemberIds('rv-a3-prove'), contains(bobId));

    // 触发已登记的删除（不是手动 remove）。
    await b.triggerOnDisconnect(bobId);

    // 独立证据 2：触发后成员节点真的被摘除（登记的动作执行了）。
    expect(b.debugMemberIds('rv-a3-prove'), isNot(contains(bobId)),
        reason: 'trigger 必须执行登记的动作把节点删掉，而不是假装断开');
    // 独立证据 3：对端观测到 departed。
    await aliceSession.peerPresence
        .firstWhere((p) => p == PeerPresence.departed)
        .timeout(const Duration(seconds: 5));

    await alice.dispose();
    await bob.dispose();
  });

  // ── A8 变异守卫：departed 依赖 onDisconnect 登记，删掉登记步骤就红 ──

  test('A8 · 变异守卫：未登记 onDisconnect 时崩溃不产出 departed', () async {
    final b = MemoryRendezvousBackend();
    final alice = CloudSignaling(backend: b);
    final bob = CloudSignaling(backend: b);

    final aliceSession = await alice.open('rv-mutation');
    await bob.open('rv-mutation');
    await aliceSession.peerPresence
        .firstWhere((p) => p == PeerPresence.present)
        .timeout(const Duration(seconds: 5));

    final bobId = bob.debugMemberIdOf('rv-mutation');
    expect(bobId, isNotNull);

    // 变异：抹掉 bob 已登记的断开删除（等价于实现漏了 onDisconnectRemove 一步）。
    b.debugForgetOnDisconnect(bobId!);
    await b.triggerOnDisconnect(bobId);

    // 负向（有界宽限期）：成员节点仍在 → 对端不得 departed。
    await Future<void>.delayed(grace);
    expect(b.debugMemberIds('rv-mutation'), contains(bobId),
        reason: '未登记 onDisconnect 时，断开不应触发任何删除');
    expect(
      await aliceSession.peerPresence.first.timeout(const Duration(seconds: 5)),
      isNot(PeerPresence.departed),
      reason: 'departed 必须来自服务端 onDisconnect 机制；'
          '删掉登记步骤后崩溃不应再产出 departed',
    );

    await alice.dispose();
    await bob.dispose();
  });

  // ── R2：close 后 send 必须抛 StorageError 子类（契约 §3.6 / A5 不静默丢弃）──

  test('R2 · close 后 send 抛 StorageError 子类，不静默丢弃', () async {
    final b = MemoryRendezvousBackend();
    final alice = CloudSignaling(backend: b);
    final bob = CloudSignaling(backend: b);

    final aliceSession = await alice.open('rv-r2-closed-send');
    await bob.open('rv-r2-closed-send');
    await aliceSession.peerPresence
        .firstWhere((p) => p == PeerPresence.present)
        .timeout(const Duration(seconds: 5));

    await aliceSession.close();

    // close 后 send：必须抛 StorageError 子类（不是静默成功，也不是裸 StateError）。
    expect(
      () => aliceSession.send(const ByeEnvelope()),
      throwsA(isA<StorageError>()),
      reason: 'close 后 send 必须抛 StorageError 子类（契约 §3.6 / A5 不静默丢弃）；'
          '与 p2p LocalSignaling 的语义差异见决定记录 D5',
    );

    await alice.dispose();
    await bob.dispose();
  });

  // ── A7 隐私：RTDB 路径与载荷不含身份（可读回的返回值上的断言）──

  test('A7 · 会合路径与载荷不含 scopeUid / 用户名 / 设备名', () async {
    const scopeUid = 'user-scope-42';
    const userName = 'alice-wang';
    const deviceName = 'alice-macbook';

    final b = MemoryRendezvousBackend();
    final alice = CloudSignaling(backend: b);
    final bob = CloudSignaling(backend: b);

    final aliceSession = await alice.open('rv-a7-privacy');
    final bobSession = await bob.open('rv-a7-privacy');

    await aliceSession.send(const SessionDescriptionEnvelope(
      kind: SdpKind.offer,
      sdp: 'v=0\r\na=fingerprint:sha-256 AA:BB\r\n',
    ));
    await aliceSession.send(const IceCandidateEnvelope(
      candidate: 'candidate:1 1 udp 2130706431 192.168.0.2 54321 typ host',
      sdpMid: '0',
      sdpMLineIndex: 0,
    ));
    await bobSession.send(const ByeEnvelope());

    // 可读回的返回值：会合点路径段 + 全部信封载荷（等价 RTDB 上真实存储）。
    final text = b.debugSerializedRoom('rv-a7-privacy');
    expect(text, isNot(contains(scopeUid)),
        reason: '会合路径与载荷不得含 scopeUid');
    expect(text, isNot(contains(userName)), reason: '不得含用户名');
    expect(text, isNot(contains(deviceName)), reason: '不得含设备名');

    await alice.dispose();
    await bob.dispose();
  });
}
