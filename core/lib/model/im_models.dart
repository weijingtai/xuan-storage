import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// Computes the deterministic 1:1 conversation ID for direct messaging between two users.
///
/// Format: `dm_v1_` + sha256(UTF8("dm:v1|" + min(uidA, uidB) + "|" + max(uidA, uidB))).hex
String deriveConversationId(String appUserIdA, String appUserIdB) {
  final cmp = appUserIdA.compareTo(appUserIdB);
  final minUser = cmp <= 0 ? appUserIdA : appUserIdB;
  final maxUser = cmp <= 0 ? appUserIdB : appUserIdA;
  final preimage = 'dm:v1|$minUser|$maxUser';
  final digest = sha256.convert(utf8.encode(preimage)).toString();
  return 'dm_v1_$digest';
}

/// Immutable IM message model for local Drift storage and P2P synchronization.
@immutable
final class TIMMessage {
  const TIMMessage({
    required this.scopeUid,
    required this.messageId,
    required this.conversationId,
    required this.senderAppUserId,
    required this.recipientAppUserId,
    required this.originDeviceId,
    required this.messageType,
    required this.contentJson,
    required this.contentHash,
    this.mediaBlobHash,
    required this.createdHlcPacked,
    required this.createdHlcDeviceId,
    required this.createdAtUtcMs,
  });

  final String scopeUid;
  final String messageId;
  final String conversationId;
  final String senderAppUserId;
  final String recipientAppUserId;
  final String originDeviceId;
  final String messageType;
  final String contentJson;
  final String contentHash;
  final String? mediaBlobHash;
  final int createdHlcPacked;
  final String createdHlcDeviceId;
  final int createdAtUtcMs;

  /// Serializes into RFC 8785 Canonical JSON payload format for oplog distribution.
  /// Keys are strictly sorted, and no transient/delivery ID fields are included.
  String toCanonicalJson() {
    final buffer = StringBuffer();
    buffer.write('{');
    buffer.write('"content_hash":${jsonEncode(contentHash)},');
    buffer.write('"content_json":${jsonEncode(contentJson)},');
    buffer.write('"conversation_id":${jsonEncode(conversationId)},');
    buffer.write('"created_at_utc_ms":$createdAtUtcMs,');
    buffer.write('"created_hlc_device_id":${jsonEncode(createdHlcDeviceId)},');
    buffer.write('"created_hlc_packed":$createdHlcPacked,');
    buffer.write('"media_blob_hash":${mediaBlobHash == null ? 'null' : jsonEncode(mediaBlobHash)},');
    buffer.write('"message_id":${jsonEncode(messageId)},');
    buffer.write('"message_type":${jsonEncode(messageType)},');
    buffer.write('"origin_device_id":${jsonEncode(originDeviceId)},');
    buffer.write('"recipient_app_user_id":${jsonEncode(recipientAppUserId)},');
    buffer.write('"schema_version":1,');
    buffer.write('"sender_app_user_id":${jsonEncode(senderAppUserId)}');
    buffer.write('}');
    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'schema_version': 1,
      'message_id': messageId,
      'conversation_id': conversationId,
      'sender_app_user_id': senderAppUserId,
      'recipient_app_user_id': recipientAppUserId,
      'origin_device_id': originDeviceId,
      'message_type': messageType,
      'content_json': contentJson,
      'content_hash': contentHash,
      'media_blob_hash': mediaBlobHash,
      'created_hlc_packed': createdHlcPacked,
      'created_hlc_device_id': createdHlcDeviceId,
      'created_at_utc_ms': createdAtUtcMs,
    };
  }

  factory TIMMessage.fromJson(Map<String, dynamic> json, {required String scopeUid}) {
    return TIMMessage(
      scopeUid: scopeUid,
      messageId: json['message_id'] as String,
      conversationId: json['conversation_id'] as String,
      senderAppUserId: json['sender_app_user_id'] as String,
      recipientAppUserId: json['recipient_app_user_id'] as String,
      originDeviceId: json['origin_device_id'] as String,
      messageType: json['message_type'] as String,
      contentJson: json['content_json'] as String,
      contentHash: json['content_hash'] as String,
      mediaBlobHash: json['media_blob_hash'] as String?,
      createdHlcPacked: json['created_hlc_packed'] as int,
      createdHlcDeviceId: json['created_hlc_device_id'] as String,
      createdAtUtcMs: json['created_at_utc_ms'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TIMMessage &&
          runtimeType == other.runtimeType &&
          scopeUid == other.scopeUid &&
          messageId == other.messageId &&
          conversationId == other.conversationId &&
          senderAppUserId == other.senderAppUserId &&
          recipientAppUserId == other.recipientAppUserId &&
          originDeviceId == other.originDeviceId &&
          messageType == other.messageType &&
          contentJson == other.contentJson &&
          contentHash == other.contentHash &&
          mediaBlobHash == other.mediaBlobHash &&
          createdHlcPacked == other.createdHlcPacked &&
          createdHlcDeviceId == other.createdHlcDeviceId &&
          createdAtUtcMs == other.createdAtUtcMs;

  @override
  int get hashCode => Object.hash(
        scopeUid,
        messageId,
        conversationId,
        senderAppUserId,
        recipientAppUserId,
        originDeviceId,
        messageType,
        contentJson,
        contentHash,
        mediaBlobHash,
        createdHlcPacked,
        createdHlcDeviceId,
        createdAtUtcMs,
      );

  @override
  String toString() =>
      'TIMMessage(messageId: $messageId, conv: $conversationId, sender: $senderAppUserId, hlc: $createdHlcPacked)';
}

/// Immutable IM conversation model.
@immutable
final class TIMConversation {
  const TIMConversation({
    required this.scopeUid,
    required this.conversationId,
    required this.peerAppUserId,
    required this.peerNicknameSnapshot,
    this.peerAvatarUrlSnapshot,
    this.lastMessageId,
    this.lastMessageHlcPacked,
    this.lastMessageHlcDeviceId,
    this.lastReadHlcPacked,
    this.lastReadHlcDeviceId,
    this.unreadCountCache = 0,
    this.isPinned = false,
    this.isMuted = false,
    required this.settingsHlcPacked,
    required this.settingsHlcDeviceId,
    required this.updatedAtUtcMs,
  });

  final String scopeUid;
  final String conversationId;
  final String peerAppUserId;
  final String peerNicknameSnapshot;
  final String? peerAvatarUrlSnapshot;
  final String? lastMessageId;
  final int? lastMessageHlcPacked;
  final String? lastMessageHlcDeviceId;
  final int? lastReadHlcPacked;
  final String? lastReadHlcDeviceId;
  final int unreadCountCache;
  final bool isPinned;
  final bool isMuted;
  final int settingsHlcPacked;
  final String settingsHlcDeviceId;
  final int updatedAtUtcMs;

  TIMConversation copyWith({
    String? scopeUid,
    String? conversationId,
    String? peerAppUserId,
    String? peerNicknameSnapshot,
    Object? peerAvatarUrlSnapshot = _unset,
    Object? lastMessageId = _unset,
    Object? lastMessageHlcPacked = _unset,
    Object? lastMessageHlcDeviceId = _unset,
    Object? lastReadHlcPacked = _unset,
    Object? lastReadHlcDeviceId = _unset,
    int? unreadCountCache,
    bool? isPinned,
    bool? isMuted,
    int? settingsHlcPacked,
    String? settingsHlcDeviceId,
    int? updatedAtUtcMs,
  }) {
    return TIMConversation(
      scopeUid: scopeUid ?? this.scopeUid,
      conversationId: conversationId ?? this.conversationId,
      peerAppUserId: peerAppUserId ?? this.peerAppUserId,
      peerNicknameSnapshot: peerNicknameSnapshot ?? this.peerNicknameSnapshot,
      peerAvatarUrlSnapshot: identical(peerAvatarUrlSnapshot, _unset)
          ? this.peerAvatarUrlSnapshot
          : peerAvatarUrlSnapshot as String?,
      lastMessageId: identical(lastMessageId, _unset)
          ? this.lastMessageId
          : lastMessageId as String?,
      lastMessageHlcPacked: identical(lastMessageHlcPacked, _unset)
          ? this.lastMessageHlcPacked
          : lastMessageHlcPacked as int?,
      lastMessageHlcDeviceId: identical(lastMessageHlcDeviceId, _unset)
          ? this.lastMessageHlcDeviceId
          : lastMessageHlcDeviceId as String?,
      lastReadHlcPacked: identical(lastReadHlcPacked, _unset)
          ? this.lastReadHlcPacked
          : lastReadHlcPacked as int?,
      lastReadHlcDeviceId: identical(lastReadHlcDeviceId, _unset)
          ? this.lastReadHlcDeviceId
          : lastReadHlcDeviceId as String?,
      unreadCountCache: unreadCountCache ?? this.unreadCountCache,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      settingsHlcPacked: settingsHlcPacked ?? this.settingsHlcPacked,
      settingsHlcDeviceId: settingsHlcDeviceId ?? this.settingsHlcDeviceId,
      updatedAtUtcMs: updatedAtUtcMs ?? this.updatedAtUtcMs,
    );
  }

  static const Object _unset = Object();

  Map<String, dynamic> toJson() => {
        'scope_uid': scopeUid,
        'conversation_id': conversationId,
        'peer_app_user_id': peerAppUserId,
        'peer_nickname_snapshot': peerNicknameSnapshot,
        'peer_avatar_url_snapshot': peerAvatarUrlSnapshot,
        'last_message_id': lastMessageId,
        'last_message_hlc_packed': lastMessageHlcPacked,
        'last_message_hlc_device_id': lastMessageHlcDeviceId,
        'last_read_hlc_packed': lastReadHlcPacked,
        'last_read_hlc_device_id': lastReadHlcDeviceId,
        'unread_count_cache': unreadCountCache,
        'is_pinned': isPinned,
        'is_muted': isMuted,
        'settings_hlc_packed': settingsHlcPacked,
        'settings_hlc_device_id': settingsHlcDeviceId,
        'updated_at_utc_ms': updatedAtUtcMs,
      };

  factory TIMConversation.fromJson(Map<String, dynamic> json) {
    return TIMConversation(
      scopeUid: json['scope_uid'] as String,
      conversationId: json['conversation_id'] as String,
      peerAppUserId: json['peer_app_user_id'] as String,
      peerNicknameSnapshot: json['peer_nickname_snapshot'] as String,
      peerAvatarUrlSnapshot: json['peer_avatar_url_snapshot'] as String?,
      lastMessageId: json['last_message_id'] as String?,
      lastMessageHlcPacked: json['last_message_hlc_packed'] as int?,
      lastMessageHlcDeviceId: json['last_message_hlc_device_id'] as String?,
      lastReadHlcPacked: json['last_read_hlc_packed'] as int?,
      lastReadHlcDeviceId: json['last_read_hlc_device_id'] as String?,
      unreadCountCache: json['unread_count_cache'] as int? ?? 0,
      isPinned: json['is_pinned'] as bool? ?? false,
      isMuted: json['is_muted'] as bool? ?? false,
      settingsHlcPacked: json['settings_hlc_packed'] as int,
      settingsHlcDeviceId: json['settings_hlc_device_id'] as String,
      updatedAtUtcMs: json['updated_at_utc_ms'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TIMConversation &&
          runtimeType == other.runtimeType &&
          scopeUid == other.scopeUid &&
          conversationId == other.conversationId &&
          peerAppUserId == other.peerAppUserId &&
          peerNicknameSnapshot == other.peerNicknameSnapshot &&
          peerAvatarUrlSnapshot == other.peerAvatarUrlSnapshot &&
          lastMessageId == other.lastMessageId &&
          lastMessageHlcPacked == other.lastMessageHlcPacked &&
          lastMessageHlcDeviceId == other.lastMessageHlcDeviceId &&
          lastReadHlcPacked == other.lastReadHlcPacked &&
          lastReadHlcDeviceId == other.lastReadHlcDeviceId &&
          unreadCountCache == other.unreadCountCache &&
          isPinned == other.isPinned &&
          isMuted == other.isMuted &&
          settingsHlcPacked == other.settingsHlcPacked &&
          settingsHlcDeviceId == other.settingsHlcDeviceId &&
          updatedAtUtcMs == other.updatedAtUtcMs;

  @override
  int get hashCode => Object.hash(
        scopeUid,
        conversationId,
        peerAppUserId,
        peerNicknameSnapshot,
        peerAvatarUrlSnapshot,
        lastMessageId,
        lastMessageHlcPacked,
        lastMessageHlcDeviceId,
        lastReadHlcPacked,
        lastReadHlcDeviceId,
        unreadCountCache,
        isPinned,
        isMuted,
        settingsHlcPacked,
        settingsHlcDeviceId,
        updatedAtUtcMs,
      );

  @override
  String toString() =>
      'TIMConversation(convId: $conversationId, peer: $peerAppUserId, unread: $unreadCountCache)';
}

/// Message Tombstone representing soft-delete in local database and P2P reconciliation.
@immutable
final class TIMMessageTombstone {
  const TIMMessageTombstone({
    required this.scopeUid,
    required this.messageId,
    required this.deleteHlcPacked,
    required this.deleteHlcDeviceId,
    this.reason,
  });

  final String scopeUid;
  final String messageId;
  final int deleteHlcPacked;
  final String deleteHlcDeviceId;
  final String? reason;

  Map<String, dynamic> toJson() => {
        'schema_version': 1,
        'scope_uid': scopeUid,
        'message_id': messageId,
        'delete_hlc_packed': deleteHlcPacked,
        'delete_hlc_device_id': deleteHlcDeviceId,
        'reason': reason,
      };

  String toCanonicalJson() {
    final buffer = StringBuffer();
    buffer.write('{');
    buffer.write('"delete_hlc_device_id":${jsonEncode(deleteHlcDeviceId)},');
    buffer.write('"delete_hlc_packed":$deleteHlcPacked,');
    buffer.write('"message_id":${jsonEncode(messageId)},');
    buffer.write('"reason":${reason == null ? 'null' : jsonEncode(reason)},');
    buffer.write('"schema_version":1,');
    buffer.write('"scope_uid":${jsonEncode(scopeUid)}');
    buffer.write('}');
    return buffer.toString();
  }

  factory TIMMessageTombstone.fromJson(Map<String, dynamic> json) => TIMMessageTombstone(
        scopeUid: json['scope_uid'] as String,
        messageId: json['message_id'] as String,
        deleteHlcPacked: json['delete_hlc_packed'] as int,
        deleteHlcDeviceId: json['delete_hlc_device_id'] as String,
        reason: json['reason'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TIMMessageTombstone &&
          runtimeType == other.runtimeType &&
          scopeUid == other.scopeUid &&
          messageId == other.messageId &&
          deleteHlcPacked == other.deleteHlcPacked &&
          deleteHlcDeviceId == other.deleteHlcDeviceId &&
          reason == other.reason;

  @override
  int get hashCode => Object.hash(scopeUid, messageId, deleteHlcPacked, deleteHlcDeviceId, reason);
}

/// Message delivery/read receipt fact.
@immutable
final class TIMMessageReceipt {
  const TIMMessageReceipt({
    required this.scopeUid,
    required this.messageId,
    required this.recipientAppUserId,
    required this.recipientDeviceId,
    required this.receiptType,
    required this.receiptHlcPacked,
    required this.receiptHlcDeviceId,
  });

  final String scopeUid;
  final String messageId;
  final String recipientAppUserId;
  final String recipientDeviceId;
  final String receiptType; // 'delivered' | 'read'
  final int receiptHlcPacked;
  final String receiptHlcDeviceId;

  bool get isValidReceiptType => receiptType == 'delivered' || receiptType == 'read';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TIMMessageReceipt &&
          runtimeType == other.runtimeType &&
          scopeUid == other.scopeUid &&
          messageId == other.messageId &&
          recipientAppUserId == other.recipientAppUserId &&
          recipientDeviceId == other.recipientDeviceId &&
          receiptType == other.receiptType &&
          receiptHlcPacked == other.receiptHlcPacked &&
          receiptHlcDeviceId == other.receiptHlcDeviceId;

  @override
  int get hashCode => Object.hash(
        scopeUid,
        messageId,
        recipientAppUserId,
        recipientDeviceId,
        receiptType,
        receiptHlcPacked,
        receiptHlcDeviceId,
      );
}

/// Dedup fact for envelopes to prevent replay/tampering.
@immutable
final class TIMEnvelopeDedup {
  const TIMEnvelopeDedup({
    required this.scopeUid,
    required this.envelopeId,
    required this.messageId,
    required this.ciphertextHash,
    required this.committedAtUtcMs,
  });

  final String scopeUid;
  final String envelopeId;
  final String messageId;
  final String ciphertextHash;
  final int committedAtUtcMs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TIMEnvelopeDedup &&
          runtimeType == other.runtimeType &&
          scopeUid == other.scopeUid &&
          envelopeId == other.envelopeId &&
          messageId == other.messageId &&
          ciphertextHash == other.ciphertextHash &&
          committedAtUtcMs == other.committedAtUtcMs;

  @override
  int get hashCode => Object.hash(scopeUid, envelopeId, messageId, ciphertextHash, committedAtUtcMs);
}

/// Incoming delivery record fact.
@immutable
final class IncomingDeliveryFact {
  const IncomingDeliveryFact({
    required this.scopeUid,
    required this.deliveryId,
    required this.envelopeId,
    required this.messageId,
    required this.committedAtUtcMs,
  });

  final String scopeUid;
  final String deliveryId;
  final String envelopeId;
  final String messageId;
  final int committedAtUtcMs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomingDeliveryFact &&
          runtimeType == other.runtimeType &&
          scopeUid == other.scopeUid &&
          deliveryId == other.deliveryId &&
          envelopeId == other.envelopeId &&
          messageId == other.messageId &&
          committedAtUtcMs == other.committedAtUtcMs;

  @override
  int get hashCode => Object.hash(scopeUid, deliveryId, envelopeId, messageId, committedAtUtcMs);
}

/// Outgoing message send state tracking.
@immutable
final class TIMSendState {
  const TIMSendState({
    required this.scopeUid,
    required this.messageId,
    required this.transportState,
    this.attempt = 0,
    this.retryAtUtcMs,
    this.lastErrorCode,
    required this.updatedAtUtcMs,
  });

  final String scopeUid;
  final String messageId;
  final String transportState; // 'pending' | 'uploading' | 'accepted' | 'failed'
  final int attempt;
  final int? retryAtUtcMs;
  final String? lastErrorCode;
  final int updatedAtUtcMs;

  bool get isValidTransportState =>
      transportState == 'pending' ||
      transportState == 'uploading' ||
      transportState == 'accepted' ||
      transportState == 'failed';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TIMSendState &&
          runtimeType == other.runtimeType &&
          scopeUid == other.scopeUid &&
          messageId == other.messageId &&
          transportState == other.transportState &&
          attempt == other.attempt &&
          retryAtUtcMs == other.retryAtUtcMs &&
          lastErrorCode == other.lastErrorCode &&
          updatedAtUtcMs == other.updatedAtUtcMs;

  @override
  int get hashCode => Object.hash(
        scopeUid,
        messageId,
        transportState,
        attempt,
        retryAtUtcMs,
        lastErrorCode,
        updatedAtUtcMs,
      );
}

/// Peer authorization record for same-account device trust validation.
@immutable
final class TIMPeerAuthorization {
  const TIMPeerAuthorization({
    required this.scopeUid,
    required this.peerDeviceId,
    required this.peerPublicKeyFingerprint,
    required this.accountBindingCertHash,
    required this.keyEpoch,
    required this.trustState,
    required this.expiresAtUtcMs,
  });

  final String scopeUid;
  final String peerDeviceId;
  final String peerPublicKeyFingerprint;
  final String accountBindingCertHash;
  final int keyEpoch;
  final String trustState; // 'active' | 'revoked'
  final int expiresAtUtcMs;

  bool get isValidTrustState => trustState == 'active' || trustState == 'revoked';
  bool get isTrusted => trustState == 'active';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TIMPeerAuthorization &&
          runtimeType == other.runtimeType &&
          scopeUid == other.scopeUid &&
          peerDeviceId == other.peerDeviceId &&
          peerPublicKeyFingerprint == other.peerPublicKeyFingerprint &&
          accountBindingCertHash == other.accountBindingCertHash &&
          keyEpoch == other.keyEpoch &&
          trustState == other.trustState &&
          expiresAtUtcMs == other.expiresAtUtcMs;

  @override
  int get hashCode => Object.hash(
        scopeUid,
        peerDeviceId,
        peerPublicKeyFingerprint,
        accountBindingCertHash,
        keyEpoch,
        trustState,
        expiresAtUtcMs,
      );
}
