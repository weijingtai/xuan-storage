/// 组合 Repository：Feed 列表（S2 Phase 4 + FW1-C 游标切换容错）。
///
/// 实现业务层端口 [PlaygroundFeedRepository]。
///
/// 缓存裁定：Feed 列表页本身**不缓存**（实时翻页）；但翻页取到的帖子正文
/// 逐条回写帖子缓存（供详情页/骨架屏命中，契约套件 C3 依赖此回写）。
///
/// FW1-C §6.2 游标跨适配器切换处理：当遇到失效/不兼容的游标时，自动重置游标重新拉取第 1 页，
/// 严禁崩溃，严禁静默返回空列表。
library;

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'playground/rest_playground_feed_repository.dart';

final class CachedPlaygroundFeedRepository
    implements PlaygroundFeedRepository {
  CachedPlaygroundFeedRepository({
    required PlaygroundFeedRemoteDataSource remote,
    required PlaygroundPostCacheStore cache,
  })  : _remote = remote,
        _cache = cache;

  final PlaygroundFeedRemoteDataSource _remote;
  final PlaygroundPostCacheStore _cache;

  @override
  Future<PlaygroundPage<PlaygroundPost>> getFeed(GetFeedQuery query) {
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
  Future<PlaygroundPage<PlaygroundPost>> getRecommendedFeed(
      GetFeedQuery query) async {
    final page = await _fetchWithCursorFallback(
      query,
      (q) => _remote.getRecommendedFeed(q),
    );
    await _writeThrough(page);
    return page;
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getPendingDivinationFeed(
      GetFeedQuery query) async {
    final page = await _fetchWithCursorFallback(
      query,
      (q) => _remote.getPendingDivinationFeed(q),
    );
    await _writeThrough(page);
    return page;
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getLatestFeed(
      GetFeedQuery query) async {
    final page = await _fetchWithCursorFallback(
      query,
      (q) => _remote.getLatestFeed(q),
    );
    await _writeThrough(page);
    return page;
  }

  /// 游标跨适配器失效降级机制（§6.2）：
  /// 若带有 cursor 的请求抛出游标失效/不兼容异常，自动重置为第 1 页重新拉取。
  Future<PlaygroundPage<PlaygroundPost>> _fetchWithCursorFallback(
    GetFeedQuery query,
    Future<PlaygroundPage<PlaygroundPost>> Function(GetFeedQuery q) fetcher,
  ) async {
    try {
      return await fetcher(query);
    } catch (e) {
      if (query.cursor != null && query.cursor!.isNotEmpty) {
        if (e is PlaygroundStaleCursorException ||
            e.toString().contains('CURSOR_INVALID_OR_STALE') ||
            e.toString().contains('cursor') ||
            e.toString().contains('startAfter') ||
            e.toString().contains('invalid_argument')) {
          final resetQuery = GetFeedQuery(
            tab: query.tab,
            filter: query.filter,
            limit: query.limit,
            cursor: null,
          );
          return await fetcher(resetQuery);
        }
      }
      rethrow;
    }
  }

  /// 翻页结果逐条回写帖子缓存（并行写；单条失败不阻断 Feed 返回）。
  Future<void> _writeThrough(PlaygroundPage<PlaygroundPost> page) async {
    await Future.wait(
      page.items.map((post) async {
        try {
          await _cache.upsertPost(post);
        } catch (_) {
          // 缓存写入失败不影响 Feed 展示。
        }
      }),
    );
  }
}
