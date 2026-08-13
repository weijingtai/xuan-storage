/// Phase 7B：Engagement adapter（FirebasePlaygroundEngagementRepository）
/// 契约测试 —— RED → GREEN。
///
/// 断言：
/// 1. setContentLike → httpsCallable("setLike")：入参白名单
///    （postId/replyId/action/idempotency_key），**零可伪造身份字段**；
/// 2. setBookmark → httpsCallable("setBookmark")：入参白名单
///    （postId/action），零身份字段；
/// 3. getViewerState 直连读（likes/bookmarks 集合，Rules 认证可读）：
///    PostTarget 返回 isLiked/isBookmarked/canVerify，ReplyTarget 返回 isLiked；
/// 4. getMyBookmarkedPosts 返回安全 [PublicPost]。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_schema.dart';
import 'package:persistence_firebase/playground/firebase_playground_engagement_repository.dart';

import 'fake_callable_functions.dart';

const forbiddenIdentityKeys = <String>[
  'user_provider_uid',
  'user_app_user_id',
  'author_provider_uid',
  'author_app_user_id',
  'appUserId',
  'isPoster',
  'verifier_provider_uid',
  'verifier_app_user_id',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const viewerUid = 'eng-viewer-uid';
  const authorUid = 'eng-author-uid';
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FakeFirebaseFunctions functions;
  late FirebasePlaygroundEngagementRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: viewerUid, isAnonymous: false),
      signedIn: true,
    );
    functions = FakeFirebaseFunctions();
    // 模拟 Functions 服务端落库语义（契约 C4：callable 成功后立刻可读）。
    functions.handlers['setLike'] = (params) async {
      final postId = params?['postId'] as String?;
      final replyId = params?['replyId'] as String?;
      final action = params?['action'] as String?;
      final targetType = postId != null ? 'post' : 'reply';
      final docId = postId != null
          ? 'like_post_${viewerUid}_$postId'
          : 'like_reply_${viewerUid}_$replyId';
      final ref = firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .doc(docId);
      if (action == 'like') {
        await ref.set({
          'user_provider_uid': viewerUid,
          'post_id': postId,
          'reply_id': replyId,
          'target_type': targetType,
          'created_at': DateTime.utc(2026, 1, 1),
        });
      } else {
        await ref.delete();
      }
      return <String, dynamic>{'liked': action == 'like', 'id': docId};
    };
    functions.handlers['setBookmark'] = (params) async {
      final postId = params?['postId'] as String?;
      final action = params?['action'] as String?;
      final docId = 'bookmark_${viewerUid}_$postId';
      final ref = firestore
          .collection(PlaygroundFirestoreSchema.bookmarks)
          .doc(docId);
      if (action == 'bookmark') {
        await ref.set({
          'user_provider_uid': viewerUid,
          'post_id': postId,
          'created_at': DateTime.utc(2026, 1, 1),
        });
      } else {
        await ref.delete();
      }
      return <String, dynamic>{'bookmarked': action == 'bookmark', 'id': docId};
    };
    repo = FirebasePlaygroundEngagementRepository(
      firestore: firestore,
      auth: auth,
      functions: functions,
    );
  });

  group('setContentLike（callable 白名单）', () {
    test('post like → httpsCallable("setLike")，仅 postId/action/idempotency_key',
        () async {
      await repo.setContentLike(SetContentLikeCommand.post(
        PlaygroundPostId('post-1'),
        liked: true,
        idempotencyKey: 'like-key-1',
      ));

      expect(functions.calledNames, contains('setLike'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'setLike 入参不得包含身份字段 $key');
      }
      expect(params['postId'], 'post-1');
      expect(params['action'], 'like');
      expect(params['idempotency_key'], 'like-key-1');
      expect(params.containsKey('replyId'), isFalse);
    });

    test('reply unlike → action=unlike + replyId', () async {
      await repo.setContentLike(SetContentLikeCommand.reply(
        PlaygroundReplyId('reply-1'),
        liked: false,
        idempotencyKey: 'like-key-2',
      ));

      final params = functions.calledParameters.last!;
      expect(params['replyId'], 'reply-1');
      expect(params['action'], 'unlike');
      expect(params['idempotency_key'], 'like-key-2');
      expect(params.containsKey('postId'), isFalse);
    });
  });

  group('setBookmark（callable 白名单）', () {
    test('bookmark → httpsCallable("setBookmark")，仅 postId/action', () async {
      await repo.setBookmark(const SetBookmarkCommand(
        postId: PlaygroundPostId('post-1'),
        bookmarked: true,
        idempotencyKey: 'book-key-1',
      ));

      expect(functions.calledNames, contains('setBookmark'));
      final params = functions.calledParameters.last!;
      for (final key in forbiddenIdentityKeys) {
        expect(params.containsKey(key), isFalse,
            reason: 'setBookmark 入参不得包含身份字段 $key');
      }
      expect(params['postId'], 'post-1');
      expect(params['action'], 'bookmark');
    });

    test('unbookmark → action=unbookmark', () async {
      await repo.setBookmark(const SetBookmarkCommand(
        postId: PlaygroundPostId('post-1'),
        bookmarked: false,
      ));
      final params = functions.calledParameters.last!;
      expect(params['action'], 'unbookmark');
    });
  });

  group('getViewerState（直连读）', () {
    Future<void> seedPost(String postId, {String? authorUid}) {
      return firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId)
          .set({
        'author_provider_uid': authorUid ?? 'eng-author-uid',
        'text': '帖文',
        'status': 'active',
        'created_at': DateTime.utc(2026, 1, 1),
      });
    }

    test('PostTarget：isLiked/isBookmarked/canVerify', () async {
      await seedPost('post-1', authorUid: authorUid);
      await firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .doc('like_post_${viewerUid}_post-1')
          .set({'post_id': 'post-1', 'user_provider_uid': viewerUid});
      await firestore
          .collection(PlaygroundFirestoreSchema.bookmarks)
          .doc('bookmark_${viewerUid}_post-1')
          .set({'post_id': 'post-1', 'user_provider_uid': viewerUid});

      final state = await repo.getViewerState(const PostTarget(PlaygroundPostId('post-1')));
      expect(state.isLiked, isTrue);
      expect(state.isBookmarked, isTrue);
      expect(state.canVerify, isTrue, reason: 'viewer 非作者可应验');
    });

    test('PostTarget：作者视角 canVerify=false', () async {
      await seedPost('my-post', authorUid: viewerUid);
      final state = await repo.getViewerState(const PostTarget(PlaygroundPostId('my-post')));
      expect(state.isLiked, isFalse);
      expect(state.isBookmarked, isFalse);
      expect(state.canVerify, isFalse, reason: '作者不能应验自己的帖');
    });

    test('ReplyTarget：isLiked 直连读 likes 集合', () async {
      await firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .doc('like_reply_${viewerUid}_reply-1')
          .set({'reply_id': 'reply-1', 'user_provider_uid': viewerUid});
      final state = await repo.getViewerState(const ReplyTarget(PlaygroundReplyId('reply-1')));
      expect(state.isLiked, isTrue);
      expect(state.isBookmarked, isFalse);
    });

    test('未登录 viewer → 空状态', () async {
      final anonRepo = FirebasePlaygroundEngagementRepository(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
        functions: functions,
      );
      final state =
          await anonRepo.getViewerState(const PostTarget(PlaygroundPostId('post-1')));
      expect(state.isLiked, isFalse);
      expect(state.isBookmarked, isFalse);
      expect(state.canVerify, isFalse);
    });
  });

  group('getMyBookmarkedPosts', () {
    test('返回安全 PublicPost（收藏帖正文可见）', () async {
      await firestore.collection(PlaygroundFirestoreSchema.posts).doc('p1').set({
        'author_provider_uid': authorUid,
        'text': '收藏的帖子',
        'status': 'active',
        'allowed_chart_technique_ids': <String>[],
        'attachments': <dynamic>[],
        'revisions': <dynamic>[],
        'has_outcome_feedback': false,
        'created_at': DateTime.utc(2026, 1, 1),
      });
      await firestore
          .collection(PlaygroundFirestoreSchema.bookmarks)
          .doc('bookmark_${viewerUid}_p1')
          .set({
        'user_provider_uid': viewerUid,
        'post_id': 'p1',
        'created_at': DateTime.utc(2026, 1, 2),
      });

      final page = await repo.getMyBookmarkedPosts();
      expect(page.items, isNotEmpty);
      expect(page.items.first, isA<PublicPost>());
      expect(page.items.first.publicPostId.value, 'p1');
      expect(page.items.first.body, '收藏的帖子');
    });

    test('收藏但底层帖子不可用时返回 tombstone 投影（不泄漏正文）', () async {
      await firestore
          .collection(PlaygroundFirestoreSchema.bookmarks)
          .doc('bookmark_${viewerUid}_gone')
          .set({
        'user_provider_uid': viewerUid,
        'post_id': 'gone',
        'created_at': DateTime.utc(2026, 1, 2),
      });

      final page = await repo.getMyBookmarkedPosts();
      expect(page.items, isNotEmpty);
      final item = page.items.first;
      expect(item.publicPostId.value, 'gone');
      expect(item.body, isNull);
      expect(item.displayStatus, PublicPostDisplayStatus.tombstoned);
    });
  });
}
