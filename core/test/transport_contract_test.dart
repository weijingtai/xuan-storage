import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/export_bundle.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/transport.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/persistence_core.dart' as barrel;
// 共享契约套件走深路径消费（决定记录 D7：test_support 不进 barrel）。
import 'package:persistence_core/test_support/peer_stream_contract_suite.dart';

void main() {
  group('Transport 主动侧与被动侧成对', () {
    test('two_transports_can_rendezvous', () async {
      // 本任务的存在理由：补丁之前 Transport 只有 discover/connect，
      // 两台装同一 app 的设备都只会拨号、没有一方会接听，物理上无法建连。
      final fabric = _FakeLanFabric();
      final alice = _FakeTransport(fabric, deviceId: 'alice');
      final bob = _FakeTransport(fabric, deviceId: 'bob');

      final inbound = <PeerSession>[];
      final sub = alice.incoming.listen(inbound.add);

      await alice.advertise(keys: _FakeKeyStore('alice'));
      final found = await bob.discover().first;
      final bobSide = await bob.connect(found, keys: _FakeKeyStore('bob'));
      await pumpEventQueue();

      expect(inbound, hasLength(1), reason: 'alice 必须接听到 bob 的连入');
      expect(inbound.single.remote.deviceId, 'bob');
      expect(bobSide.remote.deviceId, 'alice');

      await sub.cancel();
      await alice.dispose();
      await bob.dispose();
    });

    test('discover_sees_nothing_before_advertise', () async {
      // 反向：没人广播时 discover 必须空手而归，不得凭空造出对端。
      final fabric = _FakeLanFabric();
      final bob = _FakeTransport(fabric, deviceId: 'bob');
      expect(await bob.discover().toList(), isEmpty);
      await bob.dispose();
    });

    test('stop_advertising_removes_from_discovery', () async {
      final fabric = _FakeLanFabric();
      final alice = _FakeTransport(fabric, deviceId: 'alice');
      final bob = _FakeTransport(fabric, deviceId: 'bob');

      await alice.advertise(keys: _FakeKeyStore('alice'));
      expect(await bob.discover().toList(), hasLength(1));

      await alice.stopAdvertising();
      expect(await bob.discover().toList(), isEmpty);

      // 幂等：未在广播时再调一次不得抛错
      await alice.stopAdvertising();

      await alice.dispose();
      await bob.dispose();
    });
  });

  group('广播的隐私约定（补丁前无处可验）', () {
    test('advertisement_id_leaks_no_identity', () async {
      final fabric = _FakeLanFabric();
      final alice = _FakeTransport(fabric, deviceId: 'alice');

      final handle = await alice.advertise(
        keys: _FakeKeyStore('alice', scopeUid: 'user-scope-42'),
      );

      expect(handle.transientServiceId, isNot(contains('user-scope-42')),
          reason: '广播 id 不得含 scopeUid');
      expect(handle.transientServiceId, isNot(contains('alice')),
          reason: '广播 id 不得含设备名');
      expect(handle.rotateAfter, greaterThan(Duration.zero),
          reason: '必须有轮换周期，否则可被长期追踪');

      await alice.dispose();
    });
  });

  group('PeerSession 多路复用双向成立', () {
    test('multiplexing_uses_awaited_instances', () async {
      // 补丁前这条是恒绿的：openStream 是 async，直接比较返回的两个
      // Future 对象恒不相等 —— 即使实现每次返回同一条流也照样通过。
      // 必须 await 之后再比真实例。
      final session = await _connectedPair().then((p) => p.caller);

      final a = await session.openStream(StreamKind.oplog);
      final b = await session.openStream(StreamKind.blobChunk);

      expect(a, isNot(same(b)));
    });

    test('outbound_stream_appears_in_peer_incoming_streams', () async {
      // 一侧 openStream，另一侧必须能从 incomingStreams 接到。
      // 补丁前 PeerSession 只有 openStream，多路复用只在单向成立。
      final pair = await _connectedPair();

      final received = <PeerStream>[];
      final sub = pair.callee.incomingStreams.listen(received.add);

      await pair.caller.openStream(StreamKind.oplog);
      await pumpEventQueue();

      expect(received, hasLength(1), reason: '对端必须收到入站流');

      await sub.cancel();
    });
  });

  group('私钥不出契约', () {
    test('key_store_exposes_no_private_key_accessor', () {
      // 机械扫描：契约里不得出现任何"取出私钥"的口子，也不得残留
      // 已被取代的 DeviceKeyPair（它的字段形态会诱导实现方把私钥塞进值类）。
      final src = File('lib/model/transport.dart').readAsStringSync();

      expect(src.contains('privateKey'), isFalse,
          reason: '私钥不得以字节形式出现在契约里；只暴露 sign()，不暴露取出');
      expect(src.contains('DeviceKeyPair'), isFalse,
          reason: 'DeviceKeyPair 已由 DeviceKeyStore 取代');
      expect(src.contains('abstract interface class DeviceKeyStore'), isTrue);
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

    test('export_reader_reuses_existing_remote_changes_page', () async {
      final reader = _FakeExportBundleReader();
      expect(reader, isA<ExportBundleReader>());
      // 原写法把断言放在未 await 的 .listen 回调里，与上面 multiplexing
      // 那条是同一类恒绿缺陷。改为 await first 后再断言。
      final page = await reader.readChanges('/tmp/bundle', scopeUid: 'u1').first;
      expect(page, isA<RemoteChangesPage>());
      expect(page.changes, isA<List<RemoteChange>>());
      expect(page.hasMore, isFalse);
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

  // ── S3c-c-pre：PeerStream 背压契约，两个结构迥异的内存 fake 各跑一遍 ──
  group('PeerStream 背压契约', () {
    runPeerStreamContractSuite(
      topologyName: 'Fake A · wait（字节会计 + Completer 挂起 + 单订阅流）',
      makeSession: _makeWaitSession,
    );
    runPeerStreamContractSuite(
      topologyName: 'Fake B · fail（队列计数 + 同步抛错 + 单订阅流）',
      makeSession: _makeFailSession,
    );
  });

  group('barrel 可消费（背压契约必须能从包入口拿到）', () {
    test('barrel 导出的背压类型与深路径导出的是同一个', () {
      // 类型引用在编译期解析：若 barrel 未 export transport.dart（或
      // transport.dart 未导出新类型），这里的 barrel.XXX 引用会直接编译失败。
      expect(barrel.OverflowPolicy.wait, same(OverflowPolicy.wait));
      expect(barrel.OverflowPolicy.fail, same(OverflowPolicy.fail));
      expect(barrel.BackpressureOverflowError(),
          isA<BackpressureOverflowError>());
      expect(barrel.BackpressureOverflowError(), isA<barrel.StorageError>());
    });
  });

  group('A7 · 全仓仍零 Transport 实现', () {
    test('lib 下不存在任何 implements Transport 的实现', () {
      // S3c-c-pre 本轮零实现：只有契约与契约测试，不写任何传输实现。
      // 一旦有人在 lib/ 里写了实现，这里立即红。
      final hits = <String>[];
      void walk(Directory d) {
        for (final e in d.listSync(followLinks: false)) {
          if (e is Directory) {
            walk(e);
          } else if (e is File && e.path.endsWith('.dart')) {
            final src = e.readAsStringSync();
            if (RegExp(r'implements\s+Transport\b').hasMatch(src)) {
              hits.add(e.path);
            }
          }
        }
      }

      walk(Directory('lib'));
      expect(hits, isEmpty, reason: 'lib/ 下不得出现 Transport 实现（本轮零实现）：'
          '${hits.join(', ')}');
    });
  });
}

// ── 测试用 fake（实现细节在测试里，不算 S1a 交付物）──

/// 已连通的一对会话：caller 是主动拨号侧，callee 是接听侧。
typedef _Pair = ({PeerSession caller, PeerSession callee});

Future<_Pair> _connectedPair() async {
  final fabric = _FakeLanFabric();
  final alice = _FakeTransport(fabric, deviceId: 'alice');
  final bob = _FakeTransport(fabric, deviceId: 'bob');

  final inbound = <PeerSession>[];
  alice.incoming.listen(inbound.add);
  await alice.advertise(keys: _FakeKeyStore('alice'));
  final found = await bob.discover().first;
  final callerSide = await bob.connect(found, keys: _FakeKeyStore('bob'));
  await pumpEventQueue();

  return (caller: callerSide, callee: inbound.single);
}

/// 内存版"局域网"：广播方在这里登记，发现方从这里查。
class _FakeLanFabric {
  final Map<String, _FakeTransport> _advertisers = {};
  int _seq = 0;

  String nextServiceId() => 'svc-${_seq++}';
  void publish(String id, _FakeTransport t) => _advertisers[id] = t;
  void unpublish(String id) => _advertisers.remove(id);
  Iterable<String> get serviceIds => _advertisers.keys.toList();
  _FakeTransport? resolve(String id) => _advertisers[id];
}

class _FakeTransport implements Transport {
  _FakeTransport(this._fabric, {required this.deviceId});

  final _FakeLanFabric _fabric;
  final String deviceId;
  String? _advertisedId;
  final StreamController<PeerSession> _inbound =
      StreamController<PeerSession>.broadcast();

  @override
  Channel get channel => Channel.lan;

  @override
  Stream<DiscoveredPeer> discover({Duration? timeout}) =>
      Stream<DiscoveredPeer>.fromIterable(
        _fabric.serviceIds
            .where((id) => id != _advertisedId)
            .map((id) => DiscoveredPeer(
                  transientServiceId: id,
                  channel: Channel.lan,
                )),
      );

  @override
  Future<AdvertisementHandle> advertise({
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  }) async {
    final id = _fabric.nextServiceId();
    _advertisedId = id;
    _fabric.publish(id, this);
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
      _fabric.unpublish(id);
      _advertisedId = null;
    }
  }

  @override
  Stream<PeerSession> get incoming => _inbound.stream;

  @override
  Future<PeerSession> connect(
    DiscoveredPeer peer, {
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  }) async {
    final remote = _fabric.resolve(peer.transientServiceId);
    if (remote == null) {
      throw StateError('对端不可达: ${peer.transientServiceId}');
    }
    final localIdentity = await keys.localIdentity;

    final callerSide = _FakePeerSession(PeerIdentity(
      deviceId: remote.deviceId,
      publicKeyFingerprint: 'fp-${remote.deviceId}',
    ));
    final calleeSide = _FakePeerSession(localIdentity);
    callerSide.link(calleeSide);
    calleeSide.link(callerSide);

    remote._inbound.add(calleeSide);
    return callerSide;
  }

  @override
  Future<void> dispose() async {
    await stopAdvertising();
    await _inbound.close();
  }
}

class _FakePeerSession implements PeerSession {
  _FakePeerSession(this.remote);

  @override
  final PeerIdentity remote;

  _FakePeerSession? _peer;
  final StreamController<PeerStream> _incomingStreams =
      StreamController<PeerStream>.broadcast();

  void link(_FakePeerSession peer) => _peer = peer;

  @override
  Stream<PeerSessionState> get state =>
      Stream<PeerSessionState>.value(PeerSessionState.authenticated);

  @override
  Future<PeerStream> openStream(StreamKind kind) async {
    // 本端拿到自己的一条流，对端从 incomingStreams 收到配对的一条。
    _peer?._incomingStreams.add(_FakePeerStream(kind));
    return _FakePeerStream(kind);
  }

  @override
  Stream<PeerStream> get incomingStreams => _incomingStreams.stream;

  @override
  Future<void> close() async {
    await _incomingStreams.close();
  }
}

class _FakePeerStream implements PeerStream {
  _FakePeerStream(this.kind);

  final StreamKind kind;

  @override
  Stream<List<int>> get incoming => Stream<List<int>>.empty();

  @override
  int get maxBufferedAmount => 0;

  @override
  int get bufferedAmount => 0;

  @override
  OverflowPolicy get overflowPolicy => OverflowPolicy.wait;

  @override
  Future<void> send(List<int> bytes) async {}

  @override
  Future<void> close() async {}
}

class _FakeKeyStore implements DeviceKeyStore {
  _FakeKeyStore(this._deviceId, {String scopeUid = 'scope-1'})
      : _scopeUid = scopeUid;

  final String _deviceId;
  // ignore: unused_field
  final String _scopeUid;

  @override
  Future<PeerIdentity> get localIdentity async => PeerIdentity(
        deviceId: _deviceId,
        publicKeyFingerprint: 'fp-$_deviceId',
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

// ── S3c-c-pre 背压契约 fake（测试私有，不算 S1a 交付物）──

/// 契约测试统一使用的背压上限：8192 字节，chunk 64B 下 128 次 send 才触顶，
/// 留足「消费中水位不触顶」的余量。
const int _kFakeBufferSize = 8192;

Future<PeerSessionPair> _makeWaitSession() async {
  final caller = _WaitPeerSession(
    const PeerIdentity(deviceId: 'a', publicKeyFingerprint: 'fp-a'),
  );
  final callee = _WaitPeerSession(
    const PeerIdentity(deviceId: 'b', publicKeyFingerprint: 'fp-b'),
  );
  caller.link(callee);
  callee.link(caller);
  return (caller: caller, callee: callee);
}

Future<PeerSessionPair> _makeFailSession() async {
  final caller = _FailPeerSession(
    const PeerIdentity(deviceId: 'a', publicKeyFingerprint: 'fp-a'),
  );
  final callee = _FailPeerSession(
    const PeerIdentity(deviceId: 'b', publicKeyFingerprint: 'fp-b'),
  );
  caller.link(callee);
  callee.link(caller);
  return (caller: caller, callee: callee);
}

/// 背压契约 Fake A（overflowPolicy = wait）。
///
/// 结构特征（与 Fake B 迥异，S3c-a 规矩）：
/// - 发送侧用**字节会计**（`_buffered` 累计未确认字节）+ **Completer 挂起**；
/// - 接收侧用**单订阅 StreamController**，消费确认经 `onListen/onPause/
///   onResume/onCancel` 回调驱动 —— 订阅者 pause 即停止确认，发送侧水位
///   随之触顶（A5 传导的可测实现）。
class _WaitPeerSession implements PeerSession {
  _WaitPeerSession(this.remote);

  @override
  final PeerIdentity remote;

  _WaitPeerSession? _peer;
  final StreamController<PeerStream> _incomingStreams =
      StreamController<PeerStream>.broadcast();

  void link(_WaitPeerSession peer) => _peer = peer;

  @override
  Stream<PeerSessionState> get state =>
      Stream<PeerSessionState>.value(PeerSessionState.authenticated);

  @override
  Future<PeerStream> openStream(StreamKind kind) async {
    final out = _WaitStream(maxBufferedAmount: _kFakeBufferSize);
    _peer!._incomingStreams.add(out);
    return out;
  }

  @override
  Stream<PeerStream> get incomingStreams => _incomingStreams.stream;

  @override
  Future<void> close() async => _incomingStreams.close();
}

class _WaitStream implements PeerStream {
  _WaitStream({required this.maxBufferedAmount}) {
    _incoming = StreamController<List<int>>(
      onListen: _activeChanged,
      onPause: _activeChanged,
      onResume: _activeChanged,
      onCancel: _activeChanged,
    );
  }

  @override
  final int maxBufferedAmount;

  late final StreamController<List<int>> _incoming;
  int _buffered = 0;
  bool _active = false;
  Completer<void>? _spaceAvailable;
  final List<List<int>> _pending = [];

  // 流对象自配对：caller.openStream 返回的对象原样进入对端 incomingStreams，
  // 因此本流的 send 数据投递到本流自己的 incoming，由「本流 incoming 的订阅
  // 者是否活跃」决定消费确认 —— 即对端（本流 incoming 的订阅者）是否在消费。

  void _activeChanged() {
    _active = _incoming.hasListener && !_incoming.isPaused;
    if (_active) {
      _pump();
    }
  }

  @override
  OverflowPolicy get overflowPolicy => OverflowPolicy.wait;

  @override
  int get bufferedAmount => _buffered;

  @override
  Stream<List<int>> get incoming => _incoming.stream;

  @override
  Future<void> send(List<int> bytes) async {
    if (_buffered >= maxBufferedAmount) {
      final c = Completer<void>();
      _spaceAvailable = c;
      await c.future;
    }
    _buffered += bytes.length;
    _enqueue(bytes);
  }

  void _enqueue(List<int> bytes) {
    _pending.add(bytes);
    if (_active) {
      _pump();
    }
  }

  void _pump() {
    while (_pending.isNotEmpty && _active) {
      final b = _pending.removeAt(0);
      _incoming.add(b);
      _confirm(b.length);
    }
  }

  /// 对端（本流 incoming 的订阅者）消费确认 [len] 字节：发送水位下降，
  /// 释放挂起的 send。
  void _confirm(int len) {
    _buffered -= len;
    if (_buffered < maxBufferedAmount) {
      final c = _spaceAvailable;
      if (c != null && !c.isCompleted) {
        c.complete();
      }
    }
  }

  @override
  Future<void> close() async => _incoming.close();
}

/// 背压契约 Fake B（overflowPolicy = fail）。
///
/// 结构特征（与 Fake A 迥异）：
/// - 发送侧用**队列计数**（`_queued`）+ **同步抛错**（`send` 入口检查，
///   触顶即抛 [BackpressureOverflowError]，无 Completer、无挂起）；
/// - 接收侧同样用单订阅 controller + 消费确认回调，但确认逻辑比 Fake A
///   简单（只有减计数，没有空间释放）。
class _FailPeerSession implements PeerSession {
  _FailPeerSession(this.remote);

  @override
  final PeerIdentity remote;

  _FailPeerSession? _peer;
  final StreamController<PeerStream> _incomingStreams =
      StreamController<PeerStream>.broadcast();

  void link(_FailPeerSession peer) => _peer = peer;

  @override
  Stream<PeerSessionState> get state =>
      Stream<PeerSessionState>.value(PeerSessionState.authenticated);

  @override
  Future<PeerStream> openStream(StreamKind kind) async {
    final out = _FailStream(maxBufferedAmount: _kFakeBufferSize);
    _peer!._incomingStreams.add(out);
    return out;
  }

  @override
  Stream<PeerStream> get incomingStreams => _incomingStreams.stream;

  @override
  Future<void> close() async => _incomingStreams.close();
}

class _FailStream implements PeerStream {
  _FailStream({required this.maxBufferedAmount}) {
    _incoming = StreamController<List<int>>(
      onListen: _activeChanged,
      onPause: _activeChanged,
      onResume: _activeChanged,
      onCancel: _activeChanged,
    );
  }

  @override
  final int maxBufferedAmount;

  late final StreamController<List<int>> _incoming;
  int _queued = 0;
  bool _active = false;
  final List<List<int>> _pending = [];

  // 流对象自配对：send 数据投递到本流自己的 incoming，消费确认由本流
  // incoming 的订阅者是否活跃决定（与 _WaitStream 同构）。

  void _activeChanged() {
    _active = _incoming.hasListener && !_incoming.isPaused;
    if (_active) {
      _pump();
    }
  }

  @override
  OverflowPolicy get overflowPolicy => OverflowPolicy.fail;

  @override
  int get bufferedAmount => _queued;

  @override
  Stream<List<int>> get incoming => _incoming.stream;

  @override
  Future<void> send(List<int> bytes) async {
    if (_queued >= maxBufferedAmount) {
      throw BackpressureOverflowError();
    }
    _queued += bytes.length;
    _enqueue(bytes);
  }

  void _enqueue(List<int> bytes) {
    _pending.add(bytes);
    if (_active) {
      _pump();
    }
  }

  void _pump() {
    while (_pending.isNotEmpty && _active) {
      final b = _pending.removeAt(0);
      _incoming.add(b);
      _confirm(b.length);
    }
  }

  /// 对端（本流 incoming 的订阅者）消费确认 [len] 字节：发送队列计数下降。
  void _confirm(int len) {
    _queued -= len;
  }

  @override
  Future<void> close() async => _incoming.close();
}
