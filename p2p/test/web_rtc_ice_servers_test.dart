import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/ice_server.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_p2p/web_rtc_transport.dart';

/// 步骤 4 门禁（VM 单测）：`IceServerProvider` 注入后，RTCConfiguration
/// 生成逻辑（`WebRtcTransport.buildConfigurationForTest`）把 ICE 服务器
/// 列表并入配置，且**凭证每次建连前新取**（端口契约：不依赖缓存）。
///
/// 说明：真正的跨网络 TURN 联调需要 TURN 服务部署/签约（人类动作，目前
/// 零部署零签约），标记延后；本测试验证「接入 + 凭证时效」这半边。
void main() {
  group('步骤4 · IceServerProvider 接入 RTCConfiguration', () {
    test('注入 provider 后配置含 ICE 服务器（urls/username/credential）', () async {
      final provider = _CountingIceServerProvider([
        IceServer(
          urls: 'stun:stun.example.com',
          username: 'user-1',
          credential: _constCredential('cred-1'),
          expiresAt: _farFuture,
        ),
      ]);
      final transport = WebRtcTransport(
        signaling: _NoopSignaling(),
        iceServers: provider,
      );

      final config = await transport.buildConfigurationForTest();

      expect(config, contains('iceServers'));
      final servers = config['iceServers'] as List<dynamic>;
      expect(servers, hasLength(1));
      final s = servers.single as Map<String, dynamic>;
      expect(s['urls'], ['stun:stun.example.com']);
      expect(s['username'], 'user-1');
      expect(s['credential'], 'cred-1');
    });

    test('凭证每次建连前新取，不依赖缓存（端口契约）', () async {
      var fetchCount = 0;
      final provider = _CountingIceServerProvider([
        IceServer(
          urls: 'turn:turn.example.com',
          credential: () async {
            fetchCount++;
            return 'fresh-$fetchCount';
          },
          expiresAt: _farFuture,
        ),
      ]);
      final transport = WebRtcTransport(
        signaling: _NoopSignaling(),
        iceServers: provider,
      );

      await transport.buildConfigurationForTest();
      await transport.buildConfigurationForTest();

      expect(fetchCount, 2, reason: '每次建连前都必须重新索取凭证，不得缓存');
      // 两次取到的凭证是不同值（fresh-1 / fresh-2）—— 时效性可机械验证。
      expect(provider.iceServersCalls, 2);
    });

    test('无注入 provider 时返回空 ICE 服务器列表（调用方可区分无服务器与出错）',
        () async {
      final transport = WebRtcTransport(signaling: _NoopSignaling());
      final config = await transport.buildConfigurationForTest();
      expect(config['iceServers'], isEmpty);
    });
  });
}

/// 固定「未来时刻」凭证过期时间（isValidCredentialExpiry 窗口内：>5min）。
final DateTime _farFuture =
    DateTime.now().toUtc().add(const Duration(hours: 1));

Future<String> Function() _constCredential(String value) =>
    () => Future<String>.value(value);

/// 记录 iceServers() 调用次数的 provider。
class _CountingIceServerProvider implements IceServerProvider {
  _CountingIceServerProvider(this._servers);

  final List<IceServer> _servers;
  int iceServersCalls = 0;

  @override
  Future<List<IceServer>> iceServers() async {
    iceServersCalls++;
    return _servers;
  }
}

/// 占位信令（本测试只验证配置生成，不建连）。
class _NoopSignaling implements SignalingChannel {
  @override
  Future<SignalingSession> open(
    String rendezvous, {
    CancellationToken? cancel,
  }) async =>
      throw UnimplementedError('本测试不建连');

  @override
  Future<void> dispose() async {}
}
