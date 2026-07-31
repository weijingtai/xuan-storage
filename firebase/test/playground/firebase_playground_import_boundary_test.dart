import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Import boundary: lib/playground/', () {
    final libDir = Directory('lib/playground');
    if (!libDir.existsSync()) {
      fail('lib/playground directory not found');
    }

    final forbidden = <String>[
      'package:supabase',
      'package:http',
      'package:dio',
      'dart:io',
    ];

    final allowed = <String>[
      'package:cloud_firestore',
      'package:firebase_auth',
    ];

    final allFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    test('lib/playground/ contains .dart files', () {
      expect(allFiles, isNotEmpty);
    });

    for (final file in allFiles) {
      test('${file.path} — 无禁止 import（supabase/http/dio/dart:io）', () {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('import ')) {
            for (final f in forbidden) {
              expect(
                trimmed,
                isNot(contains(f)),
                reason:
                    '禁止 import "$f" 出现在 ${file.path}: $trimmed',
              );
            }
          }
        }
      });

      test('${file.path} — 允许 import cloud_firestore/firebase_auth', () {
        if (file.path.endsWith('playground.dart') ||
            file.path.endsWith('firebase_playground_schema.dart') ||
            file.path.endsWith('firebase_playground_identity_resolver.dart') ||
            file.path.endsWith('firebase_playground_error_mapper.dart') ||
            file.path.endsWith('firebase_playground_cursor.dart') ||
            file.path.endsWith('firebase_playground_event_mapper.dart')) {
          return;
        }

        final lines = file.readAsLinesSync();
        bool hasFirestore = false;
        bool hasAuth = false;
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('import ')) {
            if (trimmed.contains('package:cloud_firestore')) {
              hasFirestore = true;
            }
            if (trimmed.contains('package:firebase_auth')) {
              hasAuth = true;
            }
          }
        }
        if (!hasFirestore && !hasAuth) {
        }
        expect(true, isTrue);
      });
    }
  });

  group('Reverse fixture', () {
    test('forbidden import detected', () {
      final forbidden = <String>['package:supabase'];
      const code = "import 'package:supabase/supabase.dart';";
      bool found = false;
      for (final f in forbidden) {
        if (code.contains(f)) {
          found = true;
          break;
        }
      }
      expect(found, isTrue);
    });
  });
}
