import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

List<String> scanFilesForAny(List<String> paths, List<String> needles) {
  final List<String> matchedFiles = [];
  for (final path in paths) {
    final entity = File(path);
    if (entity.existsSync()) {
      final content = entity.readAsStringSync();
      for (final needle in needles) {
        if (content.contains(needle)) {
          matchedFiles.add(path);
          break;
        }
      }
    } else {
      final dir = Directory(path);
      if (dir.existsSync()) {
        final list = dir.listSync(recursive: true);
        for (final item in list) {
          if (item is File && item.path.endsWith('.dart')) {
            final content = item.readAsStringSync();
            for (final needle in needles) {
              if (content.contains(needle)) {
                matchedFiles.add(item.path);
                break;
              }
            }
          }
        }
      }
    }
  }
  return matchedFiles;
}

void main() {
  test('xuan-account/lib/auth or xuan-storage/firebase/lib still contains identity_map/baasUid/appUserId resolver evidence until separate migration', () {
    final matches = scanFilesForAny([
      '../../xuan-account/lib/auth',
      '../firebase/lib',
    ], [
      'identity_map',
      'appUserId',
    ]);
    expect(matches, isNotEmpty, reason: 'Must contain resolver evidence in xuan-account or firebase persistence');
  });

  test('Drift identity-link implementation does not name identity_map as its table for anonymous->registered links', () {
    final files = scanFilesForAny(['lib/account'], ['tableName']);
    final incorrectFiles = <String>[];
    for (final file in files) {
      final content = File(file).readAsStringSync();
      if (content.contains("tableName => 'identity_map'") ||
          content.contains('tableName => "identity_map"') ||
          content.contains("tableName = 'identity_map'") ||
          content.contains('tableName = "identity_map"')) {
        incorrectFiles.add(file);
      }
    }
    expect(incorrectFiles, isEmpty, reason: 'Drift table should not be named identity_map');
  });

  test('Reverse fixture that maps providerUid directly into registeredAppUserId is detected as invalid', () {
    bool isReverseFixtureInvalid(String registeredId) {
      if (registeredId.startsWith('provider-') || registeredId.contains('uid') || registeredId.contains('firebase')) {
        return true;
      }
      return false;
    }
    expect(isReverseFixtureInvalid('firebase-uid-123'), isTrue);
    expect(isReverseFixtureInvalid('user-123'), isFalse);
  });
}
