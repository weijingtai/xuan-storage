import 'package:test/test.dart';
import 'package:persistence_core/persistence_core.dart';

void main() {
  group('XuanStorageError Specialized Types', () {
    test('StorageError base should have code, message, and suggestion', () {
      final error = StorageError(
        code: 'storage.generic',
        message: 'A generic storage error',
        reason: 'Unknown cause',
        suggestion: 'Retry later',
      );

      expect(error.code, 'storage.generic');
      expect(error.toString(), contains('storage.generic'));
    });

    test('SyncConflictError should provide relevant suggestion', () {
      final error = SyncConflictError(
        serverVersion: {'v': 2},
        localVersion: {'v': 1},
      );

      expect(error.code, 'storage.sync_conflict');
      expect(error.suggestion, contains('手动合并'));
    });

    test('VaultAccessError should point to permission issues', () {
      final error = VaultAccessError(path: '/shared/xuan.db');

      expect(error.code, 'storage.vault_access_denied');
      expect(error.suggestion, contains('权限'));
    });
  });

  group('StorageResult Integration', () {
    test('StorageResult.failure should be type-safe with XuanError', () {
      final error = StorageError(
        code: 'test.fail',
        message: 'Fail',
        reason: 'Reason',
        suggestion: 'Fix it',
      );

      final result = StorageResult<String>.failure(error);

      expect(result.isFailure, isTrue);
      expect(result.error?.code, 'test.fail');
    });
  });
}
