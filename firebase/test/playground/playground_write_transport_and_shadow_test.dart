import 'dart:convert';
import 'dart:typed_data';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_firebase/playground/playground.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class _MockHttpTransport implements PlaygroundHttpTransport {
  _MockHttpTransport({
    this.onPut,
    this.onGet,
    this.onPost,
    this.onPatch,
    this.onDelete,
  });

  Future<PlaygroundHttpResponse> Function(Uri uri, Map<String, String>? headers, Object? body)? onPut;
  Future<PlaygroundHttpResponse> Function(Uri uri, Map<String, String>? headers)? onGet;
  Future<PlaygroundHttpResponse> Function(Uri uri, Map<String, String>? headers, Object? body)? onPost;
  Future<PlaygroundHttpResponse> Function(Uri uri, Map<String, String>? headers, Object? body)? onPatch;
  Future<PlaygroundHttpResponse> Function(Uri uri, Map<String, String>? headers)? onDelete;

  int putCallCount = 0;
  List<Map<String, String>?> putHeadersHistory = [];
  Uri? lastPutUri;
  Map<String, String>? lastPutHeaders;
  Object? lastPutBody;

  int postCallCount = 0;
  Uri? lastPostUri;
  Map<String, String>? lastPostHeaders;
  Object? lastPostBody;

  int patchCallCount = 0;
  Uri? lastPatchUri;
  Map<String, String>? lastPatchHeaders;
  Object? lastPatchBody;

  int deleteCallCount = 0;
  Uri? lastDeleteUri;
  Map<String, String>? lastDeleteHeaders;

  @override
  Future<PlaygroundHttpResponse> get(Uri uri, {Map<String, String>? headers}) async {
    if (onGet != null) return onGet!(uri, headers);
    return PlaygroundHttpResponse(statusCode: 200, bodyBytes: Uint8List.fromList(utf8.encode('{}')), headers: {});
  }

  @override
  Future<PlaygroundHttpResponse> put(Uri uri, {Map<String, String>? headers, Object? body}) async {
    putCallCount++;
    putHeadersHistory.add(headers);
    lastPutUri = uri;
    lastPutHeaders = headers;
    lastPutBody = body;
    if (onPut != null) return onPut!(uri, headers, body);
    return PlaygroundHttpResponse(
      statusCode: 200,
      bodyBytes: Uint8List.fromList(utf8.encode('{"liked": true, "id": "like_post_u1_p1", "target_type": "post"}')),
      headers: {'content-type': 'application/json'},
    );
  }

  @override
  Future<PlaygroundHttpResponse> post(Uri uri, {Map<String, String>? headers, Object? body}) async {
    postCallCount++;
    lastPostUri = uri;
    lastPostHeaders = headers;
    lastPostBody = body;
    if (onPost != null) return onPost!(uri, headers, body);
    return PlaygroundHttpResponse(
      statusCode: 201,
      bodyBytes: Uint8List.fromList(utf8.encode('{"id": "gen_post_1", "text": "测试", "status": "active", "author_app_user_id": "app_user_1"}')),
      headers: {'content-type': 'application/json'},
    );
  }

  @override
  Future<PlaygroundHttpResponse> patch(Uri uri, {Map<String, String>? headers, Object? body}) async {
    patchCallCount++;
    lastPatchUri = uri;
    lastPatchHeaders = headers;
    lastPatchBody = body;
    if (onPatch != null) return onPatch!(uri, headers, body);
    return PlaygroundHttpResponse(
      statusCode: 200,
      bodyBytes: Uint8List.fromList(utf8.encode('{"id": "gen_post_1", "text": "已修改", "status": "active"}')),
      headers: {'content-type': 'application/json'},
    );
  }

  @override
  Future<PlaygroundHttpResponse> delete(Uri uri, {Map<String, String>? headers, Object? body}) async {
    deleteCallCount++;
    lastDeleteUri = uri;
    lastDeleteHeaders = headers;
    if (onDelete != null) return onDelete!(uri, headers);
    return PlaygroundHttpResponse(
      statusCode: 200,
      bodyBytes: Uint8List.fromList(utf8.encode('{"success": true, "id": "del_1"}')),
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  group('FW2-C · 客户端写端点切换与影子比对 (C1~C6 验收集)', () {
    test('C1: setLike 与 setBookmark 开关独立可切且默认严格关闭 (走 callable / firestore)', () {
      final config = PlaygroundTransportConfig.defaults();
      expect(config.likeTransport, equals(TransportMode.firestore));
      expect(config.bookmarkTransport, equals(TransportMode.firestore));
      expect(config.isRestLikeEnabled, isFalse);
      expect(config.isRestBookmarkEnabled, isFalse);

      // 单独开 like
      final onlyLike = config.copyWith(likeTransport: TransportMode.rest);
      expect(onlyLike.isRestLikeEnabled, isTrue);
      expect(onlyLike.isRestBookmarkEnabled, isFalse);

      // 单独开 bookmark
      final onlyBookmark = config.copyWith(bookmarkTransport: TransportMode.rest);
      expect(onlyBookmark.isRestLikeEnabled, isFalse);
      expect(onlyBookmark.isRestBookmarkEnabled, isTrue);

      // 一键回滚全部归位
      final rollbacked = onlyLike.copyWith(bookmarkTransport: TransportMode.rest).rollbackToFirestore();
      expect(rollbacked.isRestLikeEnabled, isFalse);
      expect(rollbacked.isRestBookmarkEnabled, isFalse);
    });

    test('C2: REST 点赞写路径请求体与头构造符合 OpenAPI 契约且无伪造身份头', () async {
      final transport = _MockHttpTransport();
      final config = PlaygroundTransportConfig.defaults().copyWith(
        likeTransport: TransportMode.rest,
      );

      final uri = Uri.parse('http://127.0.0.1:8080/v1');
      final fakeFirestore = FakeFirebaseFirestore();
      final fakeAuth = MockFirebaseAuth();
      final identityResolver = FirebasePlaygroundIdentityResolver(firestore: fakeFirestore, auth: fakeAuth);

      final repo = FirebasePlaygroundLikeRepository(
        firestore: fakeFirestore,
        auth: fakeAuth,
        identityResolver: identityResolver,
        config: config,
        httpTransport: transport,
        baseUri: uri,
      );

      await repo.setLike(const SetLikeCommand(
        liked: true,
        postId: PlaygroundPostId('p100'),
        idempotencyKey: 'custom-idem-key-1',
      ));

      expect(transport.putCallCount, equals(1));
      expect(transport.lastPutUri.toString(), contains('/playground/likes'));
      expect(transport.lastPutHeaders?['Idempotency-Key'], equals('custom-idem-key-1'));
      // 验证绝不包含伪造的身份头
      expect(transport.lastPutHeaders?.containsKey('${"X-"}Caller-UID'), isFalse);
      expect(transport.lastPutHeaders?.containsKey('${"X-"}User-ID'), isFalse);

      final decodedBody = jsonDecode(transport.lastPutBody as String);
      expect(decodedBody['postId'], equals('p100'));
      expect(decodedBody['action'], equals('like'));
    });

    test('C2: REST 收藏路径请求体与头构造符合 OpenAPI 契约且无伪造身份头', () async {
      final transport = _MockHttpTransport(
        onPut: (uri, headers, body) async => PlaygroundHttpResponse(
          statusCode: 200,
          bodyBytes: Uint8List.fromList(utf8.encode('{"bookmarked": true, "id": "bookmark_u1_p200"}')),
          headers: {'content-type': 'application/json'},
        ),
      );
      final config = PlaygroundTransportConfig.defaults().copyWith(
        bookmarkTransport: TransportMode.rest,
      );

      final uri = Uri.parse('http://127.0.0.1:8080/v1');
      final fakeFirestore = FakeFirebaseFirestore();
      final fakeAuth = MockFirebaseAuth();
      final identityResolver = FirebasePlaygroundIdentityResolver(firestore: fakeFirestore, auth: fakeAuth);

      final repo = FirebasePlaygroundBookmarkRepository(
        firestore: fakeFirestore,
        auth: fakeAuth,
        identityResolver: identityResolver,
        config: config,
        httpTransport: transport,
        baseUri: uri,
      );

      await repo.setBookmark(const SetBookmarkCommand(
        bookmarked: true,
        postId: PlaygroundPostId('p200'),
        idempotencyKey: 'bm-idem-key-1',
      ));

      expect(transport.putCallCount, equals(1));
      expect(transport.lastPutUri.toString(), contains('/playground/bookmarks'));
      expect(transport.lastPutHeaders?['Idempotency-Key'], equals('bm-idem-key-1'));
      expect(transport.lastPutHeaders?.containsKey('${"X-"}Caller-UID'), isFalse);
      expect(transport.lastPutHeaders?.containsKey('${"X-"}User-ID'), isFalse);

      final decodedBody = jsonDecode(transport.lastPutBody as String);
      expect(decodedBody['postId'], equals('p200'));
      expect(decodedBody['action'], equals('bookmark'));
    });

    test('C3: 防双写安全机制与读路径真影子比对验证 (敏感写仅 primary 执行，读路径真双跑)', () async {
      final transport = _MockHttpTransport();
      final fakeFirestore = FakeFirebaseFirestore();
      final fakeAuth = MockFirebaseAuth();

      final factory = PlaygroundRepositoryFactory(
        initialConfig: PlaygroundTransportConfig.defaults().copyWith(
          likeTransport: TransportMode.rest,
          shadowComparisonEnabled: true,
        ),
        restBaseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        httpTransport: transport,
        firestore: fakeFirestore,
        auth: fakeAuth,
      );

      ShadowComparisonResult? capturedResult;
      String? capturedOp;

      final likeDataSource = factory.createLikeRemoteDataSource(
        onShadowComparison: (result, op) {
          capturedResult = result;
          capturedOp = op;
        },
      );

      expect(likeDataSource, isA<ShadowPlaygroundLikeRemoteDataSource>());

      // 1. 真调用被测写路径：敏感写仅由 primary 执行，绝无假信号上报
      await likeDataSource.setLike(const SetLikeCommand(
        liked: true,
        postId: PlaygroundPostId('p300'),
        idempotencyKey: 'idem-shadow-test',
      ));

      // 验证防双写：网络写请求严格只有 1 次（不发起 secondary 写）
      expect(transport.putCallCount, equals(1));
      // 验证写路径不发恒真假比对信号
      expect(capturedResult, isNull);

      // 2. 读路径真双跑比对：isLiked 触发真实比对回调
      final isLiked = await likeDataSource.isLiked(postId: const PlaygroundPostId('p300'));
      expect(isLiked, isFalse);
      expect(capturedResult, isNotNull);
      expect(capturedResult!.isMatch, isTrue);
      expect(capturedOp, equals('isLiked'));
    });

    test('C4: 影子比对具备强鉴别力（反例注入与 ID 篡改必须断言出差异）', () {
      final resA = {'liked': true, 'id': 'like_post_u1_p1', 'target_type': 'post'};
      final resB = {'liked': true, 'id': 'like_post_u1_p1', 'target_type': 'post'};
      final matchResult = PlaygroundShadowComparator.compareLikeResult(resA, resB);
      expect(matchResult.isMatch, isTrue);

      // 反例 1：liked 状态被翻转
      final mutatedLiked = {'liked': false, 'id': 'like_post_u1_p1', 'target_type': 'post'};
      final r1 = PlaygroundShadowComparator.compareLikeResult(resA, mutatedLiked);
      expect(r1.isMatch, isFalse);
      expect(r1.discrepancies, contains(contains('liked')));

      // 反例 2：target_type 不符
      final mutatedType = {'liked': true, 'id': 'like_post_u1_p1', 'target_type': 'reply'};
      final r2 = PlaygroundShadowComparator.compareLikeResult(resA, mutatedType);
      expect(r2.isMatch, isFalse);
      expect(r2.discrepancies, contains(contains('target_type')));

      // 反例 3：id 不符 (P2-2 覆盖)
      final mutatedId = {'liked': true, 'id': 'like_post_u2_p1', 'target_type': 'post'};
      final rId = PlaygroundShadowComparator.compareLikeResult(resA, mutatedId);
      expect(rId.isMatch, isFalse);
      expect(rId.discrepancies, contains(contains('id')));

      // 收藏比对反例
      final bmA = {'bookmarked': true, 'id': 'bm_1'};
      final bmMutated = {'bookmarked': false, 'id': 'bm_1'};
      final r3 = PlaygroundShadowComparator.compareBookmarkResult(bmA, bmMutated);
      expect(r3.isMatch, isFalse);
      expect(r3.discrepancies, contains(contains('bookmarked')));

      // 收藏 ID 不符反例
      final bmIdMutated = {'bookmarked': true, 'id': 'bm_2'};
      final rBmId = PlaygroundShadowComparator.compareBookmarkResult(bmA, bmIdMutated);
      expect(rBmId.isMatch, isFalse);
      expect(rBmId.discrepancies, contains(contains('id')));
    });

    test('C5: 客户端幂等键生成与重试复用同一键真调用验证', () async {
      int attempts = 0;
      final transport = _MockHttpTransport(
        onPut: (uri, headers, body) async {
          attempts++;
          if (attempts == 1) {
            // 第一次模拟 503 失败
            return PlaygroundHttpResponse(
              statusCode: 503,
              bodyBytes: Uint8List.fromList(utf8.encode('{"type":"unavailable","title":"Retry"}')),
              headers: {'content-type': 'application/problem+json'},
            );
          }
          return PlaygroundHttpResponse(
            statusCode: 200,
            bodyBytes: Uint8List.fromList(utf8.encode('{"liked": true, "id": "like_1", "target_type": "post"}')),
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final repo = FirebasePlaygroundLikeRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        identityResolver: FirebasePlaygroundIdentityResolver(firestore: FakeFirebaseFirestore(), auth: MockFirebaseAuth()),
        config: PlaygroundTransportConfig.defaults().copyWith(likeTransport: TransportMode.rest),
        httpTransport: transport,
        baseUri: Uri.parse('http://127.0.0.1:8080/v1'),
      );

      const command = SetLikeCommand(
        liked: true,
        postId: PlaygroundPostId('p1'),
        idempotencyKey: 'idem-stable-key-123',
      );

      // 第一次调用触发 503 异常
      expect(() => repo.setLike(command), throwsA(isA<PlaygroundError>()));

      // 重试重放相同 command
      await repo.setLike(command);

      expect(transport.putCallCount, equals(2));
      // 验证两次请求复用了完全相同的 Idempotency-Key
      expect(transport.putHeadersHistory[0]?['Idempotency-Key'], equals('idem-stable-key-123'));
      expect(transport.putHeadersHistory[1]?['Idempotency-Key'], equals('idem-stable-key-123'));
    });

    test('C6: REST 写失败路径与 HTTP 错误码映射验证 (P1-3 覆盖)', () async {
      final statuses = [400, 401, 403, 404, 409, 429, 503];
      for (final status in statuses) {
        final err = FirebasePlaygroundErrorMapper.mapHttpStatus(
          status,
          jsonEncode({
            'type': 'test_error',
            'title': 'Test Error $status',
            'detail': 'Detail $status',
          }),
        );
        expect(err.message, equals('Detail $status'));
      }

      final transport = _MockHttpTransport(
        onPut: (uri, headers, body) async => PlaygroundHttpResponse(
          statusCode: 404,
          bodyBytes: Uint8List.fromList(utf8.encode('{"type":"not_found","title":"Post Not Found","detail":"Post not found"}')),
          headers: {'content-type': 'application/problem+json'},
        ),
      );

      final repo = FirebasePlaygroundLikeRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        identityResolver: FirebasePlaygroundIdentityResolver(firestore: FakeFirebaseFirestore(), auth: MockFirebaseAuth()),
        config: PlaygroundTransportConfig.defaults().copyWith(likeTransport: TransportMode.rest),
        httpTransport: transport,
        baseUri: Uri.parse('http://127.0.0.1:8080/v1'),
      );

      expect(
        () => repo.setLike(const SetLikeCommand(liked: true, postId: PlaygroundPostId('p404'))),
        throwsA(isA<PlaygroundError>().having((e) => e.code, 'code', equals(PlaygroundErrorCode.notFound))),
      );
    });

    test('C6: FirebasePlaygroundEngagementRepository REST 分支端到端覆盖 (P1-4 覆盖)', () async {
      final transport = _MockHttpTransport();
      final engagementRepo = FirebasePlaygroundEngagementRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        config: PlaygroundTransportConfig.defaults().copyWith(
          likeTransport: TransportMode.rest,
          bookmarkTransport: TransportMode.rest,
        ),
        httpTransport: transport,
        baseUri: Uri.parse('http://127.0.0.1:8080/v1'),
      );

      // 1. 测试 setContentLike (Post)
      await engagementRepo.setContentLike(SetContentLikeCommand.post(
        const PlaygroundPostId('post_eng_1'),
        liked: true,
        idempotencyKey: 'idem-eng-like-1',
      ));
      expect(transport.putCallCount, equals(1));
      expect(transport.lastPutUri.toString(), contains('/playground/likes'));
      expect(transport.lastPutHeaders?['Idempotency-Key'], equals('idem-eng-like-1'));

      // 2. 测试 setContentLike (Reply)
      await engagementRepo.setContentLike(SetContentLikeCommand.reply(
        const PlaygroundReplyId('reply_eng_1'),
        liked: false,
        idempotencyKey: 'idem-eng-like-2',
      ));
      expect(transport.putCallCount, equals(2));
      expect(jsonDecode(transport.lastPutBody as String)['replyId'], equals('reply_eng_1'));
      expect(jsonDecode(transport.lastPutBody as String)['action'], equals('unlike'));

      // 3. 测试 setBookmark
      await engagementRepo.setBookmark(const SetBookmarkCommand(
        postId: PlaygroundPostId('post_eng_2'),
        bookmarked: true,
        idempotencyKey: 'idem-eng-bm-1',
      ));
      expect(transport.putCallCount, equals(3));
      expect(transport.lastPutUri.toString(), contains('/playground/bookmarks'));
      expect(transport.lastPutHeaders?['Idempotency-Key'], equals('idem-eng-bm-1'));
    });
  });

  group('FW3-C · 客户端 12 端点切流与影子比对 (6 批全面验证)', () {
    test('FW3 开关默认关闭且支持细粒度覆盖与一键回滚', () {
      final config = PlaygroundTransportConfig.defaults();
      expect(config.isRestCreatePostEnabled, isFalse);
      expect(config.isRestEditPostEnabled, isFalse);
      expect(config.isRestTombstonePostEnabled, isFalse);
      expect(config.isRestProfileEnabled, isFalse);
      expect(config.isRestCreateRootReplyEnabled, isFalse);
      expect(config.isRestCreateDiscussionReplyEnabled, isFalse);
      expect(config.isRestEditReplyEnabled, isFalse);
      expect(config.isRestDeleteReplyEnabled, isFalse);
      expect(config.isRestVerifyRootReplyEnabled, isFalse);
      expect(config.isRestRevokeVerificationEnabled, isFalse);
      expect(config.isRestSetOutcomeFeedbackEnabled, isFalse);
      expect(config.isRestRevokeOutcomeFeedbackEnabled, isFalse);

      final allRest = config.copyWith(
        createPostTransport: TransportMode.rest,
        editPostTransport: TransportMode.rest,
        tombstonePostTransport: TransportMode.rest,
        profileTransport: TransportMode.rest,
        createRootReplyTransport: TransportMode.rest,
        createDiscussionReplyTransport: TransportMode.rest,
        editReplyTransport: TransportMode.rest,
        deleteReplyTransport: TransportMode.rest,
        verifyRootReplyTransport: TransportMode.rest,
        revokeVerificationTransport: TransportMode.rest,
        setOutcomeFeedbackTransport: TransportMode.rest,
        revokeOutcomeFeedbackTransport: TransportMode.rest,
      );

      expect(allRest.isRestCreatePostEnabled, isTrue);
      expect(allRest.isRestEditPostEnabled, isTrue);
      expect(allRest.isRestTombstonePostEnabled, isTrue);
      expect(allRest.isRestProfileEnabled, isTrue);
      expect(allRest.isRestCreateRootReplyEnabled, isTrue);
      expect(allRest.isRestCreateDiscussionReplyEnabled, isTrue);
      expect(allRest.isRestEditReplyEnabled, isTrue);
      expect(allRest.isRestDeleteReplyEnabled, isTrue);
      expect(allRest.isRestVerifyRootReplyEnabled, isTrue);
      expect(allRest.isRestRevokeVerificationEnabled, isTrue);
      expect(allRest.isRestSetOutcomeFeedbackEnabled, isTrue);
      expect(allRest.isRestRevokeOutcomeFeedbackEnabled, isTrue);

      final rolledBack = allRest.rollbackToFirestore();
      expect(rolledBack.isRestCreatePostEnabled, isFalse);
      expect(rolledBack.isRestProfileEnabled, isFalse);
      expect(rolledBack.isRestCreateRootReplyEnabled, isFalse);
      expect(rolledBack.isRestVerifyRootReplyEnabled, isFalse);
      expect(rolledBack.isRestSetOutcomeFeedbackEnabled, isFalse);
    });

    test('Batch 1: createPost 与 editPost (POST /posts, PATCH /posts/{id}) 契约与透传', () async {
      final transport = _MockHttpTransport(
        onPost: (uri, headers, body) async => PlaygroundHttpResponse(
          statusCode: 201,
          bodyBytes: Uint8List.fromList(utf8.encode('{"id":"p_new_1","text":"新帖正文","status":"active","author_app_user_id":"u_1","created_at":"2026-08-22T12:00:00.000Z"}')),
          headers: {'content-type': 'application/json'},
        ),
        onPatch: (uri, headers, body) async => PlaygroundHttpResponse(
          statusCode: 200,
          bodyBytes: Uint8List.fromList(utf8.encode('{"id":"p_new_1","text":"已编辑正文","status":"active","author_app_user_id":"u_1","updated_at":"2026-08-22T12:05:00.000Z"}')),
          headers: {'content-type': 'application/json'},
        ),
      );

      final config = PlaygroundTransportConfig.defaults().copyWith(
        createPostTransport: TransportMode.rest,
        editPostTransport: TransportMode.rest,
      );

      final postRepo = FirebasePlaygroundPostRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        identityResolver: FirebasePlaygroundIdentityResolver(firestore: FakeFirebaseFirestore(), auth: MockFirebaseAuth()),
        config: config,
        httpTransport: transport,
        baseUri: Uri.parse('http://127.0.0.1:8080/v1'),
      );

      final created = await postRepo.createPost(const CreatePostCommand(
        text: '新帖正文',
        idempotencyKey: 'idem-post-001',
      ));
      expect(created.id.value, equals('p_new_1'));
      expect(created.text, equals('新帖正文'));
      expect(transport.postCallCount, equals(1));
      expect(transport.lastPostUri.toString(), contains('/playground/posts'));
      expect(transport.lastPostHeaders?['Idempotency-Key'], equals('idem-post-001'));
      expect(transport.lastPostHeaders?.containsKey('X-Caller-UID'), isFalse);

      final edited = await postRepo.editPost(const EditPostCommand(
        postId: PlaygroundPostId('p_new_1'),
        text: '已编辑正文',
        idempotencyKey: 'idem-post-002',
      ));
      expect(edited.text, equals('已编辑正文'));
      expect(transport.patchCallCount, equals(1));
      expect(transport.lastPatchUri.toString(), contains('/playground/posts/p_new_1'));
      expect(transport.lastPatchHeaders?['Idempotency-Key'], equals('idem-post-002'));
    });

    test('Batch 2: tombstonePost 与 updateProfile (DELETE /posts/{id}, PATCH /profile) 契约', () async {
      final transport = _MockHttpTransport();
      final config = PlaygroundTransportConfig.defaults().copyWith(
        tombstonePostTransport: TransportMode.rest,
        profileTransport: TransportMode.rest,
      );

      final postRepo = FirebasePlaygroundPostRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        identityResolver: FirebasePlaygroundIdentityResolver(firestore: FakeFirebaseFirestore(), auth: MockFirebaseAuth()),
        config: config,
        httpTransport: transport,
        baseUri: Uri.parse('http://127.0.0.1:8080/v1'),
      );

      final profileRepo = FirebasePlaygroundProfileRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        config: config,
        httpTransport: transport,
        baseUri: Uri.parse('http://127.0.0.1:8080/v1'),
      );

      // tombstonePost
      final deleted = await postRepo.deletePost(const DeletePostCommand(
        postId: PlaygroundPostId('p_del_1'),
        idempotencyKey: 'idem-del-001',
      ));
      expect(deleted.isTombstoned, isTrue);
      expect(transport.deleteCallCount, equals(1));
      expect(transport.lastDeleteUri.toString(), contains('/playground/posts/p_del_1'));
      expect(transport.lastDeleteHeaders?['Idempotency-Key'], equals('idem-del-001'));

      // updateProfile
      await profileRepo.updateProfile(
        userId: const PlaygroundUserId('u100'),
        displayName: '易学大师',
        bio: '精通紫微斗数',
        idempotencyKey: 'idem-prof-001',
      );
      expect(transport.patchCallCount, equals(1));
      expect(transport.lastPatchUri.toString(), contains('/playground/profile'));
      expect(transport.lastPatchHeaders?['Idempotency-Key'], equals('idem-prof-001'));
      expect(jsonDecode(transport.lastPatchBody as String)['displayName'], equals('易学大师'));
    });

    test('Batch 3 & 4: Replies 4 端点 (createRoot, createDiscussion, edit, delete) 契约与透传', () async {
      final transport = _MockHttpTransport(
        onPost: (uri, headers, body) async => PlaygroundHttpResponse(
          statusCode: 201,
          bodyBytes: Uint8List.fromList(utf8.encode('{"id":"r_gen_1","post_id":"p1","body":"回复正文","author_app_user_id":"u_2","created_at":"2026-08-22T12:00:00.000Z"}')),
          headers: {'content-type': 'application/json'},
        ),
        onPatch: (uri, headers, body) async => PlaygroundHttpResponse(
          statusCode: 200,
          bodyBytes: Uint8List.fromList(utf8.encode('{"id":"r_gen_1","post_id":"p1","body":"已编辑回复","author_app_user_id":"u_2","updated_at":"2026-08-22T12:10:00.000Z"}')),
          headers: {'content-type': 'application/json'},
        ),
      );

      final config = PlaygroundTransportConfig.defaults().copyWith(
        createRootReplyTransport: TransportMode.rest,
        createDiscussionReplyTransport: TransportMode.rest,
        editReplyTransport: TransportMode.rest,
        deleteReplyTransport: TransportMode.rest,
      );

      final replyRepo = FirebasePlaygroundReplyCommandRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        config: config,
        httpTransport: transport,
        baseUri: Uri.parse('http://127.0.0.1:8080/v1'),
      );

      // 1. createRootReply
      final root = await replyRepo.createRootReply(const CreateRootReplyCommand(
        postId: PlaygroundPostId('p1'),
        body: '回复正文',
        idempotencyKey: 'idem-reply-001',
      ));
      expect(root.publicReplyId.value, equals('r_gen_1'));
      expect(transport.postCallCount, equals(1));
      expect(transport.lastPostUri.toString(), contains('/playground/posts/p1/replies'));
      expect(transport.lastPostHeaders?['Idempotency-Key'], equals('idem-reply-001'));

      // 2. createDiscussionReply
      final disc = await replyRepo.createDiscussionReply(const CreateDiscussionReplyCommand(
        postId: PlaygroundPostId('p1'),
        rootReplyId: PlaygroundReplyId('r_gen_1'),
        body: '跟帖正文',
        idempotencyKey: 'idem-reply-002',
      ));
      expect(disc.publicReplyId.value, equals('r_gen_1'));
      expect(transport.postCallCount, equals(2));
      expect(transport.lastPostUri.toString(), contains('/playground/replies/r_gen_1/discussion'));
      expect(transport.lastPostHeaders?['Idempotency-Key'], equals('idem-reply-002'));

      // 3. editReply
      final edited = await replyRepo.editReply(const EditReplyCommand(
        replyId: PlaygroundReplyId('r_gen_1'),
        body: '已编辑回复',
        idempotencyKey: 'idem-reply-003',
      ));
      expect(edited.body, equals('已编辑回复'));
      expect(transport.patchCallCount, equals(1));
      expect(transport.lastPatchUri.toString(), contains('/playground/replies/r_gen_1'));
      expect(transport.lastPatchHeaders?['Idempotency-Key'], equals('idem-reply-003'));

      // 4. tombstoneReply
      await replyRepo.tombstoneReply(const DeleteReplyCommand(
        replyId: PlaygroundReplyId('r_gen_1'),
        idempotencyKey: 'idem-reply-004',
      ));
      expect(transport.deleteCallCount, equals(1));
      expect(transport.lastDeleteUri.toString(), contains('/playground/replies/r_gen_1'));
      expect(transport.lastDeleteHeaders?['Idempotency-Key'], equals('idem-reply-004'));
    });

    test('Batch 5 & 6: 应验 (PUT/DELETE) 与 最终反馈 (PUT/DELETE) 4 端点契约', () async {
      final transport = _MockHttpTransport(
        onPut: (uri, headers, body) async => PlaygroundHttpResponse(
          statusCode: 200,
          bodyBytes: Uint8List.fromList(utf8.encode('{"id":"fb_1","post_id":"p1","root_reply_id":"r1","verifier_app_user_id":"u_poster","author_app_user_id":"u_poster","outcome_description":"成功应验","created_at":"2026-08-22T12:00:00.000Z"}')),
          headers: {'content-type': 'application/json'},
        ),
      );

      final config = PlaygroundTransportConfig.defaults().copyWith(
        verifyRootReplyTransport: TransportMode.rest,
        revokeVerificationTransport: TransportMode.rest,
        setOutcomeFeedbackTransport: TransportMode.rest,
        revokeOutcomeFeedbackTransport: TransportMode.rest,
      );

      final veriRepo = FirebasePlaygroundVerificationRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        identityResolver: FirebasePlaygroundIdentityResolver(firestore: FakeFirebaseFirestore(), auth: MockFirebaseAuth()),
        config: config,
        httpTransport: transport,
        baseUri: Uri.parse('http://127.0.0.1:8080/v1'),
      );

      final outcomeRepo = FirebasePlaygroundOutcomeFeedbackRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
        identityResolver: FirebasePlaygroundIdentityResolver(firestore: FakeFirebaseFirestore(), auth: MockFirebaseAuth()),
        config: config,
        httpTransport: transport,
        baseUri: Uri.parse('http://127.0.0.1:8080/v1'),
      );

      // 1. verifyRootReply
      final veri = await veriRepo.verifyRootReply(const VerifyRootReplyCommand(
        postId: PlaygroundPostId('p1'),
        rootReplyId: PlaygroundReplyId('r1'),
        idempotencyKey: 'idem-veri-001',
      ));
      expect(veri.isRevoked, isFalse);
      expect(transport.putCallCount, equals(1));
      expect(transport.lastPutUri.toString(), contains('/playground/replies/r1/verification'));
      expect(transport.lastPutHeaders?['Idempotency-Key'], equals('idem-veri-001'));

      // 2. revokeVerification
      final unveri = await veriRepo.revokeVerification(const RevokeVerificationCommand(
        postId: PlaygroundPostId('p1'),
        rootReplyId: PlaygroundReplyId('r1'),
        idempotencyKey: 'idem-veri-002',
      ));
      expect(unveri.isRevoked, isTrue);
      expect(transport.deleteCallCount, equals(1));
      expect(transport.lastDeleteUri.toString(), contains('/playground/replies/r1/verification'));
      expect(transport.lastDeleteHeaders?['Idempotency-Key'], equals('idem-veri-002'));

      // 3. setOutcomeFeedback
      final fb = await outcomeRepo.setOutcomeFeedback(const SetOutcomeFeedbackCommand(
        postId: PlaygroundPostId('p1'),
        body: '成功应验反馈',
        idempotencyKey: 'idem-fb-001',
      ));
      expect(fb.body, equals('成功应验'));
      expect(transport.putCallCount, equals(2));
      expect(transport.lastPutUri.toString(), contains('/playground/posts/p1/outcome-feedback'));
      expect(transport.lastPutHeaders?['Idempotency-Key'], equals('idem-fb-001'));

      // 4. revokeOutcomeFeedback
      await outcomeRepo.revokeOutcomeFeedback(const RevokeOutcomeFeedbackCommand(
        postId: PlaygroundPostId('p1'),
        idempotencyKey: 'idem-fb-002',
      ));
      expect(transport.deleteCallCount, equals(2));
      expect(transport.lastDeleteUri.toString(), contains('/playground/posts/p1/outcome-feedback'));
      expect(transport.lastDeleteHeaders?['Idempotency-Key'], equals('idem-fb-002'));
    });
  });
}
