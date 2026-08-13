import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';
import 'firebase_playground_public_mapper.dart';

/// Phase 7B：互动端口 adapter（PlaygroundEngagementRepository）。
///
/// - setContentLike/setBookmark 走既有受信 callable（setLike / setBookmark），
///   客户端只传业务参数 + idempotency_key（like），**零可伪造身份字段**；
/// - getViewerState / getMyBookmarkedPosts 直连读（likes/bookmarks 集合
///   Rules 认证可见），映射安全公开投影。
final class FirebasePlaygroundEngagementRepository
    implements PlaygroundEngagementRepository {
  FirebasePlaygroundEngagementRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _auth = auth,
        _functions = functions ?? FirebaseFunctions.instance,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final FirebasePlaygroundPublicMapper _mapper;

  @override
  Future<void> setContentLike(SetContentLikeCommand command) async {
    try {
      final params = <String, dynamic>{};
      switch (command.target) {
        case PostTarget(:final id):
          params['postId'] = id.value;
        case ReplyTarget(:final id):
          params['replyId'] = id.value;
        case ProfileTarget() ||
              ConversationTarget() ||
              MessageTarget() ||
              MediaTarget():
          throw const PlaygroundError(
            code: PlaygroundErrorCode.invalidArgument,
            message: '仅 Post|Reply 可被点赞',
            machineCode: 'engagement/like-target-invalid',
          );
      }
      params['action'] = command.liked ? 'like' : 'unlike';
      if (command.idempotencyKey != null) {
        params['idempotency_key'] = command.idempotencyKey;
      }

      await _functions.httpsCallable('setLike').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> setBookmark(SetBookmarkCommand command) async {
    try {
      // Functions `setBookmark` 只接收 postId + action（bookmark/unbookmark），
      // 无 idempotency 支持；客户端不传可伪造身份字段。
      final params = <String, dynamic>{
        'postId': command.postId.value,
        'action': command.bookmarked ? 'bookmark' : 'unbookmark',
      };
      await _functions.httpsCallable('setBookmark').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPostViewerState> getViewerState(
      PlaygroundContentTarget target) async {
    try {
      switch (target) {
        case PostTarget(:final id):
          final postSnap = await _firestore
              .collection(PlaygroundFirestoreSchema.posts)
              .doc(id.value)
              .get();
          final postData = postSnap.data() ?? const <String, dynamic>{};
          return _mapper.viewerStateForPost(id.value, postData);
        case ReplyTarget(:final id):
          return _mapper.viewerStateForReply(id.value);
        case ProfileTarget() ||
              ConversationTarget() ||
              MessageTarget() ||
              MediaTarget():
          return const PlaygroundPostViewerState();
      }
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<PublicPost>> getMyBookmarkedPosts({
    PlaygroundCursor? cursor,
    int limit = 20,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return PlaygroundPage.empty();

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
      final items = <PublicPost>[];
      for (final snap in snaps.docs) {
        final postId = snap.data()['post_id'] as String? ?? '';
        if (postId.isEmpty) continue;
        final postSnap = await _firestore
            .collection(PlaygroundFirestoreSchema.posts)
            .doc(postId)
            .get();
        if (postSnap.exists) {
          final data = postSnap.data()!;
          items.add(_mapper.publicPostFromDoc(
            postId,
            data,
            replyCount: 0,
            likeCount: 0,
            verificationCount: 0,
            viewerState: const PlaygroundPostViewerState(isBookmarked: true),
          ));
        } else {
          // 收藏但底层帖子不可用：返回安全 tombstone 投影（不泄漏正文）。
          items.add(PublicPost(
            publicPostId: PlaygroundPostId(postId),
            author: _mapper.publicAuthorFromDoc(const <String, dynamic>{}),
            displayStatus: PublicPostDisplayStatus.tombstoned,
            viewerState: const PlaygroundPostViewerState(isBookmarked: true),
            createdAt: DateTime.now(),
          ));
        }
      }

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == limit
          ? FirebasePlaygroundCursor.fromQueryDocument(snaps.docs.last)
          : null;

      return PlaygroundPage<PublicPost>(
        items: items,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
        totalCount: -1,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }
}
