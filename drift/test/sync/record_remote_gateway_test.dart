import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/persistence_core.dart';

class _InMemorySyncPeer implements SyncPeer {
  final _store = <String, List<Map<String, dynamic>>>{};

  @override
  PeerId get peerId => const PeerId('in-memory');

  @override
  Channel get channel => Channel.cloud;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    _store.putIfAbsent('${record.scopeUid}:${record.entityType}', () => []);
    _store['${record.scopeUid}:${record.entityType}']!.add({
      'operationId': record.operationId,
      'entityType': record.entityType,
      'entityId': record.entityId,
      'opType': record.opType,
      'payloadJson': record.payloadJson,
      'serverTimeUtc': DateTime.now().toUtc().toIso8601String(),
    });
    return null;
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    final key = '$scopeUid:$entityType';
    final rows = _store[key] ?? [];
    final sinceTime = sinceCursor is TimestampCursor
        ? sinceCursor.serverUpdatedAtUtc
        : DateTime.fromMillisecondsSinceEpoch(0);

    final filtered = rows.where((r) {
      final t = DateTime.parse(r['serverTimeUtc'] as String);
      return t.isAfter(sinceTime);
    }).toList();

    final changes = filtered.map((r) => RemoteChange(
      operationId: r['operationId'] as String,
      entityType: r['entityType'] as String,
      entityId: r['entityId'] as String,
      opType: r['opType'] as String,
      cursor: TimestampCursor(
        serverUpdatedAtUtc: DateTime.parse(r['serverTimeUtc'] as String),
        tieBreaker: r['operationId'] as String,
      ),
      payloadJson: r['payloadJson'] as String,
      serverTimeUtc: DateTime.parse(r['serverTimeUtc'] as String),
    )).toList();

    return RemoteChangesPage(
      changes: changes.take(limit).toList(),
      nextCursor: changes.isNotEmpty
          ? TimestampCursor(
              serverUpdatedAtUtc: DateTime.parse(
                changes.last.serverTimeUtc!.toUtc().toIso8601String(),
              ),
              tieBreaker: changes.last.operationId,
            )
          : null,
      hasMore: changes.length > limit,
    );
  }

  @override
  Future<PeerCapabilities> getCapabilities() async => PeerCapabilities(
    peerId: peerId,
    channel: channel,
    entityVersions: const {'record_meta': 1},
    supportedFeatures: const {'outbox_v1'},
    protocolVersion: 1,
  );
}

void main() {
  group('SyncPeer with record_meta', () {
    test('push record_meta outbox record succeeds', () async {
      final gw = _InMemorySyncPeer();
      final record = OutboxRecord(
        operationId: 'op-push-1', scopeUid: 's1',
        entityType: 'record_meta', entityId: 'r1',
        opType: 'UPSERT',
        payloadJson: jsonEncode({'meta': {'uuid': 'r1'}}),
        createdAtUtc: DateTime.now().toUtc(), attempt: 0,
      );

      final err = await gw.push(record);
      expect(err, isNull);
    });

    test('listChanges returns records since cursor', () async {
      final gw = _InMemorySyncPeer();
      final record = OutboxRecord(
        operationId: 'op-list-1', scopeUid: 's1',
        entityType: 'record_meta', entityId: 'r1',
        opType: 'UPSERT',
        payloadJson: jsonEncode({'meta': {'uuid': 'r1'}}),
        createdAtUtc: DateTime.now().toUtc(), attempt: 0,
      );
      await gw.push(record);

      final page = await gw.listChanges(
        scopeUid: 's1', entityType: 'record_meta',
        sinceCursor: TimestampCursor(
          serverUpdatedAtUtc: DateTime.utc(2025),
          tieBreaker: '',
        ),
        limit: 100,
      );

      expect(page.changes, hasLength(1));
      expect(page.changes.single.entityType, 'record_meta');
      expect(page.changes.single.entityId, 'r1');
    });

    test('listChanges empty when no new records', () async {
      final gw = _InMemorySyncPeer();
      final page = await gw.listChanges(
        scopeUid: 's1', entityType: 'record_meta',
        sinceCursor: TimestampCursor(
          serverUpdatedAtUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
          tieBreaker: '',
        ),
        limit: 100,
      );
      expect(page.changes, isEmpty);
    });

    test('listChanges is empty for uninitialized scope', () async {
      final gw = _InMemorySyncPeer();
      final page = await gw.listChanges(
        scopeUid: 'unknown', entityType: 'record_meta',
        sinceCursor: null, limit: 100,
      );
      expect(page.changes, isEmpty);
    });
  });
}
