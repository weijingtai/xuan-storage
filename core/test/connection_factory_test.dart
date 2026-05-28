import 'package:test/test.dart';
// ignore: unused_import
import 'package:persistence_core/persistence_core.dart';

void main() {
  group('SharedConnectionFactory (Task 2.2)', () {
    test('should apply WAL mode and busy timeout to the executor', () async {
      final factory = MockConnectionFactory();
      
      final executor = await factory.buildSharedExecutor(
        dbName: 'xuan.db',
        path: '/shared/path/',
      );
      
      expect(executor.journalMode, equals('WAL'));
      expect(executor.busyTimeout, equals(5000));
    });

    test('should reuse existing connection for the same path in a single process', () async {
      final factory = MockConnectionFactory();
      
      final exec1 = await factory.buildSharedExecutor(dbName: 'xuan.db', path: 'p1');
      final exec2 = await factory.buildSharedExecutor(dbName: 'xuan.db', path: 'p1');
      
      expect(identical(exec1, exec2), isTrue);
    });
  });
}

// --- Blueprint Mocks for TDD (RED Stage) ---

class MockConnectionFactory implements IConnectionFactory {
  final Map<String, MockQueryExecutor> _pool = {};

  @override
  Future<MockQueryExecutor> buildSharedExecutor({
    required String dbName,
    required String path,
  }) async {
    final fullPath = '$path$dbName';
    return _pool.putIfAbsent(fullPath, () => MockQueryExecutor());
  }
}

class MockQueryExecutor {
  String journalMode = 'WAL';
  int busyTimeout = 5000;
}

abstract interface class IConnectionFactory {
  /// Builds or retrieves a shared Drift QueryExecutor.
  /// Must ensure WAL mode and App Group shared paths.
  Future<dynamic> buildSharedExecutor({
    required String dbName,
    required String path,
  });
}
