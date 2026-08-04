import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import '../../lib/sync/record_local_applier.dart';
import '../../lib/sync/record_outbox_mapper.dart';

RecordMeta _meta(String uuid, {String scope = 's1'}) => RecordMeta(
  uuid: uuid, scopeUid: scope, module: 'meihua', category: 'divination',
  divinationType: 'mei_hua', createdAt: DateTime.utc(2026),
);

void main() {
  const _peer = PeerId('firestore');
  late PersistenceDriftDatabase db;
  late DriftRecordDataSource ds;
  late OutboxRecordsDao outboxDao;
  late DriftOutboxStore outboxStore;

  setUp(() {
    // ACT 05：peekBatch 按 channel 过滤且 fail closed。本文件用 record_meta。
    StoragePolicyRegistry.clearForTesting();
    StoragePolicyRegistry.register(
      'record_meta',
      StoragePolicy.private(carriers: const {}),
    );
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    ds = DriftRecordDataSource(db, scopeUid: 's1');
    outboxDao = OutboxRecordsDao(db);
    outboxStore = DriftOutboxStore(dao: outboxDao);
  });

  tearDown(() async => await db.close());

  group('DriftRecordDataSource.applyRemoteRecord', () {
    test('writes to t_record_meta without outbox enqueue', () async {
      await ds.applyRemoteRecord(_meta('r1'), const []);

      final found = await ds.getRecord('r1');
      expect(found, isNotNull);
      expect(found!.uuid, 'r1');

      final outboxRows = await outboxStore.peekBatch(scopeUid: 's1', peerId: _peer, channel: Channel.cloud, limit: 100);
      expect(outboxRows, isEmpty);
    });

    test('overwrites existing record with same uuid', () async {
      final original = _meta('r2');
      final updated = _meta('r2', scope: 's1');
      final overriddenMeta = updated.copyWith(question: 'updated');
      await ds.saveRecord(original, const []);
      await ds.applyRemoteRecord(overriddenMeta, const []);

      final found = await ds.getRecord('r2');
      expect(found, isNotNull);
      expect(found!.question, 'updated');
    });

    test('writes search tags to t_record_search_index', () async {
      final tags = [SearchTag('upper_gua', '3'), SearchTag('lower_gua', '7')];
      await ds.applyRemoteRecord(_meta('r3'), tags);

      final rows = await db.customSelect(
        "SELECT index_key, index_value FROM t_record_search_index WHERE record_uuid='r3'").get();
      expect(rows.length, 2);
      expect(rows[0].read<String>('index_key'), 'upper_gua');
    });

    test('respects scopeUid isolation', () async {
      final ds2 = DriftRecordDataSource(db, scopeUid: 's2');
      await ds.applyRemoteRecord(_meta('r4-s1'), const []);
      await ds2.applyRemoteRecord(_meta('r4-s2', scope: 's2'), const []);

      expect((await ds.listRecords()).where((r) => r.uuid == 'r4-s1'), hasLength(1));
      expect((await ds2.listRecords()).where((r) => r.uuid == 'r4-s2'), hasLength(1));
    });
  });

  group('RecordLocalApplier', () {
    test('applyRemoteChanges applies UPSERT RemoteChange', () async {
      final applier = RecordLocalApplier(
        applyRecord: ds.applyRemoteRecord,
        deleteRecord: ds.softDeleteRecord,
      );
      final payload = {
        'meta': RecordOutboxMapper.metaToJson(_meta('r5')),
        'searchTags': <Map<String, String>>[],
      };
      final change = RemoteChange(
        operationId: 'op-1', entityType: 'record_meta',
        entityId: 'r5', opType: 'UPSERT',
        payloadJson: jsonEncode(payload),
        cursor: TimestampCursor(serverUpdatedAtUtc: DateTime.utc(2026), tieBreaker: 'op-1'),
        serverTimeUtc: DateTime.utc(2026),
      );

      final result = await applier.applyRemoteChanges(
        scopeUid: 's1', entityType: 'record_meta',
        changes: [change],
      );

      expect(result.canAdvanceCursor, isTrue);
      expect(result.appliedCount, 1);
      final found = await ds.getRecord('r5');
      expect(found, isNotNull);
    });

    test('local applier restores record public columns', () async {
      final applier = RecordLocalApplier(
        applyRecord: ds.applyRemoteRecord,
        deleteRecord: ds.softDeleteRecord,
      );

      final metaMap = RecordOutboxMapper.metaToJson(_meta('r-public'));
      metaMap['occurredAtUtc'] = '2025-01-01T12:00:00.000Z';
      metaMap['reckoningType'] = 'true_solar';
      metaMap['timezoneStr'] = 'Asia/Shanghai';
      metaMap['latitude'] = 31.2;
      metaMap['longitude'] = 121.5;
      metaMap['locationName'] = 'Shanghai';
      metaMap['spacetimeJson'] = '{"key":"space"}';
      metaMap['gender'] = 'F';

      final payload = {
        'meta': metaMap,
        'searchTags': <Map<String, String>>[],
      };
      final change = RemoteChange(
        operationId: 'op-public', entityType: 'record_meta',
        entityId: 'r-public', opType: 'UPSERT',
        payloadJson: jsonEncode(payload),
        cursor: TimestampCursor(serverUpdatedAtUtc: DateTime.utc(2026), tieBreaker: 'op-public'),
        serverTimeUtc: DateTime.utc(2026),
      );

      await applier.applyRemoteChanges(
        scopeUid: 's1', entityType: 'record_meta',
        changes: [change],
      );

      final found = await ds.getRecord('r-public');
      expect(found, isNotNull);
      expect(found!.occurredAtUtc, DateTime.utc(2025, 1, 1, 12, 0));
      expect(found.reckoningType, 'true_solar');
      expect(found.timezoneStr, 'Asia/Shanghai');
      expect(found.latitude, 31.2);
      expect(found.longitude, 121.5);
      expect(found.locationName, 'Shanghai');
      expect(found.spacetimeJson, '{"key":"space"}');
      expect(found.gender, 'F');
    });

    test('applyRemoteChanges does not trigger outbox (anti-loop)', () async {
      final applier = RecordLocalApplier(
        applyRecord: ds.applyRemoteRecord,
        deleteRecord: ds.softDeleteRecord,
      );
      final payload = {
        'meta': RecordOutboxMapper.metaToJson(_meta('r6')),
        'searchTags': <Map<String, String>>[],
      };
      final change = RemoteChange(
        operationId: 'op-2', entityType: 'record_meta',
        entityId: 'r6', opType: 'UPSERT',
        payloadJson: jsonEncode(payload),
        cursor: TimestampCursor(serverUpdatedAtUtc: DateTime.utc(2026), tieBreaker: 'op-2'),
        serverTimeUtc: DateTime.utc(2026),
      );

      await applier.applyRemoteChanges(
        scopeUid: 's1', entityType: 'record_meta',
        changes: [change],
      );

      final outboxRows = await outboxStore.peekBatch(scopeUid: 's1', peerId: _peer, channel: Channel.cloud, limit: 100);
      expect(outboxRows, isEmpty);
    });

    test('canApply returns true only for record_meta', () {
      final applier = RecordLocalApplier(
        applyRecord: ds.applyRemoteRecord,
        deleteRecord: ds.softDeleteRecord,
      );
      expect(applier.canApply('record_meta'), isTrue);
      expect(applier.canApply('divination'), isFalse);
      expect(applier.canApply(''), isFalse);
    });
  });
}
