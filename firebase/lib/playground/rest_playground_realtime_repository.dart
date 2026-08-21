import 'dart:async';
import 'dart:convert';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'playground_http_transport.dart';
import 'playground_transport_config.dart';
import 'rest_playground_feed_repository.dart';

/// 基于 REST + ETag 轮询的实时仓储实现（降级 Firestore snapshots() 实时流）。
///
/// 严格遵守 Q2 裁决轮询策略：
/// 1. 前台活跃态 (active)：3s 轮询；
/// 2. 空闲态 (idle)：10s 轮询；
/// 3. 后台挂起态 (background)：彻底停止轮询（硬要求，0 定时器 0 网络消耗）；
/// 4. 304 Not Modified：保持基线周期；
/// 5. 429 / 503 错误：指数退避至上限 16s；200 成功时重置。
final class RestPlaygroundRealtimeRepository
    implements PlaygroundRealtimeRepository {
  RestPlaygroundRealtimeRepository({
    required this.baseUrl,
    required PlaygroundHttpTransport transport,
    this.activeInterval = const Duration(seconds: 3),
    this.idleInterval = const Duration(seconds: 10),
    this.maxBackoffInterval = const Duration(seconds: 16),
  }) : _transport = transport;

  final Uri baseUrl;
  final PlaygroundHttpTransport _transport;
  final Duration activeInterval;
  final Duration idleInterval;
  final Duration maxBackoffInterval;

  PlaygroundLifecycleState _lifecycleState = PlaygroundLifecycleState.active;
  int _backoffMultiplier = 1;

  final Set<_PollingWatchHandle> _activeWatches = {};

  PlaygroundLifecycleState get currentLifecycleState => _lifecycleState;
  bool get isPollingSuspended =>
      _lifecycleState == PlaygroundLifecycleState.background;
  int get currentBackoffMultiplier => _backoffMultiplier;

  Duration get effectiveInterval {
    final base = switch (_lifecycleState) {
      PlaygroundLifecycleState.active => activeInterval,
      PlaygroundLifecycleState.idle => idleInterval,
      PlaygroundLifecycleState.background => Duration.zero,
    };
    final calculated = base * _backoffMultiplier;
    if (calculated > maxBackoffInterval) {
      return maxBackoffInterval;
    }
    return calculated;
  }

  void updateLifecycleState(PlaygroundLifecycleState newState) {
    if (_lifecycleState == newState) return;
    _lifecycleState = newState;

    for (final handle in _activeWatches) {
      handle.onLifecycleChanged();
    }
  }

  void recordThrottleOrError(int statusCode) {
    if (statusCode == 429 || statusCode == 503) {
      _backoffMultiplier = (_backoffMultiplier * 2).clamp(1, 16);
    }
  }

  void recordSuccess() {
    _backoffMultiplier = 1;
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return baseUrl.replace(
      path: '${baseUrl.path.replaceAll(RegExp(r'/+$'), '')}$normalizedPath',
      queryParameters:
          queryParameters?.isEmpty ?? true ? null : queryParameters,
    );
  }

  @override
  Stream<PlaygroundRealtimeEvent> watchPostThread(PlaygroundPostId postId) {
    final controller = StreamController<PlaygroundRealtimeEvent>.broadcast();
    final handle = _PollingWatchHandle(
      repository: this,
      postId: postId,
      controller: controller,
    );

    controller.onListen = () {
      _activeWatches.add(handle);
      handle.start();
    };

    controller.onCancel = () {
      _activeWatches.remove(handle);
      handle.stop();
    };

    return controller.stream;
  }

  @override
  Stream<PlaygroundRealtimeEvent> watchNotifications(PlaygroundUserId userId) {
    // 通知轮询通道（若需要）
    final controller = StreamController<PlaygroundRealtimeEvent>.broadcast();
    return controller.stream;
  }

  @override
  Stream<PlaygroundRealtimeEvent> watchConversation(
      PlaygroundConversationId conversationId) {
    // 私信会话轮询通道
    final controller = StreamController<PlaygroundRealtimeEvent>.broadcast();
    return controller.stream;
  }

  void dispose() {
    for (final handle in List.of(_activeWatches)) {
      handle.stop();
    }
    _activeWatches.clear();
  }
}

final class _PollingWatchHandle {
  _PollingWatchHandle({
    required this.repository,
    required this.postId,
    required this.controller,
  });

  final RestPlaygroundRealtimeRepository repository;
  final PlaygroundPostId postId;
  final StreamController<PlaygroundRealtimeEvent> controller;

  Timer? _timer;
  String? _lastEtag;
  PlaygroundPost? _lastPost;
  bool _isPolling = false;

  void start() {
    _pollOnce(isInitial: true);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void onLifecycleChanged() {
    _timer?.cancel();
    _timer = null;

    if (repository.isPollingSuspended) {
      // 后台挂起：严禁设置 timer，彻底停止
      return;
    }

    // 恢复到前台时立即调度下一个轮询周期
    _scheduleNext();
  }

  void _scheduleNext() {
    if (controller.isClosed || repository.isPollingSuspended) return;
    final interval = repository.effectiveInterval;
    if (interval <= Duration.zero) return;

    _timer?.cancel();
    _timer = Timer(interval, () {
      _pollOnce(isInitial: false);
    });
  }

  Future<void> _pollOnce({bool isInitial = false}) async {
    if (controller.isClosed || _isPolling) return;
    if (!isInitial && repository.isPollingSuspended) return;

    _isPolling = true;
    try {
      final uri = repository._buildUri('/playground/posts/${postId.value}');
      final headers = <String, String>{
        'accept': 'application/json',
        if (_lastEtag != null) 'if-none-match': _lastEtag!,
      };

      final response = await repository._transport.get(uri, headers: headers);

      if (response.statusCode == 304) {
        // 304 Not Modified: 数据无变动，保持基线
        repository.recordSuccess();
      } else if (response.statusCode == 429 || response.statusCode == 503) {
        repository.recordThrottleOrError(response.statusCode);
      } else if (response.statusCode >= 200 && response.statusCode < 300) {
        repository.recordSuccess();
        _lastEtag = response.headers['etag'];

        final json = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        final post = RestPlaygroundFeedRemoteDataSource.parsePostFromJson(json);

        if (_lastPost != post) {
          _lastPost = post;
          if (!controller.isClosed) {
            // 发射帖子详情变更事件
            controller.add(
              PlaygroundRealtimeEvent(
                type: PlaygroundEventType.upsert,
                resourceType: PlaygroundResourceType.post,
                resourceId: postId.value,
                payload: {
                  'updatedAt': (post.updatedAt ?? post.createdAt).toIso8601String(),
                },
              ),
            );
          }
        }
      }
    } catch (e, st) {
      if (!controller.isClosed) {
        controller.addError(e, st);
      }
    } finally {
      _isPolling = false;
      if (!controller.isClosed && !repository.isPollingSuspended) {
        _scheduleNext();
      }
    }
  }
}
