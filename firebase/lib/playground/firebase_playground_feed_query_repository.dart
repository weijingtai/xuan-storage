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

import 'dart:math' as math;

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
      _assertTechniqueCount(query.filter);

      // cursor 必须绑定相同 tab/filter（filter hash 一致），否则 invalidArgument。
      _assertCursorFilter(query,
          orderByField: orderByField, descending: descending);

      // content/time 过滤在扫描页后执行（§10.1：组合索引爆炸）。
      // 扫描上限 = min(limit*5, 100)，cursor 指向最后扫描文档，防漏帖/重帖。
      final scanLimit = math.min(query.limit * 5, 100);
      final filterHash = _filterHash(query.filter, orderByField, descending);

      var q = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .where('status', isEqualTo: PlaygroundPostStatus.active.name)
          .orderBy(orderByField, descending: descending)
          .limit(scanLimit);

      if (query.filter.techniqueIds.isNotEmpty) {
        final ids = query.filter.techniqueIds.toList();
        q = q.where('allowed_chart_technique_ids', arrayContainsAny: ids);
      }

      if (query.cursor != null && query.cursor!.isNotEmpty) {
        final startDoc = FirebasePlaygroundCursor.toDocumentReference(
            query.cursor!, _firestore);
        if (startDoc != null) {
          final startSnap = await startDoc.get();
          if (startSnap.exists) {
            q = q.startAfterDocument(startSnap);
          } else {
            final startValues =
                FirebasePlaygroundCursor.toStartAfterValues(query.cursor!);
            if (startValues != null) {
              q = q.startAfter(startValues);
            }
          }
        } else {
          final startValues =
              FirebasePlaygroundCursor.toStartAfterValues(query.cursor!);
          if (startValues != null) {
            q = q.startAfter(startValues);
          }
        }
      }

      final snaps = await q.get();
      final matching = snaps.docs.where((doc) {
        final data = doc.data();
        if (!_matchesContent(data, query.filter.content)) return false;
        if (!_matchesTimeRange(data, query.filter.timeRange)) return false;
        return true;
      }).take(query.limit);

      // Feed 只允许单 query：不逐帖聚合 counts/owner（§10.3）。
      final items = <PlaygroundFeedItem>[];
      for (final doc in matching) {
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

      // cursor 推进规则（§10.1 扫描分页，禁漏帖/重帖）：
      // - 命中 limit（页大小受 item cap 约束）→ cursor 指向最后返回项，下一页续扫
      //   扫描窗内未返回的匹配项，不遗漏；
      // - 未命中 limit（扫描窗是约束，可能被 content/time 过滤掉部分）→ cursor 指向
      //   最后扫描文档，下一页从扫描尾继续，不重扫已过滤项。
      final lastScanned = snaps.docs.isNotEmpty ? snaps.docs.last : null;
      final hitCap = items.length == query.limit;
      final scanFull = snaps.docs.length == scanLimit;
      QueryDocumentSnapshot<Map<String, dynamic>>? cursorAnchor;
      if (hitCap) {
        final lastReturnedId = items.isNotEmpty
            ? items.last.post.publicPostId.value
            : null;
        if (lastReturnedId != null) {
          for (final d in snaps.docs) {
            if (d.id == lastReturnedId) {
              cursorAnchor = d;
              break;
            }
          }
        }
      } else {
        cursorAnchor = lastScanned;
      }
      final nextCursor = cursorAnchor != null && (hitCap || scanFull)
          ? FirebasePlaygroundCursor.fromQueryDocumentWithOrderBy(
              cursorAnchor, [orderByField],
              filterHash: filterHash)
          : null;

      return PlaygroundPage<PlaygroundFeedItem>(
        items: items,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
        totalCount: -1,
      );
    } catch (e, stack) {
      // ignore: avoid_print
      print('FEED_QUERY_DEBUG_ERROR: $e\n$stack');
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  /// 技法多选 1–10 项；超过 10 返回明确 validation error（§10.1）。
  void _assertTechniqueCount(PlaygroundComposableFilter filter) {
    if (filter.techniqueIds.length > 10) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'filter/technique-count-exceeded',
        message: '技法筛选最多选择 10 项',
      );
    }
  }

  /// 同一 cursor 只能与完全相同的 tab/filter 使用；错用返回 invalidArgument（§10.1）。
  void _assertCursorFilter(GetFeedBatchQuery query,
      {required String orderByField, required bool descending}) {
    final cursor = query.cursor;
    if (cursor == null || cursor.isEmpty) return;
    final cursorHash = FirebasePlaygroundCursor.filterHashOf(cursor);
    if (cursorHash == null) return; // 兼容旧 token：无 hash 不阻断。
    final expected =
        _filterHash(query.filter, orderByField, descending);
    if (cursorHash != expected) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'filter/cursor-filter-mismatch',
        message: '分页 cursor 与当前筛选不匹配，请重新加载',
      );
    }
  }

  /// content 扫描后过滤：读 `has_chart`（§10.1）。
  bool _matchesContent(Map<String, dynamic> data, PlaygroundFeedContentType content) {
    switch (content) {
      case PlaygroundFeedContentType.all:
      case PlaygroundFeedContentType.unknown:
        return true;
      case PlaygroundFeedContentType.withChart:
        return data['has_chart'] == true;
      case PlaygroundFeedContentType.textOnly:
        return data['has_chart'] != true;
    }
  }

  /// time 扫描后过滤：读 `created_at`（§10.1）。
  bool _matchesTimeRange(Map<String, dynamic> data, PlaygroundFeedTimeRange range) {
    if (range == PlaygroundFeedTimeRange.all ||
        range == PlaygroundFeedTimeRange.unknown) {
      return true;
    }
    final created = (data['created_at'] as Timestamp?)?.toDate();
    if (created == null) return false;
    final now = DateTime.now();
    final cutoff = switch (range) {
      PlaygroundFeedTimeRange.today => DateTime(now.year, now.month, now.day),
      PlaygroundFeedTimeRange.week =>
        now.subtract(const Duration(days: 7)),
      PlaygroundFeedTimeRange.month =>
        now.subtract(const Duration(days: 30)),
      PlaygroundFeedTimeRange.year =>
        now.subtract(const Duration(days: 365)),
      _ => null,
    };
    if (cutoff == null) return true;
    return !created.isBefore(cutoff);
  }

  /// filter hash：只覆盖过滤语义相关的字段 + 排序；同 tab 不同分页一致。
  String _filterHash(PlaygroundComposableFilter filter, String orderByField,
      bool descending) {
    final technique = (filter.techniqueIds.toList()..sort()).join(',');
    return sha256Hex(
        'v1|$orderByField|$descending|${filter.content.name}|'
        '${filter.timeRange.name}|$technique');
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
