import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/routing/region.dart';

/// Routes [RemoteGateway] calls to the appropriate region backend.
///
/// Used in dual-line hedge mode where users are partitioned by region
/// (mainland China → Supabase; overseas → Firebase).
///
/// 功能说明：
/// - 根据 [currentRegion] 动态分派 push / listChanges / getCapabilities。
/// - 支持运行时 region 切换（例如网络环境变化、用户手动切换）。
class RemoteGatewayRouter implements RemoteGateway {
  final Map<Region, RemoteGateway> _gateways;
  final Region Function() _currentRegion;

  RemoteGatewayRouter({
    required Map<Region, RemoteGateway> gateways,
    required Region Function() currentRegion,
  })  : _gateways = gateways,
        _currentRegion = currentRegion;

  RemoteGateway get _active {
    final region = _currentRegion();
    final gateway = _gateways[region];
    if (gateway == null) {
      throw StateError('No RemoteGateway registered for region $region');
    }
    return gateway;
  }

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
  Future<RegionCapabilities> getCapabilities() => _active.getCapabilities();
}
