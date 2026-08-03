import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Forbidden patterns that must not appear in interface or product code.
const forbiddenPatterns = <String>[
  'FirebaseAuth',
  'FirebaseDatabase',
  'FirebaseFirestore',
  'UserCredential',
  'FirebaseApp',
];

/// 从 [start] 逐级向上定位同时包含 [probe] 全部子目录的那一级（容器目录）。
///
/// 主工作区与任意深度的 worktree 都成立：不写死相对层数，
/// 向上找到文件系统根仍未命中才返回 null（不抛异常）。
///
/// 返回值：
/// - 找到的容器目录；找不到返回 null。
Directory? locateContainerDir({
  required List<String> probe,
  required Directory start,
}) {
  var dir = start;
  while (true) {
    final found = probe.every((p) => Directory('${dir.path}/$p').existsSync());
    if (found) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) return null; // 到文件系统根仍未命中
    dir = parent;
  }
}

/// 返回实际搜索过的起点路径（用于失败信息，让下一个人知道在哪儿找的）。
String searchStartHint() => Directory.current.path;

/// Scan lib/ for forbidden SDK type mentions in non-deprecated files.
List<String> findFirebaseSdkLeaks(String content) {
  final leaks = <String>[];
  final lines = content.split('\n');

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    // Skip comments
    if (line.startsWith('//') || line.startsWith('/*') || line.startsWith('*')) continue;

    for (final pattern in forbiddenPatterns) {
      if (line.contains(pattern)) {
        leaks.add('$pattern at line ${i + 1}: $line');
      }
    }
  }
  return leaks;
}

void main() {
  group('Firebase SDK Boundary (TACT-3A)', () {
    test('repository-interface-account/lib has zero Firebase SDK mentions', () {
      final container = locateContainerDir(
        probe: const ['repository-interface-account', 'xuan-account'],
        start: Directory.current,
      );
      if (container == null) {
        fail('repository-interface-account/lib not found（搜索起点: ${searchStartHint()}）');
      }

      final dir = Directory('${container.path}/repository-interface-account/lib');
      if (!dir.existsSync()) {
        fail('repository-interface-account/lib not found（搜索起点: ${searchStartHint()}）');
      }

      final violations = <String>[];
      final files = dir.listSync(recursive: true);
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = entity.readAsStringSync();
          final found = findFirebaseSdkLeaks(content);
          if (found.isNotEmpty) {
            violations.add('${entity.path}:\n${found.join('\n')}');
          }
        }
      }

      expect(violations, isEmpty, reason: 'Firebase SDK types leaked in interface:\n${violations.join('\n\n')}');
    });

    test('xuan-account/lib has zero Firebase SDK type mentions', () {
      final container = locateContainerDir(
        probe: const ['repository-interface-account', 'xuan-account'],
        start: Directory.current,
      );
      if (container == null) {
        fail('xuan-account/lib not found（搜索起点: ${searchStartHint()}）');
      }

      final dir = Directory('${container.path}/xuan-account/lib');
      if (!dir.existsSync()) {
        fail('xuan-account/lib not found（搜索起点: ${searchStartHint()}）');
      }

      final violations = <String>[];
      final files = dir.listSync(recursive: true);
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = entity.readAsStringSync();
          final found = findFirebaseSdkLeaks(content);
          if (found.isNotEmpty) {
            violations.add('${entity.path}:\n${found.join('\n')}');
          }
        }
      }

      expect(violations, isEmpty, reason: 'Firebase SDK types leaked in xuan-account:\n${violations.join('\n\n')}');
    });

    test('persistence_firebase/pubspec.yaml has repository_interface_account dep', () {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('repository_interface_account'));
    });

    test('Reverse fixture: FirebaseAuth in code is detected', () {
      const code = 'final auth = FirebaseAuth.instance;';
      final leaks = findFirebaseSdkLeaks(code);
      expect(leaks, isNotEmpty);
      expect(leaks.any((l) => l.contains('FirebaseAuth')), isTrue);
    });

    test('Reverse fixture: UserCredential in port is detected', () {
      const code = 'Future<UserCredential> signIn();';
      final leaks = findFirebaseSdkLeaks(code);
      expect(leaks, isNotEmpty);
      expect(leaks.any((l) => l.contains('UserCredential')), isTrue);
    });

    test('locator returns null instead of throwing when not found', () {
      // 从一个肯定不含 probe 的目录开始向上找，断言返回 null 而非抛异常。
      final result = locateContainerDir(
        probe: const ['__definitely_not_exists__'],
        start: Directory.systemTemp,
      );
      expect(result, isNull);
    });
  });
}
