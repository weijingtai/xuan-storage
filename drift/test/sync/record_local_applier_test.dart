import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import '../../lib/sync/record_local_applier.dart';
import '../../lib/sync/record_outbox_mapper.dart';

RecordMeta _meta(String uuid, {String scope = 's1'}) => RecordMeta(
  uuid: uuid, scopeUid: scope, module: 'meihua', category: 'divination',
  divinationType: 'mei_hua', createdAt: DateTime.utc(2026),
);

void main() {
  late PersistenceDriftDatabase db;
  late DriftRecordDataSource ds;
  late OutboxRecordsDao outboxDao;
  late DriftOutboxStore outboxStore;

  setUp(() {
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

      final outboxRows = await outboxStore.peekBatch(scopeUid: 's1', limit: 100);
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

      final outboxRows = await outboxStore.peekBatch(scopeUid: 's1', limit: 100);
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
