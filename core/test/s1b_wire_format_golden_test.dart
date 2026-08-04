import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/conflict_arbiter.dart';
import 'package:persistence_core/persistence_core.dart';

/// A14 线上格式的黄金向量测试：把 HLC-WIRE-FORMAT.md 的黄金用例表逐条搬进来。
///
/// 期望值【写死在测试里】，不许从实现反算 —— 文档与实现分家时此测试变红。
void main() {
  group('打包布局 (l << 16) | c（大端）', () {
    test('wire_format_golden_vectors', () {
      // (l, c) → packed 的黄金向量。hex 为 packed 的 64 位十六进制（补零）。
      final vectors = <({int l, int c, String deviceId, String hex})>[
        (l: 0, c: 0, deviceId: 'device-a', hex: '0000000000000000'),
        (l: 1, c: 0, deviceId: 'device-a', hex: '0000000000010000'),
        (l: 1, c: 1, deviceId: 'device-a', hex: '0000000000010001'),
        (l: 1700000000000, c: 0, deviceId: 'device-a', hex: '018bcfe568000000'),
        (
          l: 1700000000000,
          c: 65535,
          deviceId: 'device-a',
          hex: '018bcfe56800ffff',
        ),
        (
          l: 1700000000001,
          c: 0,
          deviceId: 'device-a',
          hex: '018bcfe568010000',
        ),
        (
          l: 1700000000000,
          c: 0,
          deviceId: 'device-\u{e000}',
          hex: '018bcfe568000000',
        ),
        (
          l: 1700000000000,
          c: 0,
          deviceId: 'device-\u{10000}',
          hex: '018bcfe568000000',
        ),
      ];

      for (final v in vectors) {
        final stamp = VersionStamp.fromPacked((v.l << 16) | v.c, v.deviceId);
        // 打包后等于文档写死的 hex
        expect(stamp.toPacked().toRadixString(16).padLeft(16, '0'), v.hex,
            reason: '(${v.l}, ${v.c}, ${v.deviceId}) 打包 hex 应为 ${v.hex}');
        // 从 hex 解包还原 (l, c)
        final restored = VersionStamp.fromPacked(
          int.parse(v.hex, radix: 16),
          v.deviceId,
        );
        expect(restored.hlc.dateTime.millisecondsSinceEpoch, v.l,
            reason: '解包后 l 应还原为 ${v.l}');
        expect(restored.hlc.counter, v.c, reason: '解包后 c 应还原为 ${v.c}');
      }
    });

    test('wire_format_comparison_vectors', () {
      // 比较结果黄金向量：与文档写死的胜负一致。
      final a = VersionStamp.fromPacked(1700000000000 << 16, 'device-a');
      final b = VersionStamp.fromPacked(
        (1700000000000 << 16) | 65535,
        'device-a',
      );
      final c = VersionStamp.fromPacked((1700000000001) << 16, 'device-a');
      final ue = VersionStamp.fromPacked(
        1700000000000 << 16,
        'device-\u{e000}',
      );
      final u1 = VersionStamp.fromPacked(
        1700000000000 << 16,
        'device-\u{10000}',
      );

      // 先比 l；l 相同比 c；c 相同比 deviceId（UTF-8 字节序）
      expect(a.compareTo(b), lessThan(0), reason: '同 l 时 c 小者小（c 低位不被吃掉）');
      expect(b.compareTo(c), lessThan(0), reason: 'l 递增胜出');
      expect(a.compareTo(a), 0, reason: '自反');
      expect(ue.compareTo(u1), lessThan(0),
          reason: 'deviceId 按 UTF-8 字节序：U+E000 < U+10000');
      expect(u1.compareTo(ue), greaterThan(0));
    });
  });
}
