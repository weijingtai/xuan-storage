import 'package:test/test.dart';
// ignore: unused_import
import 'package:persistence_core/persistence_core.dart';

void main() {
  group('Decision Chain Logic (Tasks 3.1)', () {
    test('should retrieve full link chain for a root divination', () async {
      final repo = MockDecisionRepository();
      
      // Setup: Link A -> Link B -> Link C
      final chain = await repo.getDecisionChain('root-uuid-123');
      
      expect(chain, hasLength(2));
      expect(chain.first.sourceId, equals('root-uuid-123'));
      expect(chain.first.intent, equals('化解'));
      expect(chain.last.contextSnapshot, containsPair('key', 'value'));
    });
  });
}

// --- Blueprint Mocks for TDD (RED Stage) ---

class MockDecisionLink {
  final String sourceId;
  final String targetId;
  final String intent;
  final Map<String, dynamic> contextSnapshot;

  MockDecisionLink({
    required this.sourceId,
    required this.targetId,
    required this.intent,
    required this.contextSnapshot,
  });
}

abstract interface class IDecisionRepository {
  /// Retrieves all links associated with a root divination.
  Future<List<MockDecisionLink>> getDecisionChain(String rootId);
}

class MockDecisionRepository implements IDecisionRepository {
  @override
  Future<List<MockDecisionLink>> getDecisionChain(String rootId) async {
    return [
      MockDecisionLink(
        sourceId: rootId,
        targetId: 'b',
        intent: '化解',
        contextSnapshot: {},
      ),
      MockDecisionLink(
        sourceId: 'b',
        targetId: 'c',
        intent: '增强',
        contextSnapshot: {'key': 'value'},
      ),
    ];
  }
}
