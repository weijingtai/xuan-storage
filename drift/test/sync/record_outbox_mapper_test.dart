import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import '../../lib/sync/record_outbox_mapper.dart';

void main() {
  final baseMeta = RecordMeta(
    uuid: 'mapper-test-uuid', scopeUid: 'test-scope',
    module: 'meihua', category: 'divination',
    divinationType: 'mei_hua', createdAt: DateTime.utc(2026, 6, 29),
    rev: 1, question: '今天运势如何？',
    moduleDataJson: '{"key":"val"}',
  );

  group('RecordOutboxMapper', () {
    test('maps RecordMeta to OutboxRecord with entity_type record_meta', () {
      final outbox = RecordOutboxMapper.toOutboxRecord(
        meta: baseMeta, tags: const [], opType: RecordOutboxMapper.opUpsert,
      );
      expect(outbox.entityType, RecordOutboxMapper.entityType);
      expect(outbox.entityId, baseMeta.uuid);
      expect(outbox.scopeUid, baseMeta.scopeUid);
      expect(outbox.operationId, isNotEmpty);
    });

    test('opType is UPSERT for new record', () {
      final outbox = RecordOutboxMapper.toOutboxRecord(
        meta: baseMeta, tags: const [], opType: RecordOutboxMapper.opUpsert,
      );
      expect(outbox.opType, 'UPSERT');
    });

    test('opType is DELETE for soft-deleted record', () {
      final outbox = RecordOutboxMapper.toOutboxRecord(
        meta: baseMeta, tags: const [], opType: RecordOutboxMapper.opDelete,
      );
      expect(outbox.opType, 'DELETE');
    });

    test('payloadJson contains meta fields and searchTags', () {
      final tags = [SearchTag('upper_gua', '3'), SearchTag('lower_gua', '7')];
      final outbox = RecordOutboxMapper.toOutboxRecord(
        meta: baseMeta, tags: tags, opType: RecordOutboxMapper.opUpsert,
      );
      final payload = jsonDecode(outbox.payloadJson) as Map<String, dynamic>;
      expect(payload['meta']['uuid'], baseMeta.uuid);
      expect(payload['meta']['question'], baseMeta.question);
      expect(payload['meta']['moduleDataJson'], baseMeta.moduleDataJson);
      expect(payload['searchTags'], isA<List>());
      expect((payload['searchTags'] as List).length, 2);
    });

    test('payloadJson includes moduleData when provided', () {
      final moduleData = {'answer': '大吉', 'score': 98};
      final outbox = RecordOutboxMapper.toOutboxRecord(
        meta: baseMeta, moduleData: moduleData, tags: const [],
        opType: RecordOutboxMapper.opUpsert,
      );
      final payload = jsonDecode(outbox.payloadJson) as Map<String, dynamic>;
      expect(payload['moduleData']['answer'], '大吉');
      expect(payload['moduleData']['score'], 98);
    });

    test('outbox payload contains record public columns', () {
      final fullMeta = baseMeta.copyWith(
        occurredAtUtc: DateTime.utc(2025, 1, 1, 12, 0),
        reckoningType: 'true_solar',
        timezoneStr: 'Asia/Shanghai',
        latitude: 31.2,
        longitude: 121.5,
        locationName: 'Shanghai',
        spacetimeJson: '{"key":"space"}',
      );
      // We manually add gender because copyWith doesn't seem to support gender in baseMeta (wait, let's check copyWith, it doesn't have gender? Wait, it does not. I will create a new RecordMeta).
      final newMeta = RecordMeta(
        uuid: baseMeta.uuid, scopeUid: baseMeta.scopeUid,
        module: baseMeta.module, category: baseMeta.category,
        divinationType: baseMeta.divinationType, createdAt: baseMeta.createdAt,
        occurredAtUtc: DateTime.utc(2025, 1, 1, 12, 0),
        reckoningType: 'true_solar',
        timezoneStr: 'Asia/Shanghai',
        latitude: 31.2,
        longitude: 121.5,
        locationName: 'Shanghai',
        spacetimeJson: '{"key":"space"}',
        gender: 'F',
      );
      final outbox = RecordOutboxMapper.toOutboxRecord(
        meta: newMeta, tags: const [], opType: RecordOutboxMapper.opUpsert,
      );
      final payload = jsonDecode(outbox.payloadJson) as Map<String, dynamic>;
      final metaPayload = payload['meta'] as Map<String, dynamic>;

      expect(metaPayload['occurredAtUtc'], '2025-01-01T12:00:00.000Z');
      expect(metaPayload['reckoningType'], 'true_solar');
      expect(metaPayload['timezoneStr'], 'Asia/Shanghai');
      expect(metaPayload['latitude'], 31.2);
      expect(metaPayload['longitude'], 121.5);
      expect(metaPayload['locationName'], 'Shanghai');
      expect(metaPayload['spacetimeJson'], '{"key":"space"}');
      expect(metaPayload['gender'], 'F');
    });

    test('scopeUid matches record.scopeUid', () {
      final outbox = RecordOutboxMapper.toOutboxRecord(
        meta: baseMeta, tags: const [], opType: RecordOutboxMapper.opUpsert,
      );
      expect(outbox.scopeUid, baseMeta.scopeUid);
    });
  });
}
