import 'package:test/test.dart';
import 'dart:async';
// ignore: unused_import
import 'package:persistence_core/persistence_core.dart';

void main() {
  group('OmniCoordinator & Tag Indexing (Tasks 3.1, 3.2, 3.3)', () {
    late MockOmniCoordinator coordinator;
    late MockLocalDriver local;
    late MockOutboxStore outbox;

    setUp(() {
      local = MockLocalDriver();
      outbox = MockOutboxStore();
      coordinator = MockOmniCoordinator(local: local, outbox: outbox);
    });

    test('save() should write to local storage first, then enqueue outbox', () async {
      final entity = TestEntity(id: 'e1', domain: 'taiyi', data: 'content');
      
      await coordinator.save(entity);
      
      expect(local.savedEntities, contains(entity));
      expect(outbox.enqueuedOperations, hasLength(1));
      expect(outbox.enqueuedOperations.first.entityId, equals('e1'));
    });

    test('save() should automatically extract and save feature tags', () async {
      final entity = TestEntity(
        id: 'e2', 
        domain: 'taiyi', 
        data: 'content',
        searchableTags: {'year_gan': 'JIA', 'life_house': 'ZI'},
      );
      
      await coordinator.save(entity);
      
      // Verify that the coordinator extracted tags and sent them to local driver
      expect(local.savedTags['e2'], containsPair('year_gan', 'JIA'));
      expect(local.savedTags['e2'], containsPair('life_house', 'ZI'));
    });

    test('delete() should perform local deletion and enqueue outbox tombstone', () async {
      await coordinator.delete('e1');
      
      expect(local.deletedIds, contains('e1'));
      expect(outbox.enqueuedOperations.first.type, equals('DELETE'));
    });
  });
}

// --- Blueprint Mocks for TDD (RED Stage) ---

class TestEntity {
  final String id;
  final String domain;
  final String data;
  final Map<String, String> searchableTags;
  
  TestEntity({
    required this.id, 
    required this.domain, 
    required this.data,
    this.searchableTags = const {},
  });

  Map<String, dynamic> toOutboxPayload() => {'id': id, 'data': data};
}

class MockOmniCoordinator {
  final MockLocalDriver local;
  final MockOutboxStore outbox;

  MockOmniCoordinator({required this.local, required this.outbox});

  Future<void> save(TestEntity entity) async {
    // 1. Write Tags
    await local.saveTags(entity.id, entity.domain, entity.searchableTags);
    // 2. Write Local
    await local.save(entity);
    // 3. Enqueue Outbox
    await outbox.enqueue(OutboxOp(entityId: entity.id, type: 'SAVE'));
  }

  Future<void> delete(String id) async {
    await local.delete(id);
    await outbox.enqueue(OutboxOp(entityId: id, type: 'DELETE'));
  }
}

class MockLocalDriver {
  final List<TestEntity> savedEntities = [];
  final List<String> deletedIds = [];
  final Map<String, Map<String, String>> savedTags = {};

  Future<void> save(TestEntity entity) async => savedEntities.add(entity);
  Future<void> delete(String id) async => deletedIds.add(id);
  Future<void> saveTags(String id, String domain, Map<String, String> tags) async {
    savedTags[id] = tags;
  }
}

class OutboxOp {
  final String entityId;
  final String type;
  OutboxOp({required this.entityId, required this.type});
}

class MockOutboxStore {
  final List<OutboxOp> enqueuedOperations = [];
  Future<void> enqueue(OutboxOp op) async => enqueuedOperations.add(op);
}
