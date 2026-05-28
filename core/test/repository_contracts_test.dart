import 'package:test/test.dart';
import 'package:persistence_core/persistence_core.dart';

void main() {
  setUp(() {
    SchemaRegistry.instance.reset();
  });

  group('SchemaRegistry (Registration Hub)', () {
    test('should register and list domain schemas', () {
      final registry = SchemaRegistry.instance;
      const testSchema = DomainSchema(domain: 'taiyi', tables: ['t_taiyi_records']);
      
      registry.register(testSchema);
      
      expect(registry.schemas, contains(testSchema));
    });

    test('should prevent duplicate domain registration', () {
      final registry = SchemaRegistry.instance;
      const testSchema = DomainSchema(domain: 'duplicate', tables: []);
      
      registry.register(testSchema);
      
      expect(() => registry.register(testSchema), throwsA(isA<ArgumentError>()));
    });
  });

  group('IRepository (Generic Contract)', () {
    test('should define standard async CRUD methods returning StorageResult', () async {
      final IRepository<TestEntity> repo = MockRepository();
      
      final result = await repo.getById('123');
      
      expect(result, isA<StorageResult<TestEntity>>());
      expect(result.isSuccess, isTrue);
    });
  });
}

// Actual implementation for testing the contract
class TestEntity {}

class MockRepository implements IRepository<TestEntity> {
  @override
  Future<StorageResult<TestEntity>> getById(String id) async {
    return StorageResult.success(TestEntity());
  }

  @override
  Future<StorageResult<void>> save(TestEntity entity) async {
    return const StorageResult.success(null);
  }

  @override
  Future<StorageResult<void>> delete(String id) async {
     return const StorageResult.success(null);
  }

  @override
  Stream<StorageResult<List<TestEntity>>> watch({int? limit, int? offset, dynamic filter}) {
    return Stream.value(StorageResult.success([]));
  }
}
