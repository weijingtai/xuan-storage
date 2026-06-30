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
  Future<bool> softDeleteRecord(String uuid, {required String module}) async => false;

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
  late PersistenceDriftDatabase db;
  late DecisionLinksDao dao;
  late TestScopedRecordStore store;
  late ForkEngine engine;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    dao = db.decisionLinksDao;
    store = TestScopedRecordStore();
    engine = ForkEngine(dao, store);
  });
  tearDown(() async => await db.close());

  test('fork creates multiple child links from one source', () async {
    await store.saveRecord(_makeMeta(uuid: 'src'));
    await store.saveRecord(_makeMeta(uuid: 'child-a'));
    await store.saveRecord(_makeMeta(uuid: 'child-b'));

    await engine.fork('src', ['child-a', 'child-b']);

    final links = await dao.listBySource('src', 'test-scope');
    expect(links.length, equals(2));
    expect(links.every((l) => l.linkType == 'fork'), isTrue);
  });

  test('fork links share same session_id', () async {
    await store.saveRecord(_makeMeta(uuid: 'src'));
    await store.saveRecord(_makeMeta(uuid: 'child-a'));
    await store.saveRecord(_makeMeta(uuid: 'child-b'));

    final sessionId = await engine.fork('src', ['child-a', 'child-b']);

    expect(sessionId, isNotNull);
    final links = await dao.listBySession(sessionId!, 'test-scope');
    expect(links.length, equals(2));
    expect(links.every((l) => l.sessionId == sessionId), isTrue);
  });

  test('fork children are queryable via listByType with fork', () async {
    await store.saveRecord(_makeMeta(uuid: 'src'));
    await store.saveRecord(_makeMeta(uuid: 'child-a'));

    await engine.fork('src', ['child-a']);

    final forks = await dao.listByType('src', 'fork', 'test-scope');
    expect(forks.length, equals(1));
    expect(forks.first.linkType, equals('fork'));
  });

  test('fork source must exist and not be deleted', () async {
    await store.saveRecord(_makeMeta(uuid: 'deleted-src'));
    await store.softDeleteRecord('deleted-src', module: 'test');

    expect(
      () => engine.fork('deleted-src', ['child-a']),
      throwsA(isA<StateError>()),
    );
  });
}
