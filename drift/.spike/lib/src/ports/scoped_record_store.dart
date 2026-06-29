import 'package:spike_typed_record_base/src/ports/record_repository.dart';
import 'package:spike_typed_record_base/src/ports/record_index_repository.dart';

abstract interface class ScopedRecordStore
    implements RecordRepository, RecordIndexRepository {
  String get scopeUid;
}
