// 包：persistence_core (test)  文件：core/test/theme_merge_bench_test.dart
// 【benchmark】S5a · P1 三层合并性能验收（设计 §7.5）。
// ⚠️ 标 @Tags(['benchmark'])，不进 CI 阻塞门禁（Flutter debug VM 抖动大）；
// CI 只跑一次冒烟确认不超时（< 100ms）。

@Tags(['benchmark'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/theme_resolution.dart';
import 'package:persistence_core/reference/theme_token_merger.dart';

import 'support/theme_bench_fixture.dart';

void main() {
  test('P1_merge_bench_under_5ms', () {
    final fixture = ThemeBenchFixture();

    // 防空输入假通过：fixture 叶子数须 >= 700（§7.5）。
    expect(fixture.leafCount, greaterThanOrEqualTo(700));

    // warm-up 20 次（触发 JIT，防 debug VM 首跑抖动）。
    for (var i = 0; i < 20; i++) {
      mergeThemeTokens(
        bundledTokens: fixture.bundledTokens,
        packageTokens: fixture.packageTokens,
        overrides: fixture.overrides,
        activeThemeId: 'demo-theme',
        activeThemeVersion: '1.0.0',
        selectionOrigin: ThemeSelectionOrigin.officialDefault,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );
    }

    // 测 100 次，取中位数。
    final samples = <int>[];
    for (var i = 0; i < 100; i++) {
      final sw = Stopwatch()..start();
      mergeThemeTokens(
        bundledTokens: fixture.bundledTokens,
        packageTokens: fixture.packageTokens,
        overrides: fixture.overrides,
        activeThemeId: 'demo-theme',
        activeThemeVersion: '1.0.0',
        selectionOrigin: ThemeSelectionOrigin.officialDefault,
        resolvedAtUtc: DateTime.utc(2026, 8, 5),
      );
      sw.stop();
      samples.add(sw.elapsedMicroseconds);
    }
    samples.sort();
    final median = samples[50]; // 100 个样本的中位数 = 下标 50。

    // 断言中位数 < 5ms（5000µs）。
    expect(median, lessThan(5000),
        reason: '三层合并中位数 $median µs 超过 5ms 预算（§7.5 P1）');
  });
}
