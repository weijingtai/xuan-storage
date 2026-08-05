import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_core/test_support/signaling_contract_suite.dart';
import 'package:persistence_p2p/local_signaling.dart';

import 'fake_lan_discovery.dart';

/// P7：同一套共享契约套件跑真实 `LocalSignaling`。
///
/// 注入 [FakeLanDiscovery]（内存发现）+ **真实 loopback socket**（A2）：
/// 本轮真正手写的「socket 上的信封交换 + presence 语义」被真实 IO 覆盖。
///
/// [simulateAbruptDisconnect] 必须真的 `destroy()` socket（A3），不许发
/// 「假装断开」的信号；下方另有一条测试证明它真断。
void main() {
  late LocalSignaling bobLocal;

  runSignalingContractSuite(
    topologyName: 'LocalSignaling（真实 loopback socket）',
    negativeAssertionGrace: const Duration(milliseconds: 300),
    makePair: () {
      final fabric = FakeLanFabric();
      final alice = LocalSignaling(discovery: FakeLanDiscovery(fabric));
      bobLocal = LocalSignaling(discovery: FakeLanDiscovery(fabric));
      return (alice: alice, bob: bobLocal);
    },
    simulateAbruptDisconnect: (session) async {
      // 真的关掉 socket：destroy()，不调 close()、不发 Bye。
      // 先等 bob 侧配对完成（socket 就绪），避免竞态。
      final socket = await bobLocal.debugSocketOf(session.rendezvous);
      socket.destroy();
    },
  );

  // ── A3 加严：simulateAbruptDisconnect 必须真的 destroy，且证明它真断 ──

  test('A3 · destroy 后底层 socket 确已终结（非假装断开）', () async {
    final fabric = FakeLanFabric();
    final alice = LocalSignaling(discovery: FakeLanDiscovery(fabric));
    final bob = LocalSignaling(discovery: FakeLanDiscovery(fabric));

    final aliceSession = await alice.open('rv-a3-prove');
    await bob.open('rv-a3-prove');

    // 等配对完成（present）。
    await aliceSession.peerPresence
        .firstWhere((p) => p == PeerPresence.present)
        .timeout(const Duration(seconds: 5));

    final socket = await bob.debugSocketOf('rv-a3-prove');
    socket.destroy();

    // 从「被销毁那一侧之外」观测：对端 alice 的 socket 读到 EOF → departed。
    // 若 simulateAbruptDisconnect 只是「假装断开」的信号（socket 还活着），
    // alice 的 socket 不会关闭，这里必超时 —— 这就是「真的 destroy 了」
    // 的独立证据（验收 A3：另有一条测试证明它真断）。
    await aliceSession.peerPresence
        .firstWhere((p) => p == PeerPresence.departed)
        .timeout(const Duration(seconds: 5));
  });
}
