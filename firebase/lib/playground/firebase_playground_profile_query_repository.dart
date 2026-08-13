import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_cursor.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_public_mapper.dart';
import 'firebase_playground_schema.dart';

/// Firebase implementation of the current-actor profile query port.
///
/// Public profile lookups accept a presentation user ID. Mutations and private
/// technique statistics resolve their actor from the authenticated session; no
/// caller-supplied user ID can influence those operations.
final class FirebasePlaygroundProfileQueryRepository
    implements PlaygroundProfileQueryRepository {
  FirebasePlaygroundProfileQueryRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required Future<PlaygroundUserId> Function() resolveCurrentActor,
    FirebaseFunctions? functions,
  }) : _firestore = firestore,
       _resolveCurrentActor = resolveCurrentActor,
       _functions = functions ?? FirebaseFunctions.instance,
       _mapper = FirebasePlaygroundPublicMapper(
         firestore: firestore,
         auth: auth,
       );

  final FirebaseFirestore _firestore;
  final Future<PlaygroundUserId> Function() _resolveCurrentActor;
  final FirebaseFunctions _functions;
  final FirebasePlaygroundPublicMapper _mapper;

  @override
  Future<PlaygroundProfile> getPublicProfile(PlaygroundUserId userId) async {
    try {
      final snap = await _profiles.doc(userId.value).get();
      if (!snap.exists) {
        return PlaygroundProfile(
          userId: userId,
          displayName: 'User_${userId.value}',
        );
      }
      return _profileFromDoc(userId, snap.data()!);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> updateMyProfile(UpdateMyProfileCommand command) async {
    try {
      final updates = <String, dynamic>{};
      if (command.displayName != null) {
        updates['displayName'] = command.displayName;
      }
      if (command.avatarUrl != null) updates['avatarUrl'] = command.avatarUrl;
      if (command.bio != null) updates['bio'] = command.bio;
      if (command.commonTechniques != null) {
        updates['commonTechniques'] = command.commonTechniques;
      }
      if (command.idempotencyKey != null) {
        updates['idempotency_key'] = command.idempotencyKey;
      }
      if (updates.isEmpty) return;

      await _functions.httpsCallable('updateMyProfile').call(updates);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<List<PlaygroundPrivateTechniqueStats>>
  getMyPrivateTechniqueStats() async {
    try {
      final actor = await _resolveCurrentActor();
      final snap = await _profiles.doc(actor.value).get();
      final techniques =
          (snap.data()?['common_techniques'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const <String>[];
      return techniques
          .map(
            (techniqueId) => PlaygroundPrivateTechniqueStats(
              userId: actor,
              techniqueId: techniqueId,
            ),
          )
          .toList();
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<PublicPost>> getPublicProfilePosts(
    GetPublicProfilePostsQuery query,
  ) async {
    try {
      var firestoreQuery = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .where('author_app_user_id', isEqualTo: query.userId.value)
          .where('status', isEqualTo: PlaygroundPostStatus.active.name)
          .where(
            'presentation_mode',
            isEqualTo: PlaygroundPresentationMode.stableAlias.name,
          )
          .orderBy('created_at', descending: true)
          .limit(query.limit);
      firestoreQuery = _applyCursor(firestoreQuery, query.cursor);
      final snaps = await firestoreQuery.get();

      final posts = <PublicPost>[];
      for (final doc in snaps.docs) {
        final data = doc.data();
        final viewerState = await _mapper.viewerStateForPost(doc.id, data);
        posts.add(
          _mapper.publicPostFromDoc(
            doc.id,
            data,
            replyCount: await _replyCount(doc.id),
            likeCount: await _likeCount(doc.id),
            verificationCount: await _verificationCount(doc.id),
            viewerState: viewerState,
            presentationMode:
                FirebasePlaygroundPublicMapper.presentationModeFromDoc(data),
          ),
        );
      }
      return _page(posts, snaps.docs, query.limit);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<PublicReply>> getPublicProfileReplies(
    GetPublicProfileRepliesQuery query,
  ) async {
    try {
      var firestoreQuery = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .where('author_app_user_id', isEqualTo: query.userId.value)
          .orderBy('created_at', descending: true)
          .limit(query.limit);
      firestoreQuery = _applyCursor(firestoreQuery, query.cursor);
      final snaps = await firestoreQuery.get();
      final replies = snaps.docs
          .map((doc) => _mapper.publicReplyFromDoc(doc.id, doc.data()))
          .toList();
      return _page(replies, snaps.docs, query.limit);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection(PlaygroundFirestoreSchema.profiles);

  Query<Map<String, dynamic>> _applyCursor(
    Query<Map<String, dynamic>> query,
    PlaygroundCursor? cursor,
  ) {
    if (cursor == null || cursor.isEmpty) return query;
    final start = FirebasePlaygroundCursor.toStartAfterValues(cursor);
    return start == null ? query : query.startAfter(start);
  }

  PlaygroundPage<T> _page<T>(
    List<T> items,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    int limit,
  ) {
    final nextCursor = docs.length == limit && docs.isNotEmpty
        ? FirebasePlaygroundCursor.fromQueryDocumentWithOrderBy(
            docs.last,
            const ['created_at'],
          )
        : null;
    return PlaygroundPage(
      items: items,
      nextCursor: nextCursor,
      hasMore: nextCursor != null,
      totalCount: -1,
    );
  }

  PlaygroundProfile _profileFromDoc(
    PlaygroundUserId userId,
    Map<String, dynamic> data,
  ) => PlaygroundProfile(
    userId: userId,
    displayName: data['display_name'] as String? ?? 'User_${userId.value}',
    avatarUrl: data['avatar_url'] as String?,
    bio: data['bio'] as String?,
    commonTechniques:
        (data['common_techniques'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const [],
    publicPostCount: data['public_post_count'] as int? ?? 0,
    publicReplyCount: data['public_reply_count'] as int? ?? 0,
    playgroundVerificationCount:
        data['playground_verification_count'] as int? ?? 0,
    playgroundLikeCount: data['playground_like_count'] as int? ?? 0,
  );

  Future<int> _replyCount(String postId) async =>
      (await _firestore
              .collection(PlaygroundFirestoreSchema.replies)
              .where('post_id', isEqualTo: postId)
              .where('is_tombstoned', isEqualTo: false)
              .get())
          .docs
          .length;

  Future<int> _likeCount(String postId) async =>
      (await _firestore
              .collection(PlaygroundFirestoreSchema.likes)
              .where('post_id', isEqualTo: postId)
              .get())
          .docs
          .length;

  Future<int> _verificationCount(String postId) async =>
      (await _firestore
              .collection(PlaygroundFirestoreSchema.verifications)
              .where('post_id', isEqualTo: postId)
              .where('revoked_at', isNull: true)
              .get())
          .docs
          .length;
}
