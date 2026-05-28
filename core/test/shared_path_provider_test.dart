import 'package:test/test.dart';
// Note: This import will fail until ISharedPathProvider is added to persistence_core.
// ignore: unused_import
import 'package:persistence_core/persistence_core.dart';

void main() {
  group('SharedPathProvider (Task 2.1)', () {
    test('should resolve database path with group ID for iOS App Groups parity', () async {
      final provider = MockSharedPathProvider(groupId: 'group.com.xuan.vault');
      
      final path = await provider.getDatabasePath('xuan.db');
      
      // Assertion: The path must include the group identifier to ensure physical sharing.
      expect(path, contains('group.com.xuan.vault'));
      expect(path, endsWith('xuan.db'));
    });

    test('should fallback to standard local storage if no group ID is provided', () async {
      final provider = MockSharedPathProvider(groupId: null);
      
      final path = await provider.getDatabasePath('xuan.db');
      
      expect(path, isNot(contains('group.')));
      expect(path, contains('app_data'));
    });
  });
}

// --- Blueprint Mocks for TDD (RED Stage) ---

/// Mock implementation to define the desired behavior for Task 2.1.
class MockSharedPathProvider implements ISharedPathProvider {
  final String? groupId;
  MockSharedPathProvider({this.groupId});

  @override
  Future<String> getDatabasePath(String dbName) async {
    if (groupId != null) {
      return '/platforms/ios/groups/$groupId/$dbName';
    }
    return '/platforms/generic/app_data/$dbName';
  }
}

/// The Interface that needs to be implemented in core ports.
abstract interface class ISharedPathProvider {
  /// Resolves the absolute physical path for a shared database.
  /// 
  /// Must handle platform-specific logic:
  /// - iOS: App Groups (containerURLForSecurityApplicationGroupIdentifier)
  /// - Android: External/Internal shared storage partitions.
  Future<String> getDatabasePath(String dbName);
}
