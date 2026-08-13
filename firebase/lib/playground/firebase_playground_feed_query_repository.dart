import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';
import 'firebase_playground_public_mapper.dart';

/// Phase 7B：Feed 查询端口 adapter（PlaygroundFeedQueryRepository）。
///
/// - 复用既有 feed 查询形状（tab/filter/分页，status=='active' 白名单）；
/// - 每页逐帖聚合 counts（reply/like/verification，bounded by page size）
///   与 viewer state，映射安全 [PlaygroundFeedItem] 公开投影，不暴露内部模型。
final class FirebasePlaygroundFeedQueryRepository
    implements PlaygroundFeedQueryRepository {
  FirebasePlaygroundFeedQueryRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth);

  final FirebaseFirestore _firestore;
  final FirebasePlaygroundPublicMapper _mapper;

  @override
  Future<PlaygroundPage<PlaygroundFeedItem>> getFeed(
      GetFeedBatchQuery query) async {
    switch (query.tab) {
      case PlaygroundFeedTab.recommended:
        return getRecommendedFeed(query);
      case PlaygroundFeedTab.pendingDivination:
        return getPendingDivinationFeed(query);
      case PlaygroundFeedTab.latest:
        return getLatestFeed(query);
    }
  }

  @override
  Future<PlaygroundPage<PlaygroundFeedItem>> getRecommendedFeed(
      GetFeedBatchQuery query) async {
    return _queryFeed(query,
        orderByField: 'recommendation_score', descending: true);
  }

  @override
  Future<PlaygroundPage<PlaygroundFeedItem>> getPendingDivinationFeed(
      GetFeedBatchQuery query) async {
    return _queryFeed(query,
        orderByField: 'created_at',
        descending: false,
        extraWhere: (q) => q.where('reply_status', isEqualTo: 'pending'));
  }

  @override
  Future<PlaygroundPage<PlaygroundFeedItem>> getLatestFeed(
      GetFeedBatchQuery query) async {
    return _queryFeed(query, orderByField: 'created_at', descending: true);
  }

  Future<PlaygroundPage<PlaygroundFeedItem>> _queryFeed(
    GetFeedBatchQuery query, {
    required String orderByField,
    required bool descending,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)?
        extraWhere,
  }) async {
    try {
      var q = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .where('status', isEqualTo: PlaygroundPostStatus.active.name);

      q = _applyComposableFilter(q, query.filter);

      if (extraWhere != null) {
        q = extraWhere(q);
      }

      q = q.orderBy(orderByField, descending: descending).limit(query.limit);

      if (query.cursor != null && query.cursor!.isNotEmpty) {
        // 优先用 values（orderBy 字段值）做 startAfter：双端稳定且 opaque；
        // 旧 path-only cursor 回退 startAfterDocument（path 恢复）。
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

      final items = <PlaygroundFeedItem>[];
      for (final doc in snaps.docs) {
        final postId = doc.id;
        final data = doc.data();
        final counts = await _aggregateCounts(postId);
        final viewerState = await _mapper.viewerStateForPost(postId, data);

        final public = _mapper.publicPostFromDoc(
          postId,
          data,
          replyCount: counts.$1,
          likeCount: counts.$2,
          verificationCount: counts.$3,
          viewerState: viewerState,
        );

        items.add(PlaygroundFeedItem(
          post: public,
          replyCount: counts.$1,
          likeCount: counts.$2,
          verificationCount: counts.$3,
          hasOutcomeFeedback: data['has_outcome_feedback'] == true,
          viewerState: viewerState,
          authorSummary: _mapper.publicAuthorFromDoc(data),
        ));
      }

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == query.limit
          ? FirebasePlaygroundCursor.fromQueryDocumentWithOrderBy(
              snaps.docs.last, [orderByField])
          : null;

      return PlaygroundPage<PlaygroundFeedItem>(
        items: items,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
        totalCount: -1,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  /// 把 typed [PlaygroundComposableFilter] 映射为 Firestore where 条件。
  Query<Map<String, dynamic>> _applyComposableFilter(
    Query<Map<String, dynamic>> q,
    PlaygroundComposableFilter filter,
  ) {
    if (filter.techniqueIds.isNotEmpty) {
      final ids = filter.techniqueIds.take(10).toList();
      q = q.where('allowed_chart_technique_ids', arrayContainsAny: ids);
    }

    switch (filter.content) {
      case PlaygroundFeedContentType.withChart:
        q = q.where('content_type', isEqualTo: 'with_chart');
      case PlaygroundFeedContentType.textOnly:
        q = q.where('content_type', isEqualTo: 'text_only');
      case PlaygroundFeedContentType.all:
      case PlaygroundFeedContentType.unknown:
        break;
    }

    switch (filter.reply) {
      case PlaygroundFeedReplyFilter.pending:
        q = q.where('reply_status', isEqualTo: 'pending');
      case PlaygroundFeedReplyFilter.answered:
        q = q.where('reply_status', isEqualTo: 'replied');
      case PlaygroundFeedReplyFilter.all:
      case PlaygroundFeedReplyFilter.unknown:
        break;
    }

    switch (filter.feedback) {
      case PlaygroundFeedFeedbackFilter.hasFeedback:
        q = q.where('feedback_status', isEqualTo: 'has_feedback');
      case PlaygroundFeedFeedbackFilter.noFeedback:
        q = q.where('feedback_status', isEqualTo: 'no_feedback');
      case PlaygroundFeedFeedbackFilter.all:
      case PlaygroundFeedFeedbackFilter.unknown:
        break;
    }

    final cutoff = _timeRangeCutoff(filter.timeRange);
    if (cutoff != null) {
      q = q.where('created_at', isGreaterThanOrEqualTo: cutoff);
    }

    return q;
  }

  DateTime? _timeRangeCutoff(PlaygroundFeedTimeRange timeRange) {
    final now = DateTime.now();
    switch (timeRange) {
      case PlaygroundFeedTimeRange.today:
        return DateTime(now.year, now.month, now.day);
      case PlaygroundFeedTimeRange.week:
        return now.subtract(const Duration(days: 7));
      case PlaygroundFeedTimeRange.month:
        return now.subtract(const Duration(days: 30));
      case PlaygroundFeedTimeRange.year:
        return now.subtract(const Duration(days: 365));
      case PlaygroundFeedTimeRange.all:
      case PlaygroundFeedTimeRange.unknown:
        return null;
    }
  }

  /// 聚合 counts（bounded by 单帖三集合查询，page size 恒定）。
  Future<(int, int, int)> _aggregateCounts(String postId) async {
    final repliesFuture = _firestore
        .collection(PlaygroundFirestoreSchema.replies)
        .where('post_id', isEqualTo: postId)
        .where('is_tombstoned', isEqualTo: false)
        .get();
    final likesFuture = _firestore
        .collection(PlaygroundFirestoreSchema.likes)
        .where('post_id', isEqualTo: postId)
        .get();
    final verificationsFuture = _firestore
        .collection(PlaygroundFirestoreSchema.verifications)
        .where('post_id', isEqualTo: postId)
        .where('revoked_at', isNull: true)
        .get();

    final results = await Future.wait(
        [repliesFuture, likesFuture, verificationsFuture]);
    return (
      results[0].docs.length,
      results[1].docs.length,
      results[2].docs.length,
    );
  }
}
