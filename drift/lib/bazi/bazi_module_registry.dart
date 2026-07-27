import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import 'bazi_record_codec.dart';
import 'record_backed_bazi_repository.dart';

class BaziModuleRegistry {
  static RecordModuleCodec<BaziRecordContract> codec() => BaziRecordCodec();

  static BaziRecordRepository repository({
    required ScopedRecordStore store,
    Uuid? uuid,
  }) =>
      RecordBackedBaziRepository(store: store, codec: codec(), uuid: uuid);
}
