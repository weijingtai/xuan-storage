// ignore_for_file: lines_longer_than_80_chars

/// BUILD-THEME 返工 P1-2：`assets/pubspec.yaml` 必须注册 `- lib/theme/`，
/// 否则内置主题载荷进不了 app bundle（rootBundle 读不到）。
///
/// 用 rootBundle 真读一次 `default.jsonl`：
/// - pubspec 未注册 `- lib/theme/` -> load 抛异常 -> 本测试红（修正标准要求）
/// - 注册后 -> 读到非空字节 -> 绿
///
/// 门禁纪律：不 mock、不用 setMockMessageHandler，走真实 rootBundle 链路。
library;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

/// 载荷在 rootBundle 里的路径（assets 包内，与 pubspec 注册目录对应）。
const _kThemeAssetPath = 'lib/theme/default.jsonl';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pubspec 注册 lib/theme/ 后 rootBundle 能真读 default.jsonl', () async {
    // 读不到（未注册 / 路径错）会抛异常，测试即红。
    final data = await rootBundle.load(_kThemeAssetPath);
    expect(data.lengthInBytes, greaterThan(0),
        reason: 'default.jsonl 应为非空载荷（真值 27458 字节）');
  });
}
