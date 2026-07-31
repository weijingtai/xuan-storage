import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class FirebasePlaygroundEventMapper {
  FirebasePlaygroundEventMapper._();

  static PlaygroundRealtimeEvent postEvent(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final type = snap.exists
        ? PlaygroundEventType.upsert
        : PlaygroundEventType.tombstone;
    return PlaygroundRealtimeEvent(
      type: type,
      resourceType: PlaygroundResourceType.post,
      resourceId: snap.id,
      payload: snap.exists ? snap.data() : null,
    );
  }

  static PlaygroundRealtimeEvent? replyEvent(DocumentChange<Map<String, dynamic>> change) {
    final snap = change.doc;
    switch (change.type) {
      case DocumentChangeType.added:
      case DocumentChangeType.modified:
        return PlaygroundRealtimeEvent(
          type: PlaygroundEventType.upsert,
          resourceType: PlaygroundResourceType.reply,
          resourceId: snap.id,
          payload: snap.data(),
        );
      case DocumentChangeType.removed:
        return PlaygroundRealtimeEvent(
          type: PlaygroundEventType.tombstone,
          resourceType: PlaygroundResourceType.reply,
          resourceId: snap.id,
        );
    }
  }

  static PlaygroundRealtimeEvent? notificationEvent(
      DocumentChange<Map<String, dynamic>> change) {
    final snap = change.doc;
    switch (change.type) {
      case DocumentChangeType.added:
        return PlaygroundRealtimeEvent(
          type: PlaygroundEventType.upsert,
          resourceType: PlaygroundResourceType.notification,
          resourceId: snap.id,
          payload: snap.data(),
        );
      case DocumentChangeType.modified:
        return PlaygroundRealtimeEvent(
          type: PlaygroundEventType.relationshipChange,
          resourceType: PlaygroundResourceType.notification,
          resourceId: snap.id,
          payload: snap.data(),
        );
      case DocumentChangeType.removed:
        return PlaygroundRealtimeEvent(
          type: PlaygroundEventType.tombstone,
          resourceType: PlaygroundResourceType.notification,
          resourceId: snap.id,
        );
    }
  }

  static PlaygroundRealtimeEvent? messageEvent(
      DocumentChange<Map<String, dynamic>> change) {
    final snap = change.doc;
    switch (change.type) {
      case DocumentChangeType.added:
        return PlaygroundRealtimeEvent(
          type: PlaygroundEventType.upsert,
          resourceType: PlaygroundResourceType.conversation,
          resourceId: snap.id,
          payload: snap.data(),
        );
      case DocumentChangeType.modified:
        return PlaygroundRealtimeEvent(
          type: PlaygroundEventType.relationshipChange,
          resourceType: PlaygroundResourceType.conversation,
          resourceId: snap.id,
        );
      case DocumentChangeType.removed:
        return PlaygroundRealtimeEvent(
          type: PlaygroundEventType.tombstone,
          resourceType: PlaygroundResourceType.conversation,
          resourceId: snap.id,
        );
    }
  }
}
