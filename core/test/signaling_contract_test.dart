import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// 本组测试刻意走深路径 import，与下方「barrel 可消费」组的 barrel import
// 形成对照 —— 只用深路径是发现不了 barrel 缺口的（本任务初版正是如此：
// signaling.dart 漏进 barrel，而全部测试照样全绿）。
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_core/persistence_core.dart' as barrel;
// 共享契约套件走深路径消费（决定记录 D3：test_support 不进 barrel）。
import 'package:persistence_core/test_support/signaling_contract_suite.dart';

/// S3c-a 信令契约测试（S3c-b 改造：11 条契约测试已提取进共享套件）。
///
/// 11 条契约测试现在住在 `core/lib/test_support/signaling_contract_suite.dart`，
/// 本文件对两个形态迥异的 fake 各调一次套件：
/// - `_LanFabricSignaling`：内存"局域网"，先到者登记、后到者直连，**无中间人**
/// - `_CloudRendezvousSignaling`：内存"会合点"，双方各自连到第三方并在同一
///   个键下读写，**有中间人**
///
/// 留在本地的两组测试（「架构守卫」「barrel 可消费」）读 `lib/` 的相对路径，
/// 只有 core 包跑得到，不能搬进套件。
void main() {
  // ── 同一套契约，两种拓扑各跑一遍 ──
  runSignalingContractSuite(
    topologyName: 'LAN 直连（无中间人）',
    makePair: () {
      final fabric = _LanFabric();
      return (
        alice: _LanFabricSignaling(fabric),
        bob: _LanFabricSignaling(fabric),
      );
    },
    simulateAbruptDisconnect: (session) =>
        (session as _CrashableSession).simulateAbruptDisconnect(),
  );

  runSignalingContractSuite(
    topologyName: '云端中转（有中间人）',
    makePair: () {
      final hub = _CloudHub();
      return (
        alice: _CloudRendezvousSignaling(hub),
        bob: _CloudRendezvousSignaling(hub),
      );
    },
    simulateAbruptDisconnect: (session) =>
        (session as _CrashableSession).simulateAbruptDisconnect(),
  );

  // ── A1 / A2 / A5 结构层：源码机械扫描 ──

  group('架构守卫（源码扫描）', () {
    late String src;

    setUpAll(() {
      src = File('lib/model/signaling.dart').readAsStringSync();
    });

    test('A1 · 契约文件零实现', () {
      expect(src.contains('UnimplementedError'), isFalse,
          reason: '契约层不得有占位实现');
      expect(RegExp(r'\bclass \w*Impl\b').hasMatch(src), isFalse,
          reason: '契约层不得有 Impl 类');
      // 抽象成员只声明不带体：契约里不应出现方法体的 `{` ... 除了
      // sealed/final 值类的 const 构造器。用「=>」与「async」做粗筛。
      expect(src.contains(' async '), isFalse,
          reason: '契约层不得有 async 方法体');
    });

    test('A2 · 后端无关：不出现任何具体 SDK 字样', () {
      for (final banned in [
        'firebase',
        'Firebase',
        'rtdb',
        'RTDB',
        'bonsoir',
        'Bonsoir',
        'webrtc',
        'WebRtc',
        'WebRTC',
        'firestore',
        'Firestore',
      ]) {
        expect(src.contains(banned), isFalse,
            reason: '契约层不得提及具体后端 "$banned"；'
                '裁定 C3 要求信令后端可换');
      }
    });

    test('A5 结构层 · 信封无 Map / dynamic 敞口', () {
      // 这条是 A5 的真正门禁：样本断言只能证明「当前载荷没塞东西」，
      // 结构断言才能证明「塞不进去」。
      expect(src.contains('dynamic'), isFalse,
          reason: '信封不得有 dynamic 口子，否则可塞任意用户数据');
      expect(RegExp(r'\bMap<').hasMatch(src), isFalse,
          reason: '信封不得有 Map 口子，否则可塞任意用户数据');
      expect(src.contains('sealed class SignalingEnvelope'), isTrue,
          reason: '信封必须是封闭类型，使「塞不进」成为类型系统的事实');
    });

    test('A5 结构层 · 信封变体穷尽且全部为具名字段', () {
      // switch 穷尽性：新增变体会让这里变红，改动无法悄悄发生。
      const envelopes = <SignalingEnvelope>[
        SessionDescriptionEnvelope(kind: SdpKind.offer, sdp: 'v=0'),
        IceCandidateEnvelope(
          candidate: 'candidate:1',
          sdpMid: '0',
          sdpMLineIndex: 0,
        ),
        ByeEnvelope(),
      ];
      for (final e in envelopes) {
        final label = switch (e) {
          SessionDescriptionEnvelope() => 'sdp',
          IceCandidateEnvelope() => 'ice',
          ByeEnvelope() => 'bye',
        };
        expect(label, isNotEmpty);
      }
      expect(envelopes, hasLength(3),
          reason: '当前恰好三个变体；新增变体必须同步更新本测试与所有 switch');
    });

    test('SdpKind / PeerPresence 取值锁定', () {
      expect(SdpKind.values.map((e) => e.name), ['offer', 'answer']);
      expect(PeerPresence.values.map((e) => e.name),
          ['awaiting', 'present', 'departed'],
          reason: 'awaiting 与 departed 必须分开：前者该等，后者该放弃');
    });
  });

  // ── A11：共享套件内零 pumpEventQueue（人类裁定 D5）──

  group('套件守卫（源码扫描）', () {
    test('A11 · 共享套件内零 pumpEventQueue', () {
      final src = File('lib/test_support/signaling_contract_suite.dart')
          .readAsStringSync();
      expect(src.contains('pumpEventQueue'), isFalse,
          reason: '共享套件不得使用 pumpEventQueue —— 它的语义是「把事件队列'
              '转若干圈」，对同步 StreamController 碰巧成立，对任何真实 I/O '
              '都不成立（字节要过内核）。正向断言 await 可观测量本身，负向'
              '断言用拓扑注入的具名宽限期（D5 / A11）');
    });
  });

  // ── barrel 可消费 ──
  //
  // 【这组测试为什么存在】本任务初版把 signaling.dart 交付完整、27 条测试
  // 全绿，却漏掉了 core/lib/persistence_core.dart 的一行 export ——
  // 于是消费方 `import 'package:persistence_core/persistence_core.dart'`
  // 根本拿不到 SignalingChannel。
  //
  // 全部测试用深路径 import，所以谁也没红。**契约交付了但消费不到，
  // 与没交付等价。** 这组测试是那个缺口的门禁。
  group('barrel 可消费（契约必须能从包入口拿到）', () {
    test('barrel 导出的信令类型与深路径导出的是同一个', () {
      // 类型别名在编译期解析：若 barrel 未 export signaling.dart，
      // 这些 barrel.XXX 引用会直接编译失败。
      expect(barrel.SdpKind.offer, same(SdpKind.offer));
      expect(barrel.PeerPresence.departed, same(PeerPresence.departed));

      const viaBarrel = barrel.ByeEnvelope();
      expect(viaBarrel, isA<SignalingEnvelope>(),
          reason: 'barrel 与深路径必须导出同一个 SignalingEnvelope 类型；'
              '若两者不同，消费方拿到的会是不兼容的类型');

      // 端口类型本身也必须可从 barrel 拿到（消费方要 implements 它们）。
      expect(_BarrelTypeProbe.channel, isNull);
      expect(_BarrelTypeProbe.session, isNull);
    });

    test('barrel 里全部 S1a 契约文件无一遗漏', () {
      // 机械扫描：model/ 下 S1a 交付的契约文件必须逐个出现在 barrel 里。
      // 下一个加契约文件的人若忘了补 export，这里立刻红 ——
      // 这正是本任务栽过的那个跟头。
      final barrelSrc = File('lib/persistence_core.dart').readAsStringSync();
      const s1aContracts = [
        'storage_classification.dart',
        'cancellation_token.dart',
        'blob_error.dart',
        'storage_policy.dart',
        'storage_policy_registry.dart',
        'blob_types.dart',
        'blob_cipher.dart',
        'local_blob_store.dart',
        'record_blob_unit_of_work.dart',
        'blob_gateway.dart',
        'transport.dart',
        'export_bundle.dart',
        'signaling.dart',
      ];
      final missing = s1aContracts
          .where((f) => !barrelSrc.contains("export 'model/$f';"))
          .toList();
      expect(missing, isEmpty,
          reason: '以下契约文件未在 barrel 中 export，消费方从包入口拿不到：'
              '$missing');
    });
  });
}

/// 探针：确认端口类型能从 barrel 拿到。
///
/// 字段类型写成 `barrel.XXX?`，若 barrel 未导出该类型则编译失败 ——
/// 这比运行期断言更早、更硬。
final class _BarrelTypeProbe {
  /// 信令通道端口（经 barrel 引用）。
  static const barrel.SignalingChannel? channel = null;

  /// 信令会话（经 barrel 引用）。
  static const barrel.SignalingSession? session = null;
}

/// 能模拟非正常断开的会话（测试用能力，不属契约）。
abstract interface class _CrashableSession {
  /// 模拟进程被杀 / 断网：不发 Bye，直接失联。
  void simulateAbruptDisconnect();
}

// ══════════════════════════════════════════════════════════════
// 拓扑一：LAN 直连（无中间人）
//
// 形态：先 open 的一方在 fabric 上"登记"，后 open 的一方查到它并**直接
// 建立一条双向管道**。没有第三方持有消息 —— 这正是 LocalSignaling 的
// 真实形态（bonsoir 发现 IP:port 后直连）。
// ══════════════════════════════════════════════════════════════

/// 内存"局域网"：会合标识 → 已登记的等待方。
class _LanFabric {
  final Map<RendezvousKey, _LanSession> _waiting = {};
}

class _LanFabricSignaling implements SignalingChannel {
  _LanFabricSignaling(this._fabric);

  final _LanFabric _fabric;
  final List<_LanSession> _opened = [];

  @override
  Future<SignalingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) async {
    final session = _LanSession(rendezvous);
    _opened.add(session);

    final waiting = _fabric._waiting[rendezvous];
    if (waiting == null) {
      // 先到者：登记，等对端来直连。
      _fabric._waiting[rendezvous] = session;
    } else {
      // 后到者：直接接上 —— 无中间人。
      session.attach(waiting);
      waiting.attach(session);
      _fabric._waiting.remove(rendezvous);
    }
    return session;
  }

  @override
  Future<void> dispose() async {
    for (final s in _opened) {
      _fabric._waiting.remove(s.rendezvous);
      await s.close();
    }
    _opened.clear();
  }
}

class _LanSession implements SignalingSession, _CrashableSession {
  _LanSession(this.rendezvous);

  @override
  final RendezvousKey rendezvous;

  final StreamController<SignalingEnvelope> _incoming =
      StreamController<SignalingEnvelope>.broadcast();
  final StreamController<PeerPresence> _presence =
      StreamController<PeerPresence>.broadcast();
  PeerPresence _current = PeerPresence.awaiting;
  _LanSession? _peer;
  bool _closed = false;

  void attach(_LanSession peer) {
    _peer = peer;
    _emit(PeerPresence.present);
  }

  void _emit(PeerPresence p) {
    _current = p;
    if (!_presence.isClosed) _presence.add(p);
  }

  void _deliver(SignalingEnvelope e) {
    if (!_incoming.isClosed) _incoming.add(e);
  }

  @override
  Stream<SignalingEnvelope> get incoming => _incoming.stream;

  @override
  Stream<PeerPresence> get peerPresence => Stream.multi((controller) {
        // 订阅即重放当前状态（契约：订阅后应立即得到当前状态，不必等下次变化）。
        // 每个订阅者独立重放 —— broadcast 的 onListen 只在首个订阅者时触发，
        // 无法服务多个订阅者。真实 socket 实现同样采用此模式。
        controller.add(_current);
        final sub = _presence.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Future<void> send(SignalingEnvelope envelope) async {
    if (_current == PeerPresence.departed) {
      throw StateError('对端已离开，拒绝发送');
    }
    _peer?._deliver(envelope);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    // 主动告别：对端立即观测到 departed，不必等后端超时判定。
    _peer?._emit(PeerPresence.departed);
    _peer?._peer = null;
    await _incoming.close();
    await _presence.close();
  }

  @override
  void simulateAbruptDisconnect() {
    // 不发 Bye、不关自己的流 —— 模拟进程被杀。
    // LAN 形态下由底层连接断开触发对端的 departed。
    _peer?._emit(PeerPresence.departed);
    _peer?._peer = null;
  }
}

// ══════════════════════════════════════════════════════════════
// 拓扑二：云端中转（有中间人）
//
// 形态：双方都不知道对方地址，各自"连到"同一个 hub，在同一个会合标识
// 下读写。hub 持有全部状态并负责判定成员离开（等价 RTDB 的
// onDisconnect()）—— 这正是 CloudSignaling 的真实形态。
// ══════════════════════════════════════════════════════════════

/// 内存"会合点"：持有每个会合标识下的成员，并负责成员离开的判定。
class _CloudHub {
  /// 会合标识 → 该标识下的在场成员。
  final Map<RendezvousKey, List<_CloudSession>> _rooms = {};

  void join(_CloudSession s) {
    final members = _rooms.putIfAbsent(s.rendezvous, () => []);
    members.add(s);
    // hub 负责把在场情况广播给每个成员。
    for (final m in members) {
      m.onRoomChanged(members.length);
    }
  }

  /// 成员离开。[graceful] 为 false 时模拟 RTDB onDisconnect 的服务端判定。
  void leave(_CloudSession s) {
    final members = _rooms[s.rendezvous];
    if (members == null || !members.remove(s)) return;
    for (final m in members) {
      m.onPeerDeparted();
    }
    if (members.isEmpty) _rooms.remove(s.rendezvous);
  }

  /// 中转一个信封给同房间的其他成员（**不回给发送者**）。
  void relay(_CloudSession from, SignalingEnvelope e) {
    final members = _rooms[from.rendezvous];
    if (members == null) return;
    for (final m in members) {
      if (!identical(m, from)) m.onRelayed(e);
    }
  }
}

class _CloudRendezvousSignaling implements SignalingChannel {
  _CloudRendezvousSignaling(this._hub);

  final _CloudHub _hub;
  final List<_CloudSession> _opened = [];

  @override
  Future<SignalingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) async {
    final session = _CloudSession(rendezvous, _hub);
    _opened.add(session);
    _hub.join(session);
    return session;
  }

  @override
  Future<void> dispose() async {
    for (final s in _opened) {
      await s.close();
    }
    _opened.clear();
  }
}

class _CloudSession implements SignalingSession, _CrashableSession {
  _CloudSession(this.rendezvous, this._hub);

  @override
  final RendezvousKey rendezvous;

  final _CloudHub _hub;
  final StreamController<SignalingEnvelope> _incoming =
      StreamController<SignalingEnvelope>.broadcast();
  final StreamController<PeerPresence> _presence =
      StreamController<PeerPresence>.broadcast();
  PeerPresence _current = PeerPresence.awaiting;
  bool _closed = false;

  void onRoomChanged(int memberCount) {
    _emit(memberCount >= 2 ? PeerPresence.present : PeerPresence.awaiting);
  }

  void onPeerDeparted() => _emit(PeerPresence.departed);

  void onRelayed(SignalingEnvelope e) {
    if (!_incoming.isClosed) _incoming.add(e);
  }

  void _emit(PeerPresence p) {
    _current = p;
    if (!_presence.isClosed) _presence.add(p);
  }

  @override
  Stream<SignalingEnvelope> get incoming => _incoming.stream;

  @override
  Stream<PeerPresence> get peerPresence => Stream.multi((controller) {
        // 订阅即重放当前状态（契约：订阅后应立即得到当前状态，不必等下次变化）。
        // 每个订阅者独立重放 —— broadcast 的 onListen 只在首个订阅者时触发，
        // 无法服务多个订阅者。真实 socket 实现同样采用此模式。
        controller.add(_current);
        final sub = _presence.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Future<void> send(SignalingEnvelope envelope) async {
    if (_current == PeerPresence.departed) {
      throw StateError('对端已离开，拒绝发送');
    }
    _hub.relay(this, envelope);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _hub.leave(this);
    await _incoming.close();
    await _presence.close();
  }

  @override
  void simulateAbruptDisconnect() {
    // 不调 close()、不关自己的流 —— 模拟客户端进程被杀。
    // 由 hub 侧判定离开，等价 RTDB 的 onDisconnect()：
    // 服务端感知连接断开并自动摘除该节点。
    _hub.leave(this);
  }
}
