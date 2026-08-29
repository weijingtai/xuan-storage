/// FirebasePlaygroundRelationshipRepository 契约测试（fake_cloud_firestore）。
///
/// 断言：
/// 1. followUser → httpsCallable('follow_user_py')，入参白名单
///    （targetAppUserId/idempotency_key），零可伪造身份字段；
/// 2. unfollowUser → httpsCallable('unfollow_user_py')，入参白名单；
/// 3. isFollowing 直连读 `playground_follows/follow_{caller}_{target}` 固定文档；
/// 4. getFollowingList/getFollowerList 按方向过滤 + join `playground_profiles`
///    组装 [RelationshipUser]（isFollowing/isFollower 标记），支持游标分页；
/// 5. getFriendList 仅返回互关用户；
/// 6. Functions 异常经 FirebasePlaygroundErrorMapper 映射为 [PlaygroundError]。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';
import 'package:persistence_firebase/playground/firebase_playground_relationship_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_schema.dart';

import 'fake_callable_functions.dart';

const forbiddenIdentityKeys = <String>[
  'follower_provider_uid',
  'follower_app_user_id',
  'following_app_user_id',
  'appUserId',
  'user_provider_uid',
  'user_app_user_id',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const providerUid = 'rel-provider-uid';
  const caller = 'rel-caller';
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FakeFirebaseFunctions functions;
  late FirebasePlaygroundRelationshipRepository repo;

  Future<void> seedIdentity({String uid = providerUid}) async {
    await firestore.collection('identity_map').doc(uid).set({
      'app_user_id': caller,
      'provider_uid': uid,
      'provider_id': 'firebase',
      'public_presentation_id': 'pub_rel_128bit',
      'public_display_alias': '关系测试用户',
    });
  }

  Future<void> seedFollow({
    required String follower,
    required String following,
    DateTime? createdAt,
  }) async {
    await firestore
        .collection(PlaygroundFirestoreSchema.follows)
        .doc('follow_${follower}_$following')
        .set({
      'id': 'follow_${follower}_$following',
      'follower_app_user_id': follower,
      'following_app_user_id': following,
      'follower_provider_uid': providerUid,
      'created_at': createdAt ?? DateTime.utc(2026, 8, 1),
    });
  }

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: providerUid, isAnonymous: false),
      signedIn: true,
    );
    functions = FakeFirebaseFunctions();
    // 模拟 Functions 服务端落库语义（与后端 _follow_user_impl 一致）。
    functions.handlers['follow_user_py'] = (params) async {
      final target = params?['targetAppUserId'] as String? ?? '';
      await seedFollow(follower: caller, following: target);
      return <String, dynamic>{
        'success': true,
        'following': true,
        'target_app_user_id': target,
      };
    };
    functions.handlers['unfollow_user_py'] = (params) async {
      final target = params?['targetAppUserId'] as String? ?? '';
      await firestore
          .collection(PlaygroundFirestoreSchema.follows)
          .doc('follow_${caller}_$target')
          .delete();
      return <String, dynamic>{
        'success': true,
        'following': false,
        'target_app_user_id': target,
      };
    };
    repo = FirebasePlaygroundRelationshipRepository(
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

  group('followUser（callable 白名单）', () {
    test('httpsCallable("follow_user_py")，仅 targetAppUserId/idempotency_key', () async {
      await repo.followUser(const FollowUserCommand(
        targetUserId: PlaygroundUserId('target-1'),
        idempotencyKey: 'follow-key-1',
      ));

      expect(functions.calledNames, contains('follow_user_py'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'follow 入参不得包含身份字段 $key');
      }
      expect(params['targetAppUserId'], 'target-1');
      expect(params['idempotency_key'], 'follow-key-1');
    });

    test('followUser 成功后可经 isFollowing 直读验证', () async {
      await repo.followUser(
        const FollowUserCommand(targetUserId: PlaygroundUserId('target-1')),
      );

      expect(await repo.isFollowing(const PlaygroundUserId('target-1')), isTrue);
      expect(await repo.isFollowing(const PlaygroundUserId('target-2')), isFalse);
    });

    test('Functions 异常映射为 PlaygroundError', () async {
      functions.throwFor['follow_user_py'] = FirebaseFunctionsException(
        code: 'permission-denied',
        message: 'mock denial',
      );

      expect(
        () => repo.followUser(
          const FollowUserCommand(targetUserId: PlaygroundUserId('target-1')),
        ),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.forbidden)),
      );
    });
  });

  group('unfollowUser（callable 白名单）', () {
    test('httpsCallable("unfollow_user_py")，仅 targetAppUserId', () async {
      await repo.unfollowUser(const UnfollowUserCommand(
        targetUserId: PlaygroundUserId('target-1'),
      ));

      expect(functions.calledNames, contains('unfollow_user_py'));
      final params = functions.calledParameters.last!;
      expect(params, {'targetAppUserId': 'target-1'});
    });

    test('取关后 isFollowing 返回 false', () async {
      await seedFollow(follower: caller, following: 'target-1');
      expect(await repo.isFollowing(const PlaygroundUserId('target-1')), isTrue);

      await repo.unfollowUser(const UnfollowUserCommand(
        targetUserId: PlaygroundUserId('target-1'),
      ));

      expect(await repo.isFollowing(const PlaygroundUserId('target-1')), isFalse);
    });
  });

  group('getFollowingList（直连读 + join profiles）', () {
    test('按 follower 过滤并组装 RelationshipUser', () async {
      await seedFollow(
        follower: caller,
        following: 'u-a',
        createdAt: DateTime.utc(2026, 8, 2),
      );
      await seedFollow(
        follower: caller,
        following: 'u-b',
        createdAt: DateTime.utc(2026, 8, 1),
      );
      // 他人关注不进我的关注列表。
      await seedFollow(follower: 'other', following: 'u-c');
      // u-a 也关注了我 → isFollower=true（好友候选）。
      await seedFollow(follower: 'u-a', following: caller);
      await firestore
          .collection(PlaygroundFirestoreSchema.profiles)
          .doc('u-a')
          .set({'display_name': '甲盘友', 'avatar_url': 'https://a/avatar.png'});

      final page = await repo.getFollowingList(const GetRelationshipListQuery(
        type: PlaygroundRelationshipListType.following,
      ));

      expect(page.items, hasLength(2));
      final a = page.items[0];
      expect(a.author.publicPresentationUserId.value, 'u-a');
      expect(a.author.displayAlias, '甲盘友');
      expect(a.isFollowing, isTrue);
      expect(a.isFollower, isTrue);
      final b = page.items[1];
      expect(b.isFollowing, isTrue);
      expect(b.isFollower, isFalse);
      expect(b.author.displayAlias, 'User_u-b',
          reason: '无 profile 时退回占位别名');
    });

    test('游标分页：limit 截断 + nextCursor 续页', () async {
      for (var i = 1; i <= 3; i++) {
        await seedFollow(
          follower: caller,
          following: 'u-$i',
          createdAt: DateTime.utc(2026, 8, i),
        );
      }

      final first = await repo.getFollowingList(const GetRelationshipListQuery(
        type: PlaygroundRelationshipListType.following,
        limit: 2,
      ));
      expect(first.items, hasLength(2));
      expect(first.hasMore, isTrue);
      expect(first.nextCursor, isNotNull);

      final second = await repo.getFollowingList(GetRelationshipListQuery(
        type: PlaygroundRelationshipListType.following,
        cursor: first.nextCursor,
        limit: 2,
      ));
      expect(second.items, hasLength(1));
      expect(second.hasMore, isFalse);
      final ids = [...first.items, ...second.items]
          .map((u) => u.author.publicPresentationUserId.value)
          .toSet();
      expect(ids, {'u-1', 'u-2', 'u-3'});
    });
  });

  group('getFollowerList', () {
    test('按 following 过滤并标记 isFollowing', () async {
      await seedFollow(follower: 'u-a', following: caller);
      await seedFollow(follower: 'u-b', following: caller);
      // 我关注了 u-b → u-b 的 isFollowing=true（互关）。
      await seedFollow(follower: caller, following: 'u-b');

      final page = await repo.getFollowerList(const GetRelationshipListQuery(
        type: PlaygroundRelationshipListType.followers,
      ));

      expect(page.items, hasLength(2));
      final byId = {
        for (final u in page.items) u.author.publicPresentationUserId.value: u,
      };
      expect(byId['u-a']!.isFollowing, isFalse);
      expect(byId['u-b']!.isFollowing, isTrue);
      expect(byId['u-b']!.isFollower, isTrue);
    });
  });

  group('getFriendList', () {
    test('仅返回互关用户', () async {
      // 互关：caller ↔ u-a。
      await seedFollow(follower: caller, following: 'u-a');
      await seedFollow(follower: 'u-a', following: caller);
      // 单向：我关注 u-b，u-b 未回关。
      await seedFollow(follower: caller, following: 'u-b');

      final page = await repo.getFriendList(const GetRelationshipListQuery(
        type: PlaygroundRelationshipListType.friends,
      ));

      expect(page.items, hasLength(1));
      expect(page.items.first.author.publicPresentationUserId.value, 'u-a');
      expect(page.items.first.isFriend, isTrue);
    });
  });
}
