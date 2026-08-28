// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'im_dao.dart';

// ignore_for_file: type=lint
mixin _$TIMDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $TIMMessagesTable get tIMMessages => attachedDatabase.tIMMessages;
  $TIMMessageTombstonesTable get tIMMessageTombstones =>
      attachedDatabase.tIMMessageTombstones;
  $TIMMessageReceiptsTable get tIMMessageReceipts =>
      attachedDatabase.tIMMessageReceipts;
  $TIMConversationsTable get tIMConversations =>
      attachedDatabase.tIMConversations;
  $TIMEnvelopeDedupsTable get tIMEnvelopeDedups =>
      attachedDatabase.tIMEnvelopeDedups;
  $IncomingDeliveriesTable get incomingDeliveries =>
      attachedDatabase.incomingDeliveries;
  $TIMSendStatesTable get tIMSendStates => attachedDatabase.tIMSendStates;
  $TIMPeerAuthorizationsTable get tIMPeerAuthorizations =>
      attachedDatabase.tIMPeerAuthorizations;
  $EntityStampsTable get entityStamps => attachedDatabase.entityStamps;
  $OutboxRecordsTable get outboxRecords => attachedDatabase.outboxRecords;
  TIMDaoManager get managers => TIMDaoManager(this);
}

class TIMDaoManager {
  final _$TIMDaoMixin _db;
  TIMDaoManager(this._db);
  $$TIMMessagesTableTableManager get tIMMessages =>
      $$TIMMessagesTableTableManager(_db.attachedDatabase, _db.tIMMessages);
  $$TIMMessageTombstonesTableTableManager get tIMMessageTombstones =>
      $$TIMMessageTombstonesTableTableManager(
        _db.attachedDatabase,
        _db.tIMMessageTombstones,
      );
  $$TIMMessageReceiptsTableTableManager get tIMMessageReceipts =>
      $$TIMMessageReceiptsTableTableManager(
        _db.attachedDatabase,
        _db.tIMMessageReceipts,
      );
  $$TIMConversationsTableTableManager get tIMConversations =>
      $$TIMConversationsTableTableManager(
        _db.attachedDatabase,
        _db.tIMConversations,
      );
  $$TIMEnvelopeDedupsTableTableManager get tIMEnvelopeDedups =>
      $$TIMEnvelopeDedupsTableTableManager(
        _db.attachedDatabase,
        _db.tIMEnvelopeDedups,
      );
  $$IncomingDeliveriesTableTableManager get incomingDeliveries =>
      $$IncomingDeliveriesTableTableManager(
        _db.attachedDatabase,
        _db.incomingDeliveries,
      );
  $$TIMSendStatesTableTableManager get tIMSendStates =>
      $$TIMSendStatesTableTableManager(_db.attachedDatabase, _db.tIMSendStates);
  $$TIMPeerAuthorizationsTableTableManager get tIMPeerAuthorizations =>
      $$TIMPeerAuthorizationsTableTableManager(
        _db.attachedDatabase,
        _db.tIMPeerAuthorizations,
      );
  $$EntityStampsTableTableManager get entityStamps =>
      $$EntityStampsTableTableManager(_db.attachedDatabase, _db.entityStamps);
  $$OutboxRecordsTableTableManager get outboxRecords =>
      $$OutboxRecordsTableTableManager(_db.attachedDatabase, _db.outboxRecords);
}
