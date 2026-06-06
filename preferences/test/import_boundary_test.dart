import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const forbidden = <String>[
  'package:firebase',
  'package:cloud_firestore',
  'package:drift',
  'package:http',
  'package:grpc',
  'dart:io',
];

List<String> findForbiddenImports(String path, String content) {
  final violations = <String>[];
  final lines = content.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('import ') || line.startsWith('export ')) {
      for (final target in forbidden) {
        if (line.contains("'$target") || line.contains('"$target')) {
          if (!violations.contains(target)) {
            violations.add(target);
          }
        }
      }
    }
  }
  return violations;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Import Boundary Test', () {
    test('positive - package:shared_preferences is allowed', () {
      final content = "import 'package:shared_preferences/shared_preferences.dart';";
      final violations = findForbiddenImports('dummy.dart', content);
      expect(violations, isEmpty);
    });

    test('negative - forbidden imports are caught', () {
      final driftContent = "import 'package:drift/drift.dart';";
      final driftViolations = findForbiddenImports('dummy.dart', driftContent);
      expect(driftViolations, contains('package:drift'));

      final ioContent = "import 'dart:io';";
      final ioViolations = findForbiddenImports('dummy.dart', ioContent);
      expect(ioViolations, contains('dart:io'));
    });

    test('all production files in lib/ have no forbidden imports', () {
      final libDir = Directory('lib');
      if (!libDir.existsSync()) {
        fail('lib directory does not exist');
      }

      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      for (final file in files) {
        final content = file.readAsStringSync();
        final violations = findForbiddenImports(file.path, content);
        expect(
          violations,
          isEmpty,
          reason: 'File ${file.path} contains forbidden imports: $violations',
        );
      }
    });
  });
}
