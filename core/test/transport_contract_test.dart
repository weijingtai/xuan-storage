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
      topologyName: 'Fake A · wait（发送侧字节会计 + Completer 挂起 + 显式投递）',
      makeSession: _makeWaitSession,
    );
    runPeerStreamContractSuite(
      topologyName: 'Fake B · fail（接收侧 credit/window + 同步抛错 + 显式投递）',
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
    test('全仓各包 lib/ 下不存在任何 implements Transport 的实现', () {
      // S3c-c-pre 本轮零实现：只有契约与契约测试，不写任何传输实现。
      // 守卫遍历仓库根下所有包的 lib/（不止 core/lib）—— 否则有人在
      // p2p/lib 里写了实现，只扫 core/lib 的守卫照样绿。
      final hits = <String>[];
      void walk(Directory d) {
        for (final e in d.listSync(followLinks: false)) {
          if (e is Directory) {
            final name = e.path.split('/').last;
            if (name.startsWith('.')) {
              continue;
            }
            walk(e);
          } else if (e is File && e.path.endsWith('.dart')) {
            final src = e.readAsStringSync();
            if (RegExp(r'implements\s+Transport\b').hasMatch(src)) {
              hits.add(e.path);
            }
          }
        }
      }

      final root = Directory('..');
      for (final pkg in root.listSync(followLinks: false)) {
        if (pkg is! Directory) {
          continue;
        }
        final name = pkg.path.split('/').last;
        if (name.startsWith('.')) {
          continue;
        }
        final lib = Directory('${pkg.path}/lib');
        if (lib.existsSync()) {
          walk(lib);
        }
      }
      expect(hits, isEmpty, reason: '全仓 lib/ 下不得出现 Transport 实现（本轮零实现）：'
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

/// 背压契约 Fake A 的会话（overflowPolicy = wait）。
///
/// [openStream] 在本端创建发送流、在对端创建**独立**的接收流，显式投递
/// 耦合（真实对端边界，返工 R1）。结构特征见 [_WaitStream]。
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
    // 真实对端边界（返工 R1）：本端拿到发送流，对端从 incomingStreams 收到
    // **独立的**接收流，两者经显式投递路径（sender._receiver）耦合 ——
    // 绝不把同一个对象既 return 又 add，否则 A5/A6 验的是 fake 自己。
    final sender = _WaitStream(maxBufferedAmount: _kFakeBufferSize);
    final receiver = _WaitStream(maxBufferedAmount: _kFakeBufferSize);
    sender._receiver = receiver;
    receiver._source = sender;
    _peer!._incomingStreams.add(receiver);
    return sender;
  }

  @override
  Stream<PeerStream> get incomingStreams => _incomingStreams.stream;

  @override
  Future<void> close() async => _incomingStreams.close();
}

/// 背压契约 Fake A 的逻辑流（wait 策略，发送侧字节会计 + Completer 挂起）。
///
/// 结构（与 Fake B 的 credit/window 骨架迥异，返工 R2）：
/// - 发送侧 `_buffered` 自记账 + `_waiting` 挂起队列（每条并发 send 一个
///   Completer，`_confirm` 每次只释放一条，保证「越界 ≤ 一个在途批次」）；
/// - 接收侧经 `_deliver` 显式接收对端投递的字节，`_pending` 队列 + `_pump`
///   在订阅者活跃时拉取投递，消费确认回调发送源 `_source._confirm`。
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

  /// 对端兄弟对象：本流作为发送侧时，[send] 的字节经它投递给对端接收流。
  _WaitStream? _receiver;

  /// 发送源：本流作为接收侧时，消费确认回调它、释放它挂起的 send。
  _WaitStream? _source;

  late final StreamController<List<int>> _incoming;
  int _buffered = 0;
  bool _active = false;
  final List<Completer<void>> _waiting = [];
  final List<List<int>> _pending = [];

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
      _waiting.add(c);
      await c.future;
    }
    _buffered += bytes.length;
    _receiver!._deliver(bytes);
  }

  /// 对端投递本段字节：进入本地待消费队列，订阅者活跃则立即消费。
  void _deliver(List<int> bytes) {
    _pending.add(bytes);
    if (_active) {
      _pump();
    }
  }

  void _pump() {
    while (_pending.isNotEmpty && _active) {
      final b = _pending.removeAt(0);
      _incoming.add(b);
      _source!._confirm(b.length);
    }
  }

  /// 本流（发送侧）的 [len] 字节被对端订阅者消费确认：水位下降，恢复一条
  /// 挂起的 send。只释放一条 —— 被恢复的 send 接受字节后水位仍可能越过上限，
  /// 越界被控制在「一个在途批次」内（返工 R5）。
  void _confirm(int len) {
    _buffered -= len;
    if (_buffered < maxBufferedAmount && _waiting.isNotEmpty) {
      _waiting.removeAt(0).complete();
    }
  }

  @override
  Future<void> close() async => _incoming.close();
}

/// 背压契约 Fake B 的会话（overflowPolicy = fail）。
///
/// [openStream] 在本端创建发送流、在对端创建**独立**的接收流，显式投递
/// 耦合（真实对端边界，返工 R1）。结构特征见 [_FailStream]。
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
    // 真实对端边界（返工 R1）：本端拿到发送流，对端收到独立的接收流。
    final sender = _FailStream(maxBufferedAmount: _kFakeBufferSize);
    final receiver = _FailStream(maxBufferedAmount: _kFakeBufferSize);
    sender._peer = receiver;
    _peer!._incomingStreams.add(receiver);
    return sender;
  }

  @override
  Stream<PeerStream> get incomingStreams => _incomingStreams.stream;

  @override
  Future<void> close() async => _incomingStreams.close();
}

/// 背压契约 Fake B 的逻辑流（fail 策略，**credit/window 流控骨架**）。
///
/// 结构（与 Fake A 的「发送侧记账 + Completer 挂起」迥异，返工 R2）：
/// - **配额在接收侧**：接收流维护一个可消耗的 `_window`（credit window，
///   初始 = maxBufferedAmount）。订阅者每消费一字节归还一字节配额 ——
///   消费确认是「对端显式归还配额」，不是发送侧自记账；
/// - `bufferedAmount` 从对端剩余配额**推导**（max - peer._window），
///   发送侧自己没有任何字节计数；
/// - 无 Completer、无挂起、无发送侧队列：send 入口检查对端窗口，不足即
///   同步抛 [BackpressureOverflowError]，接受则立即投递给对端。
class _FailStream implements PeerStream {
  _FailStream({required this.maxBufferedAmount}) {
    _window = maxBufferedAmount;
    _incoming = StreamController<List<int>>(
      onListen: _onActive,
      onPause: _onInactive,
      onResume: _onActive,
      onCancel: _onInactive,
    );
  }

  @override
  final int maxBufferedAmount;

  /// 对端兄弟对象：本流作为发送侧时，[send] 检查它的窗口并投递给它。
  _FailStream? _peer;

  late final StreamController<List<int>> _incoming;
  int _window = 0;
  bool _active = false;
  final List<List<int>> _delivered = [];

  void _onActive() {
    _active = true;
    _drain();
  }

  void _onInactive() => _active = false;

  @override
  OverflowPolicy get overflowPolicy => OverflowPolicy.fail;

  /// 已发出但未被对端消费确认的字节 = 对端已扣减、尚未归还的配额。
  @override
  int get bufferedAmount => maxBufferedAmount - _peer!._window;

  @override
  Stream<List<int>> get incoming => _incoming.stream;

  @override
  Future<void> send(List<int> bytes) async {
    final peer = _peer!;
    if (bytes.length > peer._window) {
      throw BackpressureOverflowError();
    }
    peer._deliver(bytes);
  }

  /// 对端投递本段字节：扣减本端配额（发送侧水位随之上涨），投给订阅者；
  /// 订阅者活跃则投递即消费、归还配额，不活跃则字节待投、配额不归还。
  void _deliver(List<int> bytes) {
    _window -= bytes.length;
    _delivered.add(bytes);
    _drain();
  }

  void _drain() {
    while (_delivered.isNotEmpty && _active) {
      final b = _delivered.removeAt(0);
      _incoming.add(b);
      _window += b.length;
    }
  }

  @override
  Future<void> close() async => _incoming.close();
}
