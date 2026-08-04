import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// 本组测试刻意走深路径 import，与下方「barrel 可消费」组的 barrel import
// 形成对照 —— 只用深路径是发现不了 barrel 缺口的（本任务初版正是如此：
// signaling.dart 漏进 barrel，而全部测试照样全绿）。
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_core/persistence_core.dart' as barrel;

/// S3c-a 信令契约测试。
///
/// 【本文件的核心手法】同一套契约测试跑在**两个形态迥异的 fake** 上：
/// - `_LanFabricSignaling`：内存"局域网"，先到者登记、后到者直连，**无中间人**
/// - `_CloudRendezvousSignaling`：内存"会合点"，双方各自连到第三方并在同一
///   个键下读写，**有中间人**
///
/// 若 `SignalingChannel` 的抽象漏了什么，这两个 fake 必有一个写不出来 ——
/// 这正是验收项 A3 的存在理由（见任务纪要「难点一」）。
void main() {
  // ── A3：同一套契约，两种拓扑各跑一遍 ──
  //
  // 每个 fake 用一个工厂函数表示。契约测试只依赖 SignalingChannel 接口，
  // 对两种拓扑一无所知。
  final topologies = <String, _ChannelPair Function()>{
    'LAN 直连（无中间人）': () {
      final fabric = _LanFabric();
      return (
        alice: _LanFabricSignaling(fabric),
        bob: _LanFabricSignaling(fabric),
      );
    },
    '云端中转（有中间人）': () {
      final hub = _CloudHub();
      return (
        alice: _CloudRendezvousSignaling(hub),
        bob: _CloudRendezvousSignaling(hub),
      );
    },
  };

  topologies.forEach((topologyName, makePair) {
    group('契约 · $topologyName', () {
      test('两端在同一会合标识下相遇并双向收发信封', () async {
        final pair = makePair();
        const rv = 'rv-meet';

        final aliceSession = await pair.alice.open(rv);
        final bobSession = await pair.bob.open(rv);

        final aliceGot = <SignalingEnvelope>[];
        final bobGot = <SignalingEnvelope>[];
        final subA = aliceSession.incoming.listen(aliceGot.add);
        final subB = bobSession.incoming.listen(bobGot.add);

        await aliceSession.send(const SessionDescriptionEnvelope(
          kind: SdpKind.offer,
          sdp: 'v=0\r\no=- 1 1 IN IP4 0.0.0.0\r\n',
        ));
        await bobSession.send(const SessionDescriptionEnvelope(
          kind: SdpKind.answer,
          sdp: 'v=0\r\no=- 2 2 IN IP4 0.0.0.0\r\n',
        ));
        await pumpEventQueue();

        expect(bobGot, hasLength(1), reason: 'bob 必须收到 alice 的 offer');
        expect(aliceGot, hasLength(1), reason: 'alice 必须收到 bob 的 answer');
        expect(
          (bobGot.single as SessionDescriptionEnvelope).kind,
          SdpKind.offer,
        );
        expect(
          (aliceGot.single as SessionDescriptionEnvelope).kind,
          SdpKind.answer,
        );

        await subA.cancel();
        await subB.cancel();
        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      test('incoming 不回显本端自己发出的信封', () async {
        // 契约原文：「只投递对端发来的信封，不回显本端 send 的内容」。
        // 云端拓扑最容易违反这条 —— 会合点是共享存储，天然会把自己写的
        // 也读回来。
        final pair = makePair();
        const rv = 'rv-no-echo';

        final aliceSession = await pair.alice.open(rv);
        await pair.bob.open(rv);

        final aliceGot = <SignalingEnvelope>[];
        final sub = aliceSession.incoming.listen(aliceGot.add);

        await aliceSession.send(const IceCandidateEnvelope(
          candidate: 'candidate:1 1 udp 2130706431 192.168.0.2 54321 typ host',
          sdpMid: '0',
          sdpMLineIndex: 0,
        ));
        await pumpEventQueue();

        expect(aliceGot, isEmpty, reason: '本端发出的信封不得回显给本端');

        await sub.cancel();
        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      test('trickle ICE：多条 candidate 按序全部送达', () async {
        // SDP 是 offer/answer 各一条，ICE candidate 则陆续到达、条数不定。
        // 这条测试锁住「多条」这个事实 —— 若实现只留最后一条（例如云端
        // fake 用单值键覆盖写），这里会红。
        final pair = makePair();
        const rv = 'rv-trickle';

        final aliceSession = await pair.alice.open(rv);
        final bobSession = await pair.bob.open(rv);

        final bobGot = <SignalingEnvelope>[];
        final sub = bobSession.incoming.listen(bobGot.add);

        for (var i = 0; i < 5; i++) {
          await aliceSession.send(IceCandidateEnvelope(
            candidate: 'candidate:$i 1 udp 2130706431 192.168.0.2 5432$i '
                'typ host',
            sdpMid: '0',
            sdpMLineIndex: 0,
          ));
        }
        await pumpEventQueue();

        expect(bobGot, hasLength(5), reason: '5 条 candidate 必须全部送达');
        expect(
          bobGot.map((e) => (e as IceCandidateEnvelope).candidate).toList(),
          [
            for (var i = 0; i < 5; i++)
              'candidate:$i 1 udp 2130706431 192.168.0.2 5432$i typ host',
          ],
          reason: 'candidate 必须按发送顺序送达',
        );

        await sub.cancel();
        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      // ── A4：对端掉线可感知 ──

      test('A4 · 对端尚未到场时是 awaiting，到场后转 present', () async {
        // awaiting 与 departed 必须可区分：前者该继续等，后者该放弃。
        // 见任务纪要「难点二」。
        final pair = makePair();
        const rv = 'rv-presence';

        final aliceSession = await pair.alice.open(rv);
        final seen = <PeerPresence>[];
        final sub = aliceSession.peerPresence.listen(seen.add);
        await pumpEventQueue();

        expect(seen, isNotEmpty,
            reason: '订阅后应立即得到当前状态，不必等下次变化');
        expect(seen.first, PeerPresence.awaiting,
            reason: '对端尚未 open，此刻必须是 awaiting');

        await pair.bob.open(rv);
        await pumpEventQueue();

        expect(seen.last, PeerPresence.present,
            reason: '对端到场后必须转 present');

        await sub.cancel();
        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      test('A4 · 对端主动 close 后本端观测到 departed', () async {
        final pair = makePair();
        const rv = 'rv-bye';

        final aliceSession = await pair.alice.open(rv);
        final bobSession = await pair.bob.open(rv);

        final seen = <PeerPresence>[];
        final sub = aliceSession.peerPresence.listen(seen.add);
        await pumpEventQueue();
        expect(seen.last, PeerPresence.present);

        await bobSession.close();
        await pumpEventQueue();

        expect(seen.last, PeerPresence.departed,
            reason: '对端 close 后必须观测到 departed，不能停在 present');

        await sub.cancel();
        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      test('A4 · 对端非正常断开（未告别）也必须产出 departed', () async {
        // 这条才是 onDisconnect() 的真正价值：进程被杀、断网、崩溃时
        // 对端来不及发 Bye，后端仍须判定其离开。
        // 契约原文：「不得要求调用方靠超时自行推断」。
        final pair = makePair();
        const rv = 'rv-crash';

        final aliceSession = await pair.alice.open(rv);
        final bobSession = await pair.bob.open(rv);

        final seen = <PeerPresence>[];
        final sub = aliceSession.peerPresence.listen(seen.add);
        await pumpEventQueue();
        expect(seen.last, PeerPresence.present);

        // 模拟非正常断开：不调用 close()，直接让后端判定其失联。
        (bobSession as _CrashableSession).simulateAbruptDisconnect();
        await pumpEventQueue();

        expect(seen.last, PeerPresence.departed,
            reason: '对端崩溃/断网时后端必须判定 departed，'
                '而不是让调用方靠超时去猜');

        await sub.cancel();
        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      test('A4 · 对端已 departed 时 send 必须抛错，不得静默丢弃', () async {
        final pair = makePair();
        const rv = 'rv-send-after-departed';

        final aliceSession = await pair.alice.open(rv);
        final bobSession = await pair.bob.open(rv);
        await pumpEventQueue();

        await bobSession.close();
        await pumpEventQueue();

        expect(
          () => aliceSession.send(const ByeEnvelope()),
          throwsA(isA<Object>()),
          reason: '对端已离开时发送必须抛错；静默丢弃会让调用方以为发出去了',
        );

        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      test('close 幂等：重复调用不得抛错', () async {
        final pair = makePair();
        final session = await pair.alice.open('rv-idempotent');
        await session.close();
        await session.close();
        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      test('不同会合标识互不串扰', () async {
        // 会合标识是两种拓扑的唯一公共输入（见「难点一」）。
        // 若实现把它当摆设，这里会红。
        final pair = makePair();

        final aliceSession = await pair.alice.open('rv-A');
        final bobSession = await pair.bob.open('rv-B');

        final bobGot = <SignalingEnvelope>[];
        final sub = bobSession.incoming.listen(bobGot.add);

        await aliceSession.send(const ByeEnvelope());
        await pumpEventQueue();

        expect(bobGot, isEmpty, reason: '不同会合标识下的信封不得串到一起');

        await sub.cancel();
        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      test('rendezvous 如实回报打开时用的标识', () async {
        final pair = makePair();
        final session = await pair.alice.open('rv-echo-key');
        expect(session.rendezvous, 'rv-echo-key');
        await pair.alice.dispose();
        await pair.bob.dispose();
      });

      // ── A5 样本层：信封载荷不含身份信息 ──

      test('A5 · 握手全过程的信封载荷不含 scopeUid / 用户名 / 设备名',
          () async {
        const scopeUid = 'user-scope-42';
        const deviceName = "alice-macbook";

        final pair = makePair();
        final aliceSession = await pair.alice.open('rv-privacy');
        final bobSession = await pair.bob.open('rv-privacy');

        final captured = <SignalingEnvelope>[];
        final sub = bobSession.incoming.listen(captured.add);

        await aliceSession.send(const SessionDescriptionEnvelope(
          kind: SdpKind.offer,
          sdp: 'v=0\r\na=fingerprint:sha-256 AA:BB\r\n',
        ));
        await aliceSession.send(const IceCandidateEnvelope(
          candidate: 'candidate:1 1 udp 2130706431 192.168.0.2 54321 typ host',
          sdpMid: '0',
          sdpMLineIndex: 0,
        ));
        await pumpEventQueue();

        expect(captured, hasLength(2));
        for (final e in captured) {
          final text = _serializeForPrivacyCheck(e);
          expect(text, isNot(contains(scopeUid)),
              reason: '信令载荷不得含 scopeUid');
          expect(text, isNot(contains(deviceName)),
              reason: '信令载荷不得含设备名');
        }

        await sub.cancel();
        await pair.alice.dispose();
        await pair.bob.dispose();
      });
    });
  });

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
      // 结构断言才能证明「塞不进去」。见任务纪要「难点三」。
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

/// 把信封序列化成文本，供隐私断言扫描。
///
/// 用 switch 穷尽而非 toString()：确保新增变体时这里会变红，
/// 不会有字段悄悄逃过隐私检查。
String _serializeForPrivacyCheck(SignalingEnvelope e) => switch (e) {
      SessionDescriptionEnvelope(:final kind, :final sdp) => '$kind|$sdp',
      IceCandidateEnvelope(
        :final candidate,
        :final sdpMid,
        :final sdpMLineIndex
      ) =>
        '$candidate|$sdpMid|$sdpMLineIndex',
      ByeEnvelope() => 'bye',
    };

/// 一对同拓扑的信令通道。
typedef _ChannelPair = ({SignalingChannel alice, SignalingChannel bob});

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
  _LanSession(this.rendezvous) {
    _presence.add(PeerPresence.awaiting);
  }

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
  Stream<PeerPresence> get peerPresence async* {
    // 订阅后立即给出当前状态，再跟随后续变化（契约要求）。
    yield _current;
    yield* _presence.stream;
  }

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
  Stream<PeerPresence> get peerPresence async* {
    yield _current;
    yield* _presence.stream;
  }

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
