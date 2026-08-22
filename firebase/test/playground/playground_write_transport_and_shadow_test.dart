import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_firebase/playground/playground.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class _MockHttpTransport implements PlaygroundHttpTransport {
  _MockHttpTransport({this.onPut, this.onGet});

  Future<PlaygroundHttpResponse> Function(Uri uri, Map<String, String>? headers, Object? body)? onPut;
  Future<PlaygroundHttpResponse> Function(Uri uri, Map<String, String>? headers)? onGet;

  int putCallCount = 0;
  List<Map<String, String>?> putHeadersHistory = [];
  Uri? lastPutUri;
  Map<String, String>? lastPutHeaders;
  Object? lastPutBody;

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
      final fakeAuth = FakeFirebaseAuth();
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
      final fakeAuth = FakeFirebaseAuth();
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

    test('C3: 防双写安全机制与工厂影子包装真调用验证 (只有 primary 发起实际写操作)', () async {
      final transport = _MockHttpTransport();
      final factory = PlaygroundRepositoryFactory(
        initialConfig: PlaygroundTransportConfig.defaults().copyWith(
          likeTransport: TransportMode.rest,
          shadowComparisonEnabled: true,
        ),
        restBaseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        httpTransport: transport,
        firestore: FakeFirebaseFirestore(),
        auth: FakeFirebaseAuth(),
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

      // 真调用被测写路径
      await likeDataSource.setLike(const SetLikeCommand(
        liked: true,
        postId: PlaygroundPostId('p300'),
        idempotencyKey: 'idem-shadow-test',
      ));

      // 验证防双写：网络写请求严格只有 1 次
      expect(transport.putCallCount, equals(1));
      // 验证触发了影子比对回调
      expect(capturedResult, isNotNull);
      expect(capturedResult!.isMatch, isTrue);
      expect(capturedOp, equals('setLike'));
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
        auth: FakeFirebaseAuth(),
        identityResolver: FirebasePlaygroundIdentityResolver(firestore: FakeFirebaseFirestore(), auth: FakeFirebaseAuth()),
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
        auth: FakeFirebaseAuth(),
        identityResolver: FirebasePlaygroundIdentityResolver(firestore: FakeFirebaseFirestore(), auth: FakeFirebaseAuth()),
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
        auth: FakeFirebaseAuth(),
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
}

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {}
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}
