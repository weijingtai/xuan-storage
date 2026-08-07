/// S1c 全量对齐契约套件（ACT-F）。
///
/// 把 [ReconciliationCoordinator] 四阶段握手的契约断言提成共享套件，任何
/// 实现（本轮两个结构迥异的内存 fake，以及将来的 WebRTC/LAN 传输）跑同一
/// 套断言 —— 契约约束不会各写各的。
///
/// 【为什么注入 `makeRig` 而不是具体 coordinator】契约要求「发起方与应答方
/// 是同一条链路的两端」，而各拓扑的连接方式不同（本轮的内存 rig 用可替换
/// channel 引用直接互指；真实传输靠 reconciliation 流路由）。因此套件只约定
/// rig 能给出【已接通】的发起方/应答方 coordinator 与两端数据视图，具体怎么
/// 接由拓扑自己负责。
///
/// 【seed 约定】套件每个测试都【先 seed 两端数据再跑一次对齐】，保证测试
/// 相互独立（不共享全局状态）。rig 的 [seed] 写入两端初始数据，
/// [initiatorState]/[responderState] 读两端收敛后数据。
///
/// 【两个 fake 结构迥异 + 不能是同一对象】（派工 §七第4条）：套件在
/// [runReconciliationContractSuite] 调用处由测试方注入两种不同拓扑。套件
/// 内部用 `identical(rig.initiator, rig.responder)` 守卫「两端不得是同一
/// 对象」（S3c-c-pre 曾栽过：`openStream` 把同一对象既 return 又塞对端）。
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/core/reconciliation_coordinator.dart';

/// 一个实体的初始终态（seed 用）。
typedef TerminalSpec = ({String entityId, int hlcPacked, bool isDeleted});

/// 一台全量对齐「机器」：已接通的发起方 + 应答方 + 两端数据读写。
abstract interface class ReconciliationRig {
  /// 发起方 coordinator（已接通到 [responder]）。
  ReconciliationCoordinator get initiator;

  /// 应答方 coordinator（已接通到 [initiator]）。
  ReconciliationCoordinator get responder;

  /// 用 [specs] 覆写两端初始数据。每个测试先 seed 再跑对齐。
  void seed(List<TerminalSpec> specs);

  /// 发起方本地的实体终态快照（entityId → (hlcPacked, isDeleted)）。
  Map<String, ({int hlcPacked, bool isDeleted})> initiatorState();

  /// 应答方本地的实体终态快照。
  Map<String, ({int hlcPacked, bool isDeleted})> responderState();

  /// 发起方 channel 上本次对齐实际发出的消息类型序列。
  ///
  /// 每个元素是消息类型名（如 `manifestChunk` / `cursorAdvance`），按发送
  /// 先后排列。契约套件用它对四阶段线序做守卫（返工 #4）：断言所有
  /// `manifestChunk` 必须先于任何 `cursorAdvance` —— 否则④提前到①前会
  /// 被这里拦下（该变异曾被 M2a 证实无守卫）。
  List<String> get initiatorSentOrder;
}

/// 在指定拓扑下运行全部 S1c 对齐契约测试。
///
/// 参数说明：
/// - [topologyName]: 拓扑名，只用于测试分组展示。
/// - [makeRig]: 构造一台【已接通】的对齐机器。
FutureOr<void> runReconciliationContractSuite({
  required String topologyName,
  required FutureOr<ReconciliationRig> Function() makeRig,
}) {
  group('S1c 对齐契约 · $topologyName', () {
    test('两端必须是不同对象（不得把同一对象既 return 又塞对端）', () async {
      final rig = await makeRig();
      expect(identical(rig.initiator, rig.responder), isFalse,
          reason: 'S3c-c-pre 栽过：openStream 把同一对象既 return 又塞对端');
    });

    test('重叠 + 各自独有 → 双向收敛', () async {
      final rig = await makeRig();
      rig.seed([
        // 两端都有的 r2：同一写操作（同 deviceId），比对时同版本 → 不交换。
        (entityId: 'r2', hlcPacked: 2000 << 16, isDeleted: false),
      ]);
      rig.initiatorState()['r1'] = (hlcPacked: 1000 << 16, isDeleted: false);
      rig.responderState()['r3'] = (hlcPacked: 3000 << 16, isDeleted: false);
      rig.initiatorState()['r2'] = (hlcPacked: 2000 << 16, isDeleted: false);
      rig.responderState()['r2'] = (hlcPacked: 2000 << 16, isDeleted: false);

      final run = await rig.initiator.reconcileAsInitiator(
        scopeUid: 'scope-1',
        entityType: 'record_meta',
        manifestPageSize: 10,
      );

      final initiatorState = rig.initiatorState();
      final responderState = rig.responderState();

      // 应答方 r3 是本地无/对方有 → 发起方索求 → 应答方回 ②b' → 发起方落库。
      expect(run.result.recordsReconciled, greaterThanOrEqualTo(1),
          reason: '发起方必须收到应答方独有实体');
      expect(initiatorState.containsKey('r3'), isTrue,
          reason: 'r3 必须传到发起方');

      // 发起方 r1 本地有/对方无 → 应答方遍历收到清单时索求 → 发起方回 ②b'
      // → 应答方落库 r1。
      expect(responderState.containsKey('r1'), isTrue,
          reason: 'r1 必须传到应答方');

      // r2 两端同版本 → 不交换，两端都保持。
      expect(initiatorState['r2']!.hlcPacked, 2000 << 16);
      expect(responderState['r2']!.hlcPacked, 2000 << 16);
    });

    test('新设备入网 → 对端全量推来', () async {
      final rig = await makeRig();
      rig.seed(const []);
      rig.initiatorState()['r1'] = (hlcPacked: 1000 << 16, isDeleted: false);
      rig.initiatorState()['r2'] = (hlcPacked: 2000 << 16, isDeleted: false);

      final run = await rig.initiator.reconcileAsInitiator(
        scopeUid: 'scope-2',
        entityType: 'record_meta',
        manifestPageSize: 10,
      );

      final responderState = rig.responderState();
      expect(responderState.containsKey('r1'), isTrue,
          reason: '新设备必须收到 r1');
      expect(responderState.containsKey('r2'), isTrue,
          reason: '新设备必须收到 r2');
      expect(run.result.recordsReconciled, 0,
          reason: '发起方自己没有收到任何终态');
    });

    test('墓碑传播且不复活', () async {
      final rig = await makeRig();
      rig.seed(const []);
      // 发起方有墓碑 r1（戳 3000）；应答方有活记录 r1（旧戳 1000）。
      rig.initiatorState()['r1'] = (hlcPacked: 3000 << 16, isDeleted: true);
      rig.responderState()['r1'] = (hlcPacked: 1000 << 16, isDeleted: false);

      final run = await rig.initiator.reconcileAsInitiator(
        scopeUid: 'scope-3',
        entityType: 'record_meta',
        manifestPageSize: 10,
      );

      final responderState = rig.responderState();
      expect(responderState['r1']!.isDeleted, isTrue,
          reason: '对端墓碑必须传到应答方（不复活）');
      expect(responderState['r1']!.hlcPacked, 3000 << 16);
      expect(run.result.recordsReconciled, 0,
          reason: '发起方是墓碑来源，不落库任何终态');
    });

    test('对端更新版本 → 发起方拉取', () async {
      final rig = await makeRig();
      rig.seed(const []);
      // 发起方 r1 旧戳（1000），应答方 r1 新戳（5000）。
      rig.initiatorState()['r1'] = (hlcPacked: 1000 << 16, isDeleted: false);
      rig.responderState()['r1'] = (hlcPacked: 5000 << 16, isDeleted: false);

      final run = await rig.initiator.reconcileAsInitiator(
        scopeUid: 'scope-4',
        entityType: 'record_meta',
        manifestPageSize: 10,
      );

      final initiatorState = rig.initiatorState();
      expect(run.result.recordsReconciled, 1,
          reason: '发起方必须收到对端更新版本');
      expect(initiatorState['r1']!.hlcPacked, 5000 << 16,
          reason: '发起方 r1 必须更新为对端版本');
    });

    test('线序守卫：全部 ManifestChunk 必须先于 CursorAdvance（返工#4）', () async {
      final rig = await makeRig();
      rig.seed(const []);
      // 造 3 个实体使清单分成 3 片（pageSize 1），验证分片线序不止一片。
      for (var i = 0; i < 3; i++) {
        final id = 'seq-$i';
        rig.initiatorState()[id] = (hlcPacked: 1000 << 16, isDeleted: false);
        rig.responderState()[id] = (hlcPacked: 1000 << 16, isDeleted: false);
      }

      await rig.initiator.reconcileAsInitiator(
        scopeUid: 'scope-order',
        entityType: 'record_meta',
        manifestPageSize: 1,
      );

      final order = rig.initiatorSentOrder;
      expect(order, isNotEmpty, reason: '发起方必须至少发出清单或游标确认');
      // ④ sendCursorAdvance 必须发生在所有 ① sendManifestChunk 之后：
      // 若有人把 ④ 提到 ① 前（M2a 变异形态），cursorAdvance 会出现在
      // 首个 manifestChunk 之前，本断言红（非编译失败）。
      final firstAdvance = order.indexOf('cursorAdvance');
      final lastChunk = order.lastIndexOf('manifestChunk');
      if (firstAdvance >= 0 && lastChunk >= 0) {
        expect(lastChunk < firstAdvance, isTrue,
            reason: '线序被破坏：④游标确认不得早于任何 ①清单分片 '
                '(order=$order)');
      }
      // 守卫必须真的验证到「④在①后」：若本拓扑根本没发出清单（比如
      // 空清单也被跳过），该断言形同虚设 —— 显式要求清单确实发过。
      expect(order, contains('manifestChunk'),
          reason: '线序守卫前提：3 实体分 3 片，清单分片必须真实发出');
    });
  });
}
