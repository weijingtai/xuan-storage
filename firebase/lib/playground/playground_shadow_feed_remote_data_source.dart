import 'dart:async';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'playground_shadow_comparator.dart';

/// 影子双跑比对回调。
typedef ShadowComparisonCallback = void Function(
    ShadowComparisonResult result, String operation);

/// 广场 Feed 影子双跑数据源（§5.3）。
///
/// 同时向主通道与副通道（两条真正独立的取数路径）发起查询并比对业务等价性。
final class ShadowPlaygroundFeedRemoteDataSource
    implements PlaygroundFeedRemoteDataSource {
  ShadowPlaygroundFeedRemoteDataSource({
    required this.primary,
    required this.secondary,
    this.onComparison,
    this.timestampTolerance = PlaygroundShadowComparator.defaultTimestampTolerance,
  });

  final PlaygroundFeedRemoteDataSource primary;
  final PlaygroundFeedRemoteDataSource secondary;
  final ShadowComparisonCallback? onComparison;
  final Duration timestampTolerance;

  @override
  Future<PlaygroundPage<PlaygroundPost>> getFeed(GetFeedQuery query) async {
    return _dualRun(
      'getFeed',
      () => primary.getFeed(query),
      () => secondary.getFeed(query),
    );
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getRecommendedFeed(
      GetFeedQuery query) async {
    return _dualRun(
      'getRecommendedFeed',
      () => primary.getRecommendedFeed(query),
      () => secondary.getRecommendedFeed(query),
    );
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getPendingDivinationFeed(
      GetFeedQuery query) async {
    return _dualRun(
      'getPendingDivinationFeed',
      () => primary.getPendingDivinationFeed(query),
      () => secondary.getPendingDivinationFeed(query),
    );
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getLatestFeed(
      GetFeedQuery query) async {
    return _dualRun(
      'getLatestFeed',
      () => primary.getLatestFeed(query),
      () => secondary.getLatestFeed(query),
    );
  }

  Future<PlaygroundPage<PlaygroundPost>> _dualRun(
    String operation,
    Future<PlaygroundPage<PlaygroundPost>> Function() runPrimary,
    Future<PlaygroundPage<PlaygroundPost>> Function() runSecondary,
  ) async {
    final primaryFuture = runPrimary();
    final secondaryFuture = runSecondary();

    final primaryPage = await primaryFuture;

    // 异步或并行等待副流程，执行有鉴别力的影子比对
    try {
      final secondaryPage = await secondaryFuture;
      final result = PlaygroundShadowComparator.compareFeedPage(
        primaryPage,
        secondaryPage,
        timestampTolerance: timestampTolerance,
      );
      onComparison?.call(result, operation);
    } catch (e) {
      onComparison?.call(
        ShadowComparisonResult.mismatch(
          ['Secondary pipeline failed with error: $e'],
        ),
        operation,
      );
    }

    return primaryPage;
  }
}
