import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:persistence_core/model/im_models.dart';
import 'package:persistence_core/model/im_wire_frames.dart';
import 'package:persistence_core/model/message_outbox_mapper.dart';
import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/transport.dart';
import 'package:persistence_core/test_support/fake_transport.dart';
import 'package:test/test.dart';

void main() {
  group('TIMMessage and TIMConversation Value Types', () {
    test('TIMMessage immutability, properties and canonical JSON representation', () {
      final msg = TIMMessage(
        scopeUid: 'user_alice',
        messageId: 'msg_001',
        conversationId: 'dm_v1_abc123',
        senderAppUserId: 'user_alice',
        recipientAppUserId: 'user_bob',
        originDeviceId: 'dev_phone_1',
        messageType: 'text',
        contentJson: '{"text":"Hello Bob!"}',
        contentHash: 'hash_xyz_123',
        mediaBlobHash: null,
        createdHlcPacked: 1724720400000 << 16,
        createdHlcDeviceId: 'dev_phone_1',
        createdAtUtcMs: 1724720400000,
      );

      expect(msg.scopeUid, 'user_alice');
      expect(msg.messageId, 'msg_001');
      expect(msg.conversationId, 'dm_v1_abc123');
      expect(msg.senderAppUserId, 'user_alice');
      expect(msg.recipientAppUserId, 'user_bob');
      expect(msg.originDeviceId, 'dev_phone_1');
      expect(msg.messageType, 'text');
      expect(msg.contentJson, '{"text":"Hello Bob!"}');
      expect(msg.contentHash, 'hash_xyz_123');
      expect(msg.mediaBlobHash, isNull);
      expect(msg.createdHlcPacked, 1724720400000 << 16);
      expect(msg.createdHlcDeviceId, 'dev_phone_1');
      expect(msg.createdAtUtcMs, 1724720400000);

      final canonicalJson = msg.toCanonicalJson();
      // Canonical JSON must not contain deliveryId or transient state
      expect(canonicalJson, isNot(contains('deliveryId')));
      expect(canonicalJson, isNot(contains('delivery_id')));

      final parsed = jsonDecode(canonicalJson) as Map<String, dynamic>;
      expect(parsed['schema_version'], 1);
      expect(parsed['message_id'], 'msg_001');
      expect(parsed['conversation_id'], 'dm_v1_abc123');
      expect(parsed['sender_app_user_id'], 'user_alice');
      expect(parsed['recipient_app_user_id'], 'user_bob');
      expect(parsed['origin_device_id'], 'dev_phone_1');
      expect(parsed['message_type'], 'text');
      expect(parsed['content_json'], '{"text":"Hello Bob!"}');
      expect(parsed['content_hash'], 'hash_xyz_123');
      expect(parsed['media_blob_hash'], isNull);
      expect(parsed['created_hlc_packed'], 1724720400000 << 16);
      expect(parsed['created_hlc_device_id'], 'dev_phone_1');
      expect(parsed['created_at_utc_ms'], 1724720400000);

      // Deserialization check
      final reconstructed = TIMMessage.fromJson(parsed, scopeUid: 'user_alice');
      expect(reconstructed, equals(msg));
    });

    test('deriveConversationId produces stable deterministic output independent of argument order', () {
      final conv1 = deriveConversationId('u_alice', 'u_bob');
      final conv2 = deriveConversationId('u_bob', 'u_alice');

      expect(conv1, startsWith('dm_v1_'));
      expect(conv1, equals(conv2));

      // Check SHA-256 calculation manually
      final expectedSha = sha256.convert(utf8.encode('dm:v1|u_alice|u_bob')).toString();
      expect(conv1, 'dm_v1_$expectedSha');
    });

    test('TIMConversation default fields and unread computation immutability', () {
      final conv = TIMConversation(
        scopeUid: 'user_alice',
        conversationId: 'dm_v1_abc',
        peerAppUserId: 'user_bob',
        peerNicknameSnapshot: 'Bob',
        peerAvatarUrlSnapshot: 'https://example.com/bob.png',
        lastMessageId: 'msg_001',
        lastMessageHlcPacked: 100,
        lastMessageHlcDeviceId: 'dev_1',
        lastReadHlcPacked: 50,
        lastReadHlcDeviceId: 'dev_2',
        unreadCountCache: 1,
        isPinned: false,
        isMuted: false,
        settingsHlcPacked: 200,
        settingsHlcDeviceId: 'dev_1',
        updatedAtUtcMs: 1724720400000,
      );

      expect(conv.unreadCountCache, 1);
      expect(conv.isPinned, isFalse);
      expect(conv.isMuted, isFalse);

      final updated = conv.copyWith(
        unreadCountCache: 0,
        lastReadHlcPacked: 100,
        isPinned: true,
      );

      expect(updated.unreadCountCache, 0);
      expect(updated.lastReadHlcPacked, 100);
      expect(updated.isPinned, isTrue);
      expect(conv.unreadCountCache, 1); // original remains unmodified
    });

    test('TIMMessageTombstone and TIMMessageReceipt', () {
      final tombstone = TIMMessageTombstone(
        scopeUid: 'user_alice',
        messageId: 'msg_001',
        deleteHlcPacked: 300,
        deleteHlcDeviceId: 'dev_1',
        reason: 'user_deleted',
      );
      expect(tombstone.scopeUid, 'user_alice');
      expect(tombstone.messageId, 'msg_001');
      expect(tombstone.deleteHlcPacked, 300);
      expect(tombstone.reason, 'user_deleted');

      final receipt = TIMMessageReceipt(
        scopeUid: 'user_alice',
        messageId: 'msg_001',
        recipientAppUserId: 'user_bob',
        recipientDeviceId: 'dev_bob_1',
        receiptType: 'read',
        receiptHlcPacked: 400,
        receiptHlcDeviceId: 'dev_bob_1',
      );
      expect(receipt.receiptType, 'read');
      expect(receipt.isValidReceiptType, isTrue);

      final invalidReceipt = TIMMessageReceipt(
        scopeUid: 'user_alice',
        messageId: 'msg_001',
        recipientAppUserId: 'user_bob',
        recipientDeviceId: 'dev_bob_1',
        receiptType: 'invalid_type',
        receiptHlcPacked: 400,
        receiptHlcDeviceId: 'dev_bob_1',
      );
      expect(invalidReceipt.isValidReceiptType, isFalse);
    });

    test('TIMEnvelopeDedup and IncomingDeliveryFact facts', () {
      final dedup = TIMEnvelopeDedup(
        scopeUid: 'user_alice',
        envelopeId: 'env_100',
        messageId: 'msg_001',
        ciphertextHash: 'hash_abc',
        committedAtUtcMs: 1724720400000,
      );
      expect(dedup.envelopeId, 'env_100');
      expect(dedup.ciphertextHash, 'hash_abc');

      final deliveryFact = IncomingDeliveryFact(
        scopeUid: 'user_alice',
        deliveryId: 'rly_001',
        envelopeId: 'env_100',
        messageId: 'msg_001',
        committedAtUtcMs: 1724720400000,
      );
      expect(deliveryFact.deliveryId, 'rly_001');
    });

    test('TIMSendState and TIMPeerAuthorization', () {
      final sendState = TIMSendState(
        scopeUid: 'user_alice',
        messageId: 'msg_001',
        transportState: 'pending',
        attempt: 0,
        retryAtUtcMs: null,
        lastErrorCode: null,
        updatedAtUtcMs: 1724720400000,
      );
      expect(sendState.isValidTransportState, isTrue);

      final auth = TIMPeerAuthorization(
        scopeUid: 'user_alice',
        peerDeviceId: 'dev_bob',
        peerPublicKeyFingerprint: 'fp_bob_123',
        accountBindingCertHash: 'cert_hash_123',
        keyEpoch: 1,
        trustState: 'active',
        expiresAtUtcMs: 1724720400000 + 86400000,
      );
      expect(auth.isValidTrustState, isTrue);
      expect(auth.isTrusted, isTrue);
    });
  });

  group('MessageOutboxMapper Contract', () {
    test('maps TIMMessage to stable OutboxRecord with im_message_v1 entity type', () {
      final msg = TIMMessage(
        scopeUid: 'user_alice',
        messageId: 'msg_001',
        conversationId: 'dm_v1_abc123',
        senderAppUserId: 'user_alice',
        recipientAppUserId: 'user_bob',
        originDeviceId: 'dev_phone_1',
        messageType: 'text',
        contentJson: '{"text":"Hi"}',
        contentHash: 'hash_1',
        mediaBlobHash: null,
        createdHlcPacked: 1000,
        createdHlcDeviceId: 'dev_phone_1',
        createdAtUtcMs: 1724720400000,
      );

      final mapper = MessageOutboxMapper();
      const stableOpId = 'op_im_msg_001_initial';
      final outboxRecord = mapper.map(
        entity: msg,
        operationId: stableOpId,
        opType: 'CREATE',
      );

      expect(outboxRecord.operationId, stableOpId);
      expect(outboxRecord.scopeUid, 'user_alice');
      expect(outboxRecord.entityType, MessageOutboxMapper.entityType);
      expect(MessageOutboxMapper.entityType, 'im_message_v1');
      expect(outboxRecord.entityId, 'msg_001');
      expect(outboxRecord.opType, 'CREATE');
      expect(outboxRecord.attempt, 0);
      expect(outboxRecord.createdAtUtc, DateTime.fromMillisecondsSinceEpoch(1724720400000, isUtc: true));

      final payloadMap = jsonDecode(outboxRecord.payloadJson) as Map<String, dynamic>;
      expect(payloadMap['schema_version'], 1);
      expect(payloadMap['message_id'], 'msg_001');
      expect(payloadMap['conversation_id'], 'dm_v1_abc123');
      expect(payloadMap.containsKey('delivery_id'), isFalse);
    });
  });

  group('PeerStream.kind and Wire Codecs', () {
    test('PeerStream exposes kind', () async {
      final fabric = FakeTransportFabric();
      final transportCaller = FakeTransport(fabric, deviceId: 'dev_1');
      final transportCallee = FakeTransport(fabric, deviceId: 'dev_2');
      final keys1 = const FakeDeviceKeyStore(deviceId: 'dev_1');
      final keys2 = const FakeDeviceKeyStore(deviceId: 'dev_2');

      final handle = await transportCallee.advertise(keys: keys2);
      final sessionCaller = await transportCaller.connect(
        DiscoveredPeer(transientServiceId: handle.transientServiceId, channel: Channel.lan),
        keys: keys1,
      );

      final stream = await sessionCaller.openStream(StreamKind.oplog);
      expect(stream.kind, StreamKind.oplog);
      await sessionCaller.close();
      await transportCaller.dispose();
      await transportCallee.dispose();
    });

    test('OplogFrame v1 encodes, decodes and validates signature and schema version', () {
      final frame = OplogFrame(
        schemaVersion: 1,
        operationId: 'op_100',
        scopeUid: 'user_alice',
        entityType: 'im_message_v1',
        entityId: 'msg_001',
        opType: 'CREATE',
        payloadJson: '{"schema_version":1,"message_id":"msg_001"}',
        hlcPacked: 1000,
        senderDeviceId: 'dev_1',
        signatureBase64: base64Encode(utf8.encode('mock_sig')),
      );

      final encodedBytes = frame.encode();
      final decoded = OplogFrame.decode(encodedBytes);

      expect(decoded.schemaVersion, 1);
      expect(decoded.operationId, 'op_100');
      expect(decoded.scopeUid, 'user_alice');
      expect(decoded.entityType, 'im_message_v1');
      expect(decoded.entityId, 'msg_001');
      expect(decoded.opType, 'CREATE');
      expect(decoded.payloadJson, '{"schema_version":1,"message_id":"msg_001"}');
      expect(decoded.hlcPacked, 1000);
      expect(decoded.senderDeviceId, 'dev_1');
      expect(decoded.signatureBase64, frame.signatureBase64);

      // Verify preimage construction
      final preimage = frame.computeSignaturePreimage();
      expect(preimage, isNotEmpty);
      expect(utf8.decode(preimage), contains('xuan-oplog-frame-v1'));

      // Reject unknown schema version
      final invalidVersionJson = jsonEncode({
        ...frame.toJson(),
        'schema_version': 99,
      });
      expect(
        () => OplogFrame.decode(utf8.encode(invalidVersionJson)),
        throwsA(isA<FormatException>()),
      );
    });

    test('ApplicationAckFrame v1 encodes, decodes and validates format', () {
      final ack = ApplicationAckFrame(
        schemaVersion: 1,
        operationId: 'op_100',
        receiverDeviceId: 'dev_2',
        committedHlcPacked: 1050,
        signatureBase64: base64Encode(utf8.encode('mock_ack_sig')),
      );

      final encodedBytes = ack.encode();
      final decoded = ApplicationAckFrame.decode(encodedBytes);

      expect(decoded.schemaVersion, 1);
      expect(decoded.operationId, 'op_100');
      expect(decoded.receiverDeviceId, 'dev_2');
      expect(decoded.committedHlcPacked, 1050);
      expect(decoded.signatureBase64, ack.signatureBase64);

      final preimage = ack.computeSignaturePreimage();
      expect(utf8.decode(preimage), contains('xuan-app-ack-frame-v1'));

      // Reject malformed JSON or unknown version
      expect(
        () => ApplicationAckFrame.decode(utf8.encode('{"schema_version":2}')),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
