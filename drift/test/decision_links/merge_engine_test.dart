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
  late PersistenceDriftDatabase db;
  late DecisionLinksDao dao;
  late TestScopedRecordStore store;
  late MergeEngine engine;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    dao = db.decisionLinksDao;
    store = TestScopedRecordStore();
    engine = MergeEngine(dao, store);
  });
  tearDown(() async => await db.close());

  test('mergeInto creates merge links from sources to target', () async {
    await store.saveRecord(_makeMeta(uuid: 'src-a'));
    await store.saveRecord(_makeMeta(uuid: 'src-b'));
    await store.saveRecord(_makeMeta(uuid: 'tgt-x'));

    await engine.mergeInto(['src-a', 'src-b'], 'tgt-x');

    final linksToTgt = await dao.listByTarget('tgt-x', 'test-scope');
    expect(linksToTgt.length, equals(2));

    final srcALinks = await dao.listBySource('src-a', 'test-scope');
    expect(srcALinks.length, equals(1));
    expect(srcALinks.first.linkType, equals('merge'));
    expect(srcALinks.first.mergeTargetUuid, equals('tgt-x'));
  });

  test('source records are NOT modified after merge', () async {
    final src = _makeMeta(uuid: 'src-a', scopeUid: 'test-scope');
    await store.saveRecord(src);
    await store.saveRecord(_makeMeta(uuid: 'tgt-x'));

    final moduleDataBefore = src.moduleDataJson;
    await engine.mergeInto(['src-a'], 'tgt-x');

    final after = await store.getRecord('src-a', module: 'test');
    expect(after?.moduleDataJson, equals(moduleDataBefore));
  });

  test('merge sources must exist and not be deleted', () async {
    await store.saveRecord(_makeMeta(uuid: 'deleted-src'));
    await store.softDeleteRecord('deleted-src', module: 'test');
    await store.saveRecord(_makeMeta(uuid: 'tgt'));

    expect(
      () => engine.mergeInto(['deleted-src'], 'tgt'),
      throwsA(isA<StateError>()),
    );
  });
}
