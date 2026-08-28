import 'package:drift/drift.dart';

@DataClassName('TIMMessageRow')
class TIMMessages extends Table {
  @override
  String get tableName => 't_im_message';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get messageId => text().named('message_id')();
  TextColumn get conversationId => text().named('conversation_id')();
  TextColumn get senderAppUserId => text().named('sender_app_user_id')();
  TextColumn get recipientAppUserId => text().named('recipient_app_user_id')();
  TextColumn get originDeviceId => text().named('origin_device_id')();
  TextColumn get messageType => text().named('message_type')();
  TextColumn get contentJson => text().named('content_json')();
  TextColumn get contentHash => text().named('content_hash')();
  TextColumn get mediaBlobHash => text().nullable().named('media_blob_hash')();
  IntColumn get createdHlcPacked => integer().named('created_hlc_packed')();
  TextColumn get createdHlcDeviceId => text().named('created_hlc_device_id')();
  IntColumn get createdAtUtcMs => integer().named('created_at_utc_ms')();

  @override
  Set<Column> get primaryKey => {scopeUid, messageId};

  List<Index> get indexes => [
        Index(
          'idx_im_message_timeline',
          'CREATE INDEX idx_im_message_timeline ON t_im_message (scope_uid, conversation_id, created_hlc_packed, created_hlc_device_id, message_id);',
        ),
      ];
}

@DataClassName('TIMMessageTombstoneRow')
class TIMMessageTombstones extends Table {
  @override
  String get tableName => 't_im_message_tombstone';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get messageId => text().named('message_id')();
  IntColumn get deleteHlcPacked => integer().named('delete_hlc_packed')();
  TextColumn get deleteHlcDeviceId => text().named('delete_hlc_device_id')();
  TextColumn get reason => text().nullable().named('reason')();

  @override
  Set<Column> get primaryKey => {scopeUid, messageId};
}

@DataClassName('TIMMessageReceiptRow')
class TIMMessageReceipts extends Table {
  @override
  String get tableName => 't_im_message_receipt';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get messageId => text().named('message_id')();
  TextColumn get recipientAppUserId => text().named('recipient_app_user_id')();
  TextColumn get recipientDeviceId => text().named('recipient_device_id')();
  TextColumn get receiptType => text().named('receipt_type')();
  IntColumn get receiptHlcPacked => integer().named('receipt_hlc_packed')();
  TextColumn get receiptHlcDeviceId => text().named('receipt_hlc_device_id')();

  @override
  Set<Column> get primaryKey => {scopeUid, messageId, recipientDeviceId, receiptType};

  @override
  List<String> get customConstraints => const [
        "CHECK (receipt_type IN ('delivered', 'read'))",
      ];
}

@DataClassName('TIMConversationRow')
class TIMConversations extends Table {
  @override
  String get tableName => 't_im_conversation';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get conversationId => text().named('conversation_id')();
  TextColumn get peerAppUserId => text().named('peer_app_user_id')();
  TextColumn get peerNicknameSnapshot => text().named('peer_nickname_snapshot')();
  TextColumn get peerAvatarUrlSnapshot => text().nullable().named('peer_avatar_url_snapshot')();
  TextColumn get lastMessageId => text().nullable().named('last_message_id')();
  IntColumn get lastMessageHlcPacked => integer().nullable().named('last_message_hlc_packed')();
  TextColumn get lastMessageHlcDeviceId => text().nullable().named('last_message_hlc_device_id')();
  IntColumn get lastReadHlcPacked => integer().nullable().named('last_read_hlc_packed')();
  TextColumn get lastReadHlcDeviceId => text().nullable().named('last_read_hlc_device_id')();
  IntColumn get unreadCountCache =>
      integer().withDefault(const Constant(0)).named('unread_count_cache')();
  IntColumn get isPinned =>
      integer().withDefault(const Constant(0)).named('is_pinned')();
  IntColumn get isMuted =>
      integer().withDefault(const Constant(0)).named('is_muted')();
  IntColumn get settingsHlcPacked => integer().named('settings_hlc_packed')();
  TextColumn get settingsHlcDeviceId => text().named('settings_hlc_device_id')();
  IntColumn get updatedAtUtcMs => integer().named('updated_at_utc_ms')();

  @override
  Set<Column> get primaryKey => {scopeUid, conversationId};

  @override
  List<String> get customConstraints => const [
        'CHECK (is_pinned IN (0, 1))',
        'CHECK (is_muted IN (0, 1))',
      ];
}

@DataClassName('TIMEnvelopeDedupRow')
class TIMEnvelopeDedups extends Table {
  @override
  String get tableName => 't_im_envelope_dedup';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get envelopeId => text().named('envelope_id')();
  TextColumn get messageId => text().named('message_id')();
  TextColumn get ciphertextHash => text().named('ciphertext_hash')();
  IntColumn get committedAt => integer().named('committed_at')();

  @override
  Set<Column> get primaryKey => {scopeUid, envelopeId};
}

@DataClassName('IncomingDeliveryRow')
class IncomingDeliveries extends Table {
  @override
  String get tableName => 't_incoming_delivery';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get deliveryId => text().named('delivery_id')();
  TextColumn get envelopeId => text().named('envelope_id')();
  TextColumn get messageId => text().named('message_id')();
  IntColumn get committedAt => integer().named('committed_at')();

  @override
  Set<Column> get primaryKey => {scopeUid, deliveryId};
}

@DataClassName('TIMSendStateRow')
class TIMSendStates extends Table {
  @override
  String get tableName => 't_im_send_state';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get messageId => text().named('message_id')();
  TextColumn get transportState => text().named('transport_state')();
  IntColumn get attempt =>
      integer().withDefault(const Constant(0)).named('attempt')();
  IntColumn get retryAtUtcMs => integer().nullable().named('retry_at_utc_ms')();
  TextColumn get lastErrorCode => text().nullable().named('last_error_code')();
  IntColumn get updatedAtUtcMs => integer().named('updated_at_utc_ms')();

  @override
  Set<Column> get primaryKey => {scopeUid, messageId};

  @override
  List<String> get customConstraints => const [
        "CHECK (transport_state IN ('pending', 'uploading', 'accepted', 'failed'))",
      ];
}

@DataClassName('TIMPeerAuthorizationRow')
class TIMPeerAuthorizations extends Table {
  @override
  String get tableName => 't_im_peer_authorization';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get peerDeviceId => text().named('peer_device_id')();
  TextColumn get peerPublicKeyFingerprint => text().named('peer_public_key_fingerprint')();
  TextColumn get accountBindingCertHash => text().named('account_binding_cert_hash')();
  IntColumn get keyEpoch => integer().named('key_epoch')();
  TextColumn get trustState => text().named('trust_state')();
  IntColumn get expiresAtUtcMs => integer().named('expires_at_utc_ms')();

  @override
  Set<Column> get primaryKey => {scopeUid, peerDeviceId};

  @override
  List<String> get customConstraints => const [
        "CHECK (trust_state IN ('active', 'revoked'))",
      ];
}
