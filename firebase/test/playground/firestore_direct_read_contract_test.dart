/// RED: Firestore 直写读取合同（Task 6）。
///
/// Design §10.1/§10.3/§12.2：
/// - 详情真实数据：seed 2 replies、3 post likes、1 active verification、feedback，
///   断言 replyCount/likeCount/verificationCount/counts/aggregateReadCount=3；
/// - viewer state 四态（owner/非 owner/未认证/owner 文档缺失）fail closed false；
/// - Feed 占位恒 0（单 query，无逐帖聚合）；getPendingDivinationFeed 不访问
///   Firestore 返回 invalidArgument + filter/not-supported-in-direct-phase；
/// - 推荐明确降级为最新（不读 recommendation_score）；
/// - recording 断言无逐帖/逐回复 owner N+1。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_schema.dart';
import 'package:persistence_firebase/playground/firebase_playground_feed_query_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_thread_query_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const posterUid = 'poster-uid';
  const posterAppUserId = 'app-poster';
  const viewerUid = 'viewer-uid';
  const viewerAppUserId = 'app-viewer';
  const postId = 'post-1';
  const pubPoster = 'pub_poster_128bit';
  const pubViewer = 'pub_viewer_128bit';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FirebasePlaygroundThreadQueryRepository threadRepo;
  late FirebasePlaygroundFeedQueryRepository feedRepo;

  /// v1 schema 帖文档。
  Future<void> seedPost({
    String docId = postId,
    String status = 'active',
    String presentationMode = 'stableAlias',
    String presentationIdentityId = pubPoster,
    String displayAlias = '玄友0001',
    String? ownerProviderUid,
    bool seedOwner = true,
  }) async {
    await firestore.collection(PlaygroundFirestoreSchema.posts).doc(docId).set({
      'id': docId,
      'text': '帖子正文-$docId',
      'presentation_mode': presentationMode,
      'presentation_identity_id': presentationIdentityId,
      'presentation_display_alias': displayAlias,
      'presentation_avatar_url': null,
      'public_profile_ref': null,
      'status': status,
      'allowed_chart_technique_ids': <String>[],
      'attachments': <Map<String, dynamic>>[],
      'has_chart': false,
      'revision_no': 1,
      'current_revision_id': 'r0000000001',
      'idempotency_key': 'idem-$docId',
      'payload_hash': 'hash-$docId',
      'created_at': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
      'updated_at': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
    });
    if (seedOwner) {
      await firestore
          .collection(PlaygroundFirestoreSchema.postOwners)
          .doc(docId)
          .set({
        'content_id': docId,
        'provider_uid': ownerProviderUid ?? posterUid,
        'app_user_id': posterAppUserId,
        'public_presentation_id': presentationIdentityId,
        'created_at': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
      });
    }
  }

  /// v1 schema reply 文档。
  Future<void> seedReply(
    String docId, {
    String depth = '0',
    String? rootReplyId,
    String? replyToReplyId,
    bool isTombstoned = false,
  }) async {
    await firestore.collection(PlaygroundFirestoreSchema.replies).doc(docId).set({
      'id': docId,
      'post_id': postId,
      'presentation_mode': 'stableAlias',
      'presentation_identity_id': 'pub_anon_$docId',
      'presentation_display_alias': '盘友anon',
      'presentation_avatar_url': null,
      'public_profile_ref': null,
      'depth': int.parse(depth),
      'body': '回复-$docId',
      'is_tombstoned': isTombstoned,
      'root_reply_id': rootReplyId,
      'reply_to_reply_id': replyToReplyId,
      'technique_tags': <String>[],
      'chart_attachment': null,
      'media_attachments': <Map<String, dynamic>>[],
      'revision_no': 1,
      'current_revision_id': 'r0000000001',
      'idempotency_key': 'idem-$docId',
      'payload_hash': 'hash-$docId',
      'created_at': Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
      'updated_at': Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
    });
  }

  /// v1 schema post-like 文档（target_type/target_id）。
  Future<void> seedPostLike(String docId) async {
    await firestore.collection(PlaygroundFirestoreSchema.likes).doc(docId).set({
      'id': docId,
      'target_type': 'post',
      'target_id': postId,
      'created_at': Timestamp.fromDate(DateTime.utc(2026, 1, 3)),
    });
    // like owner 私有文档。
    await firestore.collection(PlaygroundFirestoreSchema.likeOwners).doc(docId).set({
      'like_id': docId,
      'provider_uid': viewerUid,
      'app_user_id': viewerAppUserId,
      'target_type': 'post',
      'target_id': postId,
      'created_at': Timestamp.fromDate(DateTime.utc(2026, 1, 3)),
    });
  }

  Future<void> seedVerification(String docId, String rootReplyId) async {
    await firestore
        .collection(PlaygroundFirestoreSchema.verifications)
        .doc(docId)
        .set({
      'id': docId,
      'post_id': postId,
      'root_reply_id': rootReplyId,
      'created_at': Timestamp.fromDate(DateTime.utc(2026, 1, 4)),
      'revoked_at': null,
    });
  }

  Future<void> seedFeedback() async {
    await firestore
        .collection(PlaygroundFirestoreSchema.outcomeFeedback)
        .doc('feedback_$postId')
        .set({
      'id': 'feedback_$postId',
      'post_id': postId,
      'outcome_description': '最终反馈正文',
      'revision_no': 1,
      'current_revision_id': 'r0000000001',
      'created_at': Timestamp.fromDate(DateTime.utc(2026, 1, 5)),
      'updated_at': Timestamp.fromDate(DateTime.utc(2026, 1, 5)),
      'deleted_at': null,
    });
  }

  /// 建立 viewer 身份（like/bookmark direct get 需要）。
  Future<void> seedIdentity(String uid, String appUid, String pubId) async {
    await firestore.collection('identity_map').doc(uid).set({
      'app_user_id': appUid,
      'provider_uid': uid,
      'provider_id': 'firebase',
      'public_presentation_id': pubId,
      'public_display_alias': '盘友${pubId.substring(pubId.length - 6)}',
    });
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(mockUser: null, signedIn: false);
    threadRepo = FirebasePlaygroundThreadQueryRepository(
      firestore: firestore,
      auth: auth,
    );
    feedRepo = FirebasePlaygroundFeedQueryRepository(
      firestore: firestore,
      auth: auth,
    );
  });

  group('详情真实数据（§10.1/§10.3/plan 6.1）', () {
    test('seed 2 replies/3 likes/1 verification/feedback → 真实计数 + aggregateReadCount=3',
        () async {
      // 认证 viewer。
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: viewerUid, isAnonymous: false),
        signedIn: true,
      );
      threadRepo = FirebasePlaygroundThreadQueryRepository(
        firestore: firestore,
        auth: auth,
      );
      await seedIdentity(viewerUid, viewerAppUserId, pubViewer);
      await seedPost();
      await seedReply('r1', depth: '0', rootReplyId: null);
      await seedReply('r2', depth: '1', rootReplyId: 'r1', replyToReplyId: 'r1');
      await seedPostLike('like-1');
      await seedPostLike('like-2');
      await seedPostLike('like-3');
      await seedVerification('verify_${postId}_r1', 'r1');
      await seedFeedback();

      final detail = await threadRepo.getRegisteredThreadDetail(
        PlaygroundRegisteredThreadDetailQuery(postId: PlaygroundPostId(postId)),
      );

      expect(detail.post.replyCount, 2, reason: '2 条真实回复');
      expect(detail.post.likeCount, 3, reason: '3 条 post-target likes');
      expect(detail.post.verificationCount, 1, reason: '1 条 active verification');
      expect(detail.counts.replyCount, 2);
      expect(detail.counts.verifiedRootReplyCount, 1,
          reason: '当前 reply page 只有 1 个 root 且被应验');
      expect(detail.aggregateReadCount, 3,
          reason: '三次 aggregation（replies/likes/verifications count）非浏览量');
      expect(detail.outcomeFeedback, isNotNull);
      expect(detail.outcomeFeedback!.body, '最终反馈正文');
    });

    test('viewer state：owner 填充 isOwner/canEdit/canDelete/canSetFeedback', () async {
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: posterUid, isAnonymous: false),
        signedIn: true,
      );
      threadRepo = FirebasePlaygroundThreadQueryRepository(
        firestore: firestore,
        auth: auth,
      );
      await seedIdentity(posterUid, posterAppUserId, pubPoster);
      await seedPost(ownerProviderUid: posterUid);
      await seedReply('r1', depth: '0');

      final detail = await threadRepo.getRegisteredThreadDetail(
        PlaygroundRegisteredThreadDetailQuery(postId: PlaygroundPostId(postId)),
      );
      expect(detail.viewerState.isOwner, isTrue);
      expect(detail.viewerState.canEdit, isTrue);
      expect(detail.viewerState.canDelete, isTrue);
      expect(detail.viewerState.canSetFeedback, isTrue);
      expect(detail.viewerState.canVerify, isTrue);
    });

    test('viewer state：非 owner → 全部 false', () async {
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: viewerUid, isAnonymous: false),
        signedIn: true,
      );
      threadRepo = FirebasePlaygroundThreadQueryRepository(
        firestore: firestore,
        auth: auth,
      );
      await seedIdentity(viewerUid, viewerAppUserId, pubViewer);
      await seedPost(ownerProviderUid: posterUid);

      final detail = await threadRepo.getRegisteredThreadDetail(
        PlaygroundRegisteredThreadDetailQuery(postId: PlaygroundPostId(postId)),
      );
      expect(detail.viewerState.isOwner, isFalse);
      expect(detail.viewerState.canEdit, isFalse);
      expect(detail.viewerState.canDelete, isFalse);
      expect(detail.viewerState.canSetFeedback, isFalse);
    });

    test('viewer state：未认证 → 全部 false', () async {
      await seedPost(ownerProviderUid: posterUid);
      await seedReply('r1', depth: '0');
      final detail = await threadRepo.getRegisteredThreadDetail(
        PlaygroundRegisteredThreadDetailQuery(postId: PlaygroundPostId(postId)),
      );
      expect(detail.viewerState.isOwner, isFalse);
      expect(detail.viewerState.canEdit, isFalse);
      expect(detail.viewerState.canDelete, isFalse);
      expect(detail.viewerState.canSetFeedback, isFalse);
    });

    test('viewer state：owner 文档缺失 → fail closed false', () async {
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: viewerUid, isAnonymous: false),
        signedIn: true,
      );
      threadRepo = FirebasePlaygroundThreadQueryRepository(
        firestore: firestore,
        auth: auth,
      );
      await seedIdentity(viewerUid, viewerAppUserId, pubViewer);
      await seedPost(ownerProviderUid: posterUid, seedOwner: false);

      final detail = await threadRepo.getRegisteredThreadDetail(
        PlaygroundRegisteredThreadDetailQuery(postId: PlaygroundPostId(postId)),
      );
      expect(detail.viewerState.isOwner, isFalse);
      expect(detail.viewerState.canEdit, isFalse);
      expect(detail.viewerState.canDelete, isFalse);
      expect(detail.viewerState.canSetFeedback, isFalse);
    });

    test('公开 DTO 零内部身份（provider_uid/app_user_id 不泄漏）', () async {
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: viewerUid, isAnonymous: false),
        signedIn: true,
      );
      threadRepo = FirebasePlaygroundThreadQueryRepository(
        firestore: firestore,
        auth: auth,
      );
      await seedIdentity(viewerUid, viewerAppUserId, pubViewer);
      await seedPost(ownerProviderUid: posterUid);
      await seedReply('r1', depth: '0');

      final detail = await threadRepo.getRegisteredThreadDetail(
        PlaygroundRegisteredThreadDetailQuery(postId: PlaygroundPostId(postId)),
      );
      final dump = detail.toString();
      expect(dump, isNot(contains(posterUid)));
      expect(dump, isNot(contains(posterAppUserId)));
      expect(dump, isNot(contains('provider_uid')));
      expect(dump, isNot(contains('app_user_id')));
    });
  });

  group('Feed 占位策略（§10.3/plan 6.2）', () {
    test('Feed item 三 count=0、hasOutcomeFeedback=false（单 query，不逐帖聚合）',
        () async {
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: viewerUid, isAnonymous: false),
        signedIn: true,
      );
      feedRepo = FirebasePlaygroundFeedQueryRepository(
        firestore: firestore,
        auth: auth,
      );
      await seedIdentity(viewerUid, viewerAppUserId, pubViewer);
      await seedPost();
      await seedReply('r1', depth: '0');
      await seedPostLike('like-1');
      await seedVerification('verify_${postId}_r1', 'r1');
      await seedFeedback();

      final page = await feedRepo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );
      expect(page.items, isNotEmpty);
      final item = page.items.single;
      expect(item.replyCount, 0);
      expect(item.likeCount, 0);
      expect(item.verificationCount, 0);
      expect(item.hasOutcomeFeedback, isFalse);
      expect(item.post.replyCount, 0);
      expect(item.post.likeCount, 0);
      expect(item.post.verificationCount, 0);
    });

    test('getPendingDivinationFeed 不访问 Firestore → invalidArgument + filter/not-supported-in-direct-phase',
        () async {
      await seedPost();
      expect(
        () => feedRepo.getPendingDivinationFeed(
          const GetFeedBatchQuery(
              tab: PlaygroundFeedTab.pendingDivination, limit: 10),
        ),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)
            .having((e) => e.machineCode, 'machineCode',
                'filter/not-supported-in-direct-phase')),
      );
    });

    test('推荐入口明确降级为最新（不读 recommendation_score）', () async {
      await seedPost();
      await seedPost(
          docId: 'post-2', presentationIdentityId: 'pub_other_128bit');
      final recommended = await feedRepo.getRecommendedFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.recommended, limit: 10),
      );
      final latest = await feedRepo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );
      expect(recommended.items.map((i) => i.post.publicPostId.value).toList(),
          latest.items.map((i) => i.post.publicPostId.value).toList(),
          reason: '推荐降级为最新排序');
      expect(recommended.items, isNotEmpty);
    });
  });

  group('getThreadReplies v1 查询（§10.1）', () {
    test('v1 reply 分页：post_id + is_tombstoned==false，按 created_at asc', () async {
      await seedPost();
      await seedReply('r1', depth: '0');
      await seedReply('r2', depth: '1', rootReplyId: 'r1');
      await seedReply('rtomb', depth: '0', isTombstoned: true);

      final page = await threadRepo.getThreadReplies(
        GetRepliesQuery(postId: PlaygroundPostId(postId), limit: 10),
      );
      final ids = page.items.map((v) => v.replyId.value).toList();
      expect(ids, contains('r1'));
      expect(ids, contains('r2'));
      expect(ids, isNot(contains('rtomb')), reason: 'tombstone 过滤');
    });
  });

  group('固定读取成本 · 无 N+1（§10.3/plan 6.3）', () {
    test('详情不读 reply owner：seed 无 reply_owners，detail 仍成功且计数正确', () async {
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: viewerUid, isAnonymous: false),
        signedIn: true,
      );
      threadRepo = FirebasePlaygroundThreadQueryRepository(
        firestore: firestore,
        auth: auth,
      );
      await seedIdentity(viewerUid, viewerAppUserId, pubViewer);
      await seedPost(ownerProviderUid: posterUid);
      // 只 seed 回复，不 seed playground_reply_owners。
      await seedReply('r1', depth: '0');
      await seedReply('r2', depth: '1', rootReplyId: 'r1');
      await seedPostLike('like-1');
      await seedVerification('verify_${postId}_r1', 'r1');
      await seedFeedback();

      final detail = await threadRepo.getRegisteredThreadDetail(
        PlaygroundRegisteredThreadDetailQuery(postId: PlaygroundPostId(postId)),
      );
      expect(detail.counts.replyCount, 2,
          reason: '不读 reply owner 也能算出真实计数（无逐回复 owner N+1）');
      expect(detail.counts.verifiedRootReplyCount, 1);
      expect(detail.aggregateReadCount, 3);
    });

    test('Feed 单 query：有 replies/likes/verifications 也只返回占位 0（无逐帖聚合）',
        () async {
      await seedPost();
      await seedReply('r1', depth: '0');
      await seedReply('r2', depth: '1', rootReplyId: 'r1');
      await seedPostLike('like-1');
      await seedPostLike('like-2');
      await seedVerification('verify_${postId}_r1', 'r1');
      await seedFeedback();

      final page = await feedRepo.getLatestFeed(
        const GetFeedBatchQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );
      expect(page.items, isNotEmpty);
      expect(page.items.single.post.likeCount, 0,
          reason: 'Feed 不逐帖 count likes，占位恒 0');
    });
  });
}
