import 'package:spike_typed_record_base/src/models/record_meta.dart';

abstract interface class RecordRepository {
  Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData});
  Future<RecordMeta?> getRecord(String uuid, {required String module});
  Future<List<RecordMeta>> listRecords({
    required String module,
    String? category,
    String? divinationType,
    required int limit,
    String? cursor,
  });
  Future<bool> softDeleteRecord(String uuid, {required String module});
  Stream<List<RecordMeta>> watchRecords({required String module});
}
