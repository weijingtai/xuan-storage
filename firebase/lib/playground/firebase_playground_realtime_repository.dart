import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_event_mapper.dart';

final class FirebasePlaygroundRealtimeRepository
    implements PlaygroundRealtimeRepository {
  FirebasePlaygroundRealtimeRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<PlaygroundRealtimeEvent> watchPostThread(
      PlaygroundPostId postId) {
    final postsStream = _firestore
        .collection(PlaygroundFirestoreSchema.posts)
        .doc(postId.value)
        .snapshots()
        .map((snap) => FirebasePlaygroundEventMapper.postEvent(snap));

    final repliesStream = _firestore
        .collection(PlaygroundFirestoreSchema.replies)
        .where('post_id', isEqualTo: postId.value)
        .snapshots()
        .expand((snap) sync* {
          for (final doc in snap.docChanges) {
            final event =
                FirebasePlaygroundEventMapper.replyEvent(doc);
            if (event != null) yield event;
          }
        });

    return StreamGroup.merge([postsStream, repliesStream]);
  }

  @override
  Stream<PlaygroundRealtimeEvent> watchNotifications(
      PlaygroundUserId userId) {
    return _firestore
        .collection(PlaygroundFirestoreSchema.notifications)
        .where('recipient_app_user_id', isEqualTo: userId.value)
        .snapshots()
        .expand((snap) sync* {
          for (final doc in snap.docChanges) {
            final event =
                FirebasePlaygroundEventMapper.notificationEvent(doc);
            if (event != null) yield event;
          }
        });
  }

  @override
  Stream<PlaygroundRealtimeEvent> watchConversation(
      PlaygroundConversationId conversationId) {
    return _firestore
        .collection(PlaygroundFirestoreSchema.messages)
        .where('conversation_id',
            isEqualTo: conversationId.value)
        .orderBy('sent_at', descending: false)
        .snapshots()
        .expand((snap) sync* {
          for (final doc in snap.docChanges) {
            final event =
                FirebasePlaygroundEventMapper.messageEvent(doc);
            if (event != null) yield event;
          }
        });
  }
}

class StreamGroup {
  static Stream<T> merge<T>(Iterable<Stream<T>> streams) {
    if (streams.isEmpty) return const Stream.empty();
    if (streams.length == 1) return streams.first;

    final controller = StreamController<T>();
    var subscriptions = <StreamSubscription<T>>[];
    var completedCount = 0;
    final totalCount = streams.length;

    for (final stream in streams) {
      final sub = stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: () {
          completedCount++;
          if (completedCount == totalCount) {
            controller.close();
          }
        },
      );
      subscriptions.add(sub);
    }

    controller.onCancel = () {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    };

    return controller.stream;
  }
}
