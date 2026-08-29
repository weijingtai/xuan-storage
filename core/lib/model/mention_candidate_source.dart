/// @ 提及候选用户数据源契约（发帖/回复/聊天输入框共用）。
///
/// provider-neutral 端口：与 `playground_remote_data_source.dart` 同一分层
/// 定位——业务/UI 层只消费本接口，Firebase adapter 实现它，composition root
/// 装配。候选顺序由实现方保证（后端已按 P0 关注/粉丝/会话参与者 > P1 公开
/// Profile 排序，且自动排除自身与双向拉黑用户）。
library;

import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 一个 @ 提及候选用户（仅公开展示字段）。
final class MentionCandidate {
  const MentionCandidate({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });

  /// 用户唯一标识（app user id，即 `playground_profiles` 文档 id）。
  final PlaygroundUserId userId;

  /// 展示昵称/别名。
  final String displayName;

  /// 公开头像 URL（可为空，UI 回退到首字符占位）。
  final String? avatarUrl;
}

/// @ 候选数据源端口。
///
/// [query] 为 `@` 之后已输入的过滤词（可为空串 = 拉取 P0 默认列表）；
/// [limit] 服务端上限（Python callable 会 clamp 到 [1, 50]）。
abstract interface class MentionCandidateSource {
  Future<List<MentionCandidate>> getCandidates({
    String query = '',
    int limit = 20,
  });
}

/// 空实现（fail-closed）：不装配真实数据源时返回空列表，UI 不弹候选框。
final class EmptyMentionCandidateSource implements MentionCandidateSource {
  const EmptyMentionCandidateSource();

  @override
  Future<List<MentionCandidate>> getCandidates({
    String query = '',
    int limit = 20,
  }) async {
    return const <MentionCandidate>[];
  }
}
