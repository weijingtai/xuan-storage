/// RED: Firestore Rules 单一源合同（Task 8）。
///
/// 断言 emulator 配置只引用一份生产 `firestore.rules`：
/// - `infrastructure/emulator/firebase.json` 的 `firestore.rules` == `../firestore.rules`
///   （相对 emulator 目录，解析后指向生产 rules，文件存在且非空）；
/// - `infrastructure/emulator/firestore.rules`（旧 callable 版）**不存在**；
/// - 生产 `infrastructure/firestore.rules` 存在，且不残留 thread-presentation 私有映射
///   （验证与 Task 7 单一源内容一致）。
///
/// 在删除旧 emulator/firestore.rules 之前必须失败（静态 RED）。
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const emulatorDir = 'infrastructure/emulator';
  const emulatorConfig = '$emulatorDir/firebase.json';
  const oldRules = '$emulatorDir/firestore.rules';
  const productionRules = 'infrastructure/firestore.rules';

  test('emulator firebase.json 引用生产 ../firestore.rules（单一源）', () {
    final raw = File(emulatorConfig).readAsStringSync();
    final config = jsonDecode(raw) as Map<String, dynamic>;
    final firestore = config['firestore'] as Map<String, dynamic>;
    final rulesRef = firestore['rules'] as String?;

    expect(rulesRef, '../firestore.rules',
        reason: 'emulator 必须引用生产 rules（单一源），而非本地副本');
    // 相对 emulator 目录解析后的绝对路径必须存在且非空。
    final resolved = File('$emulatorDir/$rulesRef');
    expect(resolved.existsSync(), isTrue,
        reason: '解析后指向的生产 rules 必须存在');
    final content = resolved.readAsStringSync();
    expect(content.trim(), isNotEmpty);
  });

  test('旧 emulator/firestore.rules 已删除（单一源无重复副本）', () {
    expect(File(oldRules).existsSync(), isFalse,
        reason: 'emulator/firestore.rules 必须删除，只保留生产 rules');
  });

  test('生产 firestore.rules 存在且不残留 thread-presentation 私有映射', () {
    final rules = File(productionRules).readAsStringSync();
    expect(rules.trim(), isNotEmpty);
    expect(rules, isNot(contains('playground_thread_presentations')),
        reason: 'Task 7 已移除 thread-presentation 私有映射，单一源内容应一致');
    expect(rules, contains('oneTimeAnonymous'));
  });
}
