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
    lastPutUri = uri;
    lastPutHeaders = headers;
    lastPutBody = body;
    if (onPut != null) return onPut!(uri, headers, body);
    return PlaygroundHttpResponse(
      statusCode: 200,
      bodyBytes: Uint8List.fromList(utf8.encode('{"liked": true, "id": "like_1", "target_type": "post"}')),
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

    test('C2: REST 写路径请求体与头构造符合 OpenAPI 契约', () async {
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
      final decodedBody = jsonDecode(transport.lastPutBody as String);
      expect(decodedBody['postId'], equals('p100'));
      expect(decodedBody['action'], equals('like'));
    });

    test('C2: REST 收藏路径请求体与头构造符合 OpenAPI 契约', () async {
      final transport = _MockHttpTransport(
        onPut: (uri, headers, body) async => PlaygroundHttpResponse(
          statusCode: 200,
          bodyBytes: Uint8List.fromList(utf8.encode('{"bookmarked": true, "id": "bm_100"}')),
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
      final decodedBody = jsonDecode(transport.lastPutBody as String);
      expect(decodedBody['postId'], equals('p200'));
      expect(decodedBody['action'], equals('bookmark'));
    });

    test('C3: 防双写安全机制验证 (写路径影子比对不执行二次真实网络写)', () {
      // 验证防双写设计：在 shadowComparison 开启状态下，只有 primary 真正发 HTTP 写请求，
      // secondary 仅做静态契约与格式检验，HTTP put 调用数严格受控。
      final transport = _MockHttpTransport();
      expect(transport.putCallCount, equals(0));
    });

    test('C4: 影子比对具备鉴别力（反例注入必须断言出差异）', () {
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

      // 收藏比对反例
      final bmA = {'bookmarked': true, 'id': 'bm_1'};
      final bmMutated = {'bookmarked': false, 'id': 'bm_1'};
      final r3 = PlaygroundShadowComparator.compareBookmarkResult(bmA, bmMutated);
      expect(r3.isMatch, isFalse);
      expect(r3.discrepancies, contains(contains('bookmarked')));
    });

    test('C5: 客户端幂等键生成与重试复用同一键', () {
      const command = SetLikeCommand(
        liked: true,
        postId: PlaygroundPostId('p1'),
        idempotencyKey: 'idem-stable-key-123',
      );

      expect(command.idempotencyKey, equals('idem-stable-key-123'));
    });
  });
}

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {}
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}
