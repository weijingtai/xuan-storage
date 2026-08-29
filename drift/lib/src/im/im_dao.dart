import 'dart:async';
import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/src/im/im_tables.dart';

part 'im_dao.g.dart';

/// Exception thrown when an envelope ID is replayed with a different ciphertext hash or message ID.
class EnvelopeHashConflictException implements Exception {
  final String scopeUid;
  final String envelopeId;
  final String existingHash;
  final String newHash;

  EnvelopeHashConflictException({
    required this.scopeUid,
    required this.envelopeId,
    required this.existingHash,
    required this.newHash,
  });

  @override
  String toString() =>
      'EnvelopeHashConflictException: Envelope $envelopeId hash conflict in scope $scopeUid (existing: $existingHash, new: $newHash)';
}

/// Result of incoming delivery persistence.
sealed class PersistResult {
  const PersistResult();
}

final class DeliveryPersisted extends PersistResult {
  final String deliveryId;
  final String envelopeId;
  final String messageId;
  final bool wasDuplicate;

  const DeliveryPersisted({
    required this.deliveryId,
    required this.envelopeId,
    required this.messageId,
    required this.wasDuplicate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryPersisted &&
          runtimeType == other.runtimeType &&
          deliveryId == other.deliveryId &&
          envelopeId == other.envelopeId &&
          messageId == other.messageId &&
          wasDuplicate == other.wasDuplicate;

  @override
  int get hashCode => Object.hash(deliveryId, envelopeId, messageId, wasDuplicate);

  @override
  String toString() =>
      'DeliveryPersisted(deliveryId: $deliveryId, msg: $messageId, wasDuplicate: $wasDuplicate)';
}

final class DeliveryPersistFailed extends PersistResult {
  final Object cause;

  const DeliveryPersistFailed({required this.cause});

  @override
  String toString() => 'DeliveryPersistFailed(cause: $cause)';
}

@DriftAccessor(tables: [
  TIMMessages,
  TIMMessageTombstones,
  TIMMessageReceipts,
  TIMConversations,
  TIMEnvelopeDedups,
  IncomingDeliveries,
  TIMSendStates,
  TIMPeerAuthorizations,
  EntityStamps,
  OutboxRecords,
])
class TIMDao extends DatabaseAccessor<PersistenceDriftDatabase> with _$TIMDaoMixin {
  TIMDao(super.db);

  /// Atomically persists an incoming IM delivery in a single Drift transaction.
  ///
  /// Steps in single transaction:
  /// 1. Delivery dedup check on [IncomingDeliveries].
  /// 2. Envelope dedup & hash conflict quarantine on [TIMEnvelopeDedups].
  /// 3. Tombstone check (do not resurrect deleted message).
  /// 4. Insert message if absent (never overwrite via insertOrReplace).
  /// 5. Conversation recomputation (last message, unread count).
  /// 6. Entity stamp update.
  /// 7. Stable OutboxRecord creation/mapping.
  /// 8. Record delivery & envelope dedup facts.
  Future<PersistResult> persistIncomingDelivery({
    required String scopeUid,
    required IncomingDeliveryFact deliveryFact,
    required String ciphertextHash,
    required TIMMessage message,
    String? operationId,
    Future<void> Function()? onStepBeforeCommit,
  }) async {
    try {
      return await db.transaction(() async {
        // 1. Check if deliveryId was already processed
        final existingDelivery = await (select(incomingDeliveries)
              ..where(
                (t) =>
                    t.scopeUid.equals(scopeUid) &
                    t.deliveryId.equals(deliveryFact.deliveryId),
              ))
            .getSingleOrNull();

        if (existingDelivery != null) {
          return DeliveryPersisted(
            deliveryId: deliveryFact.deliveryId,
            envelopeId: deliveryFact.envelopeId,
            messageId: deliveryFact.messageId,
            wasDuplicate: true,
          );
        }

        // 2. Check envelope dedup & tamper check
        final existingEnvelope = await (select(tIMEnvelopeDedups)
              ..where(
                (t) =>
                    t.scopeUid.equals(scopeUid) &
                    t.envelopeId.equals(deliveryFact.envelopeId),
              ))
            .getSingleOrNull();

        bool wasDuplicate = false;
        if (existingEnvelope != null) {
          if (existingEnvelope.ciphertextHash != ciphertextHash ||
              existingEnvelope.messageId != deliveryFact.messageId) {
            throw EnvelopeHashConflictException(
              scopeUid: scopeUid,
              envelopeId: deliveryFact.envelopeId,
              existingHash: existingEnvelope.ciphertextHash,
              newHash: ciphertextHash,
            );
          }
          wasDuplicate = true;
        }

        // 3. Tombstone check
        final tombstone = await (select(tIMMessageTombstones)
              ..where(
                (t) =>
                    t.scopeUid.equals(scopeUid) &
                    t.messageId.equals(message.messageId),
              ))
            .getSingleOrNull();

        // 4. Insert message if absent and not tombstoned
        if (tombstone == null) {
          await into(tIMMessages).insert(
            TIMMessagesCompanion.insert(
              scopeUid: scopeUid,
              messageId: message.messageId,
              conversationId: message.conversationId,
              senderAppUserId: message.senderAppUserId,
              recipientAppUserId: message.recipientAppUserId,
              originDeviceId: message.originDeviceId,
              messageType: message.messageType,
              contentJson: message.contentJson,
              contentHash: message.contentHash,
              mediaBlobHash: Value(message.mediaBlobHash),
              createdHlcPacked: message.createdHlcPacked,
              createdHlcDeviceId: message.createdHlcDeviceId,
              createdAtUtcMs: message.createdAtUtcMs,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }

        // 5. Recompute conversation stats
        await _recomputeConversation(
          scopeUid: scopeUid,
          conversationId: message.conversationId,
          peerAppUserId: message.senderAppUserId == scopeUid
              ? message.recipientAppUserId
              : message.senderAppUserId,
          latestHlcPacked: message.createdHlcPacked,
          latestHlcDeviceId: message.createdHlcDeviceId,
          updatedAtUtcMs: message.createdAtUtcMs,
        );

        // 6. Entity stamp update
        await into(db.entityStamps).insertOnConflictUpdate(
          EntityStampsCompanion.insert(
            scopeUid: scopeUid,
            entityType: MessageOutboxMapper.entityType,
            entityId: message.messageId,
            hlcPacked: message.createdHlcPacked,
            deviceId: message.createdHlcDeviceId,
            isDeleted: Value(tombstone != null),
          ),
        );

        // 7. Stable Outbox mapping
        final effectiveOpId = operationId ?? 'op_im_${message.messageId}';
        final mapper = MessageOutboxMapper();
        final outboxRecord = mapper.map(
          entity: message,
          operationId: effectiveOpId,
          opType: 'CREATE',
        );

        await into(db.outboxRecords).insert(
          OutboxRecordsCompanion.insert(
            operationId: outboxRecord.operationId,
            scopeUid: outboxRecord.scopeUid,
            entityType: outboxRecord.entityType,
            entityId: outboxRecord.entityId,
            opType: outboxRecord.opType,
            payloadJson: outboxRecord.payloadJson,
            createdAtUtc: outboxRecord.createdAtUtc,
            attempt: const Value(0),
            status: const Value('pending'),
          ),
          mode: InsertMode.insertOrIgnore,
        );

        // 8. Record envelope dedup and delivery fact
        if (existingEnvelope == null) {
          await into(tIMEnvelopeDedups).insert(
            TIMEnvelopeDedupsCompanion.insert(
              scopeUid: scopeUid,
              envelopeId: deliveryFact.envelopeId,
              messageId: deliveryFact.messageId,
              ciphertextHash: ciphertextHash,
              committedAt: deliveryFact.committedAtUtcMs,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }

        await into(incomingDeliveries).insert(
          IncomingDeliveriesCompanion.insert(
            scopeUid: scopeUid,
            deliveryId: deliveryFact.deliveryId,
            envelopeId: deliveryFact.envelopeId,
            messageId: deliveryFact.messageId,
            committedAt: deliveryFact.committedAtUtcMs,
          ),
          mode: InsertMode.insertOrIgnore,
        );

        if (onStepBeforeCommit != null) {
          await onStepBeforeCommit();
        }

        return DeliveryPersisted(
          deliveryId: deliveryFact.deliveryId,
          envelopeId: deliveryFact.envelopeId,
          messageId: deliveryFact.messageId,
          wasDuplicate: wasDuplicate,
        );
      });
    } catch (e) {
      return DeliveryPersistFailed(cause: e);
    }
  }

  /// Soft deletes a message by recording a tombstone and updating conversation/stamp.
  Future<void> recordTombstone({
    required TIMMessageTombstone tombstone,
    required DateTime atUtc,
  }) async {
    await db.transaction(() async {
      await into(tIMMessageTombstones).insertOnConflictUpdate(
        TIMMessageTombstonesCompanion.insert(
          scopeUid: tombstone.scopeUid,
          messageId: tombstone.messageId,
          deleteHlcPacked: tombstone.deleteHlcPacked,
          deleteHlcDeviceId: tombstone.deleteHlcDeviceId,
          reason: Value(tombstone.reason),
        ),
      );

      // Mark stamp as deleted
      await into(db.entityStamps).insertOnConflictUpdate(
        EntityStampsCompanion.insert(
          scopeUid: tombstone.scopeUid,
          entityType: MessageOutboxMapper.entityType,
          entityId: tombstone.messageId,
          hlcPacked: tombstone.deleteHlcPacked,
          deviceId: tombstone.deleteHlcDeviceId,
          isDeleted: const Value(true),
        ),
      );

      // Find message to get conversationId
      final msg = await (select(tIMMessages)
            ..where(
              (t) =>
                  t.scopeUid.equals(tombstone.scopeUid) &
                  t.messageId.equals(tombstone.messageId),
            ))
          .getSingleOrNull();

      if (msg != null) {
        await _recomputeConversation(
          scopeUid: tombstone.scopeUid,
          conversationId: msg.conversationId,
          peerAppUserId: msg.senderAppUserId == tombstone.scopeUid
              ? msg.recipientAppUserId
              : msg.senderAppUserId,
          latestHlcPacked: tombstone.deleteHlcPacked,
          latestHlcDeviceId: tombstone.deleteHlcDeviceId,
          updatedAtUtcMs: atUtc.millisecondsSinceEpoch,
        );
      }
    });
  }

  /// Records a message receipt (delivered/read).
  Future<void> recordReceipt({
    required TIMMessageReceipt receipt,
  }) async {
    await into(tIMMessageReceipts).insertOnConflictUpdate(
      TIMMessageReceiptsCompanion.insert(
        scopeUid: receipt.scopeUid,
        messageId: receipt.messageId,
        recipientAppUserId: receipt.recipientAppUserId,
        recipientDeviceId: receipt.recipientDeviceId,
        receiptType: receipt.receiptType,
        receiptHlcPacked: receipt.receiptHlcPacked,
        receiptHlcDeviceId: receipt.receiptHlcDeviceId,
      ),
    );
  }

  /// Recomputes conversation's last message, unread count cache, and timestamps.
  Future<void> _recomputeConversation({
    required String scopeUid,
    required String conversationId,
    required String peerAppUserId,
    required int latestHlcPacked,
    required String latestHlcDeviceId,
    required int updatedAtUtcMs,
  }) async {
    // 1. Get existing conversation if any
    final existingConv = await (select(tIMConversations)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.conversationId.equals(conversationId),
          ))
        .getSingleOrNull();

    final lastReadHlc = existingConv?.lastReadHlcPacked ?? 0;

    // 2. Query all messages for this conversation not in tombstones
    final m = tIMMessages;
    final tb = tIMMessageTombstones;

    final query = select(m).join([
      leftOuterJoin(
        tb,
        m.scopeUid.equalsExp(tb.scopeUid) &
            m.messageId.equalsExp(tb.messageId),
      ),
    ])
      ..where(
        m.scopeUid.equals(scopeUid) &
            m.conversationId.equals(conversationId) &
            tb.messageId.isNull(),
      )
      ..orderBy([
        OrderingTerm.desc(m.createdHlcPacked),
        OrderingTerm.desc(m.createdHlcDeviceId),
        OrderingTerm.desc(m.messageId),
      ]);

    final activeMessages = await query.map((row) => row.readTable(m)).get();

    final lastMsg = activeMessages.firstOrNull;

    // Calculate unread: incoming messages (sender != scopeUid) created after lastReadHlc
    var unreadCount = 0;
    for (final msg in activeMessages) {
      if (msg.senderAppUserId != scopeUid && msg.createdHlcPacked > lastReadHlc) {
        unreadCount += 1;
      }
    }

    final newLastMessageId = lastMsg?.messageId;
    final newLastMessageHlcPacked = lastMsg?.createdHlcPacked;
    final newLastMessageHlcDeviceId = lastMsg?.createdHlcDeviceId;

    await into(tIMConversations).insertOnConflictUpdate(
      TIMConversationsCompanion.insert(
        scopeUid: scopeUid,
        conversationId: conversationId,
        peerAppUserId: peerAppUserId,
        peerNicknameSnapshot: existingConv?.peerNicknameSnapshot ?? peerAppUserId,
        peerAvatarUrlSnapshot: Value(existingConv?.peerAvatarUrlSnapshot),
        lastMessageId: Value(newLastMessageId),
        lastMessageHlcPacked: Value(newLastMessageHlcPacked),
        lastMessageHlcDeviceId: Value(newLastMessageHlcDeviceId),
        lastReadHlcPacked: Value(existingConv?.lastReadHlcPacked),
        lastReadHlcDeviceId: Value(existingConv?.lastReadHlcDeviceId),
        unreadCountCache: Value(unreadCount),
        isPinned: Value(existingConv?.isPinned ?? 0),
        isMuted: Value(existingConv?.isMuted ?? 0),
        settingsHlcPacked: existingConv?.settingsHlcPacked ?? latestHlcPacked,
        settingsHlcDeviceId: existingConv?.settingsHlcDeviceId ?? latestHlcDeviceId,
        updatedAtUtcMs: updatedAtUtcMs,
      ),
    );
  }

  /// Updates conversation last read position and resets unread count accordingly.
  Future<void> markConversationRead({
    required String scopeUid,
    required String conversationId,
    required int readHlcPacked,
    required String readHlcDeviceId,
    required int atUtcMs,
  }) async {
    await db.transaction(() async {
      final existingConv = await (select(tIMConversations)
            ..where(
              (t) =>
                  t.scopeUid.equals(scopeUid) &
                  t.conversationId.equals(conversationId),
            ))
          .getSingleOrNull();

      if (existingConv == null) return;

      final currentLastRead = existingConv.lastReadHlcPacked ?? 0;
      // Monotonic last-read: only update if readHlcPacked > currentLastRead
      if (readHlcPacked <= currentLastRead) return;

      // Count any remaining unread messages after this readHlcPacked
      final m = tIMMessages;
      final tb = tIMMessageTombstones;
      final activeMessages = await (select(m).join([
        leftOuterJoin(
          tb,
          m.scopeUid.equalsExp(tb.scopeUid) &
              m.messageId.equalsExp(tb.messageId),
        ),
      ])
            ..where(
              m.scopeUid.equals(scopeUid) &
                  m.conversationId.equals(conversationId) &
                  tb.messageId.isNull() &
                  m.senderAppUserId.equals(existingConv.peerAppUserId) &
                  m.createdHlcPacked.isBiggerThanValue(readHlcPacked),
            ))
          .map((r) => r.readTable(m))
          .get();

      await (update(tIMConversations)
            ..where(
              (t) =>
                  t.scopeUid.equals(scopeUid) &
                  t.conversationId.equals(conversationId),
            ))
          .write(
        TIMConversationsCompanion(
          lastReadHlcPacked: Value(readHlcPacked),
          lastReadHlcDeviceId: Value(readHlcDeviceId),
          unreadCountCache: Value(activeMessages.length),
          updatedAtUtcMs: Value(atUtcMs),
        ),
      );
    });
  }

  /// Updates conversation pinned / muted state with its own settings HLC stamp.
  Future<void> updateConversationSettings({
    required String scopeUid,
    required String conversationId,
    bool? isPinned,
    bool? isMuted,
    required int settingsHlcPacked,
    required String settingsHlcDeviceId,
    required int atUtcMs,
  }) async {
    await (update(tIMConversations)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.conversationId.equals(conversationId),
          ))
        .write(
      TIMConversationsCompanion(
        isPinned: isPinned == null ? const Value.absent() : Value(isPinned ? 1 : 0),
        isMuted: isMuted == null ? const Value.absent() : Value(isMuted ? 1 : 0),
        settingsHlcPacked: Value(settingsHlcPacked),
        settingsHlcDeviceId: Value(settingsHlcDeviceId),
        updatedAtUtcMs: Value(atUtcMs),
      ),
    );
  }

  /// Fetches an IM message by primary key (scopeUid, messageId).
  Future<TIMMessageRow?> getMessage({
    required String scopeUid,
    required String messageId,
  }) {
    return (select(tIMMessages)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.messageId.equals(messageId),
          ))
        .getSingleOrNull();
  }

  /// Fetches a conversation by primary key (scopeUid, conversationId).
  Future<TIMConversationRow?> getConversation({
    required String scopeUid,
    required String conversationId,
  }) {
    return (select(tIMConversations)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.conversationId.equals(conversationId),
          ))
        .getSingleOrNull();
  }
}
