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

/// 广场传输层配置与一键回滚开关规范（§5.2、FW2/FW3 逐命令开关）。
final class PlaygroundTransportConfig extends Equatable {
  const PlaygroundTransportConfig({
    this.feedTransport = TransportMode.firestore,
    this.postTransport = TransportMode.firestore,
    this.likeTransport = TransportMode.firestore,
    this.bookmarkTransport = TransportMode.firestore,
    this.createPostTransport = TransportMode.firestore,
    this.editPostTransport = TransportMode.firestore,
    this.tombstonePostTransport = TransportMode.firestore,
    this.profileTransport = TransportMode.firestore,
    this.createRootReplyTransport = TransportMode.firestore,
    this.createDiscussionReplyTransport = TransportMode.firestore,
    this.editReplyTransport = TransportMode.firestore,
    this.deleteReplyTransport = TransportMode.firestore,
    this.verifyRootReplyTransport = TransportMode.firestore,
    this.revokeVerificationTransport = TransportMode.firestore,
    this.setOutcomeFeedbackTransport = TransportMode.firestore,
    this.revokeOutcomeFeedbackTransport = TransportMode.firestore,
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

  // FW3 逐命令开关
  final TransportMode createPostTransport;
  final TransportMode editPostTransport;
  final TransportMode tombstonePostTransport;
  final TransportMode profileTransport;
  final TransportMode createRootReplyTransport;
  final TransportMode createDiscussionReplyTransport;
  final TransportMode editReplyTransport;
  final TransportMode deleteReplyTransport;
  final TransportMode verifyRootReplyTransport;
  final TransportMode revokeVerificationTransport;
  final TransportMode setOutcomeFeedbackTransport;
  final TransportMode revokeOutcomeFeedbackTransport;

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

  // FW3 逐命令判断（支持总开关 postTransport / replyTransport 级联或细粒度开关）
  bool get isRestCreatePostEnabled =>
      createPostTransport == TransportMode.rest || isRestPostEnabled;
  bool get isRestEditPostEnabled =>
      editPostTransport == TransportMode.rest || isRestPostEnabled;
  bool get isRestTombstonePostEnabled =>
      tombstonePostTransport == TransportMode.rest || isRestPostEnabled;
  bool get isRestProfileEnabled => profileTransport == TransportMode.rest;
  bool get isRestCreateRootReplyEnabled =>
      createRootReplyTransport == TransportMode.rest;
  bool get isRestCreateDiscussionReplyEnabled =>
      createDiscussionReplyTransport == TransportMode.rest;
  bool get isRestEditReplyEnabled => editReplyTransport == TransportMode.rest;
  bool get isRestDeleteReplyEnabled => deleteReplyTransport == TransportMode.rest;
  bool get isRestVerifyRootReplyEnabled =>
      verifyRootReplyTransport == TransportMode.rest;
  bool get isRestRevokeVerificationEnabled =>
      revokeVerificationTransport == TransportMode.rest;
  bool get isRestSetOutcomeFeedbackEnabled =>
      setOutcomeFeedbackTransport == TransportMode.rest;
  bool get isRestRevokeOutcomeFeedbackEnabled =>
      revokeOutcomeFeedbackTransport == TransportMode.rest;

  bool get isRestPollingEnabled => realtimeMode == RealtimeMode.restPolling;

  PlaygroundTransportConfig copyWith({
    TransportMode? feedTransport,
    TransportMode? postTransport,
    TransportMode? likeTransport,
    TransportMode? bookmarkTransport,
    TransportMode? createPostTransport,
    TransportMode? editPostTransport,
    TransportMode? tombstonePostTransport,
    TransportMode? profileTransport,
    TransportMode? createRootReplyTransport,
    TransportMode? createDiscussionReplyTransport,
    TransportMode? editReplyTransport,
    TransportMode? deleteReplyTransport,
    TransportMode? verifyRootReplyTransport,
    TransportMode? revokeVerificationTransport,
    TransportMode? setOutcomeFeedbackTransport,
    TransportMode? revokeOutcomeFeedbackTransport,
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
      createPostTransport: createPostTransport ?? this.createPostTransport,
      editPostTransport: editPostTransport ?? this.editPostTransport,
      tombstonePostTransport:
          tombstonePostTransport ?? this.tombstonePostTransport,
      profileTransport: profileTransport ?? this.profileTransport,
      createRootReplyTransport:
          createRootReplyTransport ?? this.createRootReplyTransport,
      createDiscussionReplyTransport:
          createDiscussionReplyTransport ?? this.createDiscussionReplyTransport,
      editReplyTransport: editReplyTransport ?? this.editReplyTransport,
      deleteReplyTransport: deleteReplyTransport ?? this.deleteReplyTransport,
      verifyRootReplyTransport:
          verifyRootReplyTransport ?? this.verifyRootReplyTransport,
      revokeVerificationTransport:
          revokeVerificationTransport ?? this.revokeVerificationTransport,
      setOutcomeFeedbackTransport:
          setOutcomeFeedbackTransport ?? this.setOutcomeFeedbackTransport,
      revokeOutcomeFeedbackTransport:
          revokeOutcomeFeedbackTransport ?? this.revokeOutcomeFeedbackTransport,
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
      createPostTransport: TransportMode.firestore,
      editPostTransport: TransportMode.firestore,
      tombstonePostTransport: TransportMode.firestore,
      profileTransport: TransportMode.firestore,
      createRootReplyTransport: TransportMode.firestore,
      createDiscussionReplyTransport: TransportMode.firestore,
      editReplyTransport: TransportMode.firestore,
      deleteReplyTransport: TransportMode.firestore,
      verifyRootReplyTransport: TransportMode.firestore,
      revokeVerificationTransport: TransportMode.firestore,
      setOutcomeFeedbackTransport: TransportMode.firestore,
      revokeOutcomeFeedbackTransport: TransportMode.firestore,
      realtimeMode: RealtimeMode.firestoreSnapshots,
    );
  }

  @override
  List<Object?> get props => [
        feedTransport,
        postTransport,
        likeTransport,
        bookmarkTransport,
        createPostTransport,
        editPostTransport,
        tombstonePostTransport,
        profileTransport,
        createRootReplyTransport,
        createDiscussionReplyTransport,
        editReplyTransport,
        deleteReplyTransport,
        verifyRootReplyTransport,
        revokeVerificationTransport,
        setOutcomeFeedbackTransport,
        revokeOutcomeFeedbackTransport,
        realtimeMode,
        activePollingInterval,
        idlePollingInterval,
        maxBackoffInterval,
        shadowComparisonEnabled,
        shadowSamplingRate,
      ];
}
