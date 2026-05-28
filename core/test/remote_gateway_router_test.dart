import 'package:test/test.dart';
import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/routing/region.dart';
import 'package:persistence_core/routing/remote_gateway_router.dart';

class _FakeGateway implements RemoteGateway {
  final String label;
  _FakeGateway(this.label);
  @override
  Future<SyncError?> push(OutboxRecord record) async => null;
  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    return const RemoteChangesPage(changes: [], nextCursor: null, hasMore: false);
  }
  @override
  Future<RegionCapabilities> getCapabilities() async {
    return RegionCapabilities(
      entityVersions: {label: 1},
      supportedFeatures: const {},
      serverProtocolVersion: 1,
    );
  }
}

void main() {
  test('router delegates to active region gateway', () async {
    var current = Region.firebase;
    final router = RemoteGatewayRouter(
      gateways: {
        Region.firebase: _FakeGateway('fb'),
        Region.supabase: _FakeGateway('sb'),
      },
      currentRegion: () => current,
    );
    var caps = await router.getCapabilities();
    expect(caps.entityVersions, containsPair('fb', 1));

    current = Region.supabase;
    caps = await router.getCapabilities();
    expect(caps.entityVersions, containsPair('sb', 1));
  });
}
