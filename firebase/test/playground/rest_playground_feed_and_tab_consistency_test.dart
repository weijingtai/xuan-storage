import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:persistence_firebase/http_playground_transport.dart';
import 'package:persistence_firebase/playground/playground.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

void main() {
  group('C2 · 三 Tab 排序与多维过滤一致性 (RestPlaygroundFeedRemoteDataSource)', () {
    late Map<String, dynamic> fakeFeedData;
    late http.Client mockClient;
    late String lastRequestedUri;
    late Map<String, String> lastRequestedHeaders;

    setUp(() {
      fakeFeedData = {
        'items': [
          {
            'id': 'post-1',
            'text': '推荐帖 1',
            'authorUserId': 'user-1',
            'status': 'active',
            'allowedChartTechniqueIds': ['tech-1', 'tech-2'],
            'attachments': [
              {
                'type': 'image',
                'mediaObjectId': 'media-1',
                'mimeType': 'image/jpeg',
                'width': 1080,
                'height': 720,
                'moderationState': 'approved',
              }
            ],
            'revisions': [
              {
                'body': '推荐帖 1 初始',
                'editedBy': 'user-1',
                'editedAt': '2026-08-21T10:00:00.000Z',
              }
            ],
            'createdAt': '2026-08-21T10:00:00.000Z',
            'updatedAt': '2026-08-21T10:05:00.000Z',
            'hasOutcomeFeedback': true,
          },
          {
            'id': 'post-2',
            'text': '推荐帖 2',
            'authorUserId': 'user-2',
            'status': 'active',
            'allowedChartTechniqueIds': ['tech-3'],
            'attachments': [],
            'revisions': [],
            'createdAt': '2026-08-21T09:00:00.000Z',
            'updatedAt': null,
            'hasOutcomeFeedback': false,
          },
        ],
        'nextCursor': 'next-cursor-token-abc',
        'hasMore': true,
        'totalCount': 2,
      };

      mockClient = MockClient((request) async {
        lastRequestedUri = request.url.toString();
        lastRequestedHeaders = request.headers;

        if (request.headers['if-none-match'] == '"etag-match-123"') {
          return http.Response('', 304, headers: {'etag': '"etag-match-123"'});
        }

        return http.Response(
          jsonEncode(fakeFeedData),
          200,
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'etag': '"etag-12345"',
          },
        );
      });
    });

    test('推荐 Tab (recommended) 发起正确参数与解析', () async {
      final remote = RestPlaygroundFeedRemoteDataSource(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        transport: DefaultPlaygroundHttpTransport(mockClient),
      );

      final query = GetFeedQuery(
        tab: PlaygroundFeedTab.recommended,
        limit: 20,
        filter: const PlaygroundFeedFilter(
          contentType: 'divination_case',
          replyStatus: 'pending',
          feedbackStatus: 'received',
          techniqueIds: ['tech-1', 'tech-2'],
        ),
      );

      final page = await remote.getRecommendedFeed(query);

      expect(lastRequestedUri, contains('/playground/feed'));
      expect(lastRequestedUri, contains('tab=recommended'));
      expect(lastRequestedUri, contains('limit=20'));
      expect(lastRequestedUri, contains('contentType=divination_case'));
      expect(lastRequestedUri, contains('replyStatus=pending'));
      expect(lastRequestedUri, contains('feedbackStatus=received'));
      expect(lastRequestedUri, contains('techniqueIds=tech-1%2Ctech-2'));

      expect(page.items.length, equals(2));
      expect(page.items[0].id.value, equals('post-1'));
      expect(page.items[0].text, equals('推荐帖 1'));
      expect(page.items[0].authorUserId.value, equals('user-1'));
      expect(page.items[0].status, equals(PlaygroundPostStatus.active));
      expect(page.items[0].allowedChartTechniqueIds, equals(['tech-1', 'tech-2']));
      expect(page.items[0].attachments.length, equals(1));
      expect(page.items[0].attachments[0].type, equals(PlaygroundAttachmentType.image));
      expect(page.items[0].revisions.length, equals(1));
      expect(page.items[0].hasOutcomeFeedback, isTrue);
      expect(page.nextCursor?.token, equals('next-cursor-token-abc'));
      expect(page.hasMore, isTrue);
    });

    test('待断 Tab (pendingDivination) 路由正确', () async {
      final remote = RestPlaygroundFeedRemoteDataSource(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        transport: DefaultPlaygroundHttpTransport(mockClient),
      );

      final query = GetFeedQuery(
        tab: PlaygroundFeedTab.pendingDivination,
        limit: 10,
      );

      final page = await remote.getPendingDivinationFeed(query);
      expect(lastRequestedUri, contains('tab=pendingDivination'));
      expect(page.items.length, equals(2));
    });

    test('最新 Tab (latest) 路由正确', () async {
      final remote = RestPlaygroundFeedRemoteDataSource(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        transport: DefaultPlaygroundHttpTransport(mockClient),
      );

      final query = GetFeedQuery(
        tab: PlaygroundFeedTab.latest,
        limit: 15,
      );

      final page = await remote.getLatestFeed(query);
      expect(lastRequestedUri, contains('tab=latest'));
      expect(page.items.length, equals(2));
    });

    test('ETag 304 条件协商与本地缓存快照返回', () async {
      final remote = RestPlaygroundFeedRemoteDataSource(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        transport: DefaultPlaygroundHttpTransport(mockClient),
      );

      // 第 1 次请求，获取 200 与 ETag
      final query = GetFeedQuery(tab: PlaygroundFeedTab.recommended);
      final page1 = await remote.getFeed(query);
      expect(page1.items.length, equals(2));

      // 切换 mockClient 返回 304
      mockClient = MockClient((request) async {
        if (request.headers['if-none-match'] != null) {
          return http.Response('', 304, headers: {'etag': request.headers['if-none-match']!});
        }
        return http.Response(jsonEncode(fakeFeedData), 200);
      });

      final remoteWith304 = RestPlaygroundFeedRemoteDataSource(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        transport: DefaultPlaygroundHttpTransport(mockClient),
        initialEtagCache: {'recommended': '"etag-cached"'},
        initialSnapshotCache: {'recommended': page1},
      );

      final page2 = await remoteWith304.getFeed(query);
      // 命中 304 时返回缓存快照
      expect(page2.items.length, equals(2));
      expect(page2.items[0].id.value, equals('post-1'));
    });
  });
}
