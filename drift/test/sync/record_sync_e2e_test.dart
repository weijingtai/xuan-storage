import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/sync/record_local_applier.dart';
import 'package:persistence_drift/sync/record_outbox_mapper.dart';

class _TagAdapter implements ModuleRecordAdapter {
  @override String get module => 'meihua';
  @override String get category => 'divination';
  @override String get divinationType => 'mei_hua';
  @override ({RecordMeta meta, Map<String, dynamic>? moduleData}) toRecord(Object m) =>
      throw UnimplementedError();
  @override Object fromRecord(RecordMeta meta, Map<String, dynamic>? d) =>
      throw UnimplementedError();
  @override List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? d) =>
      const [SearchTag('upper_gua', '3')];
}

class _InMemRemoteGw implements SyncPeer {
  final _store = <String, List<Map<String, dynamic>>>{};
  int _clockMillis = 1700000000000;

  @override
  PeerId get peerId => const PeerId('in-memory');

  @override
  Channel get channel => Channel.cloud;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    _store.putIfAbsent('${record.scopeUid}:${record.entityType}', () => []);
    // 模拟真实网关：为入站记录分配一个单调递增的 HLC 戳（ACT 08 线上格式）。
    // 无戳的 change 会被 applier 判 keepLocal（fail-safe），e2e 期望两条都应用，
    // 因此 push 必须带上戳 —— 这与真实 Firestore/RTDB 网关行为一致。
    _clockMillis = _clockMillis + 1;
    _store['${record.scopeUid}:${record.entityType}']!.add({
      'operationId': record.operationId,
      'entityType': record.entityType,
      'entityId': record.entityId,
      'opType': record.opType,
      'payloadJson': record.payloadJson,
      'serverTimeUtc': DateTime.now().toUtc().toIso8601String(),
      'hlcPacked': _clockMillis << 16,
      'deviceId': 'e2e-gateway-device',
    });
    return null;
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid, required String entityType,
    required PullCursor? sinceCursor, required int limit,
  }) async {
    final key = '$scopeUid:$entityType';
    final rows = _store[key] ?? [];
    final sinceTime = sinceCursor is TimestampCursor
        ? sinceCursor.serverUpdatedAtUtc
        : DateTime.fromMillisecondsSinceEpoch(0);
    final filtered = rows.where((r) =>
        DateTime.parse(r['serverTimeUtc'] as String).isAfter(sinceTime)).toList();
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
      hlcPacked: r['hlcPacked'] as int?,
      deviceId: r['deviceId'] as String?,
    )).toList();
    return RemoteChangesPage(
      changes: changes.take(limit).toList(),
      nextCursor: changes.isNotEmpty ? TimestampCursor(
        serverUpdatedAtUtc: DateTime.parse(changes.last.serverTimeUtc!.toUtc().toIso8601String()),
        tieBreaker: changes.last.operationId,
      ) : null,
      hasMore: changes.length > limit,
    );
  }

  @override Future<PeerCapabilities> getCapabilities() async => PeerCapabilities(
    peerId: peerId, channel: channel,
    entityVersions: const {'record_meta': 1}, supportedFeatures: const {'outbox_v1'},
    protocolVersion: 1,
  );
}

void main() {
  const peer = PeerId('firestore');
  setUp(() {
    // ACT 05：peekBatch 按 channel 过滤且 fail closed。本文件用 record_meta。
    StoragePolicyRegistry.clearForTesting();
    StoragePolicyRegistry.register(
      'record_meta',
      StoragePolicy.private(carriers: const {}),
    );
  });

  test('full sync cycle: save → outbox → push → pull → verify on peer', () async {
    final dbA = PersistenceDriftDatabase(NativeDatabase.memory());
    final dbB = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(dbA.close);
    addTearDown(dbB.close);

    final gw = _InMemRemoteGw();
    final scope = 'test-scope-e2e';

    // Device A: save + outbox
    final dsA = DriftRecordDataSource(dbA, scopeUid: scope);
    final daoA = OutboxRecordsDao(dbA);
    final outboxA = DriftOutboxStore(dao: daoA);
    final registry = RecordAdapterRegistry([_TagAdapter()]);
    final repoA = LocalRecordRepository(dsA, registry, outboxStore: outboxA);

    await repoA.saveRecord(RecordMeta(
      uuid: 'e2e-r1', scopeUid: scope, module: 'meihua',
      category: 'divination', divinationType: 'mei_hua',
      createdAt: DateTime.now(), question: 'E2E测试问题',
    ));

    // Push from outbox
    final batch = await outboxA.peekBatch(scopeUid: scope, peerId: peer, channel: Channel.cloud, limit: 100);
    expect(batch, hasLength(1));
    for (final record in batch) {
      final err = await gw.push(record);
      expect(err, isNull);
    }

    // Device B: pull + apply
    final dsB = DriftRecordDataSource(dbB, scopeUid: scope);
    final applierB = RecordLocalApplier(
      scopeUid: scope,
      applyRecord: dsB.applyRemoteRecord,
      deleteRecord: dsB.softDeleteRecord,
      readLocalRecord: (uuid) => dsB.getRecord(uuid),
      readLocalStamp: (entityId) => dbB.getEntityStamp(
        scopeUid: scope,
        entityType: RecordOutboxMapper.entityType,
        entityId: entityId,
      ),
      applyWithStamp: ({
        required entityType,
        required entityId,
        required hlcPacked,
        required deviceId,
        required write,
      }) =>
          dbB.applyWithStamp(
            scopeUid: scope,
            entityType: entityType,
            entityId: entityId,
            hlcPacked: hlcPacked,
            deviceId: deviceId,
            write: write,
          ),
      arbiter: const HlcConflictArbiter(),
    );

    final page = await gw.listChanges(
      scopeUid: scope, entityType: 'record_meta',
      sinceCursor: null, limit: 100,
    );
    expect(page.changes, hasLength(1));

    final result = await applierB.applyRemoteChanges(
      scopeUid: scope, entityType: 'record_meta',
      changes: page.changes,
    );
    expect(result.canAdvanceCursor, isTrue);
    expect(result.appliedCount, 1);

    // Verify device B has the record
    final found = await dsB.getRecord('e2e-r1');
    expect(found, isNotNull);
    expect(found!.question, 'E2E测试问题');
    expect(found.scopeUid, scope);
  });

  test('soft-delete syncs to peer', () async {
    final dbA = PersistenceDriftDatabase(NativeDatabase.memory());
    final dbB = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(dbA.close);
    addTearDown(dbB.close);

    final gw = _InMemRemoteGw();
    final scope = 'test-scope-e2e-del';

    // Device A: save + soft-delete
    final dsA = DriftRecordDataSource(dbA, scopeUid: scope);
    final daoA = OutboxRecordsDao(dbA);
    final outboxA = DriftOutboxStore(dao: daoA);
    final registry = RecordAdapterRegistry([_TagAdapter()]);
    final repoA = LocalRecordRepository(dsA, registry, outboxStore: outboxA);
    final uuid = 'e2e-del-r1';

    await repoA.saveRecord(RecordMeta(
      uuid: uuid, scopeUid: scope, module: 'meihua',
      category: 'divination', divinationType: 'mei_hua',
      createdAt: DateTime.now(),
    ));
    final deleted = await repoA.softDeleteRecord(uuid, module: 'meihua');
    expect(deleted, isTrue);

    // Push all outbox records
    final batch = await outboxA.peekBatch(scopeUid: scope, peerId: peer, channel: Channel.cloud, limit: 100);
    // We should have 2: one UPSERT, one DELETE
    expect(batch, hasLength(2));

    for (final record in batch) {
      await gw.push(record);
    }

    // Device B: pull + apply
    final dsB = DriftRecordDataSource(dbB, scopeUid: scope);
    final applierB = RecordLocalApplier(
      scopeUid: scope,
      applyRecord: dsB.applyRemoteRecord,
      deleteRecord: dsB.softDeleteRecord,
      readLocalRecord: (uuid) => dsB.getRecord(uuid),
      readLocalStamp: (entityId) => dbB.getEntityStamp(
        scopeUid: scope,
        entityType: RecordOutboxMapper.entityType,
        entityId: entityId,
      ),
      applyWithStamp: ({
        required entityType,
        required entityId,
        required hlcPacked,
        required deviceId,
        required write,
      }) =>
          dbB.applyWithStamp(
            scopeUid: scope,
            entityType: entityType,
            entityId: entityId,
            hlcPacked: hlcPacked,
            deviceId: deviceId,
            write: write,
          ),
      arbiter: const HlcConflictArbiter(),
    );

    // Apply both changes on device B
    final page = await gw.listChanges(
      scopeUid: scope, entityType: 'record_meta',
      sinceCursor: null, limit: 100,
    );
    expect(page.changes, hasLength(2));

    final result = await applierB.applyRemoteChanges(
      scopeUid: scope, entityType: 'record_meta',
      changes: page.changes,
    );
    expect(result.canAdvanceCursor, isTrue);
    expect(result.appliedCount, 2);

    // Record should be deleted on device B
    // Soft-deleted records are not visible via listRecords (filtered)
    final recordsB = await dsB.listRecords();
    expect(recordsB.where((r) => r.uuid == uuid), isEmpty);
    // But can still fetch by uuid directly
    final fetchedB = await dsB.getRecord(uuid);
    expect(fetchedB, isNotNull);
    expect(fetchedB!.deletedAt, isNotNull);
  });

  test('scope isolation: records from different scopes do not leak', () async {
    final dbA = PersistenceDriftDatabase(NativeDatabase.memory());
    final dbB = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(dbA.close);
    addTearDown(dbB.close);

    final gw = _InMemRemoteGw();
    final registry = RecordAdapterRegistry([_TagAdapter()]);

    // Two scopes
    for (final scope in ['scope-a', 'scope-b']) {
      final ds = DriftRecordDataSource(dbA, scopeUid: scope);
      final dao = OutboxRecordsDao(dbA);
      final outbox = DriftOutboxStore(dao: dao);
      final repo = LocalRecordRepository(ds, registry, outboxStore: outbox);

      await repo.saveRecord(RecordMeta(
        uuid: 'e2e-scope-r1', scopeUid: scope, module: 'meihua',
        category: 'divination', divinationType: 'mei_hua',
        createdAt: DateTime.now(),
      ));

      final batch = await outbox.peekBatch(scopeUid: scope, peerId: peer, channel: Channel.cloud, limit: 100);
      for (final record in batch) {
        await gw.push(record);
      }
    }

    // Device B scope-a: should only get scope-a records
    final dsB = DriftRecordDataSource(dbB, scopeUid: 'scope-a');
    final applierB = RecordLocalApplier(
      scopeUid: 'scope-a',
      applyRecord: dsB.applyRemoteRecord,
      deleteRecord: dsB.softDeleteRecord,
      readLocalRecord: (uuid) => dsB.getRecord(uuid),
      readLocalStamp: (entityId) => dbB.getEntityStamp(
        scopeUid: 'scope-a',
        entityType: RecordOutboxMapper.entityType,
        entityId: entityId,
      ),
      applyWithStamp: ({
        required entityType,
        required entityId,
        required hlcPacked,
        required deviceId,
        required write,
      }) =>
          dbB.applyWithStamp(
            scopeUid: 'scope-a',
            entityType: entityType,
            entityId: entityId,
            hlcPacked: hlcPacked,
            deviceId: deviceId,
            write: write,
          ),
      arbiter: const HlcConflictArbiter(),
    );

    final page = await gw.listChanges(
      scopeUid: 'scope-a', entityType: 'record_meta',
      sinceCursor: null, limit: 100,
    );
    expect(page.changes, hasLength(1));

    await applierB.applyRemoteChanges(
      scopeUid: 'scope-a', entityType: 'record_meta',
      changes: page.changes,
    );

    final foundB = await dsB.getRecord('e2e-scope-r1');
    expect(foundB, isNotNull);
    expect(foundB!.scopeUid, 'scope-a');
  });
}
