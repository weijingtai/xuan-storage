import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  late PersistenceDriftDatabase db;
  late DecisionLinksDao dao;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    dao = db.decisionLinksDao;
  });
  tearDown(() async => await db.close());

  group('listByTarget', () {
    test('returns links pointing to target', () async {
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-t1',
        sourceUuid: 'src-a',
        targetUuid: 'tgt-x',
        intent: 'link1',
        linkType: const Value('sequential'),
        createdAtMs: 1000,
        updatedAtMs: 1000,
        scopeUid: 'scope',
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-t2',
        sourceUuid: 'src-b',
        targetUuid: 'tgt-x',
        intent: 'link2',
        linkType: const Value('fork'),
        createdAtMs: 2000,
        updatedAtMs: 2000,
        scopeUid: 'scope',
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-t3',
        sourceUuid: 'src-c',
        targetUuid: 'tgt-y',
        intent: 'other',
        linkType: const Value('sequential'),
        createdAtMs: 3000,
        updatedAtMs: 3000,
        scopeUid: 'scope',
      ));

      final links = await dao.listByTarget('tgt-x', 'scope');
      expect(links.length, equals(2));
      expect(links.every((l) => l.targetUuid == 'tgt-x'), isTrue);
    });
  });

  group('listBySession', () {
    test('groups links by session_id', () async {
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-s1',
        sourceUuid: 'src-a',
        targetUuid: 'tgt-x',
        intent: 'inf1',
        linkType: const Value('inference'),
        sessionId: const Value('session-1'),
        createdAtMs: 1000,
        updatedAtMs: 1000,
        scopeUid: 'scope',
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-s2',
        sourceUuid: 'src-b',
        targetUuid: 'tgt-y',
        intent: 'inf2',
        linkType: const Value('inference'),
        sessionId: const Value('session-1'),
        createdAtMs: 2000,
        updatedAtMs: 2000,
        scopeUid: 'scope',
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-s3',
        sourceUuid: 'src-c',
        targetUuid: 'tgt-z',
        intent: 'other',
        linkType: const Value('sequential'),
        sessionId: const Value('session-2'),
        createdAtMs: 3000,
        updatedAtMs: 3000,
        scopeUid: 'scope',
      ));

      final links = await dao.listBySession('session-1', 'scope');
      expect(links.length, equals(2));
      expect(links.every((l) => l.sessionId == 'session-1'), isTrue);
    });
  });

  group('listForks', () {
    test('returns only fork-type links from source', () async {
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-f1',
        sourceUuid: 'src-a',
        targetUuid: 'fork-1',
        intent: 'branch1',
        linkType: const Value('fork'),
        createdAtMs: 1000,
        updatedAtMs: 1000,
        scopeUid: 'scope',
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-f2',
        sourceUuid: 'src-a',
        targetUuid: 'fork-2',
        intent: 'branch2',
        linkType: const Value('fork'),
        createdAtMs: 2000,
        updatedAtMs: 2000,
        scopeUid: 'scope',
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-f3',
        sourceUuid: 'src-a',
        targetUuid: 'seq-1',
        intent: 'normal',
        linkType: const Value('sequential'),
        createdAtMs: 3000,
        updatedAtMs: 3000,
        scopeUid: 'scope',
      ));

      final forks = await dao.listByType('src-a', 'fork', 'scope');
      expect(forks.length, equals(2));
      expect(forks.every((l) => l.linkType == 'fork'), isTrue);
    });
  });

  group('deleteBySession', () {
    test('removes all links of a session', () async {
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-d1',
        sourceUuid: 'src-a',
        targetUuid: 'tgt-x',
        intent: 'del1',
        linkType: const Value('inference'),
        sessionId: const Value('session-undo'),
        createdAtMs: 1000,
        updatedAtMs: 1000,
        scopeUid: 'scope',
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-d2',
        sourceUuid: 'src-b',
        targetUuid: 'tgt-y',
        intent: 'del2',
        linkType: const Value('inference'),
        sessionId: const Value('session-undo'),
        createdAtMs: 2000,
        updatedAtMs: 2000,
        scopeUid: 'scope',
      ));

      final deleted = await dao.deleteBySession('session-undo', 'scope');
      expect(deleted, equals(2));

      final remaining = await dao.listBySession('session-undo', 'scope');
      expect(remaining, isEmpty);
    });
  });

  group('getMergeChain', () {
    test('traverses merge links recursively', () async {
      // chain: src-a → merge1 → merge2 → merge3
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-m1',
        sourceUuid: 'src-a',
        targetUuid: 'merge1',
        intent: 'merge_step',
        linkType: const Value('merge'),
        mergeTargetUuid: const Value('merge1'),
        createdAtMs: 1000,
        updatedAtMs: 1000,
        scopeUid: 'scope',
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-m2',
        sourceUuid: 'merge1',
        targetUuid: 'merge2',
        intent: 'merge_step',
        linkType: const Value('merge'),
        mergeTargetUuid: const Value('merge2'),
        createdAtMs: 2000,
        updatedAtMs: 2000,
        scopeUid: 'scope',
      ));
      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'dl-m3',
        sourceUuid: 'merge2',
        targetUuid: 'merge3',
        intent: 'merge_step',
        linkType: const Value('merge'),
        mergeTargetUuid: const Value('merge3'),
        createdAtMs: 3000,
        updatedAtMs: 3000,
        scopeUid: 'scope',
      ));

      final chain = await dao.getMergeChain('src-a', 'scope');
      expect(chain.length, equals(3));
      expect(chain[0].id, equals('dl-m1'));
      expect(chain[2].id, equals('dl-m3'));
    });
  });
}
