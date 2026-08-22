import 'package:equatable/equatable.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 影子比对结果。
final class ShadowComparisonResult extends Equatable {
  const ShadowComparisonResult({
    required this.isMatch,
    this.discrepancies = const [],
    this.targetId = '',
  });

  factory ShadowComparisonResult.match([String targetId = '']) =>
      ShadowComparisonResult(isMatch: true, targetId: targetId);

  factory ShadowComparisonResult.mismatch(
    List<String> discrepancies, [
    String targetId = '',
  ]) =>
      ShadowComparisonResult(
        isMatch: false,
        discrepancies: discrepancies,
        targetId: targetId,
      );

  final bool isMatch;
  final List<String> discrepancies;
  final String targetId;

  @override
  List<Object?> get props => [isMatch, discrepancies, targetId];
}

/// 广场只读路径影子比对器（§5.3）。
///
/// 具备强鉴别力：
/// - 业务字段 100% 严格比对（id, text, authorUserId, status, allowedChartTechniqueIds, attachments, revisions, hasOutcomeFeedback）；
/// - 时间戳容差 ±1000ms（允许时钟漂移与精度微差）；
/// - 严禁假双跑与自我克隆比对。
final class PlaygroundShadowComparator {
  const PlaygroundShadowComparator();

  static const Duration defaultTimestampTolerance =
      Duration(milliseconds: 1000);

  /// 比对单条帖子。
  static ShadowComparisonResult comparePost(
    PlaygroundPost a,
    PlaygroundPost b, {
    Duration timestampTolerance = defaultTimestampTolerance,
  }) {
    final discrepancies = <String>[];
    final postId = a.id.value;

    if (a.id != b.id) {
      discrepancies.add('id mismatch: a=${a.id.value} vs b=${b.id.value}');
    }
    if (a.text != b.text) {
      discrepancies.add('text mismatch: a="${a.text}" vs b="${b.text}"');
    }
    if (a.authorUserId != b.authorUserId) {
      discrepancies.add(
          'authorUserId mismatch: a=${a.authorUserId.value} vs b=${b.authorUserId.value}');
    }
    if (a.status != b.status) {
      discrepancies
          .add('status mismatch: a=${a.status.name} vs b=${b.status.name}');
    }
    if (!_areListsEqual(
        a.allowedChartTechniqueIds, b.allowedChartTechniqueIds)) {
      discrepancies.add(
          'allowedChartTechniqueIds mismatch: a=${a.allowedChartTechniqueIds} vs b=${b.allowedChartTechniqueIds}');
    }
    if (a.hasOutcomeFeedback != b.hasOutcomeFeedback) {
      discrepancies.add(
          'hasOutcomeFeedback mismatch: a=${a.hasOutcomeFeedback} vs b=${b.hasOutcomeFeedback}');
    }

    // 时间戳容差比对
    final createdDiff = a.createdAt.difference(b.createdAt).abs();
    if (createdDiff > timestampTolerance) {
      discrepancies.add(
          'createdAt drift exceeds tolerance (${createdDiff.inMilliseconds}ms > ${timestampTolerance.inMilliseconds}ms): a=${a.createdAt} vs b=${b.createdAt}');
    }

    if (a.updatedAt != null || b.updatedAt != null) {
      if (a.updatedAt == null || b.updatedAt == null) {
        discrepancies
            .add('updatedAt nullness mismatch: a=${a.updatedAt} vs b=${b.updatedAt}');
      } else {
        final updatedDiff = a.updatedAt!.difference(b.updatedAt!).abs();
        if (updatedDiff > timestampTolerance) {
          discrepancies.add(
              'updatedAt drift exceeds tolerance (${updatedDiff.inMilliseconds}ms > ${timestampTolerance.inMilliseconds}ms): a=${a.updatedAt} vs b=${b.updatedAt}');
        }
      }
    }

    // 附件比对
    if (a.attachments.length != b.attachments.length) {
      discrepancies.add(
          'attachments.length mismatch: a=${a.attachments.length} vs b=${b.attachments.length}');
    } else {
      for (var i = 0; i < a.attachments.length; i++) {
        final attA = a.attachments[i];
        final attB = b.attachments[i];
        if (attA != attB) {
          discrepancies.add('attachments[$i] mismatch: a=$attA vs b=$attB');
        }
      }
    }

    // 修订历史比对
    if (a.revisions.length != b.revisions.length) {
      discrepancies.add(
          'revisions.length mismatch: a=${a.revisions.length} vs b=${b.revisions.length}');
    } else {
      for (var i = 0; i < a.revisions.length; i++) {
        final revA = a.revisions[i];
        final revB = b.revisions[i];
        if (revA.body != revB.body ||
            revA.editedBy != revB.editedBy ||
            revA.changeDescription != revB.changeDescription) {
          discrepancies.add('revisions[$i] mismatch: a=$revA vs b=$revB');
        } else {
          final editDiff = revA.editedAt.difference(revB.editedAt).abs();
          if (editDiff > timestampTolerance) {
            discrepancies.add(
                'revisions[$i].editedAt drift exceeds tolerance: a=${revA.editedAt} vs b=${revB.editedAt}');
          }
        }
      }
    }

    if (discrepancies.isEmpty) {
      return ShadowComparisonResult.match(postId);
    }
    return ShadowComparisonResult.mismatch(discrepancies, postId);
  }

  /// 比对 Feed 列表页面。
  static ShadowComparisonResult compareFeedPage(
    PlaygroundPage<PlaygroundPost> a,
    PlaygroundPage<PlaygroundPost> b, {
    Duration timestampTolerance = defaultTimestampTolerance,
  }) {
    final discrepancies = <String>[];

    if (a.items.length != b.items.length) {
      discrepancies.add(
          'items.length mismatch: a=${a.items.length} vs b=${b.items.length}');
    } else {
      for (var i = 0; i < a.items.length; i++) {
        final postResult = comparePost(
          a.items[i],
          b.items[i],
          timestampTolerance: timestampTolerance,
        );
        if (!postResult.isMatch) {
          discrepancies.addAll(
              postResult.discrepancies.map((d) => 'items[$i]: $d'));
        }
      }
    }

    if (a.hasMore != b.hasMore) {
      discrepancies.add('hasMore mismatch: a=${a.hasMore} vs b=${b.hasMore}');
    }

    if (discrepancies.isEmpty) {
      return ShadowComparisonResult.match();
    }
    return ShadowComparisonResult.mismatch(discrepancies);
  }

  /// 比对点赞写操作返回结果。
  static ShadowComparisonResult compareLikeResult(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final discrepancies = <String>[];
    final targetId = a['id']?.toString() ?? '';

    if (a['liked'] != b['liked']) {
      discrepancies.add('liked mismatch: a=${a['liked']} vs b=${b['liked']}');
    }
    if (a['id'] != b['id']) {
      discrepancies.add('id mismatch: a="${a['id']}" vs b="${b['id']}"');
    }
    if (a['target_type'] != b['target_type']) {
      discrepancies.add(
          'target_type mismatch: a="${a['target_type']}" vs b="${b['target_type']}"');
    }

    if (discrepancies.isEmpty) {
      return ShadowComparisonResult.match(targetId);
    }
    return ShadowComparisonResult.mismatch(discrepancies, targetId);
  }

  /// 比对收藏写操作返回结果。
  static ShadowComparisonResult compareBookmarkResult(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final discrepancies = <String>[];
    final targetId = a['id']?.toString() ?? '';

    if (a['bookmarked'] != b['bookmarked']) {
      discrepancies.add(
          'bookmarked mismatch: a=${a['bookmarked']} vs b=${b['bookmarked']}');
    }
    if (a['id'] != b['id']) {
      discrepancies.add('id mismatch: a="${a['id']}" vs b="${b['id']}"');
    }

    if (discrepancies.isEmpty) {
      return ShadowComparisonResult.match(targetId);
    }
    return ShadowComparisonResult.mismatch(discrepancies, targetId);
  }

  static bool _areListsEqual<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
