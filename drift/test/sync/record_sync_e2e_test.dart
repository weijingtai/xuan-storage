import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import '../../lib/sync/record_local_applier.dart';
import '../../lib/sync/record_sync_config.dart';

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

class _InMemRemoteGw implements RemoteGateway {
  final _store = <String, List<Map<String, dynamic>>>{};

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

  @override Future<RegionCapabilities> getCapabilities() async => RegionCapabilities(
    entityVersions: {'record_meta': 1}, supportedFeatures: {'outbox_v1'}, serverProtocolVersion: 1,
  );
}

void main() {
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
    final batch = await outboxA.peekBatch(scopeUid: scope, limit: 100);
    expect(batch, hasLength(1));
    for (final record in batch) {
      final err = await gw.push(record);
      expect(err, isNull);
    }

    // Device B: pull + apply
    final dsB = DriftRecordDataSource(dbB, scopeUid: scope);
    final applierB = RecordLocalApplier(
      applyRecord: dsB.applyRemoteRecord,
      deleteRecord: dsB.softDeleteRecord,
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
    final batch = await outboxA.peekBatch(scopeUid: scope, limit: 100);
    // We should have 2: one UPSERT, one DELETE
    expect(batch, hasLength(2));

    for (final record in batch) {
      await gw.push(record);
    }

    // Device B: pull + apply
    final dsB = DriftRecordDataSource(dbB, scopeUid: scope);
    final applierB = RecordLocalApplier(
      applyRecord: dsB.applyRemoteRecord,
      deleteRecord: dsB.softDeleteRecord,
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

      final batch = await outbox.peekBatch(scopeUid: scope, limit: 100);
      for (final record in batch) {
        await gw.push(record);
      }
    }

    // Device B scope-a: should only get scope-a records
    final dsB = DriftRecordDataSource(dbB, scopeUid: 'scope-a');
    final applierB = RecordLocalApplier(
      applyRecord: dsB.applyRemoteRecord,
      deleteRecord: dsB.softDeleteRecord,
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
