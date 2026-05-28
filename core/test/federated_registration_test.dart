import 'package:test/test.dart';
// ignore: unused_import
import 'package:persistence_core/persistence_core.dart';

void main() {
  group('Federated Schema Registration (Task 4.2 Parity)', () {
    setUp(() {
      SchemaRegistry.instance.reset();
    });

    test('should allow multiple modules to register their unique tables', () {
      final registry = SchemaRegistry.instance;
      
      // Simulating xuan-ai registration
      registry.register(const DomainSchema(
        domain: 'ai_core',
        tables: ['t_ai_messages', 't_ai_personas'],
      ));
      
      // Simulating xuan-taiyishenshu registration
      registry.register(const DomainSchema(
        domain: 'taiyi',
        tables: ['t_taiyi_records'],
      ));
      
      expect(registry.schemas, hasLength(2));
      expect(
        registry.schemas.any((s) => s.domain == 'ai_core'), 
        isTrue
      );
    });

    test('Registry should return combined table list for the Hub', () {
      final registry = SchemaRegistry.instance;
      registry.register(const DomainSchema(domain: 'a', tables: ['t1']));
      registry.register(const DomainSchema(domain: 'b', tables: ['t2']));
      
      final allTables = registry.schemas.expand((s) => s.tables).toList();
      expect(allTables, containsAll(['t1', 't2']));
    });
  });
}
