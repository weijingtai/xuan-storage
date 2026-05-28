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
    return RemoteChangesPage(changes: const [], nextCursor: null, hasMore: false);
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

  test('router throws StateError for unregistered region', () async {
    final router = RemoteGatewayRouter(
      gateways: {
        Region.firebase: _FakeGateway('fb'),
      },
      currentRegion: () => Region.supabase,
    );
    expect(
      () => router.getCapabilities(),
      throwsA(isA<StateError>()),
    );
  });

  test('router delegates push to active gateway', () async {
    final router = RemoteGatewayRouter(
      gateways: {
        Region.firebase: _FakeGateway('fb'),
      },
      currentRegion: () => Region.firebase,
    );
    final record = OutboxRecord(
      operationId: 'op-1',
      scopeUid: 'user-1',
      entityType: 'seeker',
      entityId: 's-1',
      opType: 'upsert',
      payloadJson: '{}',
      createdAtUtc: DateTime.utc(2026, 1, 1),
      attempt: 0,
    );
    final error = await router.push(record);
    expect(error, isNull);
  });

  test('router delegates listChanges to active gateway', () async {
    final router = RemoteGatewayRouter(
      gateways: {
        Region.firebase: _FakeGateway('fb'),
      },
      currentRegion: () => Region.firebase,
    );
    final page = await router.listChanges(
      scopeUid: 'user-1',
      entityType: 'seeker',
      sinceCursor: null,
      limit: 10,
    );
    expect(page.changes, isEmpty);
    expect(page.hasMore, isFalse);
  });
}
