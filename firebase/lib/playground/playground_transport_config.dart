import 'package:equatable/equatable.dart';

/// 传输模式。
enum TransportMode {
  /// 原生 Firestore SDK 访问。
  firestore,

  /// REST / HTTP API 访问。
  rest,
}

/// 实时事件模式。
enum RealtimeMode {
  /// Firestore 原生 snapshots() 实时监听流。
  firestoreSnapshots,

  /// REST ETag 条件轮询。
  restPolling,
}

/// 客户端生命周期状态（用于精细化轮询调频）。
enum PlaygroundLifecycleState {
  /// 前台活跃态（默认 3s 轮询）。
  active,

  /// 前台空闲态（无交互，10s 轮询）。
  idle,

  /// 后台挂起态（彻底停止轮询，0 网络消耗）。
  background,
}

/// 广场传输层配置与一键回滚开关规范（§5.2、FW2 逐命令开关）。
final class PlaygroundTransportConfig extends Equatable {
  const PlaygroundTransportConfig({
    this.feedTransport = TransportMode.firestore,
    this.postTransport = TransportMode.firestore,
    this.likeTransport = TransportMode.firestore,
    this.bookmarkTransport = TransportMode.firestore,
    this.realtimeMode = RealtimeMode.firestoreSnapshots,
    this.activePollingInterval = const Duration(seconds: 3),
    this.idlePollingInterval = const Duration(seconds: 10),
    this.maxBackoffInterval = const Duration(seconds: 16),
    this.shadowComparisonEnabled = false,
    this.shadowSamplingRate = 1.0,
  });

  /// 默认配置：严格保持默认关闭（默认全走 Firestore / callable / snapshots()，保证生产零风险）。
  factory PlaygroundTransportConfig.defaults() =>
      const PlaygroundTransportConfig();

  final TransportMode feedTransport;
  final TransportMode postTransport;
  final TransportMode likeTransport;
  final TransportMode bookmarkTransport;
  final RealtimeMode realtimeMode;
  final Duration activePollingInterval;
  final Duration idlePollingInterval;
  final Duration maxBackoffInterval;
  final bool shadowComparisonEnabled;
  final double shadowSamplingRate;

  bool get isRestFeedEnabled => feedTransport == TransportMode.rest;
  bool get isRestPostEnabled => postTransport == TransportMode.rest;
  bool get isRestLikeEnabled => likeTransport == TransportMode.rest;
  bool get isRestBookmarkEnabled => bookmarkTransport == TransportMode.rest;
  bool get isRestPollingEnabled => realtimeMode == RealtimeMode.restPolling;

  PlaygroundTransportConfig copyWith({
    TransportMode? feedTransport,
    TransportMode? postTransport,
    TransportMode? likeTransport,
    TransportMode? bookmarkTransport,
    RealtimeMode? realtimeMode,
    Duration? activePollingInterval,
    Duration? idlePollingInterval,
    Duration? maxBackoffInterval,
    bool? shadowComparisonEnabled,
    double? shadowSamplingRate,
  }) {
    return PlaygroundTransportConfig(
      feedTransport: feedTransport ?? this.feedTransport,
      postTransport: postTransport ?? this.postTransport,
      likeTransport: likeTransport ?? this.likeTransport,
      bookmarkTransport: bookmarkTransport ?? this.bookmarkTransport,
      realtimeMode: realtimeMode ?? this.realtimeMode,
      activePollingInterval:
          activePollingInterval ?? this.activePollingInterval,
      idlePollingInterval: idlePollingInterval ?? this.idlePollingInterval,
      maxBackoffInterval: maxBackoffInterval ?? this.maxBackoffInterval,
      shadowComparisonEnabled:
          shadowComparisonEnabled ?? this.shadowComparisonEnabled,
      shadowSamplingRate: shadowSamplingRate ?? this.shadowSamplingRate,
    );
  }

  /// 一键回滚：将所有读写与实时路径切回原生 Firestore / Callable。
  PlaygroundTransportConfig rollbackToFirestore() {
    return copyWith(
      feedTransport: TransportMode.firestore,
      postTransport: TransportMode.firestore,
      likeTransport: TransportMode.firestore,
      bookmarkTransport: TransportMode.firestore,
      realtimeMode: RealtimeMode.firestoreSnapshots,
    );
  }

  @override
  List<Object?> get props => [
        feedTransport,
        postTransport,
        likeTransport,
        bookmarkTransport,
        realtimeMode,
        activePollingInterval,
        idlePollingInterval,
        maxBackoffInterval,
        shadowComparisonEnabled,
        shadowSamplingRate,
      ];
}
