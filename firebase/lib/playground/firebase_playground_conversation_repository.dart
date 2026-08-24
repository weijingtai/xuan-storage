import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';

@Deprecated('Firestore Realtime 方案成本过高，用户 2026-08-23 裁决弃用：改用自研后端（xuan-server/notifier，Go + Centrifugo SSE）')
final class FirebasePlaygroundConversationRepository
    implements PlaygroundConversationRepository {
  FirebasePlaygroundConversationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundIdentityResolver _identityResolver;
  final FirebaseFunctions _functions;

  @override
  Future<PlaygroundConversation> sendDmRequest(
      SendDmRequestCommand command) async {
    try {
      // BLOCK-01：敏感写走受信 Functions `sendDmRequest`。
      // 客户端只传业务参数 + idempotency_key；actor 来自 Auth context。
      final actor = await _identityResolver.resolveActor();
      final params = <String, dynamic>{
        'targetAppUserId': command.recipientUserId.value,
        if (command.initialMessage != null)
          'initialMessage': command.initialMessage,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      final result = await _functions
          .httpsCallable('sendDmRequest')
          .call<Map<String, dynamic>>(params);
      final data = result.data;

      return PlaygroundConversation(
        id: PlaygroundConversationId(data['conversation_id'] as String? ?? ''),
        participantA: actor,
        participantB: command.recipientUserId,
        status: _statusFromCallable(data['status'] as String?),
        createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundConversation> respondDmRequest(
      RespondDmRequestCommand command) async {
    try {
      // BLOCK-01：敏感写走受信 Functions `respondDmRequest`。
      // 返回值只用 callable 响应 + resolveMyIdentity，禁止直读 conversations。
      final actor = await _identityResolver.resolveActor();
      final params = <String, dynamic>{
        'conversationId': command.conversationId.value,
        'accept': command.accept,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      final result = await _functions
          .httpsCallable('respondDmRequest')
          .call<Map<String, dynamic>>(params);
      final data = result.data;

      final participants = (data['participants'] as List<dynamic>? ?? [])
          .cast<String>();
      final participantA = participants.isNotEmpty
          ? PlaygroundUserId(participants[0])
          : actor;
      final participantB = participants.length > 1
          ? PlaygroundUserId(participants[1])
          : actor;

      return PlaygroundConversation(
        id: PlaygroundConversationId(
            data['conversation_id'] as String? ?? command.conversationId.value),
        participantA: participantA,
        participantB: participantB,
        status: _statusFromCallable(data['status'] as String?),
        createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundDirectMessage> sendMessage(
      SendMessageCommand command) async {
    try {
      // BLOCK-01：敏感写走受信 Functions `sendMessage`。
      final actor = await _identityResolver.resolveActor();
      final params = <String, dynamic>{
        'conversationId': command.conversationId.value,
        'text': command.text,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      final result = await _functions
          .httpsCallable('sendMessage')
          .call<Map<String, dynamic>>(params);
      final data = result.data;

      final senderId = data['sender_app_user_id'] as String? ?? '';
      return PlaygroundDirectMessage(
        id: data['message_id'] as String? ?? '',
        conversationId: command.conversationId,
        senderUserId: senderId.isEmpty ? actor : PlaygroundUserId(senderId),
        text: data['text'] as String? ?? command.text,
        sentAt: _parseDate(data['created_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> blockUser(BlockUserCommand command) async {
    try {
      // BLOCK-01：敏感写走受信 Functions `blockUser`。
      final params = <String, dynamic>{
        'targetAppUserId': command.blockedUserId.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      await _functions.httpsCallable('blockUser').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> unblockUser(PlaygroundUserId blockedUserId) async {
    try {
      // BLOCK-01：敏感写走受信 Functions `unblockUser`。
      final params = <String, dynamic>{
        'targetAppUserId': blockedUserId.value,
      };
      await _functions.httpsCallable('unblockUser').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<PlaygroundConversation>> getConversations({
    PlaygroundCursor? cursor,
    int limit = 20,
  }) async {
    try {
      // 读路径保持直连（Rules read 允许）。
      if (_auth.currentUser == null) {
        return PlaygroundPage.empty();
      }
      final actor = await _identityResolver.resolveActor();

      var q = _firestore
          .collection(PlaygroundFirestoreSchema.conversations)
          .where('participants', arrayContains: actor.value)
          .orderBy('updated_at', descending: true)
          .limit(limit);

      if (cursor != null && cursor.isNotEmpty) {
        final startDoc =
            FirebasePlaygroundCursor.toDocumentReference(cursor, _firestore);
        if (startDoc != null) {
          final startSnap = await startDoc.get();
          q = q.startAfterDocument(startSnap);
        }
      }

      final snaps = await q.get();
      final items = snaps.docs.map((doc) {
        return _docToConversation(doc.data(), doc.id);
      }).toList();

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == limit
          ? FirebasePlaygroundCursor.fromQueryDocument(snaps.docs.last)
          : null;

      return PlaygroundPage(
        items: items,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<PlaygroundDirectMessage>> getMessages(
    PlaygroundConversationId conversationId, {
    PlaygroundCursor? cursor,
    int limit = 50,
  }) async {
    try {
      // 读路径保持直连（Rules read 允许）。
      var q = _firestore
          .collection(PlaygroundFirestoreSchema.messages)
          .where('conversation_id',
              isEqualTo: conversationId.value)
          .orderBy('sent_at', descending: false)
          .limit(limit);

      if (cursor != null && cursor.isNotEmpty) {
        final startDoc =
            FirebasePlaygroundCursor.toDocumentReference(cursor, _firestore);
        if (startDoc != null) {
          final startSnap = await startDoc.get();
          q = q.startAfterDocument(startSnap);
        }
      }

      final snaps = await q.get();
      final items = snaps.docs.map((doc) {
        final d = doc.data();
        final sentAt = d['sent_at'] as Timestamp?;
        return PlaygroundDirectMessage(
          id: doc.id,
          conversationId: PlaygroundConversationId(
              d['conversation_id'] as String? ?? ''),
          senderUserId: PlaygroundUserId(
              d['sender_app_user_id'] as String? ?? ''),
          text: d['text'] as String? ?? '',
          sentAt: sentAt?.toDate() ?? DateTime.now(),
        );
      }).toList();

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == limit
          ? FirebasePlaygroundCursor.fromQueryDocument(snaps.docs.last)
          : null;

      return PlaygroundPage(
        items: items,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  PlaygroundConversation _docToConversation(
      Map<String, dynamic> d, String docId) {
    final timestamp = d['created_at'] as Timestamp?;
    final updatedTs = d['updated_at'] as Timestamp?;
    final blockedBy = d['blocked_by'] as String?;
    final participants = (d['participants'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false);

    return PlaygroundConversation(
      id: PlaygroundConversationId(docId),
      participantA: PlaygroundUserId(
          d['participant_a_app_user_id'] as String? ??
              (participants.isNotEmpty ? participants.first : '')),
      participantB: PlaygroundUserId(
          d['participant_b_app_user_id'] as String? ??
              (participants.length > 1 ? participants[1] : '')),
      status: PlaygroundConversationStatus.values
          .byName(d['status'] as String? ?? 'pendingRequest'),
      blockedBy: blockedBy != null ? PlaygroundUserId(blockedBy) : null,
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate(),
    );
  }

  static PlaygroundConversationStatus _statusFromCallable(String? status) {
    return switch (status) {
      'active' => PlaygroundConversationStatus.active,
      'declined' => PlaygroundConversationStatus.rejected,
      'blocked' => PlaygroundConversationStatus.blocked,
      _ => PlaygroundConversationStatus.pendingRequest,
    };
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    if (raw is DateTime) {
      return raw;
    }
    return null;
  }
}
