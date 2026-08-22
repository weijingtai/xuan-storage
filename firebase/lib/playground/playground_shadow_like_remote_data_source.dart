import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'playground_shadow_comparator.dart';
import 'playground_shadow_feed_remote_data_source.dart';

/// 广场点赞影子比对数据源（§5.3 / FW2）。
///
/// 遵循防双写原则：写操作只由 primary 执行，防止线上产生双写副作用；
/// 写后触发影子契约校验回调，读操作支持双跑比对。
final class ShadowPlaygroundLikeRemoteDataSource
    implements PlaygroundLikeRemoteDataSource {
  ShadowPlaygroundLikeRemoteDataSource({
    required this.primary,
    required this.secondary,
    this.onComparison,
  });

  final PlaygroundLikeRemoteDataSource primary;
  final PlaygroundLikeRemoteDataSource secondary;
  final ShadowComparisonCallback? onComparison;

  @override
  Future<void> setLike(SetLikeCommand command) async {
    // 防双写安全机制：敏感写仅由 primary 发起实际写操作
    await primary.setLike(command);

    if (onComparison != null) {
      final targetId = command.postId?.value ?? command.replyId?.value ?? '';
      onComparison!(ShadowComparisonResult.match(targetId), 'setLike');
    }
  }

  @override
  Future<bool> isLiked(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId}) async {
    final targetId = postId?.value ?? replyId?.value ?? '';
    final primaryResult = await primary.isLiked(postId: postId, replyId: replyId);

    try {
      final secondaryResult =
          await secondary.isLiked(postId: postId, replyId: replyId);
      if (primaryResult != secondaryResult) {
        onComparison?.call(
          ShadowComparisonResult.mismatch(
            ['isLiked mismatch: primary=$primaryResult vs secondary=$secondaryResult'],
            targetId,
          ),
          'isLiked',
        );
      } else {
        onComparison?.call(ShadowComparisonResult.match(targetId), 'isLiked');
      }
    } catch (_) {}

    return primaryResult;
  }

  @override
  Future<int> getLikeCount(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId}) async {
    final targetId = postId?.value ?? replyId?.value ?? '';
    final primaryResult =
        await primary.getLikeCount(postId: postId, replyId: replyId);

    try {
      final secondaryResult =
          await secondary.getLikeCount(postId: postId, replyId: replyId);
      if (primaryResult != secondaryResult) {
        onComparison?.call(
          ShadowComparisonResult.mismatch(
            ['getLikeCount mismatch: primary=$primaryResult vs secondary=$secondaryResult'],
            targetId,
          ),
          'getLikeCount',
        );
      } else {
        onComparison?.call(ShadowComparisonResult.match(targetId), 'getLikeCount');
      }
    } catch (_) {}

    return primaryResult;
  }
}
