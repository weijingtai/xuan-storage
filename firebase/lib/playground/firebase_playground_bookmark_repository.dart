import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';

final class FirebasePlaygroundBookmarkRepository
    implements PlaygroundBookmarkRepository {
  FirebasePlaygroundBookmarkRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
  })  : _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundIdentityResolver _identityResolver;

  String _bookmarkDocId(PlaygroundPostId postId) {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'anonymous';
    return '${uid}_${
        postId.value}';
  }

  @override
  Future<void> setBookmark(SetBookmarkCommand command) async {
    try {
      final docId = _bookmarkDocId(command.postId);
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.bookmarks).doc(docId);

      if (command.bookmarked) {
        final user = _auth.currentUser;
        final actor = await _identityResolver.resolveActor();
        await docRef.set({
          'user_provider_uid': user?.uid,
          'user_app_user_id': actor.value,
          'post_id': command.postId.value,
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<bool> isBookmarked(PlaygroundPostId postId) async {
    try {
      final docId = _bookmarkDocId(postId);
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.bookmarks)
          .doc(docId)
          .get();
      return snap.exists;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getBookmarkedPosts({
    PlaygroundCursor? cursor,
    int limit = 20,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return PlaygroundPage.empty();
      }

      var q = _firestore
          .collection(PlaygroundFirestoreSchema.bookmarks)
          .where('user_provider_uid', isEqualTo: user.uid)
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
      final postIds = snaps.docs
          .map((doc) => PlaygroundPostId(doc.data()['post_id'] as String? ?? ''))
          .toList();

      final posts = <PlaygroundPost>[];
      for (final pid in postIds) {
        final postSnap = await _firestore
            .collection(PlaygroundFirestoreSchema.posts)
            .doc(pid.value)
            .get();
        if (postSnap.exists) {
          posts.add(_docToPost(postSnap.data()!, postSnap.id));
        }
      }

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == limit
          ? FirebasePlaygroundCursor.fromQueryDocument(snaps.docs.last)
          : null;

      return PlaygroundPage(
        items: posts,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  static PlaygroundPost _docToPost(Map<String, dynamic> d, String docId) {
    final timestamp = d['created_at'] as Timestamp?;
    final updatedTs = d['updated_at'] as Timestamp?;
    final appUserId =
        d['author_app_user_id'] as String? ?? d['author_provider_uid'] as String? ?? '';

    return PlaygroundPost(
      id: PlaygroundPostId(docId),
      text: d['text'] as String? ?? '',
      authorUserId: PlaygroundUserId(appUserId),
      status: PlaygroundPostStatus.values
          .byName(d['status'] as String? ?? 'active'),
      allowedChartTechniqueIds:
          (d['allowed_chart_technique_ids'] as List<dynamic>?)
                  ?.cast<String>() ??
              const <String>[],
      attachments: const [],
      revisions: const [],
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate(),
      hasOutcomeFeedback: d['has_outcome_feedback'] as bool? ?? false,
    );
  }
}
