import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_p2p/lan_discovery.dart';

import 'fake_lan_discovery.dart';

/// P5 LanDiscovery 窄端口测试：fake 的行为 + A7 隐私抓手（可读回）。
void main() {
  group('FakeLanDiscovery', () {
    test('advertise 后实际广播内容可读回（A7 抓手）', () async {
      final fabric = FakeLanFabric();
      final discovery = FakeLanDiscovery(fabric);

      await discovery.advertise(
        serviceName: 'tr-7f3a2b',
        txt: const {'rv': 'rv-meet'},
        port: 43210,
      );

      // 读回实际广播出去的内容（A7 断言建立在这些返回值上，不是注释）。
      expect(discovery.lastAdvertisedServiceName, 'tr-7f3a2b');
      expect(discovery.lastAdvertisedTxt, {'rv': 'rv-meet'});
      expect(discovery.lastAdvertisedPort, 43210);
    });

    test('startDiscovery 重放 fabric 中已有的服务', () async {
      final fabric = FakeLanFabric();
      final alice = FakeLanDiscovery(fabric);
      await alice.advertise(
        serviceName: 'tr-aaaa',
        txt: const {'rv': 'rv-meet'},
        port: 43211,
      );

      final bob = FakeLanDiscovery(fabric);
      final seen = <LanDiscoveredService>[];
      final sub = bob.discoveredServices.listen(seen.add);
      await bob.startDiscovery();

      // 等重放送达（broadcast 异步分发）。
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(seen, hasLength(1), reason: '重放 fabric 已有服务');
      expect(seen.single.serviceName, 'tr-aaaa');
      expect(seen.single.host, '127.0.0.1');
      expect(seen.single.port, 43211);
      expect(seen.single.txt['rv'], 'rv-meet');

      await sub.cancel();
      await bob.stopDiscovery();
      await alice.unadvertise();
    });

    test('发现中后新注册的服务实时推送', () async {
      final fabric = FakeLanFabric();
      final bob = FakeLanDiscovery(fabric);
      final seen = <LanDiscoveredService>[];
      final sub = bob.discoveredServices.listen(seen.add);
      await bob.startDiscovery();

      final alice = FakeLanDiscovery(fabric);
      await alice.advertise(
        serviceName: 'tr-bbbb',
        txt: const {'rv': 'rv-late'},
        port: 43212,
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(seen, hasLength(1), reason: '发现中后注册的服务实时到达');
      expect(seen.single.serviceName, 'tr-bbbb');

      await sub.cancel();
      await bob.stopDiscovery();
      await alice.unadvertise();
    });
  });
}
