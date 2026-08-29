import 'package:cloud_functions/cloud_functions.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_error_mapper.dart';

/// Firebase 实现：@ 提及候选数据源。
///
/// 封装后端 callable `get_mention_candidates_py`（firebase.json 只部署 Python
/// functions，调用名必须带 `_py` 后缀）。候选顺序由后端保证：P0（我关注的/
/// 关注我的/会话参与者）> P1（公开 Profile），且自动排除自身与双向拉黑用户。
///
/// 入参只含业务参数 `query` / `limit`，actor 由 Functions Auth context 派生，
/// **零可伪造身份字段**（与 BLOCK-01 callable adapter 同一约束）。
final class FirebasePlaygroundMentionCandidateSource
    implements MentionCandidateSource {
  FirebasePlaygroundMentionCandidateSource({
    FirebaseFunctions? functions,
  }) : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  static const String callableName = 'get_mention_candidates_py';

  @override
  Future<List<MentionCandidate>> getCandidates({
    String query = '',
    int limit = 20,
  }) async {
    try {
      final result = await _functions
          .httpsCallable(callableName)
          .call<Map<String, dynamic>>(<String, dynamic>{
        'query': query,
        'limit': limit,
      });
      final data = result.data;
      final raw = (data['candidates'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>();
      return raw
          .map((item) => MentionCandidate(
                userId: PlaygroundUserId(
                  _readString(item, 'app_user_id') ??
                      _readString(item, 'appUserId') ??
                      '',
                ),
                displayName: _readString(item, 'display_name') ??
                    _readString(item, 'displayName') ??
                    '用户',
                avatarUrl:
                    _readString(item, 'avatar_url') ??
                        _readString(item, 'avatarUrl'),
              ))
          .where((candidate) => candidate.userId.value.isNotEmpty)
          .toList(growable: false);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  static String? _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is String && value.isNotEmpty ? value : null;
  }
}
