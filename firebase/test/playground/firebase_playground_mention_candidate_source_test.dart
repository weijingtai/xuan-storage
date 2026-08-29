/// FirebasePlaygroundMentionCandidateSource 单元测试。
///
/// 用 FakeFirebaseFunctions 断言：
/// 1. 调用名必须是 `get_mention_candidates_py`（Python codebase 后缀）；
/// 2. 入参只含业务参数 `query` / `limit`，**零可伪造身份字段**；
/// 3. snake_case / camelCase 双字段兼容解析；
/// 4. 缺 id 的脏条目被过滤；错误经 FirebasePlaygroundErrorMapper 归一化。
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_mention_candidate_source.dart';

import 'fake_callable_functions.dart';

const _forbiddenIdentityKeys = <String>[
  'user_provider_uid',
  'user_app_user_id',
  'author_provider_uid',
  'author_app_user_id',
  'appUserId',
  'sender_provider_uid',
  'blocker_provider_uid',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFunctions functions;
  late FirebasePlaygroundMentionCandidateSource source;

  setUp(() {
    functions = FakeFirebaseFunctions();
    source = FirebasePlaygroundMentionCandidateSource(functions: functions);
  });

  test('调用名带 _py 后缀且入参只含 query/limit（零可伪造身份字段）', () async {
    functions.responses[FirebasePlaygroundMentionCandidateSource.callableName] =
        <String, dynamic>{
      'candidates': <dynamic>[],
      'total': 0,
    };

    await source.getCandidates(query: '玄', limit: 20);

    expect(functions.calledNames, [
      FirebasePlaygroundMentionCandidateSource.callableName,
    ]);
    final params = functions.calledParameters.single;
    expect(params, isNotNull);
    expect(params!['query'], '玄');
    expect(params['limit'], 20);
    for (final key in _forbiddenIdentityKeys) {
      expect(params.containsKey(key), isFalse,
          reason: 'callable 入参不得含可伪造身份键 $key');
    }
  });

  test('解析 snake_case 与 camelCase 双字段候选', () async {
    functions.responses[FirebasePlaygroundMentionCandidateSource.callableName] =
        <String, dynamic>{
      'candidates': <dynamic>[
        <String, dynamic>{
          'app_user_id': 'u1',
          'display_name': '玄木求真',
          'avatar_url': 'https://x/1.png',
        },
        <String, dynamic>{
          'appUserId': 'u2',
          'displayName': '紫微星君',
          'avatarUrl': 'https://x/2.png',
        },
      ],
      'total': 2,
    };

    final candidates = await source.getCandidates();

    expect(candidates, hasLength(2));
    expect(candidates[0].userId, const PlaygroundUserId('u1'));
    expect(candidates[0].displayName, '玄木求真');
    expect(candidates[0].avatarUrl, 'https://x/1.png');
    expect(candidates[1].userId, const PlaygroundUserId('u2'));
    expect(candidates[1].displayName, '紫微星君');
    expect(candidates[1].avatarUrl, 'https://x/2.png');
  });

  test('缺 id 的脏条目被过滤，空候选返回空列表', () async {
    functions.responses[FirebasePlaygroundMentionCandidateSource.callableName] =
        <String, dynamic>{
      'candidates': <dynamic>[
        <String, dynamic>{'display_name': '无 id 用户'},
        <String, dynamic>{
          'app_user_id': '',
          'display_name': '空 id 用户',
        },
      ],
      'total': 2,
    };

    final candidates = await source.getCandidates();

    expect(candidates, isEmpty);
  });

  test('callable 异常经 FirebasePlaygroundErrorMapper 归一化为 PlaygroundError',
      () async {
    functions.throwFor[
        FirebasePlaygroundMentionCandidateSource.callableName] =
        FirebaseFunctionsException(
      code: 'permission-denied',
      message: 'mock denial',
    );

    expect(
      () => source.getCandidates(),
      throwsA(
        isA<PlaygroundError>().having(
          (e) => e.code,
          'code',
          PlaygroundErrorCode.forbidden,
        ),
      ),
    );
  });
}
