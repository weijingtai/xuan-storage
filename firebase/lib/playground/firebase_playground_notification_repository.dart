import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';

final class FirebasePlaygroundNotificationRepository
    implements PlaygroundNotificationRepository {
  FirebasePlaygroundNotificationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
  })  : _firestore = firestore,
        _identityResolver = identityResolver;

  final FirebaseFirestore _firestore;
  final FirebasePlaygroundIdentityResolver _identityResolver;

  @override
  Future<PlaygroundPage<PlaygroundNotification>> getNotifications({
    PlaygroundCursor? cursor,
    int limit = 20,
  }) async {
    try {
      final actor = await _identityResolver.resolveActor();

      var q = _firestore
          .collection(PlaygroundFirestoreSchema.notifications)
          .where('recipient_app_user_id', isEqualTo: actor.value)
          .orderBy('created_at', descending: true)
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
        return _docToNotification(d, doc.id);
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
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(PlaygroundFirestoreSchema.notifications)
          .doc(notificationId)
          .update({'is_read': true});
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final actor = await _identityResolver.resolveActor();
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.notifications)
          .where('recipient_app_user_id', isEqualTo: actor.value)
          .where('is_read', isEqualTo: false)
          .get();

      for (final doc in snaps.docs) {
        await doc.reference.update({'is_read': true});
      }
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final actor = await _identityResolver.resolveActor();
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.notifications)
          .where('recipient_app_user_id', isEqualTo: actor.value)
          .where('is_read', isEqualTo: false)
          .get();

      return snaps.docs.length;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundNotificationPreferences> getPreferences(
      PlaygroundUserId userId) async {
    try {
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.profiles)
          .doc(userId.value)
          .get();

      if (!snap.exists || snap.data()?['notification_prefs'] == null) {
        return PlaygroundNotificationPreferences(userId: userId);
      }

      final prefs = snap.data()!['notification_prefs'] as Map<String, dynamic>;
      final enabledCategories = (prefs['enabled_categories'] as List<dynamic>?)
              ?.map((c) =>
                  PlaygroundNotificationCategory.values.byName(c as String))
              .toSet() ??
          const <PlaygroundNotificationCategory>{};

      return PlaygroundNotificationPreferences(
        userId: userId,
        enabledCategories: enabledCategories,
        pushEnabled: prefs['push_enabled'] as bool? ?? true,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> updatePreferences(
      PlaygroundNotificationPreferences preferences) async {
    try {
      final prefsMap = {
        'enabled_categories': preferences.enabledCategories
            .map((c) => c.name)
            .toList(),
        'push_enabled': preferences.pushEnabled,
      };

      await _firestore
          .collection(PlaygroundFirestoreSchema.profiles)
          .doc(preferences.userId.value)
          .set({
        'notification_prefs': prefsMap,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  PlaygroundNotification _docToNotification(Map<String, dynamic> d, String docId) {
    final timestamp = d['created_at'] as Timestamp?;
    final sourcePost = d['source_post_id'] as String?;
    final sourceReply = d['source_reply_id'] as String?;

    return PlaygroundNotification(
      id: docId,
      recipientUserId: PlaygroundUserId(
          d['recipient_app_user_id'] as String? ?? ''),
      actorUserId: d['actor_app_user_id'] != null
          ? PlaygroundUserId(d['actor_app_user_id'] as String)
          : null,
      category: PlaygroundNotificationCategory.values
          .byName(d['category'] as String? ?? 'reply'),
      title: d['title'] as String?,
      body: d['body'] as String?,
      sourcePostId:
          sourcePost != null ? PlaygroundPostId(sourcePost) : null,
      sourceReplyId:
          sourceReply != null ? PlaygroundReplyId(sourceReply) : null,
      isRead: d['is_read'] as bool? ?? false,
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }
}
