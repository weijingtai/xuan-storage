import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:persistence_firebase/playground/playground.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

void main() {
  group('C3 · 轮询策略 4 态与后台停止 (RestPlaygroundRealtimeRepository)', () {
    test('前台活跃态 (active) 默认 3s 轮询', () {
      final repo = RestPlaygroundRealtimeRepository(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        activeInterval: const Duration(seconds: 3),
        idleInterval: const Duration(seconds: 10),
      );

      expect(repo.activeInterval, equals(const Duration(seconds: 3)));
      expect(repo.currentLifecycleState, equals(PlaygroundLifecycleState.active));
      expect(repo.effectiveInterval, equals(const Duration(seconds: 3)));
    });

    test('空闲态 (idle) 切换为 10s 轮询', () {
      final repo = RestPlaygroundRealtimeRepository(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        activeInterval: const Duration(seconds: 3),
        idleInterval: const Duration(seconds: 10),
      );

      repo.updateLifecycleState(PlaygroundLifecycleState.idle);
      expect(repo.currentLifecycleState, equals(PlaygroundLifecycleState.idle));
      expect(repo.effectiveInterval, equals(const Duration(seconds: 10)));
    });

    test('后台挂起态 (background) 必须彻底停止轮询（硬要求）', () async {
      var requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        return http.Response(
          jsonEncode({
            'id': 'post-1',
            'text': '正文',
            'authorUserId': 'user-1',
            'status': 'active',
            'createdAt': '2026-08-21T10:00:00.000Z',
          }),
          200,
          headers: {
            'etag': '"rev-1"',
            'content-type': 'application/json; charset=utf-8',
          },
        );
      });

      final repo = RestPlaygroundRealtimeRepository(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        client: mockClient,
        activeInterval: const Duration(milliseconds: 50),
        idleInterval: const Duration(milliseconds: 100),
      );

      final stream = repo.watchPostThread(const PlaygroundPostId('post-1'));
      final sub = stream.listen((_) {});

      // 等待首帧发完
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final countBeforeBg = requestCount;
      expect(countBeforeBg, greaterThan(0));

      // 切到后台
      repo.updateLifecycleState(PlaygroundLifecycleState.background);
      expect(repo.isPollingSuspended, isTrue);

      // 等待 150ms，在此期间后台挂起，请求数绝不增加
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(requestCount, equals(countBeforeBg),
          reason: '后台挂起期间严禁发起任何轮询网络请求');

      // 切回前台恢复轮询
      repo.updateLifecycleState(PlaygroundLifecycleState.active);
      expect(repo.isPollingSuspended, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(requestCount, greaterThan(countBeforeBg),
          reason: '切回前台后轮询应当恢复');

      await sub.cancel();
      repo.dispose();
    });

    test('304 Not Modified 保持基线轮询周期', () async {
      var requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        if (requestCount > 1) {
          return http.Response('', 304, headers: {'etag': '"rev-1"'});
        }
        return http.Response(
          jsonEncode({
            'id': 'post-1',
            'text': '正文',
            'authorUserId': 'user-1',
            'status': 'active',
            'createdAt': '2026-08-21T10:00:00.000Z',
          }),
          200,
          headers: {
            'etag': '"rev-1"',
            'content-type': 'application/json; charset=utf-8',
          },
        );
      });

      final repo = RestPlaygroundRealtimeRepository(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        client: mockClient,
        activeInterval: const Duration(milliseconds: 50),
      );

      final stream = repo.watchPostThread(const PlaygroundPostId('post-1'));
      final events = <PlaygroundRealtimeEvent>[];
      final sub = stream.listen(events.add);

      await Future<void>.delayed(const Duration(milliseconds: 130));
      expect(repo.currentBackoffMultiplier, equals(1));

      await sub.cancel();
      repo.dispose();
    });

    test('429 / 503 指数退避至 16s 上限', () {
      final repo = RestPlaygroundRealtimeRepository(
        baseUrl: Uri.parse('http://127.0.0.1:8080/v1'),
        activeInterval: const Duration(seconds: 3),
        maxBackoffInterval: const Duration(seconds: 16),
      );

      expect(repo.currentBackoffMultiplier, equals(1));
      expect(repo.effectiveInterval, equals(const Duration(seconds: 3)));

      // 模拟第 1 次 429
      repo.recordThrottleOrError(429);
      expect(repo.currentBackoffMultiplier, equals(2));
      expect(repo.effectiveInterval, equals(const Duration(seconds: 6)));

      // 模拟第 2 次 503
      repo.recordThrottleOrError(503);
      expect(repo.currentBackoffMultiplier, equals(4));
      expect(repo.effectiveInterval, equals(const Duration(seconds: 12)));

      // 模拟第 3 次 429 -> 达到上限 16s
      repo.recordThrottleOrError(429);
      expect(repo.effectiveInterval, equals(const Duration(seconds: 16)));

      // 恢复 200 OK -> 重置倍数
      repo.recordSuccess();
      expect(repo.currentBackoffMultiplier, equals(1));
      expect(repo.effectiveInterval, equals(const Duration(seconds: 3)));
    });
  });
}
