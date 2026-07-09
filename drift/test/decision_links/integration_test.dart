import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class TestScopedRecordStore implements ScopedRecordStore {
  @override
  final String scopeUid;
  final _records = <String, RecordMeta>{};

  TestScopedRecordStore({this.scopeUid = 'test-scope'});

  @override
  Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData}) async {
    _records[record.uuid] = record;
  }

  @override
  Future<RecordMeta?> getRecord(String uuid, {required String module}) async => _records[uuid];

  @override
  Future<List<RecordMeta>> listRecords({required String module, String? category, String? divinationType, required int limit, String? cursor}) async => [];

  @override
  Future<bool> softDeleteRecord(String uuid, {required String module}) async {
    final r = _records[uuid];
    if (r == null) return false;
    _records[uuid] = r.copyWith(deletedAt: DateTime.now());
    return true;
  }

  @override
  Stream<List<RecordMeta>> watchRecords({required String module}) => const Stream.empty();

  @override
  Future<List<RecordMeta>> findByIndex({required String module, required String indexKey, required String indexValue, required int limit}) async => [];

  @override
  Stream<List<RecordMeta>> watchByIndex({required String module, required String indexKey, required String indexValue}) => const Stream.empty();
}

RecordMeta _makeMeta({required String uuid, String scopeUid = 'test-scope'}) {
  return RecordMeta(
    uuid: uuid, scopeUid: scopeUid, module: 'test', category: 'divination',
    divinationType: 'test_type', createdAt: DateTime.now(),
  );
}

void main() {
  group('full scenario: create → fork → infer → merge → verify chain', () {
    test('end-to-end decision chain', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      final dao = db.decisionLinksDao;
      final store = TestScopedRecordStore();
      final inferenceEngine = InferenceEngine(dao, store);
      final forkEngine = ForkEngine(dao, store);
      final mergeEngine = MergeEngine(dao, store);
      final traverser = DecisionChainTraverser(dao);

      await store.saveRecord(_makeMeta(uuid: 'root'));
      await store.saveRecord(_makeMeta(uuid: 'fork-a'));
      await store.saveRecord(_makeMeta(uuid: 'fork-b'));
      await store.saveRecord(_makeMeta(uuid: 'inf-target'));
      await store.saveRecord(_makeMeta(uuid: 'merge-src'));
      await store.saveRecord(_makeMeta(uuid: 'merge-tgt'));

      // fork: root → [fork-a, fork-b]
      await forkEngine.fork('root', ['fork-a', 'fork-b']);
      // inference: fork-a → inf-target
      await inferenceEngine.inferLink(
        sourceUuid: 'fork-a', targetUuid: 'inf-target', intent: 'auto_infer',
        confidence: 0.85,
      );
      // merge: merge-src → merge-tgt
      await mergeEngine.mergeInto(['merge-src'], 'merge-tgt');

      // verify full chain from root
      final allLinks = await dao.listBySource('root', 'test-scope');
      expect(allLinks.length, equals(2)); // 2 fork links
      expect(allLinks.every((l) => l.linkType == 'fork'), isTrue);

      // verify inference link
      final infLinks = await traverser.getInferenceChain('inf-target', 'test-scope');
      expect(infLinks.length, equals(1));
      expect(infLinks.first.linkType, equals('inference'));

      // verify merge link
      final mergeSources = await traverser.getMergeSources('merge-tgt', 'test-scope');
      expect(mergeSources.length, equals(1));
      expect(mergeSources.first.linkType, equals('merge'));

      await db.close();
    });
  });

  group('scope A chain invisible in scope B', () {
    test('scope isolation works', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      final dao = db.decisionLinksDao;

      await dao.upsert(DecisionLinksCompanion.insert(
        id: 'scope-test-1', sourceUuid: 'src', targetUuid: 'tgt', intent: 'test',
        linkType: const Value('sequential'), scopeUid: 'scope-a',
        createdAtMs: 1000, updatedAtMs: 1000,
      ));

      final inA = await dao.listBySource('src', 'scope-a');
      expect(inA.length, equals(1));

      final inB = await dao.listBySource('src', 'scope-b');
      expect(inB, isEmpty);

      await db.close();
    });
  });

  group('session undo removes all links atomically', () {
    test('atomic undo with inference engine', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      final dao = db.decisionLinksDao;
      final store = TestScopedRecordStore();
      final inferenceEngine = InferenceEngine(dao, store);

      await store.saveRecord(_makeMeta(uuid: 'src-a'));
      await store.saveRecord(_makeMeta(uuid: 'src-b'));
      await store.saveRecord(_makeMeta(uuid: 'tgt'));

      final sessionId = 'integration-undo-session';
      await inferenceEngine.inferLink(
        sourceUuid: 'src-a', targetUuid: 'tgt', intent: 'a',
        sessionId: sessionId,
      );
      await inferenceEngine.inferLink(
        sourceUuid: 'src-b', targetUuid: 'tgt', intent: 'b',
        sessionId: sessionId,
      );

      expect(await dao.listBySession(sessionId, 'test-scope'), hasLength(2));
      await inferenceEngine.undoSession(sessionId);
      expect(await dao.listBySession(sessionId, 'test-scope'), isEmpty);

      await db.close();
    });
  });

  group('ambiguity downgrade preserves chain but marks ambiguous', () {
    test('low confidence creates ambiguous link in traverser output', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      final dao = db.decisionLinksDao;
      final store = TestScopedRecordStore();
      final inferenceEngine = InferenceEngine(dao, store);
      final traverser = DecisionChainTraverser(dao);

      await store.saveRecord(_makeMeta(uuid: 'src'));
      await store.saveRecord(_makeMeta(uuid: 'tgt'));

      await inferenceEngine.inferLink(
        sourceUuid: 'src', targetUuid: 'tgt', intent: 'ambiguous',
        confidence: 0.3,
      );

      final chain = await traverser.getInferenceChain('tgt', 'test-scope');
      expect(chain.length, equals(1));
      expect(chain.first.linkType, equals('inference_ambiguous'));

      await db.close();
    });
  });
}
