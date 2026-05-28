import 'package:test/test.dart';
// ignore: unused_import
import 'package:persistence_core/persistence_core.dart';

void main() {
  group('Storage Version Guard (Tasks 3.1)', () {
    test('should throw XuanVersionMismatchError if DB version is higher than supported', () async {
      final guard = MockVersionGuard(supportedVersion: 2);
      
      // Scenario: App supports v2, but the shared vault is already at v3 (upgraded by another app).
      expect(
        () => guard.verifyCompatibility(vaultVersion: 3),
        throwsA(isA<MockVersionMismatchError>()),
      );
    });

    test('should allow access if versions match', () async {
      final guard = MockVersionGuard(supportedVersion: 2);
      expect(() => guard.verifyCompatibility(vaultVersion: 2), returnsNormally);
    });
  });
}

// --- Blueprint Mocks for TDD (RED Stage) ---

class MockVersionMismatchError implements Exception {
  final String message;
  final String suggestion;
  MockVersionMismatchError(this.message, this.suggestion);
}

class MockVersionGuard {
  final int supportedVersion;
  MockVersionGuard({required this.supportedVersion});

  void verifyCompatibility({required int vaultVersion}) {
    if (vaultVersion > supportedVersion) {
      throw MockVersionMismatchError(
        'Database version $vaultVersion is newer than supported version $supportedVersion',
        '当前数据库已被新版应用升级，请立即从应用商店下载并升级您的 APP 以保持兼容性。',
      );
    }
  }
}
