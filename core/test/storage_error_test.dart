import 'package:test/test.dart';
// Note: Imports will fail as these classes don't exist yet.
// ignore: unused_import
import 'package:persistence_core/persistence_core.dart';

void main() {
  group('XuanStorageError Specialized Types', () {
    test('XuanStorageError base should have code, message, and suggestion', () {
      final error = MockStorageError(
        code: 'storage.generic',
        message: 'A generic storage error',
        reason: 'Unknown cause',
        suggestion: 'Retry later',
      );
      
      expect(error.code, 'storage.generic');
      expect(error.toString(), contains('storage.generic'));
    });

    test('SyncConflictError should provide relevant suggestion', () {
      final error = MockSyncConflictError(
        serverVersion: {'v': 2},
        localVersion: {'v': 1},
      );
      
      expect(error.code, 'storage.sync_conflict');
      expect(error.suggestion, contains('手动合并'));
    });

    test('VaultAccessError should point to permission issues', () {
      final error = MockVaultAccessError(path: '/shared/xuan.db');
      
      expect(error.code, 'storage.vault_access_denied');
      expect(error.suggestion, contains('权限'));
    });
  });

  group('StorageResult Integration', () {
    test('StorageResult.failure should be type-safe with XuanError', () {
      final error = MockStorageError(
        code: 'test.fail',
        message: 'Fail',
        reason: 'Reason',
        suggestion: 'Fix it',
      );
      
      // BluePrint for type-safe StorageResult
      final result = MockStorageResult<String>.failure(error);
      
      expect(result.isFailure, isTrue);
      expect(result.error?.code, 'test.fail');
    });
  });
}

// --- Blueprint Mocks (RED Stage) ---

abstract class XuanError {
  String get code;
  String get message;
  String get reason;
  String get suggestion;
}

class MockStorageError implements XuanError {
  @override
  final String code;
  @override
  final String message;
  @override
  final String reason;
  @override
  final String suggestion;

  MockStorageError({
    required this.code,
    required this.message,
    required this.reason,
    required this.suggestion,
  });

  @override
  String toString() => '[$code] $message';
}

class MockSyncConflictError extends MockStorageError {
  final Map<String, dynamic> serverVersion;
  final Map<String, dynamic> localVersion;

  MockSyncConflictError({
    required this.serverVersion,
    required this.localVersion,
  }) : super(
          code: 'storage.sync_conflict',
          message: 'Conflict detected during sync',
          reason: 'Remote version is newer than local version',
          suggestion: '请进行手动合并 (Manual Merge Required)',
        );
}

class MockVaultAccessError extends MockStorageError {
  final String path;

  MockVaultAccessError({required this.path})
      : super(
          code: 'storage.vault_access_denied',
          message: 'Cannot access shared vault at $path',
          reason: 'Missing platform permissions (App Groups or Shared Storage)',
          suggestion: '请检查应用权限设置',
        );
}

class MockStorageResult<T> {
  final T? data;
  final XuanError? error;

  MockStorageResult.success(this.data) : error = null;
  MockStorageResult.failure(this.error) : data = null;

  bool get isFailure => error != null;
}
