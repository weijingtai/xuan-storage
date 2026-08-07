/// S2 契约套件在 firebase 拓扑下的实例化（C1-C10 全绿）。
///
/// 消费 `core/lib/test_support/playground_contract_suite.dart`，
/// 注入 firebase 真实现（fake_cloud_firestore + MockFirebaseAuth）与
/// 内存缓存 store（`playground_in_memory_cache_stores.dart`）。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/test_support/playground_contract_suite.dart';
import 'package:persistence_core/test_support/playground_in_memory_cache_stores.dart';
import 'package:persistence_firebase/cached_playground_bookmark_repository.dart';
import 'package:persistence_firebase/cached_playground_feed_repository.dart';
import 'package:persistence_firebase/cached_playground_like_repository.dart';
import 'package:persistence_firebase/cached_playground_post_repository.dart';
import 'package:persistence_firebase/cached_playground_reply_repository.dart';
import 'package:persistence_firebase/media/exif_stripper.dart';
import 'package:persistence_firebase/playground/firebase_playground_bookmark_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_feed_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';
import 'package:persistence_firebase/playground/firebase_playground_like_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_moderation_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_post_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_reply_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_schema.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testUid = 'contract-user-uid';
  const appUserId = 'contract-app-user';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late FirebasePlaygroundIdentityResolver identityResolver;

  // 契约套件要求 makeRepository 与 makeCacheStore 共享同一缓存实例。
  late InMemoryPlaygroundPostCacheStore postCache;
  late InMemoryPlaygroundReplyCacheStore replyCache;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(uid: testUid, isAnonymous: false),
      signedIn: true,
    );
    identityResolver = FirebasePlaygroundIdentityResolver(
      firestore: firestore,
      auth: mockAuth,
    );
    postCache = InMemoryPlaygroundPostCacheStore();
    replyCache = InMemoryPlaygroundReplyCacheStore();

    await firestore
        .collection(PlaygroundFirestoreSchema.identityMap)
        .doc(testUid)
        .set({
      'app_user_id': appUserId,
      'provider_uid': testUid,
    });
  });

  // ---- C1 + C3：帖子 ----
  runPlaygroundPostContractSuite(
    topologyName: 'firebase',
    makeRepository: () => CachedPlaygroundPostRepository(
      remote: FirebasePlaygroundPostRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      ),
      cache: postCache,
    ),
    makeRemote: () => FirebasePlaygroundPostRepository(
      firestore: firestore,
      auth: mockAuth,
      identityResolver: identityResolver,
    ),
    makeCacheStore: () => postCache,
  );

  // ---- C2：Feed ----
  runPlaygroundFeedContractSuite(
    topologyName: 'firebase',
    makeFeedRepository: () => CachedPlaygroundFeedRepository(
      remote: FirebasePlaygroundFeedRepository(firestore: firestore),
      cache: postCache,
    ),
    makePostRemote: () => FirebasePlaygroundPostRepository(
      firestore: firestore,
      auth: mockAuth,
      identityResolver: identityResolver,
    ),
    makeCacheStore: () => postCache,
  );

  // ---- C4：点赞（不缓存） ----
  runPlaygroundLikeContractSuite(
    topologyName: 'firebase',
    makeLikeRepository: () => CachedPlaygroundLikeRepository(
      remote: FirebasePlaygroundLikeRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      ),
    ),
    makeLikeRemote: () => FirebasePlaygroundLikeRepository(
      firestore: firestore,
      auth: mockAuth,
      identityResolver: identityResolver,
    ),
  );

  // ---- C5：收藏（不缓存） ----
  runPlaygroundBookmarkContractSuite(
    topologyName: 'firebase',
    makeBookmarkRepository: () => CachedPlaygroundBookmarkRepository(
      remote: FirebasePlaygroundBookmarkRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      ),
    ),
    makeBookmarkRemote: () => FirebasePlaygroundBookmarkRepository(
      firestore: firestore,
      auth: mockAuth,
      identityResolver: identityResolver,
    ),
  );

  // ---- C6：EXIF 剥离 ----
  runPlaygroundMediaContractSuite(
    topologyName: 'firebase',
    makeStripExif: stripExif,
  );

  // ---- C9：评论 ----
  runPlaygroundReplyContractSuite(
    topologyName: 'firebase',
    makeReplyRepository: () => CachedPlaygroundReplyRepository(
      remote: FirebasePlaygroundReplyRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      ),
      cache: replyCache,
    ),
    makeReplyRemote: () => FirebasePlaygroundReplyRepository(
      firestore: firestore,
      auth: mockAuth,
      identityResolver: identityResolver,
    ),
  );

  // ---- C10：举报 + 下架 + 紧急下架 ----
  runPlaygroundModerationContractSuite(
    topologyName: 'firebase',
    makeModerationRepository: () => FirebasePlaygroundModerationRepository(
      firestore: firestore,
      auth: mockAuth,
      identityResolver: identityResolver,
    ),
    makePostRemote: () => FirebasePlaygroundPostRepository(
      firestore: firestore,
      auth: mockAuth,
      identityResolver: identityResolver,
    ),
  );

  // ---- C10 落库断言（REVIEW-S2 §9-6）：举报必须真实写入 Firestore ----
  group('契约 · 举报落库 · firebase', () {
    test('reportContent 后 playground_reports 集合出现该条文档', () async {
      final postRepo = FirebasePlaygroundPostRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      );
      final moderation = FirebasePlaygroundModerationRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      );

      final post = await postRepo.createPost(
        const CreatePostCommand(text: '待举报帖子'),
      );
      await moderation.reportContent(
        ReportContentCommand(
          postId: post.id,
          reason: PlaygroundReportReason.misinformation,
          description: '落库断言',
        ),
      );

      // 断言：reports 集合出现该条文档，post_id 与 reason 落库。
      final snaps = await firestore
          .collection(PlaygroundFirestoreSchema.reports)
          .where('post_id', isEqualTo: post.id.value)
          .get();
      expect(snaps.docs, isNotEmpty,
          reason: 'C10: reportContent 必须写入 playground_reports 集合');
      final doc = snaps.docs.first.data();
      expect(doc['post_id'], post.id.value);
      expect(doc['reason'], PlaygroundReportReason.misinformation.name);
    });
  });
}
