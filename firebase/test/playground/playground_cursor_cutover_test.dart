import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_firebase/cached_playground_feed_repository.dart';
import 'package:persistence_firebase/http_playground_transport.dart';
import 'package:persistence_firebase/playground/playground.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class _InMemoryPlaygroundPostCacheStore implements PlaygroundPostCacheStore {
  final Map<String, PlaygroundPost> _cache = {};

  @override
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId) async => _cache[postId.value];

  @override
  Future<void> upsertPost(PlaygroundPost post) async => _cache[post.id.value] = post;

  @override
  Future<void> deletePost(PlaygroundPostId postId) async => _cache.remove(postId.value);
}

void main() {
  group('C5 · 游标跨适配器切换平稳重置 (§6.2)', () {
    late _InMemoryPlaygroundPostCacheStore cacheStore;

    setUp(() {
      cacheStore = _InMemoryPlaygroundPostCacheStore();
    });

    test('当传入旧/无效 cursor 时，REST 适配器抛出 CURSOR_INVALID_OR_STALE，组合仓储自动重置为第 1 页拉取且不崩溃', () async {
      var requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        final cursor = request.url.queryParameters['cursor'];

        // 如果携带了旧游标，返回 400 Bad Request + CURSOR_INVALID_OR_STALE
        if (cursor == 'incompatible-old-firestore-cursor') {
          return http.Response(
            jsonEncode({
              'type': 'invalid_argument',
              'title': 'Invalid Cursor',
              'status': 400,
              'detail': 'The provided cursor is stale or incompatible with current transport adapter.',
              'reason': 'CURSOR_INVALID_OR_STALE',
              'suggestion': 'Reset cursor and fetch from first page.',
            }),
            400,
            headers: {'content-type': 'application/problem+json'},
          );
        }

        // 无 cursor 或 cursor 为 null 时正常返回第 1 页
        return http.Response(
          jsonEncode({
            'items': [
              {
                'id': 'post-first-page-1',
                'text': '第 1 页帖子',
                'authorUserId': 'user-1',
                'status': 'active',
                'createdAt': '2026-08-21T10:00:00.000Z',
              }
            ],
            'nextCursor': 'rest-cursor-page-2',
            'hasMore': true,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final restRemote = RestPlaygroundFeedRemoteDataSource(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        transport: DefaultPlaygroundHttpTransport(mockClient),
      );

      final cachedRepo = CachedPlaygroundFeedRepository(
        remote: restRemote,
        cache: cacheStore,
      );

      // 查询时携带旧游标
      final queryWithOldCursor = GetFeedQuery(
        tab: PlaygroundFeedTab.recommended,
        cursor: const PlaygroundCursor('incompatible-old-firestore-cursor'),
      );

      final resultPage = await cachedRepo.getFeed(queryWithOldCursor);

      // 验证：
      // 1. 不崩溃；
      // 2. 严禁静默返回空列表；
      // 3. 自动降级重新拉取第 1 页并返回数据；
      // 4. 发起了重试请求。
      expect(resultPage.items, isNotEmpty);
      expect(resultPage.items.first.id.value, equals('post-first-page-1'));
      expect(resultPage.nextCursor?.token, equals('rest-cursor-page-2'));
      expect(requestCount, equals(2), reason: '首次携带旧游标失败后，自动重置 cursor 发起第 2 次拉取');
    });
  });
}
