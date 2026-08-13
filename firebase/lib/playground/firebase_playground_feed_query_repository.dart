/// Task 6：Feed 查询端口 adapter（FirebasePlaygroundFeedQueryRepository）。
///
/// Design: docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md
/// - §10.1：最新/推荐 Feed 单 query：`status==active, order created_at desc`；
///   `getPendingDivinationFeed` 不访问 Firestore，返回
///   `invalidArgument` + `filter/not-supported-in-direct-phase`；
///   推荐入口明确降级为最新（不读 recommendation_score）。
/// - §10.3：Feed 只允许单 query，不逐帖聚合 counts：
///   `PlaygroundFeedItem.replyCount/likeCount/verificationCount=0`、
///   `hasOutcomeFeedback=false`、内部 `PublicPost` 三 count=0；
///   Feed 卡片本期不加载关系计数，不逐帖读 owner/identity_map。
/// - §9：当前 Phase 的 feedback/reply 状态 filter 只接受 `all`；其他值返回
///   `filter/not-supported-in-direct-phase`（UI 当前不展示这些选项）。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';
import 'firebase_playground_public_mapper.dart';
import 'firestore_direct_playground_command_support.dart';

/// Feed 查询端口 adapter —— 生产装配的 provider（Task 6 直写读取）。
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
    // 一期推荐明确降级为最新（§10.1）；不读 recommendation_score。
    return _queryFeed(query, orderByField: 'created_at', descending: true);
  }

  @override
  Future<PlaygroundPage<PlaygroundFeedItem>> getPendingDivinationFeed(
      GetFeedBatchQuery query) async {
    // 待断依赖可信派生数据，一期不交付；不访问 Firestore（§10.1/§1）。
    throw directPlaygroundError(
      code: PlaygroundErrorCode.invalidArgument,
      machineCode: 'filter/not-supported-in-direct-phase',
      message: '待断 Feed 当前直写 Phase 不支持',
    );
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
  }) async {
    try {
      _assertSupportedFilter(query.filter);

      var q = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .where('status', isEqualTo: PlaygroundPostStatus.active.name)
          .orderBy(orderByField, descending: descending)
          .limit(query.limit);

      if (query.filter.techniqueIds.isNotEmpty) {
        final ids = query.filter.techniqueIds.take(10).toList();
        q = q.where('allowed_chart_technique_ids', arrayContainsAny: ids);
      }

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

      // Feed 只允许单 query：不逐帖聚合 counts/owner（§10.3）。
      final items = <PlaygroundFeedItem>[];
      for (final doc in snaps.docs) {
        final postId = doc.id;
        final data = doc.data();
        const viewerState = PlaygroundPostViewerState();
        final public = _mapper.publicPostFromDoc(
          postId,
          data,
          replyCount: 0,
          likeCount: 0,
          verificationCount: 0,
          viewerState: viewerState,
          presentationMode:
              FirebasePlaygroundPublicMapper.presentationModeFromDoc(data),
        );

        items.add(PlaygroundFeedItem(
          post: public,
          replyCount: 0,
          likeCount: 0,
          verificationCount: 0,
          hasOutcomeFeedback: false,
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
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  /// 当前 Phase 的 feedback/reply 状态 filter 只接受 `all`（§10.1/§9）。
  /// content/time/technique filter 保留（多选技法、时间范围）。
  void _assertSupportedFilter(PlaygroundComposableFilter filter) {
    if (filter.reply != PlaygroundFeedReplyFilter.all &&
        filter.reply != PlaygroundFeedReplyFilter.unknown) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'filter/not-supported-in-direct-phase',
        message: '回复状态筛选当前直写 Phase 不支持',
      );
    }
    if (filter.feedback != PlaygroundFeedFeedbackFilter.all &&
        filter.feedback != PlaygroundFeedFeedbackFilter.unknown) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'filter/not-supported-in-direct-phase',
        message: '反馈状态筛选当前直写 Phase 不支持',
      );
    }
  }
}
