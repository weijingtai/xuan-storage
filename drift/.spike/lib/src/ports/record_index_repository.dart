import 'package:spike_typed_record_base/src/models/record_meta.dart';

abstract interface class RecordIndexRepository {
  Future<List<RecordMeta>> findByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
    required int limit,
  });
  Stream<List<RecordMeta>> watchByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
  });
}
