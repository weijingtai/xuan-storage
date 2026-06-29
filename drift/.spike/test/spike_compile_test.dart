import 'package:test/test.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:spike_typed_record_base/spike_typed_record_base.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';

class FakeScopedRecordStore implements ScopedRecordStore {
  @override
  final String scopeUid;
  final List<RecordMeta> _records = [];

  FakeScopedRecordStore({this.scopeUid = 'spike-scope'});

  @override
  Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData}) async {
    _records.removeWhere((r) => r.uuid == record.uuid);
    _records.add(record);
  }

  @override
  Future<RecordMeta?> getRecord(String uuid, {required String module}) async {
    try {
      return _records.firstWhere(
        (r) => r.uuid == uuid && r.module == module && r.deletedAt == null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RecordMeta>> listRecords({
    required String module,
    String? category,
    String? divinationType,
    required int limit,
    String? cursor,
  }) async {
    var result = _records
        .where((r) => r.module == module && r.deletedAt == null)
        .toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (cursor != null) {
      final idx = result.indexWhere((r) => r.uuid == cursor);
      if (idx >= 0) result = result.sublist(idx + 1);
    }
    return result.take(limit).toList();
  }

  @override
  Stream<List<RecordMeta>> watchRecords({required String module}) {
    return Stream.value(_records
        .where((r) => r.module == module && r.deletedAt == null)
        .toList());
  }

  @override
  Future<bool> softDeleteRecord(String uuid, {required String module}) async {
    final idx = _records.indexWhere((r) => r.uuid == uuid && r.module == module);
    if (idx < 0) return false;
    _records[idx] = RecordMeta(
      uuid: _records[idx].uuid,
      scopeUid: _records[idx].scopeUid,
      module: _records[idx].module,
      category: _records[idx].category,
      divinationType: _records[idx].divinationType,
      createdAt: _records[idx].createdAt,
      updatedAt: _records[idx].updatedAt,
      deletedAt: DateTime.now(),
      question: _records[idx].question,
      moduleDataJson: _records[idx].moduleDataJson,
    );
    return true;
  }

  @override
  Future<List<RecordMeta>> findByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
    required int limit,
  }) async {
    return [];
  }

  @override
  Stream<List<RecordMeta>> watchByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
  }) {
    return Stream.value([]);
  }
}

class _MeiHuaRepo extends BaseRecordBackedRepository<MeiHuaDivinationRecordContract>
    implements MeiHuaDivinationRecordRepository {
  _MeiHuaRepo({required super.store, required super.codec});

  @override
  Future<String> saveRecord(MeiHuaDivinationRecordContract record) => save(record);
  @override
  Future<List<MeiHuaDivinationRecordContract>> getAllRecords() => getAll();
  @override
  Stream<List<MeiHuaDivinationRecordContract>> watchAllRecords() => watchAll();
  @override
  Future<MeiHuaDivinationRecordContract?> getRecordByUuid(String uuid) => getByUuid(uuid);
  @override
  Future<MeiHuaDivinationRecordContract?> getRecordByDivinationUuid(String duid) =>
      getFirstByIndex('divination_uuid', duid);
  @override
  Stream<MeiHuaDivinationRecordContract?> watchRecordByDivinationUuid(String duid) =>
      watchFirstByIndex('divination_uuid', duid);
  @override
  Future<bool> softDeleteRecord(String uuid) => softDelete(uuid);
}

class _LiuYaoRepo extends BaseRecordBackedRepository<SixYaoDivinationRecord>
    implements SixYaoDivinationRecordRepository {
  _LiuYaoRepo({required super.store, required super.codec});

  @override
  Future<String> saveRecord(SixYaoDivinationRecord record) => save(record);
  @override
  Future<SixYaoDivinationRecord?> getRecordByUuid(String uuid) => getByUuid(uuid);
  @override
  Future<List<SixYaoDivinationRecord>> getAllRecords() => getAll();
  @override
  Future<bool> softDeleteRecord(String uuid) => softDelete(uuid);
  @override
  Future<List<SixYaoDivinationRecord>> getLatestRecords({int limit = 10}) =>
      getLatest(limit: limit);
}

void main() {
  group('Compile-spike: types instantiate', () {
    test('MeiHuaRecordCodec satisfies RecordModuleCodec constraint', () {
      final codec = MeiHuaRecordCodec();
      expect(codec.module, 'meihua');
      expect(codec.category, 'divination');
    });

    test('LiuYaoRecordCodec satisfies RecordModuleCodec constraint', () {
      final codec = LiuYaoRecordCodec();
      expect(codec.module, 'liuyao');
      expect(codec.divinationType, 'liu_yao');
    });

    test('BaseRecordBackedRepository instantiates with MeiHua codec', () {
      final store = FakeScopedRecordStore(scopeUid: 'test');
      final codec = MeiHuaRecordCodec();
      final repo = _MeiHuaRepo(store: store, codec: codec);
      expect(repo.module, 'meihua');
    });

    test('BaseRecordBackedRepository instantiates with LiuYao codec', () {
      final store = FakeScopedRecordStore(scopeUid: 'test');
      final codec = LiuYaoRecordCodec();
      final repo = _LiuYaoRepo(store: store, codec: codec);
      expect(repo.module, 'liuyao');
    });

    test('MeiHua codec round-trip', () {
      final codec = MeiHuaRecordCodec();
      final now = DateTime.now();
      final original = MeiHuaDivinationRecordContract(
        uuid: 'test-uuid-1',
        divinationUuid: 'div-uuid-1',
        question: 'test question',
        originalUpperGua: 1,
        originalLowerGua: 2,
        changingYao: 3,
        changedUpperGua: 4,
        changedLowerGua: 5,
        huUpperGua: 6,
        huLowerGua: 7,
        method: 'time',
        paramsJson: '{}',
        createdAt: now,
        updatedAt: now,
      );
      final encoded = codec.encode(original, scopeUid: 's1');
      final decoded = codec.decode(encoded.meta, encoded.moduleData);
      expect(decoded.uuid, original.uuid);
      expect(decoded.question, original.question);
    });

    test('LiuYao codec round-trip', () {
      final codec = LiuYaoRecordCodec();
      final now = DateTime.now();
      final original = SixYaoDivinationRecord(
        uuid: 'ly-uuid-1',
        question: 'liu yao question',
        yaoResults: const [
          SixYaoYaoResult(index: 0, yaoType: YaoType.shaoyang),
          SixYaoYaoResult(index: 1, yaoType: YaoType.laoyin),
        ],
        originalGuaId: 1,
        changedGuaId: 2,
        createdAt: now,
      );
      final encoded = codec.encode(original, scopeUid: 's1');
      final decoded = codec.decode(encoded.meta, encoded.moduleData);
      expect(decoded.uuid, original.uuid);
      expect(decoded.yaoResults.length, 2);
      expect(decoded.yaoResults[0].yaoType, YaoType.shaoyang);
    });

    test('withUuid replaces uuid', () {
      final codec = MeiHuaRecordCodec();
      final now = DateTime.now();
      final record = MeiHuaDivinationRecordContract(
        uuid: '',
        divinationUuid: '',
        originalUpperGua: 1,
        originalLowerGua: 1,
        changingYao: 0,
        changedUpperGua: 1,
        changedLowerGua: 1,
        huUpperGua: 1,
        huLowerGua: 1,
        method: 'time',
        paramsJson: '{}',
        createdAt: now,
        updatedAt: now,
      );
      final updated = codec.withUuid(record, 'new-id');
      expect(updated.uuid, 'new-id');
      expect(updated.divinationUuid, 'new-id');
    });
  });
}
