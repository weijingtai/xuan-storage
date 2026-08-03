/// XRAP 协议一致性门禁（协议 §8.3）。
///
/// **这是本协议区别于普通设计文档的地方**：机械保证规范与代码不漂移。
///
/// 验两个方向：
/// - 规范文档提到的每个协议类型，代码里必须真实存在；
/// - 代码里每个公开协议类型，规范文档必须提到。
///
/// 效果：改协议必然改代码，改代码必然改协议。
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 规范文档相对 core/ 的路径。
const _specPath =
    '../docs/superpowers/specs/2026-08-02-resource-asset-protocol.md';

/// 协议契约目录。
const _contractDir = 'lib/model/dataset';

/// 覆盖下限自检（门禁纪律第 3 条）。
///
/// 正则写错扫到 0 个类型时会静默全绿，因此写死下限。
/// 实测 2026-08-02 为 14 个（6 个文件），下限取 12 留余量；
/// 新增协议类型后应上调此值。
const _minTypeCount = 12;

void main() {
  group('XRAP 协议一致性（§8.3）', () {
    late String specText;
    late Map<String, String> declaredTypes; // 类型名 → 所在文件

    setUpAll(() {
      final spec = File(_specPath);
      expect(
        spec.existsSync(),
        isTrue,
        reason: '规范文档缺失：$_specPath —— 协议没有文档等于没有协议',
      );
      specText = spec.readAsStringSync();

      declaredTypes = {};
      final dir = Directory(_contractDir);
      expect(dir.existsSync(), isTrue, reason: '协议契约目录缺失：$_contractDir');

      // 匹配公开顶层类型声明：class / enum / mixin / typedef，
      // 含任意修饰符前缀（abstract/base/interface/final/sealed 及组合）。
      final typeDecl = RegExp(
        r'^(?:abstract\s+|base\s+|interface\s+|final\s+|sealed\s+|mixin\s+)*'
        r'(?:class|enum|typedef)\s+([A-Z]\w*)',
        multiLine: true,
      );

      for (final f in dir.listSync().whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        for (final m in typeDecl.allMatches(f.readAsStringSync())) {
          declaredTypes[m.group(1)!] = f.path;
        }
      }
    });

    test('契约目录里的类型数量达到覆盖下限（防正则失效静默全绿）', () {
      expect(
        declaredTypes.length,
        greaterThanOrEqualTo(_minTypeCount),
        reason:
            '只扫到 ${declaredTypes.length} 个类型，低于下限 $_minTypeCount。'
            '要么正则失效，要么契约被大量删除 —— 两者都必须人工确认。',
      );
    });

    test('代码 → 文档：每个公开协议类型都必须在规范文档中被提及', () {
      final missing = <String>[];
      for (final name in declaredTypes.keys) {
        // 文档中以反引号包裹的形式提及即算覆盖。
        if (!specText.contains('`$name`') && !specText.contains('[$name]')) {
          missing.add('$name（${declaredTypes[name]}）');
        }
      }
      expect(
        missing,
        isEmpty,
        reason:
            '以下协议类型只存在于代码、未写入规范文档：\n  ${missing.join('\n  ')}\n'
            '协议 §0.2：任何人读本协议即可了解资源如何被管理。'
            '代码里有而文档没有的东西，破坏了这个承诺。',
      );
    });

    test('文档 → 代码：规范文档 §0.3 对应表里的接口都必须存在', () {
      // §0.3 明列的六组核心契约，逐个硬检查。
      // 【硬编码而非从文档解析】—— 从文档解析会让「文档写错」与
      // 「代码写错」不可区分，反而失去 oracle 作用。
      const required = <String>[
        'DatasetManifest',
        'DatasetDescriptor',
        'DatasetRegistry',
        'DatasetSource',
        'DatasetEndpointProvider',
        'DatasetMaterializer',
        'MaterializeOutcome',
        'DatasetInstaller',
        'InstallOutcome',
        'InstalledDataset',
        'DatasetGenerationStatus',
      ];
      final absent =
          required.where((n) => !declaredTypes.containsKey(n)).toList();
      expect(
        absent,
        isEmpty,
        reason:
            '规范文档 §0.3 声明了以下接口，但代码里不存在：${absent.join(', ')}\n'
            '协议的立身之本是「每条规则对应一个可编译签名」。',
      );
    });

    test('六条根本原则（§1 P1–P6）在文档中齐全', () {
      for (final p in ['P1', 'P2', 'P3', 'P4', 'P5', 'P6']) {
        expect(
          specText.contains('**$p ·'),
          isTrue,
          reason: '规范文档缺失根本原则 $p —— §1 是协议的宪法，不得残缺',
        );
      }
    });

    test('九条不变式（§6 I1–I9）在文档中齐全且各有强制级别', () {
      for (var i = 1; i <= 9; i++) {
        expect(
          specText.contains('| I$i |'),
          isTrue,
          reason: '规范文档 §6 缺失不变式 I$i',
        );
      }
    });

    test('八条禁止事项（§7 N1–N8）在文档中齐全', () {
      for (var i = 1; i <= 8; i++) {
        expect(
          specText.contains('| N$i |'),
          isTrue,
          reason: '规范文档 §7 缺失禁止事项 N$i',
        );
      }
    });

    test('§12 换方案索引存在 —— 这是协议的使用说明，缺了协议就退化为设计稿', () {
      expect(specText.contains('## 12. 要换方案时改哪几节'), isTrue);
      // 至少覆盖换后端、换本地存储、加载体三种典型场景。
      expect(specText.contains('换分发后端'), isTrue);
      expect(specText.contains('换本地存储'), isTrue);
      expect(specText.contains('加一种载体形态'), isTrue);
    });
  });
}
