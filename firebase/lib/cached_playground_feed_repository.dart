/// 组合 Repository：Feed 列表（S2 Phase 4）。
///
/// 实现业务层端口 [PlaygroundFeedRepository]。
///
/// 缓存裁定：Feed 列表页本身**不缓存**（实时翻页）；但翻页取到的帖子正文
/// 逐条回写帖子缓存（供详情页/骨架屏命中，契约套件 C3 依赖此回写）。
library;

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

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
    final page = await _remote.getRecommendedFeed(query);
    await _writeThrough(page);
    return page;
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getPendingDivinationFeed(
      GetFeedQuery query) async {
    final page = await _remote.getPendingDivinationFeed(query);
    await _writeThrough(page);
    return page;
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getLatestFeed(
      GetFeedQuery query) async {
    final page = await _remote.getLatestFeed(query);
    await _writeThrough(page);
    return page;
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
