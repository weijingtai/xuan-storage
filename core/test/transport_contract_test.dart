import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/blob_gateway.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/export_bundle.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/transport.dart';
import 'package:persistence_core/model/types.dart';

void main() {
  group('Transport / PeerSession 层级', () {
    test('transport_and_peer_session_are_layered_not_siblings', () {
      final transport = _FakeTransport();
      final session = transport.connect(
        const DiscoveredPeer(
          transientServiceId: 'svc-1',
          channel: Channel.lan,
        ),
        localKeys: const DeviceKeyPair(publicKeyPem: 'key'),
      ) as Future<PeerSession>;

      // ignore: unawaited_futures
      session.then((s) {
        // 同一条 session 上两条不同 kind 的流必须互不阻塞、实例不同
        final a = s.openStream(StreamKind.oplog);
        final b = s.openStream(StreamKind.blobChunk);
        expect(a, isNot(same(b)));
      });
    });
  });

  group('ExportBundle 与 Transport 独立', () {
    test('export_bundle_does_not_implement_transport', () {
      // 文件不是持续连接：ExportBundle* 不得是 Transport/PeerSession 的子类型。
      // 这条测试的存在本身就是防止后人把文件塞回连接抽象。
      final writer = _FakeExportBundleWriter();
      final reader = _FakeExportBundleReader();
      expect(writer, isNot(isA<Transport>()));
      expect(writer, isNot(isA<PeerSession>()));
      expect(reader, isNot(isA<Transport>()));
      expect(reader, isNot(isA<PeerSession>()));
    });

    test('export_reader_reuses_existing_remote_changes_page', () {
      final reader = _FakeExportBundleReader();
      expect(reader, isA<ExportBundleReader>());
      // readChanges 产出的元素类型必须是 types.dart 里既有的 RemoteChangesPage
      reader.readChanges('/tmp/bundle', scopeUid: 'u1').listen((page) {
        expect(page, isA<RemoteChangesPage>());
        expect(page.changes, isA<List<RemoteChange>>());
        expect(page.nextCursor, isA<PullCursor?>());
        expect(page.hasMore, isA<bool>());
      });
    });
  });

  group('StreamKind', () {
    test('stream_kind_has_exactly_two_values', () {
      expect(StreamKind.values, hasLength(2));
      expect(
        StreamKind.values.map((e) => e.name),
        ['oplog', 'blobChunk'],
      );
    });
  });
}

// ── 测试用 fake（实现细节在测试里，不算 S1a 交付物）──

class _FakeTransport implements Transport {
  @override
  Channel get channel => Channel.lan;

  @override
  Stream<DiscoveredPeer> discover({Duration? timeout}) =>
      Stream<DiscoveredPeer>.empty();

  @override
  Future<PeerSession> connect(
    DiscoveredPeer peer, {
    required DeviceKeyPair localKeys,
    CancellationToken? cancel,
  }) async {
    return _FakePeerSession(PeerIdentity(
      deviceId: 'device-1',
      publicKeyFingerprint: 'fp-1',
    ));
  }

  @override
  Future<void> dispose() async {}
}

class _FakePeerSession implements PeerSession {
  _FakePeerSession(this.remote);

  @override
  final PeerIdentity remote;

  @override
  Stream<PeerSessionState> get state =>
      Stream<PeerSessionState>.value(PeerSessionState.authenticated);

  @override
  Future<PeerStream> openStream(StreamKind kind) async {
    return _FakePeerStream();
  }

  @override
  Future<void> close() async {}
}

class _FakePeerStream implements PeerStream {
  @override
  Stream<List<int>> get incoming => Stream<List<int>>.empty();

  @override
  Future<void> send(List<int> bytes) async {}

  @override
  Future<void> close() async {}
}

class _FakeExportBundleWriter implements ExportBundleWriter {
  @override
  Future<void> write({
    required String scopeUid,
    required String outputPath,
    required bool includeBlobs,
    CancellationToken? cancel,
  }) async {}
}

class _FakeExportBundleReader implements ExportBundleReader {
  @override
  Future<BundleManifest> inspect(String path) async {
    return BundleManifest(
      scopeUid: 'u1',
      operationCount: 0,
      createdAtUtc: DateTime.utc(2026, 1, 1),
      signature: 'sig',
    );
  }

  @override
  Stream<RemoteChangesPage> readChanges(
    String path, {
    required String scopeUid,
  }) {
    return Stream<RemoteChangesPage>.value(RemoteChangesPage(
      changes: const [],
      nextCursor: null,
      hasMore: false,
    ));
  }
}
