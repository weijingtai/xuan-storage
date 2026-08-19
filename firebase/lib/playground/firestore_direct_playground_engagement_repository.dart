/// Firestore 直写互动仓库（like/bookmark，Task 5）。
///
/// Design: docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md
/// - §3.3：like public fact + 私有 like owner 同批；
/// - §4.2：like/bookmark ID = sha256(v1|operation|authUid|targetId)；
///   bookmark 沿用 user_provider_uid/user_app_user_id 命名；
/// - §10.1：viewer state 用确定性 ID 各 direct get；
/// - §8：确定性文档 ID；零 outbox/notification。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_public_mapper.dart';
import 'firestore_direct_playground_command_support.dart';

/// 互动直写仓库 —— 生产装配的 provider。
final class FirestoreDirectPlaygroundEngagementRepository
    implements PlaygroundEngagementRepository {
  FirestoreDirectPlaygroundEngagementRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundPublicMapper _mapper;

  @override
  Future<void> setContentLike(SetContentLikeCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      final (targetType, targetId) = _encodeLikeTarget(command.target);
      final likeId = deterministicCreateId(
        operation: 'like',
        authUid: actor.providerUid,
        idempotencyKey: targetId,
      );

      final likeRef = _firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .doc(likeId);
      final ownerRef = _firestore
          .collection(PlaygroundFirestoreSchema.likeOwners)
          .doc(likeId);

      await _firestore.runTransaction((tx) async {
        if (command.liked) {
          tx.set(likeRef, {
            'id': likeId,
            'target_type': targetType,
            'target_id': targetId,
            'created_at': FieldValue.serverTimestamp(),
          });
          tx.set(ownerRef, {
            'like_id': likeId,
            'provider_uid': actor.providerUid,
            'app_user_id': actor.appUserId,
            'target_type': targetType,
            'target_id': targetId,
            'created_at': FieldValue.serverTimestamp(),
          });
        } else {
          tx.delete(likeRef);
          tx.delete(ownerRef);
        }
      });
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw directPlaygroundError(
        code: PlaygroundErrorCode.unavailable,
        machineCode: 'provider/unavailable',
        message: 'Firestore 暂不可用',
        cause: e,
      );
    }
  }

  @override
  Future<void> setBookmark(SetBookmarkCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      final bookmarkId = deterministicCreateId(
        operation: 'bookmark',
        authUid: actor.providerUid,
        idempotencyKey: command.postId.value,
      );
      final bookmarkRef = _firestore
          .collection(PlaygroundFirestoreSchema.bookmarks)
          .doc(bookmarkId);

      await _firestore.runTransaction((tx) async {
        if (command.bookmarked) {
          tx.set(bookmarkRef, {
            'id': bookmarkId,
            'user_provider_uid': actor.providerUid,
            'user_app_user_id': actor.appUserId,
            'post_id': command.postId.value,
            'created_at': FieldValue.serverTimestamp(),
          });
        } else {
          tx.delete(bookmarkRef);
        }
      });
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw directPlaygroundError(
        code: PlaygroundErrorCode.unavailable,
        machineCode: 'provider/unavailable',
        message: 'Firestore 暂不可用',
        cause: e,
      );
    }
  }

  @override
  Future<PlaygroundPostViewerState> getViewerState(
      PlaygroundContentTarget target) async {
    try {
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      return switch (target) {
        PostTarget(:final id) => _viewerStateForPost(id.value, actor),
        ReplyTarget(:final id) => _viewerStateForReply(id.value, actor),
        _ => const PlaygroundPostViewerState(),
      };
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw directPlaygroundError(
        code: PlaygroundErrorCode.unavailable,
        machineCode: 'provider/unavailable',
        message: 'Firestore 暂不可用',
        cause: e,
      );
    }
  }

  /// 确定性 ID 各 direct get（§10.1），不逐帖聚合。
  Future<PlaygroundPostViewerState> _viewerStateForPost(
      String postId, DirectWriteActor actor) async {
    final likeId = deterministicCreateId(
      operation: 'like',
      authUid: actor.providerUid,
      idempotencyKey: postId,
    );
    final likeSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.likes)
        .doc(likeId)
        .get();
    final ownerSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.likeOwners)
        .doc(likeId)
        .get();
    final isLiked = likeSnap.exists && ownerSnap.exists;

    final bookmarkId = deterministicCreateId(
      operation: 'bookmark',
      authUid: actor.providerUid,
      idempotencyKey: postId,
    );
    final bookmarkSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.bookmarks)
        .doc(bookmarkId)
        .get();
    final isBookmarked = bookmarkSnap.exists;

    // canVerify：当前 viewer 是帖子 owner（§12.2）。
    final isOwner = await _isPostOwner(postId, actor.providerUid);

    return PlaygroundPostViewerState(
      isLiked: isLiked,
      isBookmarked: isBookmarked,
      canVerify: isOwner,
    );
  }

  Future<PlaygroundPostViewerState> _viewerStateForReply(
      String replyId, DirectWriteActor actor) async {
    final likeId = deterministicCreateId(
      operation: 'like',
      authUid: actor.providerUid,
      idempotencyKey: replyId,
    );
    final likeSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.likes)
        .doc(likeId)
        .get();
    final ownerSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.likeOwners)
        .doc(likeId)
        .get();
    return PlaygroundPostViewerState(
      isLiked: likeSnap.exists && ownerSnap.exists,
    );
  }

  Future<bool> _isPostOwner(String postId, String providerUid) async {
    final snap = await _firestore
        .collection(PlaygroundFirestoreSchema.postOwners)
        .doc(postId)
        .get();
    return snap.exists && snap.data()?['provider_uid'] == providerUid;
  }

  @override
  Future<PlaygroundPage<PublicPost>> getMyBookmarkedPosts({
    PlaygroundCursor? cursor,
    int limit = 20,
  }) async {
    try {
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      var query = _firestore
          .collection(PlaygroundFirestoreSchema.bookmarks)
          .where('user_provider_uid', isEqualTo: actor.providerUid)
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (cursor != null) {
        query = query.startAfter([cursor.token]);
      }

      final snaps = await query.get();
      final items = <PublicPost>[];
      for (final snap in snaps.docs) {
        final postId = snap.data()['post_id'] as String?;
        if (postId == null) continue;
        final postSnap = await _firestore
            .collection(PlaygroundFirestoreSchema.posts)
            .doc(postId)
            .get();
        if (!postSnap.exists) continue;
        items.add(_mapper.publicPostFromDoc(
          postId,
          postSnap.data()!,
          replyCount: 0,
          likeCount: 0,
          verificationCount: 0,
          viewerState: const PlaygroundPostViewerState(isBookmarked: true),
        ));
      }

      return PlaygroundPage(
        items: items,
        nextCursor: snaps.docs.isEmpty
            ? null
            : PlaygroundCursor(_cursorValue(snaps.docs.last)),
        hasMore: snaps.docs.length == limit,
      );
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw directPlaygroundError(
        code: PlaygroundErrorCode.unavailable,
        machineCode: 'provider/unavailable',
        message: 'Firestore 暂不可用',
        cause: e,
      );
    }
  }

  String _cursorValue(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final created = (doc.data()['created_at'] as Timestamp?)?.toDate();
    return '${created?.millisecondsSinceEpoch ?? 0}_${doc.id}';
  }

  static (String, String) _encodeLikeTarget(PlaygroundContentTarget target) {
    return switch (target) {
      PostTarget(:final id) => ('post', id.value),
      ReplyTarget(:final id) => ('reply', id.value),
      _ => throw directPlaygroundError(
          code: PlaygroundErrorCode.invalidArgument,
          machineCode: 'engagement/like-target-invalid',
          message: '仅 Post|Reply 可被点赞',
        ),
    };
  }

  static String _requireIdempotencyKey(String? key) {
    if (key == null || key.isEmpty) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'idempotency/invalid-key',
        message: '缺少幂等键',
      );
    }
    return key;
  }
}
