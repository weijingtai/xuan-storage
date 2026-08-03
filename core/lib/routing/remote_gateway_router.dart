import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/routing/region.dart';

/// Routes [SyncPeer] calls to the appropriate region backend.
///
/// Used in dual-line hedge mode where users are partitioned by region
/// (mainland China → Supabase; overseas → Firebase).
///
/// 功能说明：
/// - 根据 [currentRegion] 动态分派 push / listChanges / getCapabilities。
/// - 支持运行时 region 切换（例如网络环境变化、用户手动切换）。
/// - 本类是一个代理：身份（peerId / channel）跟随当前 region 对应的对端。
class RemoteGatewayRouter implements SyncPeer {
  final Map<Region, SyncPeer> _gateways;
  final Region Function() _currentRegion;

  RemoteGatewayRouter({
    required Map<Region, SyncPeer> gateways,
    required Region Function() currentRegion,
  })  : _gateways = gateways,
        _currentRegion = currentRegion;

  SyncPeer get _active {
    final region = _currentRegion();
    final gateway = _gateways[region];
    if (gateway == null) {
      throw StateError('No SyncPeer registered for region $region');
    }
    return gateway;
  }

  @override
  PeerId get peerId => _active.peerId;

  @override
  Channel get channel => _active.channel;

  @override
  Future<SyncError?> push(OutboxRecord record) => _active.push(record);

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) =>
      _active.listChanges(
        scopeUid: scopeUid,
        entityType: entityType,
        sinceCursor: sinceCursor,
        limit: limit,
      );

  @override
  Future<PeerCapabilities> getCapabilities() => _active.getCapabilities();
}
