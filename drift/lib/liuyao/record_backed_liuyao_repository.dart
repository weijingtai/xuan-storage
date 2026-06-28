import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
import '../record/base_record_backed_repository.dart';
import 'liuyao_record_codec.dart';

/// Drift-backed implementation of [SixYaoDivinationRecordRepository].
///
/// Uses [LocalRecordRepository] and [LiuYaoRecordCodec] to store records
/// in the unified `t_record_meta` / `t_record_search_index` tables.
class RecordBackedLiuYaoRepository
    extends BaseRecordBackedRepository<SixYaoDivinationRecord>
    implements SixYaoDivinationRecordRepository {

  RecordBackedLiuYaoRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

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

  // ── Index queries (using BaseRecordBackedRepository methods) ──

  /// Find records by original hexagram ID.
  Future<List<SixYaoDivinationRecord>> getRecordsByOriginalGua(int guaId) =>
      getAllByIndex('original_gua_id', '$guaId', limit: 200);

  /// Find records by changed hexagram ID.
  Future<List<SixYaoDivinationRecord>> getRecordsByChangedGua(int guaId) =>
      getAllByIndex('changed_gua_id', '$guaId', limit: 200);
}
