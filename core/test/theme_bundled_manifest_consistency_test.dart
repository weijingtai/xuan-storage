// ignore_for_file: lines_longer_than_80_chars

/// BUILD-THEME 验收 A2 + A6 + A7(core 侧)：内置世代 manifest 与载荷的一致性门禁。
///
/// - A2: kThemeBundledManifest 的 sha256/bytes/rowCount 与实际载荷 default.jsonl 对得上
/// - A6: 改了载荷不改 manifest（或反之）-> 本测试变红。变异自检见纪要「决定记录」
/// - A7: 载荷每行无 g 字段（R4-P0 双向扫描之 core 侧）
///
/// 判据（协议不变式 I3/I4）：安装期比对这些真值，不符则不进 ready。
/// 本测试把"事实合规"升级为"有门禁守着"：载荷字节算出的真值必须等于 manifest 声明值。
///
/// 注意：本文件是测试，用 crypto 算 sha256 做一致性校验，与 S5a A20⑤ 约束
/// （in_memory_theme_materializer.dart 不得 import crypto）不冲突 -- 那约束的是
/// reference 实现源码（完整性校验归 XRAP 安装器），不是测试文件。
///
/// 门禁纪律：每条断言能因实现变坏而变红；不用 fail()；不用未 await 的回调。
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/theme_dataset.dart';

/// 内置世代载荷文件（assets 包，core 的兄弟目录）。
/// generation 0 = default 预设（纪要决定 2：default.yaml 喂 kThemeBundledManifest）。
final _payloadFile = File('../assets/lib/theme/default.jsonl');

void main() {
  test('A2+A6: kThemeBundledManifest 真值与 default.jsonl 载荷字节一致', () {
    // 守卫：载荷文件必须存在（否则门禁无法校验，A6 形同虚设）
    expect(
      _payloadFile.existsSync(),
      isTrue,
      reason: '内置世代载荷 ${_payloadFile.path} 不存在 -- '
          '先跑 python3 assets/tool/build_theme_jsonl.py 生成',
    );

    final bytes = _payloadFile.readAsBytesSync();
    final text = utf8.decode(bytes);

    // rowCount = jsonl 行数（非空行，设计 §4.3）
    final nonEmptyLines = text.split('\n').where((l) => l.isNotEmpty).toList();

    // 断言 1: declaredRowCount 与实际行数一致（I4）
    expect(
      kThemeBundledManifest.declaredRowCount,
      equals(nonEmptyLines.length),
      reason: 'declaredRowCount(${kThemeBundledManifest.declaredRowCount}) '
          '!= 载荷实际行数(${nonEmptyLines.length})。'
          '改了 yaml 必须重跑构建脚本并回填 manifest（A6 门禁）',
    );

    // 断言 2: payloadBytes 与实际字节数一致
    expect(
      kThemeBundledManifest.payloadBytes,
      equals(bytes.length),
      reason: 'payloadBytes(${kThemeBundledManifest.payloadBytes}) '
          '!= 载荷实际字节数(${bytes.length})。'
          '改了 yaml 必须重跑构建脚本并回填 manifest（A6 门禁）',
    );

    // 断言 3: payloadSha256 与实际载荷字节 sha256 一致（I3）
    final digest = crypto.sha256.convert(bytes).toString();
    expect(
      kThemeBundledManifest.payloadSha256,
      equals(digest),
      reason: 'payloadSha256 与载荷字节算出的 sha256 不一致。\n'
          'manifest:  ${kThemeBundledManifest.payloadSha256}\n'
          '载荷实际:  $digest\n'
          '改了 yaml 必须重跑构建脚本并回填 manifest（A6 门禁）',
    );

    // 断言 4: contentVersion 不是占位值（防回退）
    expect(
      kThemeBundledManifest.contentVersion,
      isNot(equals('0.0.0-placeholder')),
      reason: 'contentVersion 仍是占位值 0.0.0-placeholder',
    );
  });

  test('A7: default.jsonl 载荷每行无 g 字段（R4-P0 双向扫描之 core 侧）', () {
    expect(_payloadFile.existsSync(), isTrue);
    final lines = _payloadFile.readAsLinesSync();
    expect(lines, isNotEmpty);
    for (final line in lines) {
      if (line.isEmpty) continue;
      final obj = jsonDecode(line) as Map<String, dynamic>;
      expect(
        obj.containsKey('g'),
        isFalse,
        reason: 'R4-P0: 载荷行不得含 g 字段: $line',
      );
      // 行 schema 严格三字段
      expect(obj.keys.toSet(), {'k', 'v', 't'}, reason: '行 schema 非法: $line');
    }
  });
}
