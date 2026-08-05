import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// S3c-b `flutter_test` 围栏（决定记录 D2b / 验收 A10）。
///
/// 【为什么存在】D2 把 `flutter_test` 从 `core` 的 dev_dependencies 提到了
/// dependencies（否则 `lib/` 下 import 它会报 depend_on_referenced_packages，
/// S1a 门禁检查 2 直接红）。不加围栏的话，半年后 `core/lib/model/` 里就会冒出
/// `flutter_test` 的 import 而门禁不响 —— 围栏把「测试框架只许进 test_support/」
/// 变成可机械检查的事实，也让 D2 可回退（将来真分包时范围已被框死）。
void main() {
  group('flutter_test 围栏（源码扫描）', () {
    test('core/lib/ 下只有 test_support/ 允许出现 flutter_test', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (!entity.readAsStringSync().contains('flutter_test')) continue;
        if (!entity.path.startsWith('lib/test_support/')) {
          offenders.add(entity.path);
        }
      }
      expect(offenders, isEmpty,
          reason: '以下 lib/ 文件出现 flutter_test，'
              'core/lib/ 下只有 test_support/ 允许 import 它：$offenders');
    });
  });
}
