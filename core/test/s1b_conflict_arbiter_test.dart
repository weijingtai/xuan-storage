import 'dart:io';
import 'dart:math';

import 'package:crdt/crdt.dart' show Hlc;
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/conflict_arbiter.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/test_support/frozen_stamps.dart';

VersionStamp _v(DateTime t, int counter, String deviceId) => VersionStamp(
      hlc: Hlc(t.toUtc(), counter, deviceId),
      deviceId: deviceId,
    );

VersionStamp _sameHlc(String deviceId) =>
    _v(DateTime.utc(2026, 1, 1, 12, 0, 0), 0, deviceId);

void main() {
  group('VersionStamp 全序比较', () {
    test('later_hlc_wins_regardless_of_device', () {
      final arbiter = HlcConflictArbiter();
      // remote hlc 严格大，deviceId 字典序更小（'aaa' < 'zzz'）
      final remote = _v(DateTime.utc(2026, 1, 2), 0, 'aaa');
      final local = _v(DateTime.utc(2026, 1, 1), 0, 'zzz');
      expect(arbiter.arbitrate(remote: remote, local: local),
          ArbitrationDecision.takeRemote);

      // 反过来 local hlc 更大 → keepLocal
      final localBig = _v(DateTime.utc(2026, 1, 3), 0, 'aaa');
      final remoteSmall = _v(DateTime.utc(2026, 1, 1), 0, 'zzz');
      expect(arbiter.arbitrate(remote: remoteSmall, local: localBig),
          ArbitrationDecision.keepLocal);
    });

    test('concurrent_tie_broken_by_device_id_deterministically', () {
      final arbiter = HlcConflictArbiter();
      final a = _sameHlc('device-a');
      final b = _sameHlc('device-b');

      // remote=b, local=a → b 胜
      expect(arbiter.arbitrate(remote: b, local: a),
          ArbitrationDecision.takeRemote);
      // 互换角色 → 仍是 b 胜（keepLocal）
      expect(arbiter.arbitrate(remote: a, local: b),
          ArbitrationDecision.keepLocal);

      // 胜者是同一台设备（b 是 UTF-8 大者，因为 'b' > 'a'）
      expect(b.compareTo(a), greaterThan(0));
    });

    test('identical_iff_both_hlc_and_device_equal', () {
      final arbiter = HlcConflictArbiter();
      final h1 = _v(DateTime.utc(2026, 1, 1), 0, 'device-a');
      final h1copy = _v(DateTime.utc(2026, 1, 1), 0, 'device-a');
      final h2 = _v(DateTime.utc(2026, 1, 1), 0, 'device-b');
      final h3 = _v(DateTime.utc(2026, 1, 2), 0, 'device-a');

      // hlc + deviceId 都相等 → identical
      expect(arbiter.arbitrate(remote: h1, local: h1copy),
          ArbitrationDecision.identical);
      // hlc 相等 deviceId 不同 → 不是 identical
      expect(arbiter.arbitrate(remote: h1, local: h2),
          isNot(ArbitrationDecision.identical));
      // hlc 不同 deviceId 相等 → 不是 identical
      expect(arbiter.arbitrate(remote: h1, local: h3),
          isNot(ArbitrationDecision.identical));
    });

    test('comparison_is_a_total_order_exhaustive', () {
      final stamps = [
        _v(DateTime.utc(2026, 1, 1), 0, 'device-a'),
        _v(DateTime.utc(2026, 1, 1), 0, 'device-b'),
        _v(DateTime.utc(2026, 1, 1), 1, 'device-a'),
        _v(DateTime.utc(2026, 1, 1), 1, 'device-b'),
        _v(DateTime.utc(2026, 1, 2), 0, 'device-a'),
        _v(DateTime.utc(2026, 1, 2), 0, 'device-b'),
        _v(DateTime.utc(2026, 1, 2), 5, 'device-c'),
        _v(DateTime.utc(2026, 1, 3), 0, 'device-zzz'),
      ];

      // 反对称
      for (final a in stamps) {
        for (final b in stamps) {
          expect(a.compareTo(b), -b.compareTo(a),
              reason: '反对称失败: $a vs $b');
        }
      }
      // 传递性
      for (final a in stamps) {
        for (final b in stamps) {
          for (final c in stamps) {
            if (a.compareTo(b) < 0 && b.compareTo(c) < 0) {
              expect(a.compareTo(c), lessThan(0),
                  reason: '传递性失败: $a < $b < $c');
            }
          }
        }
      }
      // 自反
      for (final a in stamps) {
        expect(a.compareTo(a), 0);
      }
      // 0 当且仅当 hlc 与 deviceId 都相等（显式遍历）
      for (final a in stamps) {
        for (final b in stamps) {
          final bothEqual =
              a.hlc.dateTime.isAtSameMomentAs(b.hlc.dateTime) &&
              a.hlc.counter == b.hlc.counter &&
              a.hlc.nodeId == b.hlc.nodeId &&
              a.deviceId == b.deviceId;
          expect(a.compareTo(b) == 0, bothEqual,
              reason: 'compareTo==0 必须当且仅当全等: $a vs $b');
        }
      }
    });

    test('compare_to_orders_extreme_packed_values_correctly', () {
      // l = 2^47-1（接近 48 位上限），c = 0
      final big = VersionStamp.fromPacked(
        ((1 << 47) - 1) << 16,
        'device-a',
      );
      // l = 0
      final small = VersionStamp.fromPacked(0, 'device-a');

      expect(big.compareTo(small), greaterThan(0));
      expect(small.compareTo(big), lessThan(0));
      expect(big.compareTo(big), 0);

      // c 位取满（2^16-1）的相邻值，低位不被吃掉
      final cMax = VersionStamp.fromPacked((1 << 40) | 0xffff, 'device-a');
      final cZero = VersionStamp.fromPacked(1 << 40, 'device-a');
      expect(cMax.compareTo(cZero), greaterThan(0),
          reason: 'c 低位取满时必须大于 c=0');
    });

    test('device_id_compared_as_utf8_bytes_not_utf16', () {
      // U+10000 与 U+E000：UTF-8 与 UTF-16 序相反
      final a = _sameHlc('\u{e000}'); // UTF-8 首字节 EE
      final b = _sameHlc('\u{10000}'); // UTF-8 首字节 F0

      // UTF-8 序：EE < F0 ⇒ U+E000 < U+10000 ⇒ b 是大者
      expect(b.compareTo(a), greaterThan(0),
          reason: 'U+10000 在 UTF-8 字节序下应大于 U+E000');
      expect(a.compareTo(b), lessThan(0));
    });

    test('packed_round_trips_losslessly', () {
      final cases = [
        VersionStamp.fromPacked(0, 'device-a'),
        VersionStamp.fromPacked(((1 << 47) - 1) << 16, 'device-b'),
        VersionStamp.fromPacked((1 << 40) | 0xffff, 'device-c'),
        VersionStamp.fromPacked(12345, 'device-d'),
      ];
      for (final s in cases) {
        final restored = VersionStamp.fromPacked(s.toPacked(), s.deviceId);
        expect(restored.hlc.dateTime, s.hlc.dateTime);
        expect(restored.hlc.counter, s.hlc.counter);
        expect(restored.hlc.nodeId, s.deviceId);
      }
      // 两个不同 stamp 的 packed 值不相等
      expect(cases[0].toPacked(), isNot(cases[3].toPacked()));
    });
  });

  group('null 降级', () {
    test('null_degradation_four_combinations', () {
      final arbiter = HlcConflictArbiter();
      final some = _v(DateTime.utc(2026, 1, 1), 0, 'device-a');

      // (null, null) → identical
      expect(arbiter.arbitrate(remote: null, local: null),
          ArbitrationDecision.identical);
      // (null, 有) → keepLocal（fail-safe：不丢本地）
      expect(arbiter.arbitrate(remote: null, local: some),
          ArbitrationDecision.keepLocal);
      // (有, null) → takeRemote
      expect(arbiter.arbitrate(remote: some, local: null),
          ArbitrationDecision.takeRemote);
      // (有, 有) → 正常比较
      final other = _v(DateTime.utc(2026, 1, 2), 0, 'device-b');
      expect(arbiter.arbitrate(remote: other, local: some),
          ArbitrationDecision.takeRemote);
    });
  });

  group('收敛性（真实仲裁器）', () {
    test('convergence_over_fixed_stamps', () {
      final stamps = generateFrozenStamps(seed: 7);
      final arbiter = HlcConflictArbiter();

      // 两个独立容器 + 两种到达顺序
      final containerA = <String, VersionStamp>{};
      final containerB = <String, VersionStamp>{};

      // 顺序 A：原顺序
      for (final s in stamps) {
        _merge(containerA, arbiter, s);
      }

      // 顺序 B：另一个 seed 打乱（允许违反因果先后）
      final random = Random(99);
      final shuffled = List.of(stamps)..shuffle(random);
      for (final s in shuffled) {
        _merge(containerB, arbiter, s);
      }

      // 逐 entityId 完全相等（比 hlc 与 deviceId 字段）
      expect(containerA.length, containerB.length);
      for (final entry in containerA.entries) {
        final b = containerB[entry.key];
        expect(b, isNotNull, reason: 'entityId ${entry.key} 必须两侧都有');
        expect(b!.hlc.dateTime, entry.value.hlc.dateTime);
        expect(b.hlc.counter, entry.value.hlc.counter);
        expect(b.hlc.nodeId, entry.value.hlc.nodeId);
        expect(b.deviceId, entry.value.deviceId);
      }
    });
  });

  group('冲突留档字段', () {
    test('outcome_carries_discarded_side_both_directions', () {
      // ① takeRemote 场景 → discardedSide == local
      final outcome1 = ChangeApplyOutcome(
        operationId: 'op1',
        entityType: 'record',
        entityId: 'e1',
        decision: ChangeApplyDecision.applied,
        reason: null,
        message: null,
        discardedSide: ConflictSide.local,
        discardedPayloadJson: '{"old":1}',
        discardedStamp: _v(DateTime.utc(2026, 1, 1), 0, 'device-a'),
      );
      expect(outcome1.discardedSide, ConflictSide.local);
      expect(outcome1.discardedPayloadJson, '{"old":1}');
      expect(outcome1.discardedStamp, isNotNull);

      // ② keepLocal 场景 → discardedSide == remote
      final outcome2 = ChangeApplyOutcome(
        operationId: 'op2',
        entityType: 'record',
        entityId: 'e2',
        decision: ChangeApplyDecision.skipped,
        reason: SkipReasonCode.conflictLwwLost,
        message: 'remote lost',
        discardedSide: ConflictSide.remote,
        discardedPayloadJson: '{"remote":1}',
        discardedStamp: _v(DateTime.utc(2026, 1, 2), 0, 'device-b'),
      );
      expect(outcome2.discardedSide, ConflictSide.remote);
      expect(outcome2.discardedPayloadJson, '{"remote":1}');
      expect(outcome2.discardedStamp, isNotNull);

      // 不传三个字段也能构造，且为 null（既有构造点未破坏）
      final plain = ChangeApplyOutcome(
        operationId: 'op3',
        entityType: 'record',
        entityId: 'e3',
        decision: ChangeApplyDecision.applied,
        reason: null,
        message: null,
      );
      expect(plain.discardedSide, isNull);
      expect(plain.discardedPayloadJson, isNull);
      expect(plain.discardedStamp, isNull);
    });
  });

  group('实现文本守卫', () {
    test('arbiter_has_no_wall_clock_and_no_io', () async {
      final src = await File('lib/model/conflict_arbiter.dart').readAsString();
      // 守卫意图：仲裁器【不参与定序的墙上时钟兜底】与【任何 IO】。
      // 换库后 VersionStamp 承载 crdt 的 Hlc（内建 dateTime 作为 HLC 的 l 分量），
      // 故不禁裸 `DateTime` 字面量，但严禁 .now() / updatedAt / serverTime /
      // 异步 IO —— 这些才是"顺手加个时间戳兜底比较"的退化形态。
      expect(src, isNot(contains('.now()')));
      expect(src, isNot(contains('updatedAt')));
      expect(src, isNot(contains('serverTime')));
      expect(src, isNot(contains('dart:io')));
      expect(src, isNot(contains('Future<')));
      expect(src, isNot(contains('async')));
    });
  });
}

/// 归并规则：与 ACT 09 规格完全一致，走生产仲裁器。
void _merge(
  Map<String, VersionStamp> container,
  ConflictArbiter arbiter,
  ({String entityId, int hlcPacked, String deviceId}) s,
) {
  final cur = container[s.entityId];
  final remote = VersionStamp.fromPacked(s.hlcPacked, s.deviceId);
  if (cur == null) {
    container[s.entityId] = remote;
    return;
  }
  final decision = arbiter.arbitrate(remote: remote, local: cur);
  if (decision == ArbitrationDecision.takeRemote) {
    container[s.entityId] = remote;
  }
  // keepLocal → 保持 cur；identical → 不动
}
