import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import '../cached_playground_feed_repository.dart';
import '../cached_playground_post_repository.dart';
import 'firebase_playground_bookmark_repository.dart';
import 'firebase_playground_engagement_repository.dart';
import 'firebase_playground_feed_repository.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_like_repository.dart';
import 'firebase_playground_post_repository.dart';
import 'firebase_playground_realtime_repository.dart';
import 'playground_http_transport.dart';
import 'playground_shadow_feed_remote_data_source.dart';
import 'playground_transport_config.dart';
import 'rest_playground_feed_repository.dart';
import 'rest_playground_post_repository.dart';
import 'rest_playground_realtime_repository.dart';

/// 广场仓储装配工厂与传输层切换中枢（§5.2）。
final class PlaygroundRepositoryFactory {
  PlaygroundRepositoryFactory({
    PlaygroundTransportConfig? initialConfig,
    this.restBaseUrl,
    this.httpTransport,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebasePlaygroundIdentityResolver? identityResolver,
  })  : _config = initialConfig ?? PlaygroundTransportConfig.defaults(),
        _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver;

  PlaygroundTransportConfig _config;
  final Uri? restBaseUrl;
  final PlaygroundHttpTransport? httpTransport;
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;
  final FirebasePlaygroundIdentityResolver? _identityResolver;

  PlaygroundTransportConfig get currentConfig => _config;

  bool get isRollbacked =>
      _config.feedTransport == TransportMode.firestore &&
      _config.postTransport == TransportMode.firestore &&
      _config.likeTransport == TransportMode.firestore &&
      _config.bookmarkTransport == TransportMode.firestore &&
      _config.realtimeMode == RealtimeMode.firestoreSnapshots;

  void updateConfig(PlaygroundTransportConfig newConfig) {
    _config = newConfig;
  }

  /// 一键回滚到 Firestore 原生模式。
  void rollback() {
    _config = _config.rollbackToFirestore();
  }

  /// 创建 Feed 远端数据源。
  PlaygroundFeedRemoteDataSource createFeedRemoteDataSource({
    FirebaseFirestore? firestore,
    Uri? baseUrl,
    PlaygroundHttpTransport? transport,
    ShadowComparisonCallback? onShadowComparison,
  }) {
    final effectiveFirestore = firestore ?? _firestore;
    final effectiveBaseUrl =
        baseUrl ?? restBaseUrl ?? Uri.parse('http://127.0.0.1:8080/v1');
    final effectiveTransport = transport ?? httpTransport;

    PlaygroundFeedRemoteDataSource buildFirestoreSource() {
      if (effectiveFirestore == null) {
        throw StateError('FirebaseFirestore must be provided for firestore transport');
      }
      return FirebasePlaygroundFeedRepository(firestore: effectiveFirestore);
    }

    PlaygroundFeedRemoteDataSource buildRestSource() {
      if (effectiveTransport == null) {
        throw StateError('PlaygroundHttpTransport must be provided for REST transport');
      }
      return RestPlaygroundFeedRemoteDataSource(
        baseUrl: effectiveBaseUrl,
        transport: effectiveTransport,
      );
    }

    if (_config.shadowComparisonEnabled) {
      return ShadowPlaygroundFeedRemoteDataSource(
        primary: _config.isRestFeedEnabled ? buildRestSource() : buildFirestoreSource(),
        secondary: _config.isRestFeedEnabled ? buildFirestoreSource() : buildRestSource(),
        onComparison: onShadowComparison,
      );
    }

    return _config.isRestFeedEnabled ? buildRestSource() : buildFirestoreSource();
  }

  /// 创建 Post 远端数据源。
  PlaygroundPostRemoteDataSource createPostRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebasePlaygroundIdentityResolver? identityResolver,
    Uri? baseUrl,
    PlaygroundHttpTransport? transport,
  }) {
    final effectiveFirestore = firestore ?? _firestore;
    final effectiveAuth = auth ?? _auth ?? FirebaseAuth.instance;
    final effectiveIdentityResolver = identityResolver ??
        _identityResolver ??
        FirebasePlaygroundIdentityResolver(
          firestore: effectiveFirestore ?? FirebaseFirestore.instance,
          auth: effectiveAuth,
        );

    final effectiveBaseUrl =
        baseUrl ?? restBaseUrl ?? Uri.parse('http://127.0.0.1:8080/v1');
    final effectiveTransport = transport ?? httpTransport;

    PlaygroundPostRemoteDataSource? firestoreSource;
    if (effectiveFirestore != null) {
      firestoreSource = FirebasePlaygroundPostRepository(
        firestore: effectiveFirestore,
        auth: effectiveAuth,
        identityResolver: effectiveIdentityResolver,
      );
    }

    if (_config.isRestPostEnabled) {
      if (effectiveTransport == null) {
        throw StateError('PlaygroundHttpTransport must be provided for REST post transport');
      }
      return RestPlaygroundPostRemoteDataSource(
        baseUrl: effectiveBaseUrl,
        transport: effectiveTransport,
        fallbackWriter: firestoreSource,
      );
    }

    if (firestoreSource == null) {
      throw StateError('FirebaseFirestore must be provided for firestore post transport');
    }
    return firestoreSource;
  }

  /// 创建实时仓储。
  PlaygroundRealtimeRepository createRealtimeRepository({
    FirebaseFirestore? firestore,
    Uri? baseUrl,
    PlaygroundHttpTransport? transport,
  }) {
    final effectiveFirestore = firestore ?? _firestore;
    final effectiveBaseUrl =
        baseUrl ?? restBaseUrl ?? Uri.parse('http://127.0.0.1:8080/v1');
    final effectiveTransport = transport ?? httpTransport;

    if (_config.isRestPollingEnabled) {
      if (effectiveTransport == null) {
        throw StateError('PlaygroundHttpTransport must be provided for REST realtime transport');
      }
      return RestPlaygroundRealtimeRepository(
        baseUrl: effectiveBaseUrl,
        transport: effectiveTransport,
        activeInterval: _config.activePollingInterval,
        idleInterval: _config.idlePollingInterval,
        maxBackoffInterval: _config.maxBackoffInterval,
      );
    }

    if (effectiveFirestore == null) {
      throw StateError('FirebaseFirestore must be provided for firestore realtime transport');
    }
    return FirebasePlaygroundRealtimeRepository(firestore: effectiveFirestore);
  }

  /// 创建组合 Feed 业务仓储（外接缓存）。
  PlaygroundFeedRepository createFeedRepository({
    required PlaygroundPostCacheStore cacheStore,
    FirebaseFirestore? firestore,
    Uri? baseUrl,
    PlaygroundHttpTransport? transport,
    ShadowComparisonCallback? onShadowComparison,
  }) {
    final remote = createFeedRemoteDataSource(
      firestore: firestore,
      baseUrl: baseUrl,
      transport: transport,
      onShadowComparison: onShadowComparison,
    );
    return CachedPlaygroundFeedRepository(remote: remote, cache: cacheStore);
  }

  /// 创建组合 Post 业务仓储（外接缓存）。
  PlaygroundPostRepository createPostRepository({
    required PlaygroundPostCacheStore cacheStore,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebasePlaygroundIdentityResolver? identityResolver,
    Uri? baseUrl,
    PlaygroundHttpTransport? transport,
  }) {
    final remote = createPostRemoteDataSource(
      firestore: firestore,
      auth: auth,
      identityResolver: identityResolver,
      baseUrl: baseUrl,
      transport: transport,
    );
    return CachedPlaygroundPostRepository(remote: remote, cache: cacheStore);
  }

  /// 创建 Like 远端数据源。
  PlaygroundLikeRemoteDataSource createLikeRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebasePlaygroundIdentityResolver? identityResolver,
    Uri? baseUrl,
    PlaygroundHttpTransport? transport,
  }) {
    final effectiveFirestore = firestore ?? _firestore ?? FirebaseFirestore.instance;
    final effectiveAuth = auth ?? _auth ?? FirebaseAuth.instance;
    final effectiveIdentityResolver = identityResolver ??
        _identityResolver ??
        FirebasePlaygroundIdentityResolver(
          firestore: effectiveFirestore,
          auth: effectiveAuth,
        );
    final effectiveBaseUrl =
        baseUrl ?? restBaseUrl ?? Uri.parse('http://127.0.0.1:8080/v1');
    final effectiveTransport = transport ?? httpTransport;

    return FirebasePlaygroundLikeRepository(
      firestore: effectiveFirestore,
      auth: effectiveAuth,
      identityResolver: effectiveIdentityResolver,
      config: _config,
      httpTransport: effectiveTransport,
      baseUri: effectiveBaseUrl,
    );
  }

  /// 创建 Bookmark 远端数据源。
  PlaygroundBookmarkRemoteDataSource createBookmarkRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebasePlaygroundIdentityResolver? identityResolver,
    Uri? baseUrl,
    PlaygroundHttpTransport? transport,
  }) {
    final effectiveFirestore = firestore ?? _firestore ?? FirebaseFirestore.instance;
    final effectiveAuth = auth ?? _auth ?? FirebaseAuth.instance;
    final effectiveIdentityResolver = identityResolver ??
        _identityResolver ??
        FirebasePlaygroundIdentityResolver(
          firestore: effectiveFirestore,
          auth: effectiveAuth,
        );
    final effectiveBaseUrl =
        baseUrl ?? restBaseUrl ?? Uri.parse('http://127.0.0.1:8080/v1');
    final effectiveTransport = transport ?? httpTransport;

    return FirebasePlaygroundBookmarkRepository(
      firestore: effectiveFirestore,
      auth: effectiveAuth,
      identityResolver: effectiveIdentityResolver,
      config: _config,
      httpTransport: effectiveTransport,
      baseUri: effectiveBaseUrl,
    );
  }

  /// 创建 Engagement 业务仓储。
  PlaygroundEngagementRepository createEngagementRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Uri? baseUrl,
    PlaygroundHttpTransport? transport,
  }) {
    final effectiveFirestore = firestore ?? _firestore ?? FirebaseFirestore.instance;
    final effectiveAuth = auth ?? _auth ?? FirebaseAuth.instance;
    final effectiveBaseUrl =
        baseUrl ?? restBaseUrl ?? Uri.parse('http://127.0.0.1:8080/v1');
    final effectiveTransport = transport ?? httpTransport;

    return FirebasePlaygroundEngagementRepository(
      firestore: effectiveFirestore,
      auth: effectiveAuth,
      config: _config,
      httpTransport: effectiveTransport,
      baseUri: effectiveBaseUrl,
    );
  }
}
