import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// S3c-d 架构守卫：`core` 包不得依赖任何 firebase（裁定 C3 / 验收 A6）。
///
/// 【为什么必须是测试而不是一条约定】裁定 C3 的原话是「信令后端可换，
/// 传输层实现不得直接依赖任何具体后端 SDK」。这句契约约定要防的是有人为了
/// 图快在契约层 import 一个 firebase 包。`core` 是契约层，`p2p`（局域网）已
/// 有同款守卫（`p2p/test/s3c_no_firebase_guard_test.dart`），本文件把 `core`
/// 也守起来 —— 云端实现归 `firebase` 包，任何 firebase 字样进不了 `core`。
///
/// 【为什么扫源码而不是查解析结果】查 `.dart_tool/package_config.json` 只能
/// 发现「已经解析成功的依赖」，而 pubspec 里刚写下、还没 `pub get` 的一行同样
/// 是违规，且那正是最该被当场拦下的时刻。扫源码抓的是意图，不是结果。
void main() {
  group('架构守卫（源码扫描）· 裁定 C3', () {
    test('A6 · core/pubspec.yaml 零 firebase 依赖', () {
      final src = File('pubspec.yaml').readAsStringSync();

      for (final banned in [
        'firebase',
        'Firebase',
        'firestore',
        'Firestore',
        'cloud_firestore',
        'rtdb',
        'RTDB',
        'realtime_database',
      ]) {
        expect(src.contains(banned), isFalse,
            reason: 'core/pubspec.yaml 出现 "$banned" —— '
                '裁定 C3 要求契约层不得依赖任何 firebase；'
                '云端实现归 S3c-d，落在 firebase 包里');
      }
    });

    test('A6 · core 源码不得 import 任何 firebase 包', () {
      // pubspec 干净但源码里 import 了（例如经由某个转依赖），同样违规。
      final offenders = <String>[];
      for (final dir in ['lib', 'test']) {
        final d = Directory(dir);
        if (!d.existsSync()) continue;
        for (final entity in d.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          // 本守卫文件自身写满了 firebase 字样，跳过，否则它会告发自己。
          if (entity.path.endsWith('s3c_no_firebase_guard_test.dart')) {
            continue;
          }
          final src = entity.readAsStringSync();
          if (RegExp(r"import\s+'package:(firebase|cloud_firestore)")
              .hasMatch(src)) {
            offenders.add(entity.path);
          }
        }
      }
      expect(offenders, isEmpty,
          reason: '以下 core 文件 import 了 firebase 包，违反裁定 C3：'
              '$offenders');
    });
  });
}
