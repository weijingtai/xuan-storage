import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('docs/ and drift/lib/ contain no AIGC watermarks', () {
    // Resolve xuan-storage repository root regardless of whether cwd is drift/ or repo root.
    final currentDir = Directory.current;
    final repoRoot = currentDir.path.endsWith('drift')
        ? currentDir.parent
        : (Directory('${currentDir.path}/drift').existsSync() ? currentDir : currentDir.parent);

    final targetDirs = [
      Directory('${repoRoot.path}/docs'),
      Directory('${repoRoot.path}/drift/lib'),
      Directory('${repoRoot.path}/core/lib'),
    ].where((d) => d.existsSync()).toList();

    final forbiddenPatterns = [
      RegExp(r'🤖'),
      RegExp(r'内容由\s*AI\s*生成', caseSensitive: false),
      RegExp(r'由\s*AI\s*生成', caseSensitive: false),
      RegExp(r'AI[- ]generated', caseSensitive: false),
      RegExp(r'generated\s+by\s+(claude|chatgpt|openai|anthropic|gemini|deepseek|ai)', caseSensitive: false),
      RegExp(r'co-authored-by:\s*.*(claude|chatgpt|gemini|deepseek|bot|ai)', caseSensitive: false),
      RegExp(r'written\s+by\s+(claude|chatgpt|openai|anthropic|gemini|deepseek|ai)', caseSensitive: false),
    ];

    final violations = <String>[];

    for (final dir in targetDirs) {
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File) continue;
        final path = entity.path;
        if (path.endsWith('.g.dart') ||
            path.endsWith('.mocks.dart') ||
            path.endsWith('.lock')) {
          continue;
        }
        if (!path.endsWith('.dart') && !path.endsWith('.md')) {
          continue;
        }

        final content = entity.readAsStringSync();
        for (final pattern in forbiddenPatterns) {
          if (pattern.hasMatch(content)) {
            violations.add('$path matched forbidden pattern: ${pattern.pattern}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Found forbidden AIGC watermarks in codebase:\n${violations.join('\n')}',
    );
  });
}
