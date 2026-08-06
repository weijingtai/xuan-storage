import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'support/theme_bench_fixture.dart';
import 'support/theme_probes.dart';

/// S5a · ACT 05b 测试支撑自检（fixture 与探针）。
///
/// 本文件由 ACT 05b 先写 fixture / 探针的 3 条自检用例；
/// ACT 06 会扩充同一文件的 P3/P4/P6/A21 启动路径用例。
void main() {
  group('ACT 05b 测试支撑自检', () {
    test('fixture_leaf_count_lower_bound', () {
      // §7.5：叶子总数下限 700，防空输入假通过。
      final fixture = ThemeBenchFixture();
      expect(fixture.leafCount, greaterThanOrEqualTo(700));
    });

    test('counting_installer_implements_six_methods', () {
      // 构造成功即证明六个抽象方法都有实现（缺一编译不过）。
      final fixture = ThemeBenchFixture();
      final installer =
          CountingDatasetInstaller(bundledPayload: fixture.bundledJsonlBytes);

      // 六个计数字段初值一律 0。
      expect(installer.ensureInstalledCallCount, 0);
      expect(installer.checkForUpdateCallCount, 0);
      expect(installer.activeCallCount, 0);
      expect(installer.generationsCallCount, 0);
      expect(installer.rollbackToCallCount, 0);
      expect(installer.collectGarbageCallCount, 0);
      // calledDatasetIds 是 List（可重复），初值空。
      expect(installer.calledDatasetIds, isEmpty);
    });

    test('bundled_jsonl_has_no_g_field', () async {
      // R4-P0 回归守卫：载荷行只有 k/v/t，无 g。
      final fixture = ThemeBenchFixture();
      final bytes = await fixture
          .bundledJsonlBytes()
          .fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
      final lines = utf8
          .decode(bytes)
          .split('\n')
          .where((l) => l.trim().isNotEmpty);
      var rowCount = 0;
      for (final line in lines) {
        final j = jsonDecode(line) as Map<String, dynamic>;
        expect(
          j.keys.toSet().difference({'k', 'v', 't'}),
          isEmpty,
          reason: '载荷行不得含 g 或其它字段: $line',
        );
        rowCount++;
      }
      expect(rowCount, greaterThan(0));
    });
  });
}
