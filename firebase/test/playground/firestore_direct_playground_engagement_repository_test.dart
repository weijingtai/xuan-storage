/// RED: Firestore 直写互动仓库（like/bookmark，Task 5）。
///
/// Design §3.3/§4.2/§8：
/// - like public fact + 私有 like_owner 同批写入；
/// - likeId = sha256(v1|like|authUid|targetId)；同批删除；
/// - bookmark 沿用既有 `user_provider_uid/user_app_user_id` 命名；
/// - 零 outbox/notification/callable。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firestore_direct_playground_engagement_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const aliceUid = 'alice-uid';
  const aliceApp = 'app-alice';
  const alicePresentation = 'pub_alice_pres_128bit';
  const aliceAlias = '玄友0001';

  const postId = 'post-1';
  const replyId = 'reply-1';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late FirestoreDirectPlaygroundEngagementRepository repo;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final mockUser = MockUser(uid: aliceUid, isAnonymous: false);
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    repo = FirestoreDirectPlaygroundEngagementRepository(
      firestore: firestore,
      auth: mockAuth,
    );
    await firestore.collection('identity_map').doc(aliceUid).set({
      'app_user_id': aliceApp,
      'provider_uid': aliceUid,
      'provider_id': 'firebase',
      'public_presentation_id': alicePresentation,
      'public_display_alias': aliceAlias,
    });
  });

  group('setContentLike（§4.2）', () {
    test('like 同批写 public fact + 私有 like_owner', () async {
      await repo.setContentLike(SetContentLikeCommand.post(
        PlaygroundPostId(postId),
        liked: true,
        idempotencyKey: 'like-key-1',
      ));

      final likeSnaps = await firestore.collection('playground_likes').get();
      expect(likeSnaps.docs, hasLength(1));
      final like = likeSnaps.docs.single.data();
      expect(like['target_type'], 'post');
      expect(like['target_id'], postId);
      // public fact 零内部 UID。
      expect(like.containsKey('provider_uid'), isFalse);
      expect(like.containsKey('app_user_id'), isFalse);

      // owner 文档。
      final ownerSnaps =
          await firestore.collection('playground_like_owners').get();
      expect(ownerSnaps.docs, hasLength(1));
      final owner = ownerSnaps.docs.single.data();
      expect(owner['like_id'], likeSnaps.docs.single.id);
      expect(owner['provider_uid'], aliceUid);
      expect(owner['app_user_id'], aliceApp);
      expect(owner['target_type'], 'post');
      expect(owner['target_id'], postId);
    });

    test('likeId = sha256(v1|like|authUid|targetId) 确定性', () async {
      await repo.setContentLike(SetContentLikeCommand.post(
        PlaygroundPostId(postId),
        liked: true,
        idempotencyKey: 'like-key-2',
      ));
      final snaps = await firestore.collection('playground_likes').get();
      final docId = snaps.docs.single.id;
      expect(docId, hasLength(64));
      expect(docId, isNot(contains(aliceUid)),
          reason: 'like ID 不得暴露 provider UID 原文');
    });

    test('unlike 删除 public fact + owner 同批', () async {
      // 先 like 再 unlike。
      await repo.setContentLike(SetContentLikeCommand.post(
        PlaygroundPostId(postId),
        liked: true,
        idempotencyKey: 'like-key-3',
      ));
      await repo.setContentLike(SetContentLikeCommand.post(
        PlaygroundPostId(postId),
        liked: false,
        idempotencyKey: 'like-key-3',
      ));

      expect((await firestore.collection('playground_likes').get()).docs, isEmpty);
      expect(
          (await firestore.collection('playground_like_owners').get()).docs,
          isEmpty);
    });

    test('reply 目标：target_type=reply', () async {
      await repo.setContentLike(SetContentLikeCommand.reply(
        PlaygroundReplyId(replyId),
        liked: true,
        idempotencyKey: 'like-key-4',
      ));
      final like = (await firestore.collection('playground_likes').get())
          .docs
          .single
          .data();
      expect(like['target_type'], 'reply');
      expect(like['target_id'], replyId);
    });

    test('零 outbox/notification/callable', () async {
      await repo.setContentLike(SetContentLikeCommand.post(
        PlaygroundPostId(postId),
        liked: true,
        idempotencyKey: 'like-key-5',
      ));
      final outbox = await firestore.collection('playground_outbox').get();
      expect(outbox.docs, isEmpty);
      final notif = await firestore.collection('playground_notifications').get();
      expect(notif.docs, isEmpty);
    });
  });

  group('setBookmark（§4.2）', () {
    test('bookmark 沿用 user_provider_uid/user_app_user_id 命名', () async {
      await repo.setBookmark(SetBookmarkCommand(
        postId: PlaygroundPostId(postId),
        bookmarked: true,
        idempotencyKey: 'bm-key-1',
      ));

      final snaps = await firestore.collection('playground_bookmarks').get();
      expect(snaps.docs, hasLength(1));
      final bm = snaps.docs.single.data();
      expect(bm['user_provider_uid'], aliceUid);
      expect(bm['user_app_user_id'], aliceApp);
      expect(bm['post_id'], postId);
    });

    test('unbookmark 删除', () async {
      await repo.setBookmark(SetBookmarkCommand(
        postId: PlaygroundPostId(postId),
        bookmarked: true,
        idempotencyKey: 'bm-key-2',
      ));
      await repo.setBookmark(SetBookmarkCommand(
        postId: PlaygroundPostId(postId),
        bookmarked: false,
        idempotencyKey: 'bm-key-2',
      ));
      expect(
          (await firestore.collection('playground_bookmarks').get()).docs,
          isEmpty);
    });
  });

  group('getViewerState / getMyBookmarkedPosts', () {
    test('getViewerState 反映 isLiked/isBookmarked', () async {
      await repo.setContentLike(SetContentLikeCommand.post(
        PlaygroundPostId(postId),
        liked: true,
        idempotencyKey: 'like-vs-1',
      ));
      await repo.setBookmark(SetBookmarkCommand(
        postId: PlaygroundPostId(postId),
        bookmarked: true,
        idempotencyKey: 'bm-vs-1',
      ));

      final state = await repo.getViewerState(PostTarget(PlaygroundPostId(postId)));
      expect(state.isLiked, isTrue);
      expect(state.isBookmarked, isTrue);
    });

    test('getMyBookmarkedPosts 返回本人收藏', () async {
      // seed 一个 post 文档。
      await firestore.collection('playground_posts').doc('post-bm-1').set({
        'id': 'post-bm-1',
        'text': '被收藏帖',
        'status': 'active',
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      await repo.setBookmark(SetBookmarkCommand(
        postId: PlaygroundPostId('post-bm-1'),
        bookmarked: true,
        idempotencyKey: 'bm-list-1',
      ));

      final page = await repo.getMyBookmarkedPosts();
      expect(page.items, isNotEmpty);
      expect(page.items.first.publicPostId.value, 'post-bm-1');
    });
  });
}
