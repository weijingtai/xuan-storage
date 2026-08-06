/// Test-only in-memory [Transport] implementation (S3c-c-preflight 方案丙).
///
/// Provides a fabric-based fake that supports the full discover/advertise/connect/
/// incoming contract and creates [PeerSession] instances with real backpressure-
/// capable [PeerStream] instances ([OverflowPolicy.wait]).
///
/// This is NOT a real WebRTC implementation. It exists so that
/// [package:persistence_core/test_support/peer_stream_contract_suite.dart]
/// can be run against the full [Transport] → [PeerSession] → [PeerStream] path,
/// proving that the contract call path is wired correctly before S6 delivers
/// [DeviceKeyStore] and channel binding.
///
/// ## Usage
///
/// ```dart
/// import 'package:persistence_core/test_support/fake_transport.dart';
/// import 'package:persistence_core/test_support/peer_stream_contract_suite.dart';
///
/// runPeerStreamContractSuite(
///   topologyName: 'FakeTransport',
///   makeSession: makeFakeTransportSessionPair,
/// );
/// ```
library;

import 'dart:async';

import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/transport.dart';
import 'package:persistence_core/test_support/peer_stream_contract_suite.dart';

/// Default buffer size for backpressure [PeerStream] instances.
///
/// Same value as `_kFakeBufferSize` in `transport_contract_test.dart`：
/// 8192 bytes, 64B chunk → 128 sends to reach ceiling.
const int fakeTransportBufferSize = 8192;

/// A test-only [DeviceKeyStore] that returns fixed identities.
///
/// [sign] appends `0xFF` to the payload; [verify] always returns `true`.
/// This is sufficient for contract testing — it satisfies the [DeviceKeyStore]
/// interface without requiring S6's real key storage.
final class FakeDeviceKeyStore implements DeviceKeyStore {
  /// Creates a fake key store for the given device.
  const FakeDeviceKeyStore({required this.deviceId});

  /// The device identifier.
  final String deviceId;

  @override
  Future<PeerIdentity> get localIdentity async => PeerIdentity(
        deviceId: deviceId,
        publicKeyFingerprint: 'fp-$deviceId',
      );

  @override
  Future<List<int>> sign(List<int> payload) async => [...payload, 0xFF];

  @override
  Future<bool> verify({
    required List<int> payload,
    required List<int> signature,
    required String peerPublicKeyPem,
  }) async =>
      true;
}

/// An in-memory fabric that connects [FakeTransport] instances.
///
/// Advertisers register here; discoverers read from here.
/// [FakeTransport.connect] resolves the advertiser and wires the two
/// sides together — no signaling, no WebRTC, no I/O.
final class FakeTransportFabric {
  final Map<String, FakeTransport> _advertisers = {};
  int _seq = 0;

  String _nextServiceId() => 'svc-${_seq++}';

  void _publish(String id, FakeTransport t) => _advertisers[id] = t;
  void _unpublish(String id) => _advertisers.remove(id);
  Iterable<String> get _serviceIds => _advertisers.keys.toList();
  FakeTransport? _resolve(String id) => _advertisers[id];
}

/// A test-only [Transport] implementation backed by [FakeTransportFabric].
///
/// Does NOT use WebRTC, signaling, or any real I/O. All operations are
/// synchronous in-memory with real backpressure on [PeerStream] instances.
///
/// [FakePeerSession] instances created by [connect] / [incoming] use
/// [OverflowPolicy.wait] and sender-side byte accounting with
/// Completer-based suspension — the same well-tested structure as
/// `_WaitStream` in `transport_contract_test.dart`.
final class FakeTransport implements Transport {
  /// Creates a [FakeTransport] on the given [fabric].
  FakeTransport(this._fabric, {required this.deviceId});

  final FakeTransportFabric _fabric;

  /// The device identifier for this transport endpoint.
  final String deviceId;

  String? _advertisedId;
  final StreamController<PeerSession> _incomingController =
      StreamController<PeerSession>.broadcast(sync: true);

  @override
  Channel get channel => Channel.lan;

  @override
  Stream<DiscoveredPeer> discover({Duration? timeout}) {
    return Stream<DiscoveredPeer>.fromIterable(
      _fabric._serviceIds
          .where((id) => id != _advertisedId)
          .map((id) => DiscoveredPeer(
                transientServiceId: id,
                channel: Channel.lan,
              )),
    );
  }

  @override
  Future<AdvertisementHandle> advertise({
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  }) async {
    final id = _fabric._nextServiceId();
    _advertisedId = id;
    _fabric._publish(id, this);
    return AdvertisementHandle(
      transientServiceId: id,
      startedAtUtc: DateTime.now().toUtc(),
      rotateAfter: const Duration(minutes: 15),
    );
  }

  @override
  Future<void> stopAdvertising() async {
    final id = _advertisedId;
    if (id != null) {
      _fabric._unpublish(id);
      _advertisedId = null;
    }
  }

  @override
  Stream<PeerSession> get incoming => _incomingController.stream;

  @override
  Future<PeerSession> connect(
    DiscoveredPeer peer, {
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  }) async {
    final remote = _fabric._resolve(peer.transientServiceId);
    if (remote == null) {
      throw StateError('Peer unreachable: ${peer.transientServiceId}');
    }
    final localIdentity = await keys.localIdentity;

    final callerSide = FakePeerSession(
      PeerIdentity(
        deviceId: remote.deviceId,
        publicKeyFingerprint: 'fp-${remote.deviceId}',
      ),
      bufferSize: fakeTransportBufferSize,
    );
    final calleeSide = FakePeerSession(
      PeerIdentity(
        deviceId: localIdentity.deviceId,
        publicKeyFingerprint: localIdentity.publicKeyFingerprint,
      ),
      bufferSize: fakeTransportBufferSize,
    );
    callerSide._link(calleeSide);
    calleeSide._link(callerSide);

    // [StreamController.broadcast.add] fires listeners synchronously,
    // so the callee side is delivered to incoming before connect returns.
    remote._incomingController.add(calleeSide);
    return callerSide;
  }

  @override
  Future<void> dispose() async {
    await stopAdvertising();
    await _incomingController.close();
  }
}

/// A test-only [PeerSession] backed by in-memory wait-strategy streams.
///
/// [openStream] creates a sender/receiver pair of [_FakeBackpressureStream]
/// instances linked by explicit delivery — the same structure as
/// `_WaitPeerSession` in `transport_contract_test.dart`.
final class FakePeerSession implements PeerSession {
  FakePeerSession(this.remote, {required this.bufferSize});

  @override
  final PeerIdentity remote;

  /// Buffer size for [PeerStream] instances created by this session.
  final int bufferSize;

  FakePeerSession? _peer;
  final StreamController<PeerStream> _incomingStreams =
      StreamController<PeerStream>.broadcast();

  void _link(FakePeerSession peer) => _peer = peer;

  @override
  Stream<PeerSessionState> get state =>
      Stream<PeerSessionState>.value(PeerSessionState.authenticated);

  @override
  Future<PeerStream> openStream(StreamKind kind) async {
    // Real peer boundary: the caller gets a sender stream, the callee
    // receives an independent receiver stream via incomingStreams.
    // The two are linked through explicit delivery (_receiver / _source),
    // NOT by returning the same object — that would make A5/A6 test
    // the fake itself rather than the contract.
    final sender = _FakeBackpressureStream(
      maxBufferedAmount: bufferSize,
      overflowPolicy: OverflowPolicy.wait,
    );
    final receiver = _FakeBackpressureStream(
      maxBufferedAmount: bufferSize,
      overflowPolicy: OverflowPolicy.wait,
    );
    sender._receiver = receiver;
    receiver._source = sender;
    _peer?._incomingStreams.add(receiver);
    return sender;
  }

  @override
  Stream<PeerStream> get incomingStreams => _incomingStreams.stream;

  @override
  Future<void> close() async => _incomingStreams.close();
}

/// Backpressure-capable [PeerStream] fake (wait strategy, sender-side byte
/// accounting + Completer-based suspension).
///
/// Structure mirrors the well-tested `_WaitStream` from
/// `transport_contract_test.dart`:
/// - Sender side: `_buffered` byte accounting, `_suspended` Completer queue
///   (one per concurrent send, each released one at a time by `_confirm`),
///   ensuring "overshoot ≤ one in-flight batch" (R5).
/// - Receiver side: bytes delivered via `_deliver`, queued in `_pending`,
///   pumped to subscribers when active; consumption confirmation calls
///   back to the sender's `_confirm` to release suspended sends.
class _FakeBackpressureStream implements PeerStream {
  _FakeBackpressureStream({
    required this.maxBufferedAmount,
    required this.overflowPolicy,
  }) {
    _incoming = StreamController<List<int>>(
      onListen: _onActive,
      onPause: _onInactive,
      onResume: _onActive,
      onCancel: _onInactive,
    );
  }

  @override
  final int maxBufferedAmount;

  @override
  final OverflowPolicy overflowPolicy;

  /// The peer stream: when this stream is a sender, [_receiver] is the
  /// callee-side stream that receives delivered bytes.
  _FakeBackpressureStream? _receiver;

  /// The source stream: when this stream is a receiver, [_source] is the
  /// sender-side stream whose `_confirm` is called on consumption.
  _FakeBackpressureStream? _source;

  late final StreamController<List<int>> _incoming;
  int _buffered = 0;
  bool _active = false;
  final List<Completer<void>> _suspended = [];
  final List<List<int>> _pending = [];

  void _onActive() {
    _active = true;
    _drain();
  }

  void _onInactive() => _active = false;

  @override
  int get bufferedAmount => _buffered;

  @override
  Stream<List<int>> get incoming => _incoming.stream;

  @override
  Future<void> send(List<int> bytes) async {
    if (_buffered >= maxBufferedAmount) {
      final c = Completer<void>();
      _suspended.add(c);
      await c.future;
    }
    _buffered += bytes.length;
    _receiver!._deliver(bytes);
  }

  /// Deliver bytes from the peer sender to this receiver stream.
  void _deliver(List<int> bytes) {
    _pending.add(bytes);
    if (_active) _drain();
  }

  /// Pump pending bytes to subscribers while the stream is active.
  void _drain() {
    while (_pending.isNotEmpty && _active) {
      final b = _pending.removeAt(0);
      _incoming.add(b);
      _source!._confirm(b.length);
    }
  }

  /// Confirm that [len] bytes were consumed by the peer subscriber.
  ///
  /// Releases exactly one suspended send — the resumed send may push
  /// the buffer above the ceiling again, but the overshoot is bounded
  /// to one in-flight batch (R5).
  void _confirm(int len) {
    _buffered -= len;
    if (_buffered < maxBufferedAmount && _suspended.isNotEmpty) {
      _suspended.removeAt(0).complete();
    }
  }

  @override
  Future<void> close() async => _incoming.close();
}

/// Creates a connected [PeerSessionPair] using [FakeTransport].
///
/// This is the factory for [peer_stream_contract_suite]'s [makeSession]
/// parameter. It exercises the full [Transport] contract path:
/// advertise → discover → connect → incoming → openStream.
///
/// [StreamController.broadcast.add] fires listeners synchronously in Dart,
/// so the callee side is delivered to [incoming] before [connect] returns.
/// No `pumpEventQueue` or time-based wait is needed.
Future<PeerSessionPair> makeFakeTransportSessionPair() async {
  final fabric = FakeTransportFabric();
  final alice = FakeTransport(fabric, deviceId: 'alice');
  final bob = FakeTransport(fabric, deviceId: 'bob');

  final inbound = <PeerSession>[];
  final sub = alice.incoming.listen(inbound.add);
  await alice.advertise(keys: const FakeDeviceKeyStore(deviceId: 'alice'));
  final found = await bob.discover().first;
  final caller = await bob.connect(
    found,
    keys: const FakeDeviceKeyStore(deviceId: 'bob'),
  );

  final callee = inbound.single;
  await sub.cancel();
  return (caller: caller, callee: callee);
}