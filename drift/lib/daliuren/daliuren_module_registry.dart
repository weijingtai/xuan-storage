import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'daliuren_record_codec.dart';
import 'record_backed_daliuren_repository.dart';

class DaliurenModuleRegistry {
  static RecordModuleCodec<DaliurenDivinationRecordContract> codec() =>
      DaliurenRecordCodec();

  static DaliurenRecordRepository repository({
    required ScopedRecordStore store,
    String? uuid,
  }) =>
      RecordBackedDaliurenRepository(store: store, codec: codec(), uuid: uuid);
}
