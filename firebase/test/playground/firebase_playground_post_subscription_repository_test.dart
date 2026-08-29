/// Firebase 直写帖子订阅/静音仓库测试。
///
/// 覆盖（Task: 帖子事件订阅与静音）：
/// - subscribe 幂等合并、muted=false/follows_post=true、未知事件不落库；
/// - unsubscribe 删除（幂等）；
/// - mute 收缩事件保留集合、muted=true/follows_post=false；
/// - getMySubscription 读回、getMySubscriptions 分页；
/// - 错误映射（未认证/缺幂等键）。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_post_subscription_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_cursor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const aliceUid = 'alice-uid';
  const aliceApp = 'app-alice';

  const postId = 'post-1';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late FirebasePlaygroundPostSubscriptionRepository repo;

  Future<void> seedIdentity(String uid, String appUserId) async {
    await firestore.collection('identity_map').doc(uid).set({
      'app_user_id': appUserId,
      'provider_uid': uid,
      'provider_id': 'firebase',
      'public_presentation_id': 'pub_${appUserId}_pres',
      'public_display_alias': '玄友-$appUserId',
    });
  }

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final mockUser = MockUser(uid: aliceUid, isAnonymous: false);
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    repo = FirebasePlaygroundPostSubscriptionRepository(
      firestore: firestore,
      auth: mockAuth,
    );
    await seedIdentity(aliceUid, aliceApp);
  });

  group('subscribePostEvents', () {
    test('落库 playground_post_subscriptions 并可被 getMySubscription 读回', () async {
      await repo.subscribePostEvents(
        SubscribePostEventsCommand(
          postId: PlaygroundPostId(postId),
          enabledEvents: const {
            PlaygroundSubscriptionEventType.outcomeFeedback,
            PlaygroundSubscriptionEventType.authorUpdate,
          },
          idempotencyKey: 'sub-key-1',
        ),
      );

      final snaps = await firestore
          .collection('playground_post_subscriptions')
          .get();
      expect(snaps.docs, hasLength(1));
      final doc = snaps.docs.single;
      // 文档 id 建议：sub_{subscriberAppUserId}_{postId}。
      expect(doc.id, 'sub_${aliceApp}_$postId');
      final data = doc.data();
      expect(data['subscriber_app_user_id'], aliceApp);
      expect(data['post_id'], postId);
      expect(
        (data['enabled_events'] as List).toSet(),
        {'outcomeFeedback', 'authorUpdate'},
      );
      expect(data['muted'], isFalse);
      expect(data['follows_post'], isTrue);
      expect(data['created_at'], isA<Timestamp>());
      expect(data['updated_at'], isA<Timestamp>());

      final subscription = await repo.getMySubscription(
        PlaygroundPostId(postId),
      );
      expect(subscription, isNotNull);
      expect(subscription!.postId, const PlaygroundPostId(postId));
      expect(subscription.subscriberUserId, const PlaygroundUserId(aliceApp));
      expect(subscription.enabledEvents, {
        PlaygroundSubscriptionEventType.outcomeFeedback,
        PlaygroundSubscriptionEventType.authorUpdate,
      });
      expect(subscription.muted, isFalse);
      expect(subscription.followsPost, isTrue);
    });

    test('重复订阅幂等合并（并集）且不重复文档', () async {
      await repo.subscribePostEvents(
        SubscribePostEventsCommand(
          postId: PlaygroundPostId(postId),
          enabledEvents: const {
            PlaygroundSubscriptionEventType.outcomeFeedback,
          },
          idempotencyKey: 'sub-key-2',
        ),
      );
      await repo.subscribePostEvents(
        SubscribePostEventsCommand(
          postId: PlaygroundPostId(postId),
          enabledEvents: const {
            PlaygroundSubscriptionEventType.newReply,
            PlaygroundSubscriptionEventType.authorUpdate,
          },
          idempotencyKey: 'sub-key-2b',
        ),
      );

      final snaps = await firestore
          .collection('playground_post_subscriptions')
          .get();
      expect(snaps.docs, hasLength(1));
      expect(
        (snaps.docs.single.data()['enabled_events'] as List).toSet(),
        {'outcomeFeedback', 'newReply', 'authorUpdate'},
      );
    });

    test('unknown 事件不落库', () async {
      await repo.subscribePostEvents(
        SubscribePostEventsCommand(
          postId: PlaygroundPostId(postId),
          enabledEvents: const {
            PlaygroundSubscriptionEventType.newReply,
            PlaygroundSubscriptionEventType.unknown,
          },
          idempotencyKey: 'sub-key-3',
        ),
      );

      final snap = await firestore
          .collection('playground_post_subscriptions')
          .doc('sub_${aliceApp}_$postId')
          .get();
      expect(
        (snap.data()!['enabled_events'] as List).toSet(),
        {'newReply'},
      );
    });

    test('缺少幂等键抛 invalidArgument', () async {
      await expectLater(
        repo.subscribePostEvents(
          SubscribePostEventsCommand(
            postId: PlaygroundPostId(postId),
            enabledEvents: const {PlaygroundSubscriptionEventType.newReply},
          ),
        ),
        throwsA(
          isA<PlaygroundError>().having(
            (e) => e.code,
            'code',
            PlaygroundErrorCode.invalidArgument,
          ),
        ),
      );
    });

    test('未登录抛 unauthenticated', () async {
      final unsigned = FirebasePlaygroundPostSubscriptionRepository(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );
      await expectLater(
        unsigned.subscribePostEvents(
          SubscribePostEventsCommand(
            postId: PlaygroundPostId(postId),
            enabledEvents: const {PlaygroundSubscriptionEventType.newReply},
            idempotencyKey: 'sub-key-4',
          ),
        ),
        throwsA(
          isA<PlaygroundError>().having(
            (e) => e.code,
            'code',
            PlaygroundErrorCode.unauthenticated,
          ),
        ),
      );
    });
  });

  group('unsubscribePost', () {
    test('删除订阅文档；不存在时幂等成功', () async {
      await repo.subscribePostEvents(
        SubscribePostEventsCommand(
          postId: PlaygroundPostId(postId),
          enabledEvents: const {PlaygroundSubscriptionEventType.newReply},
          idempotencyKey: 'unsub-key-1',
        ),
      );

      await repo.unsubscribePost(
        UnsubscribePostCommand(
          postId: PlaygroundPostId(postId),
          idempotencyKey: 'unsub-key-1',
        ),
      );

      final snaps = await firestore
          .collection('playground_post_subscriptions')
          .get();
      expect(snaps.docs, isEmpty);
      expect(
        await repo.getMySubscription(PlaygroundPostId(postId)),
        isNull,
      );

      // 幂等：再次取消不抛错。
      await repo.unsubscribePost(
        UnsubscribePostCommand(
          postId: PlaygroundPostId(postId),
          idempotencyKey: 'unsub-key-1',
        ),
      );
    });

    test('只删除本 actor 的订阅', () async {
      await repo.subscribePostEvents(
        SubscribePostEventsCommand(
          postId: PlaygroundPostId(postId),
          enabledEvents: const {PlaygroundSubscriptionEventType.newReply},
          idempotencyKey: 'unsub-key-2',
        ),
      );
      // 另一个 actor 订阅同一帖。
      await firestore
          .collection('playground_post_subscriptions')
          .doc('sub_app-bob_$postId')
          .set({
        'subscriber_app_user_id': 'app-bob',
        'post_id': postId,
        'enabled_events': ['newReply'],
        'muted': false,
        'follows_post': true,
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'updated_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      await repo.unsubscribePost(
        UnsubscribePostCommand(
          postId: PlaygroundPostId(postId),
          idempotencyKey: 'unsub-key-2',
        ),
      );

      final snaps = await firestore
          .collection('playground_post_subscriptions')
          .get();
      expect(snaps.docs, hasLength(1));
      expect(snaps.docs.single.id, 'sub_app-bob_$postId');
    });
  });

  group('mutePost', () {
    test('默认保留应验+重要更新，muted=true，follows_post=false', () async {
      await repo.mutePost(
        MutePostCommand(postId: PlaygroundPostId(postId), idempotencyKey: 'mute-key-1'),
      );

      final snap = await firestore
          .collection('playground_post_subscriptions')
          .doc('sub_${aliceApp}_$postId')
          .get();
      final data = snap.data()!;
      expect(data['muted'], isTrue);
      expect(data['follows_post'], isFalse);
      expect(
        (data['enabled_events'] as List).toSet(),
        {'outcomeFeedback', 'authorUpdate'},
      );

      final subscription = await repo.getMySubscription(
        PlaygroundPostId(postId),
      );
      expect(subscription, isNotNull);
      expect(subscription!.muted, isTrue);
      expect(subscription.followsPost, isFalse);
      expect(subscription.enabledEvents, {
        PlaygroundSubscriptionEventType.outcomeFeedback,
        PlaygroundSubscriptionEventType.authorUpdate,
      });
    });

    test('keepOutcomeFeedback=false 时关闭应验', () async {
      await repo.mutePost(
        MutePostCommand(
          postId: PlaygroundPostId(postId),
          keepOutcomeFeedback: false,
          idempotencyKey: 'mute-key-2',
        ),
      );

      final snap = await firestore
          .collection('playground_post_subscriptions')
          .doc('sub_${aliceApp}_$postId')
          .get();
      expect(
        (snap.data()!['enabled_events'] as List).toSet(),
        {'authorUpdate'},
      );
    });

    test('从已订阅状态静音：事件收缩为保留集合交集', () async {
      await repo.subscribePostEvents(
        SubscribePostEventsCommand(
          postId: PlaygroundPostId(postId),
          enabledEvents: const {
            PlaygroundSubscriptionEventType.newReply,
            PlaygroundSubscriptionEventType.outcomeFeedback,
            PlaygroundSubscriptionEventType.authorUpdate,
          },
          idempotencyKey: 'mute-key-3',
        ),
      );
      await repo.mutePost(
        MutePostCommand(
          postId: PlaygroundPostId(postId),
          keepOutcomeFeedback: false,
          idempotencyKey: 'mute-key-3',
        ),
      );

      final snap = await firestore
          .collection('playground_post_subscriptions')
          .doc('sub_${aliceApp}_$postId')
          .get();
      final data = snap.data()!;
      expect(data['muted'], isTrue);
      // newReply 被关闭、outcomeFeedback 被关闭、authorUpdate 保留。
      expect(
        (data['enabled_events'] as List).toSet(),
        {'authorUpdate'},
      );
    });

    test('重复静音幂等且不重复文档', () async {
      await repo.mutePost(
        MutePostCommand(postId: PlaygroundPostId(postId), idempotencyKey: 'mute-key-4'),
      );
      await repo.mutePost(
        MutePostCommand(postId: PlaygroundPostId(postId), idempotencyKey: 'mute-key-4'),
      );

      final snaps = await firestore
          .collection('playground_post_subscriptions')
          .get();
      expect(snaps.docs, hasLength(1));
    });
  });

  group('getMySubscriptions', () {
    test('返回本人订阅列表（只含本人）', () async {
      await repo.subscribePostEvents(
        SubscribePostEventsCommand(
          postId: PlaygroundPostId('post-a'),
          enabledEvents: const {PlaygroundSubscriptionEventType.newReply},
          idempotencyKey: 'list-key-1',
        ),
      );
      await repo.subscribePostEvents(
        SubscribePostEventsCommand(
          postId: PlaygroundPostId('post-b'),
          enabledEvents: const {
            PlaygroundSubscriptionEventType.outcomeFeedback,
          },
          idempotencyKey: 'list-key-2',
        ),
      );
      await firestore
          .collection('playground_post_subscriptions')
          .doc('sub_app-bob_post-c')
          .set({
        'subscriber_app_user_id': 'app-bob',
        'post_id': 'post-c',
        'enabled_events': ['newReply'],
        'muted': false,
        'follows_post': true,
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'updated_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      final page = await repo.getMySubscriptions();
      expect(page.items, hasLength(2));
      expect(
        page.items.map((s) => s.postId.value).toSet(),
        {'post-a', 'post-b'},
      );
      expect(page.items.every((s) => s.subscriberUserId.value == aliceApp), isTrue);
    });

    test('limit 生效且 hasMore/nextCursor 正确', () async {
      for (var i = 0; i < 5; i++) {
        await firestore
            .collection('playground_post_subscriptions')
            .doc('sub_${aliceApp}_post-$i')
            .set({
          'subscriber_app_user_id': aliceApp,
          'post_id': 'post-$i',
          'enabled_events': ['newReply'],
          'muted': false,
          'follows_post': true,
          'created_at': Timestamp.fromDate(DateTime(2026, 1, i + 1)),
          'updated_at': Timestamp.fromDate(DateTime(2026, 1, i + 1)),
        });
      }

      final page = await repo.getMySubscriptions(limit: 3);
      expect(page.items, hasLength(3));
      expect(page.hasMore, isTrue);
      expect(page.nextCursor, isNotNull);
      // cursor 是值编码的（可解码出 updated_at），且第二页续扫不重复。
      final values = FirebasePlaygroundCursor.toStartAfterValues(
        page.nextCursor!,
      );
      expect(values, isNotNull);
      expect(values, hasLength(1));

      final page2 = await repo.getMySubscriptions(
        cursor: page.nextCursor,
        limit: 3,
      );
      expect(page2.items, hasLength(2));
      expect(page2.hasMore, isFalse);
      final page1Ids = page.items.map((s) => s.postId.value).toSet();
      expect(
        page2.items.every((s) => !page1Ids.contains(s.postId.value)),
        isTrue,
        reason: '第二页不得与第一页重复',
      );
    });

    test('无订阅返回空页', () async {
      final page = await repo.getMySubscriptions();
      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });

  group('getMySubscription', () {
    test('无订阅返回 null', () async {
      expect(await repo.getMySubscription(PlaygroundPostId(postId)), isNull);
    });

    test('读回 muted 文档使用 .muted 构造', () async {
      await repo.mutePost(
        MutePostCommand(postId: PlaygroundPostId(postId), idempotencyKey: 'get-key-1'),
      );
      final subscription = await repo.getMySubscription(
        PlaygroundPostId(postId),
      );
      expect(subscription, isNotNull);
      expect(subscription!.muted, isTrue);
      expect(subscription.followsPost, isFalse);
    });
  });
}
