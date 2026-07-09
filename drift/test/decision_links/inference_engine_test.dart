import 'dart:async';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

/// Test-only ScopedRecordStore backed by in-memory maps.
class TestScopedRecordStore implements ScopedRecordStore {
  @override
  final String scopeUid;
  final _records = <String, RecordMeta>{};
  final _ctrl = StreamController<List<RecordMeta>>.broadcast();

  TestScopedRecordStore({this.scopeUid = 'test-scope'});

  @override
  Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData}) async {
    _records[record.uuid] = record;
    _ctrl.add(_records.values.toList());
  }

  @override
  Future<RecordMeta?> getRecord(String uuid, {required String module}) async {
    return _records[uuid];
  }

  @override
  Future<List<RecordMeta>> listRecords({
    required String module,
    String? category,
    String? divinationType,
    required int limit,
    String? cursor,
  }) async {
    return _records.values
        .where((r) => r.deletedAt == null)
        .take(limit)
        .toList();
  }

  @override
  Future<bool> softDeleteRecord(String uuid, {required String module}) async {
    final r = _records[uuid];
    if (r == null) return false;
    _records[uuid] = r.copyWith(deletedAt: DateTime.now());
    _ctrl.add(_records.values.toList());
    return true;
  }

  @override
  Stream<List<RecordMeta>> watchRecords({required String module}) =>
      _ctrl.stream;

  @override
  Future<List<RecordMeta>> findByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
    required int limit,
  }) async =>
      [];

  @override
  Stream<List<RecordMeta>> watchByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
  }) =>
      const Stream.empty();
}

RecordMeta _makeMeta({
  required String uuid,
  String scopeUid = 'test-scope',
  DateTime? deletedAt,
}) {
  return RecordMeta(
    uuid: uuid,
    scopeUid: scopeUid,
    module: 'test',
    category: 'divination',
    divinationType: 'test_type',
    createdAt: DateTime.now(),
    deletedAt: deletedAt,
  );
}

void main() {
  late PersistenceDriftDatabase db;
  late DecisionLinksDao dao;
  late TestScopedRecordStore store;
  late InferenceEngine engine;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    dao = db.decisionLinksDao;
    store = TestScopedRecordStore();
    engine = InferenceEngine(dao, store);
  });
  tearDown(() async => await db.close());

  group('hard gate: 永不修改已有记录', () {
    test('inference does not modify existing records', () async {
      final record = _makeMeta(uuid: 'src-uuid');
      await store.saveRecord(record);
      await store.saveRecord(_makeMeta(uuid: 'tgt-uuid'));

      await engine.inferLink(
        sourceUuid: 'src-uuid',
        targetUuid: 'tgt-uuid',
        intent: 'test_inference',
      );

      final after = await store.getRecord('src-uuid', module: '');
      expect(after?.moduleDataJson, isNull);
    });
  });

  group('hard gate: inference_session_id 原子 undo', () {
    test('atomic undo removes all links of a session', () async {
      await store.saveRecord(_makeMeta(uuid: 'src-a'));
      await store.saveRecord(_makeMeta(uuid: 'src-b'));
      await store.saveRecord(_makeMeta(uuid: 'tgt'));

      final sessionId = 'test-session-undo';
      await engine.inferLink(
        sourceUuid: 'src-a', targetUuid: 'tgt', intent: 'inf1',
        sessionId: sessionId,
      );
      await engine.inferLink(
        sourceUuid: 'src-b', targetUuid: 'tgt', intent: 'inf2',
        sessionId: sessionId,
      );

      final beforeUndo = await dao.listBySession(sessionId, 'test-scope');
      expect(beforeUndo.length, equals(2));

      final deleted = await engine.undoSession(sessionId);
      expect(deleted, equals(2));

      final afterUndo = await dao.listBySession(sessionId, 'test-scope');
      expect(afterUndo, isEmpty);
    });
  });

  group('hard gate: 歧义降级人工', () {
    test('low confidence creates inference_ambiguous link', () async {
      await store.saveRecord(_makeMeta(uuid: 'src-uuid'));
      await store.saveRecord(_makeMeta(uuid: 'tgt-uuid'));

      await engine.inferLink(
        sourceUuid: 'src-uuid',
        targetUuid: 'tgt-uuid',
        intent: 'ambiguous_test',
        confidence: 0.5,
      );

      final links = await dao.listBySource('src-uuid', 'test-scope');
      expect(links.length, equals(1));
      expect(links.first.linkType, equals('inference_ambiguous'));
    });

    test('high confidence creates inference link', () async {
      await store.saveRecord(_makeMeta(uuid: 'src-uuid'));
      await store.saveRecord(_makeMeta(uuid: 'tgt-uuid'));

      await engine.inferLink(
        sourceUuid: 'src-uuid',
        targetUuid: 'tgt-uuid',
        intent: 'confident_test',
        confidence: 0.9,
      );

      final links = await dao.listBySource('src-uuid', 'test-scope');
      expect(links.length, equals(1));
      expect(links.first.linkType, equals('inference'));
    });
  });

  group('hard gate: scope_uid 隔离 + 空 scope 一票否决', () {
    test('empty scopeUid throws AssertionError', () async {
      final emptyStore = TestScopedRecordStore(scopeUid: '');
      final emptyEngine = InferenceEngine(dao, emptyStore);

      expect(
        () => emptyEngine.inferLink(
          sourceUuid: 'src-uuid',
          targetUuid: 'tgt-uuid',
          intent: 'no_scope',
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('hard gate: 入口推断强兜底', () {
    test('deleted source record throws StateError', () async {
      await store.saveRecord(_makeMeta(
        uuid: 'deleted-src',
        deletedAt: DateTime.now(),
      ));
      await store.saveRecord(_makeMeta(uuid: 'tgt-uuid'));

      expect(
        () => engine.inferLink(
          sourceUuid: 'deleted-src',
          targetUuid: 'tgt-uuid',
          intent: 'on_deleted',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('scope mismatch throws StateError', () async {
      final otherScope = _makeMeta(uuid: 'other-src', scopeUid: 'other-scope');
      await store.saveRecord(otherScope);
      await store.saveRecord(_makeMeta(uuid: 'tgt-uuid'));

      expect(
        () => engine.inferLink(
          sourceUuid: 'other-src',
          targetUuid: 'tgt-uuid',
          intent: 'scope_mismatch',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
