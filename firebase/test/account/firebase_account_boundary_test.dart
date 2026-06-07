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
      final dir = Directory('../../repository-interface-account/lib');
      if (!dir.existsSync()) {
        fail('repository-interface-account/lib not found');
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
      final dir = Directory('../../xuan-account/lib');
      if (!dir.existsSync()) {
        fail('xuan-account/lib not found');
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
  });
}
