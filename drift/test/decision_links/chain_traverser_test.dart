import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  late PersistenceDriftDatabase db;
  late DecisionLinksDao dao;
  late DecisionChainTraverser traverser;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    dao = db.decisionLinksDao;
    traverser = DecisionChainTraverser(dao);
  });
  tearDown(() async => await db.close());

  group('getFullChain', () {
    test('returns all downstream links in BFS order', () async {
      // root → a → b → c (链式)
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'l1', sourceUuid: 'root', targetUuid: 'a', intent: 'step1',
        linkType: const Value('sequential'), scopeUid: 'scope',
        createdAtMs: 1000, updatedAtMs: 1000,
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'l2', sourceUuid: 'a', targetUuid: 'b', intent: 'step2',
        linkType: const Value('sequential'), scopeUid: 'scope',
        createdAtMs: 2000, updatedAtMs: 2000,
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'l3', sourceUuid: 'b', targetUuid: 'c', intent: 'step3',
        linkType: const Value('sequential'), scopeUid: 'scope',
        createdAtMs: 3000, updatedAtMs: 3000,
      ));

      final chain = await traverser.getFullChain('root', 'scope');
      expect(chain.length, equals(3));
      expect(chain[0].id, equals('l1'));
      expect(chain[2].id, equals('l3'));
    });
  });

  group('getForks', () {
    test('returns only fork links from source', () async {
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'f1', sourceUuid: 'src', targetUuid: 'a', intent: 'fork1',
        linkType: const Value('fork'), scopeUid: 'scope',
        createdAtMs: 1000, updatedAtMs: 1000,
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'f2', sourceUuid: 'src', targetUuid: 'b', intent: 'fork2',
        linkType: const Value('fork'), scopeUid: 'scope',
        createdAtMs: 2000, updatedAtMs: 2000,
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'f3', sourceUuid: 'src', targetUuid: 'c', intent: 'seq',
        linkType: const Value('sequential'), scopeUid: 'scope',
        createdAtMs: 3000, updatedAtMs: 3000,
      ));

      final forks = await traverser.getForks('src', 'scope');
      expect(forks.length, equals(2));
      expect(forks.every((l) => l.linkType == 'fork'), isTrue);
    });
  });

  group('getMergeSources', () {
    test('returns merge links pointing to target', () async {
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'm1', sourceUuid: 'a', targetUuid: 'tgt', intent: 'merge1',
        linkType: const Value('merge'), mergeTargetUuid: const Value('tgt'),
        scopeUid: 'scope', createdAtMs: 1000, updatedAtMs: 1000,
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'm2', sourceUuid: 'b', targetUuid: 'tgt', intent: 'merge2',
        linkType: const Value('merge'), mergeTargetUuid: const Value('tgt'),
        scopeUid: 'scope', createdAtMs: 2000, updatedAtMs: 2000,
      ));

      final sources = await traverser.getMergeSources('tgt', 'scope');
      expect(sources.length, equals(2));
      expect(sources.every((l) => l.linkType == 'merge'), isTrue);
    });
  });

  group('getInferenceChain', () {
    test('returns inference links pointing to target', () async {
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'i1', sourceUuid: 'a', targetUuid: 'tgt', intent: 'inf',
        linkType: const Value('inference'), scopeUid: 'scope',
        createdAtMs: 1000, updatedAtMs: 1000,
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'i2', sourceUuid: 'b', targetUuid: 'tgt', intent: 'ambig',
        linkType: const Value('inference_ambiguous'), scopeUid: 'scope',
        createdAtMs: 2000, updatedAtMs: 2000,
      ));

      final infs = await traverser.getInferenceChain('tgt', 'scope');
      expect(infs.length, equals(2));
    });
  });

  group('cycle detection', () {
    test('prevents infinite loops', () async {
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'c1', sourceUuid: 'a', targetUuid: 'b', intent: 'step',
        linkType: const Value('sequential'), scopeUid: 'scope',
        createdAtMs: 1000, updatedAtMs: 1000,
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'c2', sourceUuid: 'b', targetUuid: 'a', intent: 'loop',
        linkType: const Value('sequential'), scopeUid: 'scope',
        createdAtMs: 2000, updatedAtMs: 2000,
      ));

      final chain = await traverser.getFullChain('a', 'scope');
      // BFS: a→b added, then b→a added, then 'a' already visited → stop
      // No infinite loop, returns 2 links correctly
      expect(chain.length, equals(2));
    });
  });
}
