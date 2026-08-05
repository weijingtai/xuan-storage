import 'dart:async';

import 'package:persistence_p2p/lan_discovery.dart';

/// 内存"局域网"发现表：多个 [FakeLanDiscovery] 共享，模拟同一网段。
///
/// host 一律记 127.0.0.1 —— fake 只负责「发现」，真实连接走 loopback socket。
class FakeLanFabric {
  final Map<String, LanDiscoveredService> _services = {};
  final List<void Function(LanDiscoveredService)> _onRegister = [];

  /// 注册一个服务并通知正在发现中的订阅者。
  void register(String serviceName, Map<String, String> txt, int port) {
    final svc = LanDiscoveredService(
      serviceName: serviceName,
      txt: txt,
      host: '127.0.0.1',
      port: port,
    );
    _services[serviceName] = svc;
    for (final cb in _onRegister.toList()) {
      cb(svc);
    }
  }

  void unregister(String serviceName) {
    _services.remove(serviceName);
  }

  List<LanDiscoveredService> list() => _services.values.toList();

  /// 订阅「此后新注册的服务」，返回注销函数。
  void Function() onRegister(void Function(LanDiscoveredService) cb) {
    _onRegister.add(cb);
    return () => _onRegister.remove(cb);
  }
}

/// 内存假发现（D4）：单测用，配**真实 loopback socket**。
///
/// 【A7 隐私抓手】fake 记下**实际广播出去的 service name 与 TXT 记录**
/// 并可读回（[lastAdvertisedServiceName] / [lastAdvertisedTxt]）——把隐私
/// 约定从注释变成可断言的返回值（与 `AdvertisementHandle` 同一手法）。
///
/// 【发现流为什么用 Stream.multi】（D12 同款）broadcast 控制器在无订阅者时
/// add 的事件直接丢弃：`startDiscovery` 时重放 fabric 已有服务，若订阅晚于
/// 重放（LocalSignaling 在 startDiscovery 之后才订阅），后到者永远发现不了
/// 先到者。Stream.multi 让**每个订阅者订阅时重放当前 fabric 状态**，再推送
/// 后续注册 —— 订阅时序无关。
class FakeLanDiscovery implements LanDiscovery {
  FakeLanDiscovery(this.fabric);

  final FakeLanFabric fabric;

  /// 最近一次实际广播出去的 service name（A7 断言读回点）。
  String? lastAdvertisedServiceName;

  /// 最近一次实际广播出去的 TXT 记录（A7 断言读回点）。
  Map<String, String>? lastAdvertisedTxt;

  int? lastAdvertisedPort;

  bool _advertising = false;

  @override
  Future<void> advertise({
    required String serviceName,
    required Map<String, String> txt,
    required int port,
  }) async {
    // 记录实际广播内容（A7 抓手：测试据此断言不含身份信息）。
    lastAdvertisedServiceName = serviceName;
    lastAdvertisedTxt = Map.unmodifiable(txt);
    lastAdvertisedPort = port;
    _advertising = true;
    fabric.register(serviceName, txt, port);
  }

  @override
  Future<void> unadvertise() async {
    if (!_advertising) return;
    _advertising = false;
    final name = lastAdvertisedServiceName;
    if (name != null) fabric.unregister(name);
  }

  @override
  Future<void> startDiscovery() async {}

  @override
  Future<void> stopDiscovery() async {}

  @override
  Stream<LanDiscoveredService> get discoveredServices =>
      Stream.multi((controller) {
        // 订阅即重放 fabric 已有服务（先到者立即可见）。
        for (final svc in fabric.list()) {
          if (controller.isClosed) return;
          controller.add(svc);
        }
        // 再推送此后新注册的服务。
        final detach = fabric.onRegister((svc) {
          if (!controller.isClosed) controller.add(svc);
        });
        controller.onCancel = detach;
      });
}
