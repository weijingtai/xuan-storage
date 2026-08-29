/// FirebasePlaygroundSafetyRepository 契约测试（fake_cloud_firestore）。
///
/// 断言：
/// 1. blockUser → httpsCallable('block_user_py')，入参白名单
///    （targetAppUserId/idempotency_key），**零可伪造身份字段**；
/// 2. unblockUser → httpsCallable('unblock_user_py')，入参白名单；
/// 3. isBlocked 直连读 `playground_blocks/block_{caller}_{target}` 固定文档；
/// 4. getBlockedUsers 按 `blocker_app_user_id` 过滤 + join `playground_profiles`
///    组装安全 [PublicAuthor]（display_name/avatar_url），支持游标分页；
/// 5. Functions 异常经 FirebasePlaygroundErrorMapper 映射为 [PlaygroundError]。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';
import 'package:persistence_firebase/playground/firebase_playground_safety_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_schema.dart';

import 'fake_callable_functions.dart';

const forbiddenIdentityKeys = <String>[
  'blocker_provider_uid',
  'blocker_app_user_id',
  'blocked_app_user_id',
  'appUserId',
  'user_provider_uid',
  'user_app_user_id',
  'author_provider_uid',
  'author_app_user_id',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const providerUid = 'safety-provider-uid';
  const caller = 'safety-caller';
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FakeFirebaseFunctions functions;
  late FirebasePlaygroundSafetyRepository repo;

  Future<void> seedIdentity({String uid = providerUid}) async {
    await firestore.collection('identity_map').doc(uid).set({
      'app_user_id': caller,
      'provider_uid': uid,
      'provider_id': 'firebase',
      'public_presentation_id': 'pub_safety_128bit',
      'public_display_alias': '安全测试用户',
    });
  }

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: providerUid, isAnonymous: false),
      signedIn: true,
    );
    functions = FakeFirebaseFunctions();
    // 模拟 Functions 服务端落库语义（与后端 _block_user_impl 固定 doc id 一致）。
    functions.handlers['block_user_py'] = (params) async {
      final target = params?['targetAppUserId'] as String?;
      await firestore
          .collection(PlaygroundFirestoreSchema.blocks)
          .doc('block_${caller}_$target')
          .set({
        'id': 'block_${caller}_$target',
        'blocker_provider_uid': providerUid,
        'blocker_app_user_id': caller,
        'blocked_app_user_id': target,
        'created_at': DateTime.utc(2026, 8, 1),
      });
      return <String, dynamic>{'blocked': true};
    };
    functions.handlers['unblock_user_py'] = (params) async {
      final target = params?['targetAppUserId'] as String?;
      await firestore
          .collection(PlaygroundFirestoreSchema.blocks)
          .doc('block_${caller}_$target')
          .delete();
      return <String, dynamic>{'unblocked': true, 'removed': 1};
    };
    repo = FirebasePlaygroundSafetyRepository(
      firestore: firestore,
      auth: auth,
      identityResolver: FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: auth,
      ),
      functions: functions,
    );
    await seedIdentity();
  });

  group('blockUser（callable 白名单）', () {
    test('httpsCallable("block_user_py")，仅 targetAppUserId/idempotency_key', () async {
      await repo.blockUser(const BlockUserCommand(
        blockedUserId: PlaygroundUserId('target-1'),
        idempotencyKey: 'block-key-1',
      ));

      expect(functions.calledNames, contains('block_user_py'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'block 入参不得包含身份字段 $key');
      }
      expect(params['targetAppUserId'], 'target-1');
      expect(params['idempotency_key'], 'block-key-1');
    });

    test('blockUser 成功后可经 isBlocked 直读验证（服务端落库语义）', () async {
      await repo.blockUser(
        const BlockUserCommand(blockedUserId: PlaygroundUserId('target-1')),
      );

      expect(await repo.isBlocked(const PlaygroundUserId('target-1')), isTrue);
      expect(await repo.isBlocked(const PlaygroundUserId('target-2')), isFalse);
    });

    test('Functions 异常映射为 PlaygroundError', () async {
      functions.throwFor['block_user_py'] = FirebaseFunctionsException(
        code: 'permission-denied',
        message: 'mock denial',
      );

      expect(
        () => repo.blockUser(
          const BlockUserCommand(blockedUserId: PlaygroundUserId('target-1')),
        ),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.forbidden)),
      );
    });
  });

  group('unblockUser（callable 白名单）', () {
    test('httpsCallable("unblock_user_py")，仅 targetAppUserId', () async {
      await repo.unblockUser(const PlaygroundUserId('target-1'));

      expect(functions.calledNames, contains('unblock_user_py'));
      final params = functions.calledParameters.last!;
      expect(params, {'targetAppUserId': 'target-1'});
    });

    test('解除后 isBlocked 返回 false 且黑名单列表移除', () async {
      await repo.blockUser(
        const BlockUserCommand(blockedUserId: PlaygroundUserId('target-1')),
      );
      expect(await repo.isBlocked(const PlaygroundUserId('target-1')), isTrue);

      await repo.unblockUser(const PlaygroundUserId('target-1'));

      expect(await repo.isBlocked(const PlaygroundUserId('target-1')), isFalse);
      final page = await repo.getBlockedUsers();
      expect(page.items, isEmpty);
    });
  });

  group('getBlockedUsers（直连读 + join profiles）', () {
    test('未登录返回空页', () async {
      final unsignedRepo = FirebasePlaygroundSafetyRepository(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
        identityResolver: FirebasePlaygroundIdentityResolver(
          firestore: firestore,
          auth: MockFirebaseAuth(signedIn: false),
        ),
        functions: functions,
      );

      final page = await unsignedRepo.getBlockedUsers();
      expect(page.items, isEmpty);
      expect(page.totalCount, 0);
    });

    test('按 blocker 过滤并 join display_name/avatar_url 组装 PublicAuthor', () async {
      await firestore
          .collection(PlaygroundFirestoreSchema.blocks)
          .doc('block_${caller}_u-a')
          .set({
        'blocker_app_user_id': caller,
        'blocked_app_user_id': 'u-a',
        'created_at': DateTime.utc(2026, 8, 2),
      });
      await firestore
          .collection(PlaygroundFirestoreSchema.blocks)
          .doc('block_${caller}_u-b')
          .set({
        'blocker_app_user_id': caller,
        'blocked_app_user_id': 'u-b',
        'created_at': DateTime.utc(2026, 8, 1),
      });
      // 他人拉黑不进入我的名单。
      await firestore
          .collection(PlaygroundFirestoreSchema.blocks)
          .doc('block_other_u-c')
          .set({
        'blocker_app_user_id': 'other',
        'blocked_app_user_id': 'u-c',
        'created_at': DateTime.utc(2026, 8, 1),
      });
      await firestore
          .collection(PlaygroundFirestoreSchema.profiles)
          .doc('u-a')
          .set({'display_name': '甲盘友', 'avatar_url': 'https://a/avatar.png'});

      final page = await repo.getBlockedUsers();

      expect(page.items, hasLength(2));
      // created_at 倒序：u-a（8/2）在前。
      final a = page.items[0];
      expect(a.publicPresentationUserId.value, 'u-a');
      expect(a.displayAlias, '甲盘友');
      expect(a.avatarUrl, 'https://a/avatar.png');
      final b = page.items[1];
      expect(b.publicPresentationUserId.value, 'u-b');
      expect(b.displayAlias, '盘友u-b',
          reason: '无 profile 时退回占位别名');
    });

    test('游标分页：limit 截断 + nextCursor 续页', () async {
      for (var i = 1; i <= 3; i++) {
        await firestore
            .collection(PlaygroundFirestoreSchema.blocks)
            .doc('block_${caller}_u-$i')
            .set({
          'blocker_app_user_id': caller,
          'blocked_app_user_id': 'u-$i',
          'created_at': DateTime.utc(2026, 8, i),
        });
      }

      final first = await repo.getBlockedUsers(limit: 2);
      expect(first.items, hasLength(2));
      expect(first.hasMore, isTrue);
      expect(first.nextCursor, isNotNull);

      final second = await repo.getBlockedUsers(
        cursor: first.nextCursor,
        limit: 2,
      );
      expect(second.items, hasLength(1));
      expect(second.hasMore, isFalse);
      final ids = [...first.items, ...second.items]
          .map((a) => a.publicPresentationUserId.value)
          .toSet();
      expect(ids, {'u-1', 'u-2', 'u-3'});
    });
  });

  group('isBlocked（直连读固定文档）', () {
    test('文档存在 → true；不存在 → false', () async {
      await firestore
          .collection(PlaygroundFirestoreSchema.blocks)
          .doc('block_${caller}_u-x')
          .set({
        'blocker_app_user_id': caller,
        'blocked_app_user_id': 'u-x',
        'created_at': DateTime.utc(2026, 8, 1),
      });

      expect(await repo.isBlocked(const PlaygroundUserId('u-x')), isTrue);
      expect(await repo.isBlocked(const PlaygroundUserId('u-y')), isFalse);
    });
  });
}
