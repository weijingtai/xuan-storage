import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// S3c-b 架构守卫：`p2p` 包不得依赖任何 firebase（裁定 C3 / 验收 A6）。
///
/// 【为什么必须是测试而不是一条约定】裁定 C3 的原话是「信令后端可换，
/// 传输层实现不得直接依赖任何具体后端 SDK」。这句话写在设计稿里管不住任何人 ——
/// 半年后有人为了图快，在 `p2p` 里 import 一个 firebase 包，评审时谁也不会想起
/// 去翻设计稿。**本测试把那句话变成一条会红的断言**，这正是 A6 的原文要求：
/// 「零 firebase 依赖（架构守卫测试，源码扫描）」。
///
/// 【为什么扫源码而不是查解析结果】查 `.dart_tool/package_config.json` 只能
/// 发现「已经解析成功的依赖」，而 pubspec 里刚写下、还没 `pub get` 的一行同样
/// 是违规，且那正是最该被当场拦下的时刻。扫源码抓的是意图，不是结果。
///
/// 【为什么连注释里的 firebase 也不放过】与 `signaling.dart` 的契约守卫同一
/// 口径（见 `core/test/signaling_contract_test.dart` 的「A2 · 后端无关」组）：
/// 契约层出现后端名，哪怕只在注释中，也会让后人以为绑定了它。
void main() {
  group('架构守卫（源码扫描）· 裁定 C3', () {
    test('A6 · p2p/pubspec.yaml 零 firebase 依赖', () {
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
            reason: 'p2p/pubspec.yaml 出现 "$banned" —— '
                '裁定 C3 要求 p2p 包不得依赖任何 firebase；'
                '信令的云端实现归 S3c-d，落在别的包里');
      }
    });

    test('A6 · p2p 源码不得 import 任何 firebase 包', () {
      // pubspec 干净但源码里 import 了（例如经由某个转依赖），同样违规。
      final offenders = <String>[];
      for (final dir in ['lib', 'test']) {
        final d = Directory(dir);
        if (!d.existsSync()) continue;
        for (final entity in d.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          // 本守卫文件自身写满了 firebase 字样，跳过，否则它会告发自己。
          if (entity.path.endsWith('s3c_no_firebase_guard_test.dart')) continue;
          final src = entity.readAsStringSync();
          if (RegExp(r"import\s+'package:(firebase|cloud_firestore)")
              .hasMatch(src)) {
            offenders.add(entity.path);
          }
        }
      }
      expect(offenders, isEmpty,
          reason: '以下 p2p 文件 import 了 firebase 包，违反裁定 C3：$offenders');
    });
  });
}
