import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';

final class FirebasePlaygroundConversationRepository
    implements PlaygroundConversationRepository {
  FirebasePlaygroundConversationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
  })  : _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundIdentityResolver _identityResolver;

  @override
  Future<PlaygroundConversation> sendDmRequest(
      SendDmRequestCommand command) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final user = _auth.currentUser!;

      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.conversations).doc();

      final data = <String, dynamic>{
        'participant_a_provider_uid': user.uid,
        'participant_a_app_user_id': actor.value,
        'participant_b_app_user_id': command.recipientUserId.value,
        'status': PlaygroundConversationStatus.pendingRequest.name,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': null,
        'blocked_by': null,
      };

      await docRef.set(data);

      return PlaygroundConversation(
        id: PlaygroundConversationId(docRef.id),
        participantA: actor,
        participantB: command.recipientUserId,
        status: PlaygroundConversationStatus.pendingRequest,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundConversation> respondDmRequest(
      RespondDmRequestCommand command) async {
    try {
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.conversations)
          .doc(command.conversationId.value);

      final newStatus = command.accept
          ? PlaygroundConversationStatus.active
          : PlaygroundConversationStatus.rejected;

      await docRef.update({
        'status': newStatus.name,
        'updated_at': FieldValue.serverTimestamp(),
      });

      final snap = await docRef.get();
      return _docToConversation(snap.data()!, snap.id);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundDirectMessage> sendMessage(
      SendMessageCommand command) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final user = _auth.currentUser!;

      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.messages).doc();

      final data = <String, dynamic>{
        'conversation_id': command.conversationId.value,
        'sender_provider_uid': user.uid,
        'sender_app_user_id': actor.value,
        'text': command.text,
        'sent_at': FieldValue.serverTimestamp(),
      };

      await docRef.set(data);

      return PlaygroundDirectMessage(
        id: docRef.id,
        conversationId: command.conversationId,
        senderUserId: actor,
        text: command.text,
        sentAt: DateTime.now(),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> blockUser(BlockUserCommand command) async {
    try {
      final user = _auth.currentUser;
      final uid = user?.uid;

      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.conversations)
          .where('participant_a_provider_uid', isEqualTo: uid)
          .get();

      for (final doc in snaps.docs) {
        final d = doc.data();
        if (d['participant_b_app_user_id'] == command.blockedUserId.value) {
          await doc.reference.update({
            'status': PlaygroundConversationStatus.blocked.name,
            'blocked_by': uid,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> unblockUser(PlaygroundUserId blockedUserId) async {
    try {
      final user = _auth.currentUser;
      final uid = user?.uid;

      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.conversations)
          .where('participant_a_provider_uid', isEqualTo: uid)
          .get();

      for (final doc in snaps.docs) {
        final d = doc.data();
        if (d['participant_b_app_user_id'] == blockedUserId.value &&
            d['blocked_by'] == uid) {
          await doc.reference.update({
            'status': PlaygroundConversationStatus.active.name,
            'blocked_by': null,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
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
      final user = _auth.currentUser;
      if (user == null) {
        return PlaygroundPage.empty();
      }

      var q = _firestore
          .collection(PlaygroundFirestoreSchema.conversations)
          .where('participant_a_provider_uid', isEqualTo: user.uid)
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

    return PlaygroundConversation(
      id: PlaygroundConversationId(docId),
      participantA: PlaygroundUserId(
          d['participant_a_app_user_id'] as String? ?? ''),
      participantB: PlaygroundUserId(
          d['participant_b_app_user_id'] as String? ?? ''),
      status: PlaygroundConversationStatus.values
          .byName(d['status'] as String? ?? 'pendingRequest'),
      blockedBy: blockedBy != null ? PlaygroundUserId(blockedBy) : null,
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate(),
    );
  }
}
