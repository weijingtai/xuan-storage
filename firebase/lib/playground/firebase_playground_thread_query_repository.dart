/// Task 6：线程查询 adapter（FirebasePlaygroundThreadQueryRepository）。
///
/// Design: docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md
/// - §10.1 精确查询计划：注册用户回复分页
///   `replies: post_id==id, is_tombstoned==false, order created_at asc`；
/// - §10.3 固定读取成本：详情固定组合（1 post get + 1 post owner get + 1 replies
///   page + 每 10 个当前页 root IDs 1 次 verification query + 3 个 count()
///   aggregation + 1 feedback get + viewer like/bookmark direct gets），
///   `aggregateReadCount=3` 固定表示三次 aggregation，非浏览量；不读 root owner；
/// - §12.2 viewer capability：owner 文档 `provider_uid==auth.uid` → 填充
///   `isOwner/canEdit/canDelete/canSetFeedback`；非 owner/未认证/owner 缺失全部
///   fail closed false；owner 文档只 get、禁止 list；
/// - §1/§10.1：游客代表性回复（5–10 条）后移，`getGuestRepresentativeReplies`
///   当前返回明确 `unavailable`，不伪造可信限制；不装配 Functions。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';
import 'firebase_playground_public_mapper.dart';
import 'firestore_direct_playground_command_support.dart';

/// 线程查询 adapter —— 生产装配的 provider（Task 6 直写读取）。
final class FirebasePlaygroundThreadQueryRepository
    implements PlaygroundThreadQueryRepository {
  FirebasePlaygroundThreadQueryRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundPublicMapper _mapper;

  // ---- 游客代表性回复：后移（§1/§10.1）----

  @override
  Future<GuestRepresentativeRepliesResult> getGuestRepresentativeReplies(
      GetGuestRepresentativeRepliesQuery query) async {
    // 一期不交付游客 5–10 条代表性回复的可信服务端策略；不伪造可信限制。
    throw directPlaygroundError(
      code: PlaygroundErrorCode.unavailable,
      machineCode: 'guest/representative-replies-not-available',
      message: '游客代表性回复当前直写 Phase 不提供',
    );
  }

  // ---- 注册用户回复分页：直连 Firestore（§10.1）----

  @override
  Future<PlaygroundPage<PlaygroundReplyView>> getThreadReplies(
      GetRepliesQuery query) async {
    try {
      // v1 查询形状：post_id == + is_tombstoned == false + order created_at asc。
      var q = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .where('post_id', isEqualTo: query.postId.value)
          .where('is_tombstoned', isEqualTo: false)
          .orderBy('created_at', descending: false)
          .limit(query.limit);

      if (query.cursor != null && query.cursor!.isNotEmpty) {
        final startValues =
            FirebasePlaygroundCursor.toStartAfterValues(query.cursor!);
        if (startValues != null) {
          q = q.startAfter(startValues);
        } else {
          final startDoc = FirebasePlaygroundCursor.toDocumentReference(
              query.cursor!, _firestore);
          if (startDoc != null) {
            final startSnap = await startDoc.get();
            if (startSnap.exists) {
              q = q.startAfterDocument(startSnap);
            }
          }
        }
      }

      final snaps = await q.get();
      final views = <PlaygroundReplyView>[];
      for (final snap in snaps.docs) {
        final reply = _mapper.publicReplyFromDoc(snap.id, snap.data());
        views.add(reply.depth == 0
            ? PlaygroundRootReplyView(reply: reply)
            : PlaygroundDiscussionReplyView(reply: reply));
      }

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == query.limit
          ? FirebasePlaygroundCursor.fromQueryDocumentWithOrderBy(
              snaps.docs.last, ['created_at'])
          : null;

      return PlaygroundPage<PlaygroundReplyView>(
        items: views,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
        totalCount: -1,
      );
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  // ---- 注册用户完整详情聚合（§10.3 固定读取成本）----

  @override
  Future<PlaygroundRegisteredThreadDetail> getRegisteredThreadDetail(
      PlaygroundRegisteredThreadDetailQuery query) async {
    try {
      final postId = query.postId.value;

      // 1 post get。
      final postSnap = await _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId)
          .get();
      if (!postSnap.exists) {
        throw directPlaygroundError(
          code: PlaygroundErrorCode.notFound,
          machineCode: 'content/not-found',
          message: '帖子不存在',
        );
      }
      final postData = postSnap.data() ?? const <String, dynamic>{};

      // 2 viewer state：1 post owner get + like/bookmark direct gets。
      final viewerState = await _viewerStateForPost(postId, postData);

      // 3 replies page（v1：post_id + is_tombstoned==false + created_at asc）。
      final repliesSnap = await _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .where('post_id', isEqualTo: postId)
          .where('is_tombstoned', isEqualTo: false)
          .orderBy('created_at', descending: false)
          .limit(50)
          .get();

      // 4 verified count 使用已执行的 verification aggregation（§10.1 全帖应验总数，
      //   不再把当前页 root 数当全帖总数；不逐页查 root verification 集合）。
      final verificationsCount = await _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .where('post_id', isEqualTo: postId)
          .where('revoked_at', isNull: true)
          .count()
          .get();
      final verifiedRootCount = verificationsCount.count ?? 0;

      // 5 feedback get：feedback_{postId} 文档（未删除）。
      final feedbackSnap = await _firestore
          .collection(PlaygroundFirestoreSchema.outcomeFeedback)
          .doc('feedback_$postId')
          .get();
      PublicFeedbackSummary? feedback;
      if (feedbackSnap.exists && feedbackSnap.data()?['deleted_at'] == null) {
        feedback = _mapper.feedbackFromDoc(feedbackSnap.data()!);
      }

      // 6 两次 count() aggregation：replies / post-target likes。
      final repliesCount = await _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .where('post_id', isEqualTo: postId)
          .where('is_tombstoned', isEqualTo: false)
          .count()
          .get();
      final likesCount = await _firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .where('target_type', isEqualTo: 'post')
          .where('target_id', isEqualTo: postId)
          .count()
          .get();

      final views = <PlaygroundReplyView>[];
      for (final snap in repliesSnap.docs) {
        final reply = _mapper.publicReplyFromDoc(snap.id, snap.data());
        views.add(reply.depth == 0
            ? PlaygroundRootReplyView(reply: reply)
            : PlaygroundDiscussionReplyView(reply: reply));
      }

      final public = _mapper.publicPostFromDoc(
        postId,
        postData,
        replyCount: repliesCount.count ?? 0,
        likeCount: likesCount.count ?? 0,
        verificationCount: verificationsCount.count ?? 0,
        viewerState: viewerState,
        outcomeFeedback: feedback,
        presentationMode:
            FirebasePlaygroundPublicMapper.presentationModeFromDoc(postData),
      );

      return PlaygroundRegisteredThreadDetail(
        post: public,
        replies: views,
        outcomeFeedback: feedback,
        counts: PlaygroundThreadCounts(
          replyCount: repliesCount.count ?? 0,
          verifiedRootReplyCount: verifiedRootCount,
        ),
        viewerState: viewerState,
        aggregateReadCount: 3,
      );
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  // ---- viewer state（§12.2：owner 文档 fail closed）----

  Future<PlaygroundPostViewerState> _viewerStateForPost(
    String postId,
    Map<String, dynamic> postData,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return const PlaygroundPostViewerState();

    final uid = user.uid;

    // owner 文档：只 get，禁止 list。
    final ownerSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.postOwners)
        .doc(postId)
        .get();
    final ownerData = ownerSnap.data();
    final isOwner =
        ownerData != null && ownerData['provider_uid'] == uid;

    // viewer like/bookmark direct gets（确定性 ID，与写端一致 §8/§10.1）。
    final likeId = deterministicCreateId(
      operation: 'like',
      authUid: uid,
      idempotencyKey: postId,
    );
    final likeSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.likes)
        .doc(likeId)
        .get();
    final bookmarkId = deterministicCreateId(
      operation: 'bookmark',
      authUid: uid,
      idempotencyKey: postId,
    );
    final bookmarkSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.bookmarks)
        .doc(bookmarkId)
        .get();

    return PlaygroundPostViewerState(
      isLiked: likeSnap.exists,
      isBookmarked: bookmarkSnap.exists,
      isOwner: isOwner,
      canEdit: isOwner,
      canDelete: isOwner,
      canSetFeedback: isOwner,
      canVerify: isOwner,
    );
  }
}
