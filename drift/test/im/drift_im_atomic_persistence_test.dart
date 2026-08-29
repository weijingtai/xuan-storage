import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Drift IM Atomic Persistence & Failure Injection Matrix', () {
    late Directory tempDir;
    late File dbFile;
    late PersistenceDriftDatabase db;
    late TIMDao timDao;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('im-atomic-test-');
      dbFile = File('${tempDir.path}/test_atomic.sqlite');
      db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      timDao = db.tIMDao;
    });

    tearDown(() async {
      await db.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('ST-IM-001: persists incoming delivery atomically into message, conversation, stamp, outbox and dedup', () async {
      const scopeUid = 'u_alice';
      final msg = TIMMessage(
        scopeUid: scopeUid,
        messageId: 'msg_100',
        conversationId: 'dm_v1_conv1',
        senderAppUserId: 'u_bob',
        recipientAppUserId: 'u_alice',
        originDeviceId: 'dev_bob_phone',
        messageType: 'text',
        contentJson: '{"text":"Hello Alice"}',
        contentHash: 'hash_msg_100',
        mediaBlobHash: null,
        createdHlcPacked: 1000,
        createdHlcDeviceId: 'dev_bob_phone',
        createdAtUtcMs: 1724720400000,
      );

      final deliveryFact = IncomingDeliveryFact(
        scopeUid: scopeUid,
        deliveryId: 'rly_001',
        envelopeId: 'env_100',
        messageId: 'msg_100',
        committedAtUtcMs: 1724720400000,
      );

      final result = await timDao.persistIncomingDelivery(
        scopeUid: scopeUid,
        deliveryFact: deliveryFact,
        ciphertextHash: 'cipher_hash_100',
        message: msg,
        operationId: 'op_msg_100',
      );

      expect(result, isA<DeliveryPersisted>());
      final persisted = result as DeliveryPersisted;
      expect(persisted.deliveryId, 'rly_001');
      expect(persisted.envelopeId, 'env_100');
      expect(persisted.messageId, 'msg_100');
      expect(persisted.wasDuplicate, isFalse);

      // Verify all tables contain the persisted entities
      final storedMsg = await timDao.getMessage(scopeUid: scopeUid, messageId: 'msg_100');
      expect(storedMsg, isNotNull);
      expect(storedMsg!.contentJson, '{"text":"Hello Alice"}');

      final storedConv = await timDao.getConversation(scopeUid: scopeUid, conversationId: 'dm_v1_conv1');
      expect(storedConv, isNotNull);
      expect(storedConv!.lastMessageId, 'msg_100');
      expect(storedConv.unreadCountCache, 1, reason: 'Incoming message must increment unread');

      final stamp = await db.getEntityStamp(
        scopeUid: scopeUid,
        entityType: MessageOutboxMapper.entityType,
        entityId: 'msg_100',
      );
      expect(stamp, isNotNull);
      expect(stamp!.hlcPacked, 1000);
      expect(stamp.isDeleted, isFalse);

      final outboxRows = await (db.select(db.outboxRecords)..where((t) => t.operationId.equals('op_msg_100'))).get();
      expect(outboxRows.length, 1);
      expect(outboxRows.first.entityType, 'im_message_v1');

      final dedupRows = await (db.select(db.tIMEnvelopeDedups)..where((t) => t.envelopeId.equals('env_100'))).get();
      expect(dedupRows.length, 1);

      final deliveryRows = await (db.select(db.incomingDeliveries)..where((t) => t.deliveryId.equals('rly_001'))).get();
      expect(deliveryRows.length, 1);
    });

    test('ST-IM-001 Fault Injection: transaction failure rolls back all entities cleanly', () async {
      const scopeUid = 'u_alice';
      final msg = TIMMessage(
        scopeUid: scopeUid,
        messageId: 'msg_fault',
        conversationId: 'dm_v1_conv_fault',
        senderAppUserId: 'u_bob',
        recipientAppUserId: 'u_alice',
        originDeviceId: 'dev_bob',
        messageType: 'text',
        contentJson: '{"text":"Crash"}',
        contentHash: 'hash_crash',
        mediaBlobHash: null,
        createdHlcPacked: 2000,
        createdHlcDeviceId: 'dev_bob',
        createdAtUtcMs: 1724720400000,
      );

      final deliveryFact = IncomingDeliveryFact(
        scopeUid: scopeUid,
        deliveryId: 'rly_fault',
        envelopeId: 'env_fault',
        messageId: 'msg_fault',
        committedAtUtcMs: 1724720400000,
      );

      final result = await timDao.persistIncomingDelivery(
        scopeUid: scopeUid,
        deliveryFact: deliveryFact,
        ciphertextHash: 'cipher_hash_fault',
        message: msg,
        operationId: 'op_fault',
        onStepBeforeCommit: () async {
          throw StateError('Simulated disk/system crash before transaction commit');
        },
      );

      expect(result, isA<DeliveryPersistFailed>());

      // Assert zero orphaned rows in any table
      final storedMsg = await timDao.getMessage(scopeUid: scopeUid, messageId: 'msg_fault');
      expect(storedMsg, isNull);

      final storedConv = await timDao.getConversation(scopeUid: scopeUid, conversationId: 'dm_v1_conv_fault');
      expect(storedConv, isNull);

      final stamp = await db.getEntityStamp(
        scopeUid: scopeUid,
        entityType: MessageOutboxMapper.entityType,
        entityId: 'msg_fault',
      );
      expect(stamp, isNull);

      final outboxRows = await (db.select(db.outboxRecords)..where((t) => t.operationId.equals('op_fault'))).get();
      expect(outboxRows, isEmpty);

      final dedupRows = await (db.select(db.tIMEnvelopeDedups)..where((t) => t.envelopeId.equals('env_fault'))).get();
      expect(dedupRows, isEmpty);

      final deliveryRows = await (db.select(db.incomingDeliveries)..where((t) => t.deliveryId.equals('rly_fault'))).get();
      expect(deliveryRows, isEmpty);
    });

    test('ST-IM-002: Replay of same delivery returns wasDuplicate: true and remains ACK-eligible', () async {
      const scopeUid = 'u_alice';
      final msg = TIMMessage(
        scopeUid: scopeUid,
        messageId: 'msg_200',
        conversationId: 'dm_v1_conv2',
        senderAppUserId: 'u_bob',
        recipientAppUserId: 'u_alice',
        originDeviceId: 'dev_bob',
        messageType: 'text',
        contentJson: '{"text":"Hello again"}',
        contentHash: 'hash_msg_200',
        mediaBlobHash: null,
        createdHlcPacked: 3000,
        createdHlcDeviceId: 'dev_bob',
        createdAtUtcMs: 1724720400000,
      );

      final deliveryFact = IncomingDeliveryFact(
        scopeUid: scopeUid,
        deliveryId: 'rly_200',
        envelopeId: 'env_200',
        messageId: 'msg_200',
        committedAtUtcMs: 1724720400000,
      );

      // First pass
      final res1 = await timDao.persistIncomingDelivery(
        scopeUid: scopeUid,
        deliveryFact: deliveryFact,
        ciphertextHash: 'cipher_hash_200',
        message: msg,
      );
      expect(res1, isA<DeliveryPersisted>());
      expect((res1 as DeliveryPersisted).wasDuplicate, isFalse);

      // Second replay pass with same deliveryId
      final res2 = await timDao.persistIncomingDelivery(
        scopeUid: scopeUid,
        deliveryFact: deliveryFact,
        ciphertextHash: 'cipher_hash_200',
        message: msg,
      );
      expect(res2, isA<DeliveryPersisted>());
      expect((res2 as DeliveryPersisted).wasDuplicate, isTrue, reason: 'Replay must return wasDuplicate=true and is ACK eligible');
    });

    test('ST-IM-002: Envelope hash conflict is quarantined, returns failure, and is never ACKed', () async {
      const scopeUid = 'u_alice';
      final msg1 = TIMMessage(
        scopeUid: scopeUid,
        messageId: 'msg_300',
        conversationId: 'dm_v1_conv3',
        senderAppUserId: 'u_bob',
        recipientAppUserId: 'u_alice',
        originDeviceId: 'dev_bob',
        messageType: 'text',
        contentJson: '{"text":"Valid"}',
        contentHash: 'hash_msg_300',
        mediaBlobHash: null,
        createdHlcPacked: 4000,
        createdHlcDeviceId: 'dev_bob',
        createdAtUtcMs: 1724720400000,
      );

      final deliveryFact1 = IncomingDeliveryFact(
        scopeUid: scopeUid,
        deliveryId: 'rly_300',
        envelopeId: 'env_shared_conflict',
        messageId: 'msg_300',
        committedAtUtcMs: 1724720400000,
      );

      await timDao.persistIncomingDelivery(
        scopeUid: scopeUid,
        deliveryFact: deliveryFact1,
        ciphertextHash: 'cipher_hash_ORIGINAL',
        message: msg1,
      );

      // Malicious or corrupted replay with different ciphertext hash
      final msgTampered = TIMMessage(
        scopeUid: scopeUid,
        messageId: 'msg_300',
        conversationId: 'dm_v1_conv3',
        senderAppUserId: 'u_bob',
        recipientAppUserId: 'u_alice',
        originDeviceId: 'dev_bob',
        messageType: 'text',
        contentJson: '{"text":"Tampered"}',
        contentHash: 'hash_msg_tampered',
        mediaBlobHash: null,
        createdHlcPacked: 4000,
        createdHlcDeviceId: 'dev_bob',
        createdAtUtcMs: 1724720400000,
      );

      final deliveryFact2 = IncomingDeliveryFact(
        scopeUid: scopeUid,
        deliveryId: 'rly_301_tampered',
        envelopeId: 'env_shared_conflict',
        messageId: 'msg_300',
        committedAtUtcMs: 1724720400000,
      );

      final resultTampered = await timDao.persistIncomingDelivery(
        scopeUid: scopeUid,
        deliveryFact: deliveryFact2,
        ciphertextHash: 'cipher_hash_TAMPERED',
        message: msgTampered,
      );

      expect(resultTampered, isA<DeliveryPersistFailed>());
      final failed = resultTampered as DeliveryPersistFailed;
      expect(failed.cause, isA<EnvelopeHashConflictException>());

      // Tampered delivery was never recorded in incomingDeliveries
      final deliveryRows = await (db.select(db.incomingDeliveries)..where((t) => t.deliveryId.equals('rly_301_tampered'))).get();
      expect(deliveryRows, isEmpty, reason: 'Conflicting envelope must never be recorded into incomingDeliveries');
    });

    test('ST-IM-003: Tombstone prevents resurrection of deleted message content', () async {
      const scopeUid = 'u_alice';
      // Record tombstone first
      await timDao.recordTombstone(
        tombstone: const TIMMessageTombstone(
          scopeUid: scopeUid,
          messageId: 'msg_deleted_1',
          deleteHlcPacked: 5000,
          deleteHlcDeviceId: 'dev_1',
          reason: 'user_delete',
        ),
        atUtc: DateTime.utc(2026, 1, 1),
      );

      final msg = TIMMessage(
        scopeUid: scopeUid,
        messageId: 'msg_deleted_1',
        conversationId: 'dm_v1_conv_tomb',
        senderAppUserId: 'u_bob',
        recipientAppUserId: 'u_alice',
        originDeviceId: 'dev_bob',
        messageType: 'text',
        contentJson: '{"text":"Late arriving resurrected message"}',
        contentHash: 'hash_late',
        mediaBlobHash: null,
        createdHlcPacked: 4900,
        createdHlcDeviceId: 'dev_bob',
        createdAtUtcMs: 1724720400000,
      );

      final deliveryFact = IncomingDeliveryFact(
        scopeUid: scopeUid,
        deliveryId: 'rly_late_1',
        envelopeId: 'env_late_1',
        messageId: 'msg_deleted_1',
        committedAtUtcMs: 1724720400000,
      );

      final result = await timDao.persistIncomingDelivery(
        scopeUid: scopeUid,
        deliveryFact: deliveryFact,
        ciphertextHash: 'hash_late_cipher',
        message: msg,
      );

      expect(result, isA<DeliveryPersisted>());

      // Stored message must NOT exist in t_im_message
      final storedMsg = await timDao.getMessage(scopeUid: scopeUid, messageId: 'msg_deleted_1');
      expect(storedMsg, isNull, reason: 'Tombstone must prevent message insertion (no resurrection)');
    });
  });
}
