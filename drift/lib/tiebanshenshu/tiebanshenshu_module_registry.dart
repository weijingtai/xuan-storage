import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import 'tieban_record_codec.dart';
import 'record_backed_tieban_repository.dart';

class TiebanshenshuModuleRegistry {
  static RecordModuleCodec<TiebanDivinationRecordContract> codec() =>
      TiebanRecordCodec();

  static TiebanRecordRepository repository({
    required ScopedRecordStore store,
    Uuid? uuid,
  }) =>
      RecordBackedTiebanRepository(store: store, codec: codec(), uuid: uuid);
}
