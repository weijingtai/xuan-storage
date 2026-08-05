@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_p2p/lan_discovery.dart';

/// 真 bonsoir mDNS 集成测试（决定记录 D4 的「真实现只进集成测试」）。
///
/// 真实 mDNS 依赖组播，CI / 沙箱里常常不通 —— `dart_test.yaml` 已默认排除
/// `integration` tag，`flutter test` 不带参数不会跑它。
///
/// 人工触发（真机 / 组播可达的局域网）：
/// ```bash
/// cd p2p && flutter test --tags integration
/// ```
/// 需要同一网段至少两台设备（或本机 loopback 组播可用的环境）。
void main() {
  test('同网段 advertise 后对端 discover 到该服务（含 TXT）', () async {
    final alice = BonsoirLanDiscovery();
    final bob = BonsoirLanDiscovery();

    final found = <LanDiscoveredService>[];
    final sub = bob.discoveredServices.listen(found.add);
    await bob.startDiscovery();

    await alice.advertise(
      serviceName: 'tr-integration-probe',
      txt: const {'rv': 'rv-integration'},
      port: 47001,
    );

    // 等组播传播：真实 mDNS 有发现延迟（数百 ms 到数秒）。
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (DateTime.now().isBefore(deadline)) {
      if (found.any((s) => s.txt['rv'] == 'rv-integration')) break;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    expect(
      found.any((s) => s.txt['rv'] == 'rv-integration'),
      isTrue,
      reason: 'bob 必须发现 alice 广播的服务（凭 TXT 的 rv 匹配）',
    );
    final matched = found.firstWhere((s) => s.txt['rv'] == 'rv-integration');
    expect(matched.serviceName, isNot(contains('alice')),
        reason: 'A7：广播内容不含设备名');
    expect(matched.port, 47001, reason: '发现到的端口必须如实');

    await alice.unadvertise();
    await bob.stopDiscovery();
    await sub.cancel();
  });
}
