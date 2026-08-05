import 'dart:async';

import 'package:bonsoir/bonsoir.dart';

/// 局域网发现端口：只管「广播自己 / 发现对端」两件事（决定记录 D4）。
///
/// 【为什么把发现关进窄端口】真实 mDNS 依赖组播，CI / 沙箱里常常不通；
/// 但**只对着 fake 测，等于没测自己写的那部分**。于是：
/// - [FakeLanDiscovery]（内存）→ 单元测试用，配**真实 loopback socket**
/// - [BonsoirLanDiscovery]（真 mDNS）→ 只进集成测试（`@Tags(['integration'])`）
///
/// 这样切法让「socket 上的信封交换 + presence 语义」——本轮真正手写的东西
/// ——被真实 IO 覆盖，只有 mDNS 那一层是可选的。
///
/// 【A7 隐私抓手】service name 只放随机 transient id，会合标识放 TXT 记录；
/// 广播内容**不得**含 scopeUid / 用户名 / 设备名（与
/// `AdvertisementHandle.transientServiceId` 同一约定）。实现必须让实际广播
/// 出去的 service name 与 TXT 记录**可读回**，测试据此断言。
abstract interface class LanDiscovery {
  /// mDNS service type。`_tcp` 后缀为 bonsoir 所必需。
  static const String serviceType = '_p2p-signal._tcp';

  /// 广播本服务。
  ///
  /// - [serviceName]: 随机 transient id（隐私，A7）。**不得**含 scopeUid /
  ///   用户名 / 设备名。
  /// - [txt]: 对端发现后凭它匹配会合标识。内容同样受 A7 约束。
  /// - [port]: 本端监听 socket 的端口。
  Future<void> advertise({
    required String serviceName,
    required Map<String, String> txt,
    required int port,
  });

  /// 停止广播。未在广播时调用不得抛错（幂等）。
  Future<void> unadvertise();

  /// 开始发现同 [serviceType] 的对端服务。
  Future<void> startDiscovery();

  /// 停止发现。未在发现时调用不得抛错（幂等）。
  Future<void> stopDiscovery();

  /// 发现到的对端服务流。
  ///
  /// 每个被发现并解析的对端服务产出一条 [LanDiscoveredService]。
  /// 可多次订阅；只投递订阅之后发现的（broadcast 语义）。
  Stream<LanDiscoveredService> get discoveredServices;
}

/// 发现到的对端服务：凭 [txt] 里的会合标识匹配，凭 [host]:[port] 直连。
class LanDiscoveredService {
  /// 对端广播的 service name（随机 transient id，无身份信息）。
  final String serviceName;

  /// 对端广播的 TXT 记录（含会合标识）。
  final Map<String, String> txt;

  /// 对端监听地址。
  final String host;

  /// 对端监听端口。
  final int port;

  /// 构造一条发现到的服务。
  const LanDiscoveredService({
    required this.serviceName,
    required this.txt,
    required this.host,
    required this.port,
  });
}

/// 真 mDNS 发现（bonsoir 7.1.4）。
///
/// 只进集成测试（`@Tags(['integration'])`，默认不跑）：真实 mDNS 依赖组播，
/// CI / 沙箱里常常不通。人工触发命令见任务纪要 P8。
class BonsoirLanDiscovery implements LanDiscovery {
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _eventSub;
  final StreamController<LanDiscoveredService> _services =
      StreamController<LanDiscoveredService>.broadcast();

  @override
  Future<void> advertise({
    required String serviceName,
    required Map<String, String> txt,
    required int port,
  }) async {
    await unadvertise();
    _broadcast = BonsoirBroadcast(
      service: BonsoirService(
        name: serviceName,
        type: LanDiscovery.serviceType,
        port: port,
        attributes: txt,
      ),
    );
    await _broadcast!.initialize();
    await _broadcast!.start();
  }

  @override
  Future<void> unadvertise() async {
    final b = _broadcast;
    _broadcast = null;
    if (b != null) {
      await b.stop();
    }
  }

  @override
  Future<void> startDiscovery() async {
    await stopDiscovery();
    _discovery = BonsoirDiscovery(type: LanDiscovery.serviceType);
    _eventSub = _discovery!.eventStream?.listen((event) {
      // sealed 穷尽：只关心「解析完成」的对端服务。
      switch (event) {
        case BonsoirDiscoveryServiceResolvedEvent(:final service):
          if (_services.isClosed) return;
          _services.add(LanDiscoveredService(
            serviceName: service.name,
            txt: service.attributes,
            host: service.hostAddresses.isNotEmpty
                ? service.hostAddresses.first
                : '',
            port: service.port,
          ));
        case BonsoirDiscoveryStartedEvent():
        case BonsoirDiscoveryServiceFoundEvent():
        case BonsoirDiscoveryServiceUpdatedEvent():
        case BonsoirDiscoveryServiceResolveFailedEvent():
        case BonsoirDiscoveryServiceLostEvent():
        case BonsoirDiscoveryStoppedEvent():
        case BonsoirDiscoveryUnknownEvent():
          break;
      }
    });
    await _discovery!.initialize();
    await _discovery!.start();
  }

  @override
  Future<void> stopDiscovery() async {
    await _eventSub?.cancel();
    _eventSub = null;
    final d = _discovery;
    _discovery = null;
    if (d != null) {
      await d.stop();
    }
  }

  @override
  Stream<LanDiscoveredService> get discoveredServices => _services.stream;
}
