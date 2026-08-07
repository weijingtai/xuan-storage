// ignore_for_file: lines_longer_than_80_chars

/// 主题预设构建脚本的测试（BUILD-THEME 验收 A1 / A3 / A5 / A7）。
///
/// 用 Process 调 Python 脚本，验证：
/// - A1: 4 个预设构建成功，产出 .jsonl
/// - A3 (SHALL-1): 数值非法 fixture -> 非零退出
/// - A5 (SHALL-3): 整体形状非法 fixture -> 非零退出
/// - A7: 载荷行 schema 严格 {"k","v","t"}，零 g 字段（产物 + 源码双向扫描）
///
/// 门禁纪律：每条断言能因实现变坏而变红；不用 fail()。
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 构建脚本路径（assets/test/ 的 cwd 是 assets/ 包根）。
final _script = File('tool/build_theme_jsonl.py');
final _fixturesDir = Directory('tool/test_fixtures/theme');
final _outDir = Directory('lib/theme');

/// 跑构建脚本，返回 (exitCode, stdout, stderr)。
Future<({int exitCode, String stdout, String stderr})> _run(
  List<String> args,
) async {
  final res = await Process.run(
    'python3',
    [_script.path, ...args],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  return (
    exitCode: res.exitCode,
    stdout: res.stdout as String,
    stderr: res.stderr as String,
  );
}

/// 用 --presets-dir 把坏 fixture 喂进脚本（坏 fixture 复制为 default.yaml）。
Future<({int exitCode, String stdout, String stderr})> _runFixture(
  String fixtureName,
) async {
  final tmpDir = await Directory.systemTemp.createTemp('theme_test_');
  try {
    await File('${_fixturesDir.path}/$fixtureName.yaml').copy(
      File('${tmpDir.path}/default.yaml').path,
    );
    return await _run(['--presets-dir', tmpDir.path, 'default']);
  } finally {
    await tmpDir.delete(recursive: true);
  }
}

void main() {
  group('A1: 4 个预设构建成功', () {
    test('default 构建成功且为 BUNDLED', () async {
      final r = await _run(['default']);
      expect(r.exitCode, 0, reason: 'stdout=${r.stdout}\nstderr=${r.stderr}');
      expect(r.stdout, contains('BUNDLED -> generation 0'));
      expect(File('${_outDir.path}/default.jsonl').existsSync(), isTrue);
    });

    test('dark 构建成功', () async {
      final r = await _run(['dark']);
      expect(r.exitCode, 0, reason: 'stderr=${r.stderr}');
      expect(File('${_outDir.path}/dark.jsonl').existsSync(), isTrue);
    });

    test('ai-mingli-ink 构建成功', () async {
      final r = await _run(['ai-mingli-ink']);
      expect(r.exitCode, 0, reason: 'stderr=${r.stderr}');
      expect(File('${_outDir.path}/ai-mingli-ink.jsonl').existsSync(), isTrue);
    });

    test('ai-starry-bronze 构建成功', () async {
      final r = await _run(['ai-starry-bronze']);
      expect(r.exitCode, 0, reason: 'stderr=${r.stderr}');
      expect(File('${_outDir.path}/ai-starry-bronze.jsonl').existsSync(), isTrue);
    });
  });

  group('A3 (SHALL-1): 数值字段非数值 -> 构建失败', () {
    test('radius="8px" 的 fixture 必须非零退出', () async {
      final r = await _runFixture('bad_numeric');
      expect(
        r.exitCode,
        isNot(0),
        reason: '数值非法 fixture 应构建失败，但成功了\n'
            'stdout=${r.stdout}\nstderr=${r.stderr}',
      );
      // 错误信息应指向 SHALL-1 / A14d
      expect(r.stderr.toLowerCase(), contains('shall-1'));
    });
  });

  group('A5 (SHALL-3): 整体形状非法 -> 构建失败', () {
    test('顶层缺 light/dark 的 fixture 必须非零退出', () async {
      final r = await _runFixture('bad_shape');
      expect(
        r.exitCode,
        isNot(0),
        reason: '形状非法 fixture 应构建失败，但成功了\n'
            'stdout=${r.stdout}\nstderr=${r.stderr}',
      );
      expect(r.stderr.toLowerCase(), contains('shall-3'));
    });
  });

  group('A7: 载荷行 schema 严格 {"k","v","t"}，零 g 字段', () {
    test('default.jsonl 每行只有 k/v/t 三个字段，无 g', () async {
      // 先确保产物存在
      final r = await _run(['default']);
      expect(r.exitCode, 0);
      final lines = File('${_outDir.path}/default.jsonl').readAsLinesSync();
      expect(lines, isNotEmpty);
      for (final line in lines) {
        if (line.isEmpty) continue;
        final obj = jsonDecode(line) as Map<String, dynamic>;
        // 严格只有 k/v/t
        expect(
          obj.keys.toSet(),
          {'k', 'v', 't'},
          reason: '行 $line 含非法字段（应只有 k/v/t，无 g）',
        );
        // 显式断言无 g（R4-P0）
        expect(obj.containsKey('g'), isFalse, reason: 'R4-P0: 载荷不得含 g 字段');
        // 类型标记合法
        expect({'s', 'n', 'b', 'a', 'z'}, contains(obj['t']));
        // v 不得是 Map（嵌套应在构建期展平）
        expect(obj['v'], isNot(isA<Map>()), reason: 'v 不得是 Map');
      }
    });

    test('源码扫描：构建脚本不在 json.dumps 写 g 字段', () {
      // A7 要求源码/产物双向扫描。扫脚本源码，确认没有写 'g' 字段。
      final src = _script.readAsStringSync();
      // json.dumps 调用里不应含 'g': 键
      final jsonDumpsG = RegExp(r"""json\.dumps\(\{[^}]*['"]g['"]\s*:""");
      expect(
        jsonDumpsG.hasMatch(src),
        isFalse,
        reason: '构建脚本不得在 json.dumps 里写 g 字段（R4-P0）',
      );
    });
  });

  group('幂等性', () {
    test('连续跑两次 default，产物字节一致', () async {
      final r1 = await _run(['default']);
      expect(r1.exitCode, 0);
      final bytes1 = File('${_outDir.path}/default.jsonl').readAsBytesSync();
      final r2 = await _run(['default']);
      expect(r2.exitCode, 0);
      final bytes2 = File('${_outDir.path}/default.jsonl').readAsBytesSync();
      expect(bytes1, equals(bytes2), reason: '幂等：两次构建产物必须字节一致');
    });
  });
}
