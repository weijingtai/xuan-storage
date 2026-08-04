import 'package:test/test.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/routing/region.dart';
import 'package:persistence_core/routing/remote_gateway_router.dart';

class _FakeGateway implements SyncPeer {
  final String label;
  _FakeGateway(this.label);
  @override
  PeerId get peerId => PeerId(label);
  @override
  Channel get channel => Channel.cloud;
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
  Future<PeerCapabilities> getCapabilities() async {
    return PeerCapabilities(
      peerId: peerId,
      channel: channel,
      entityVersions: {label: 1},
      supportedFeatures: const {},
      protocolVersion: 1,
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
