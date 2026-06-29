import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'taiyi_record_codec.dart';
import 'record_backed_taiyi_repository.dart';

class TaiyishenshuModuleRegistry {
  static RecordModuleCodec<TaiyiDivinationRecordContract> codec() =>
      TaiyiRecordCodec();

  static TaiyiRecordRepository repository({
    required ScopedRecordStore store,
    String? uuid,
  }) =>
      RecordBackedTaiyiRepository(store: store, codec: codec(), uuid: uuid);
}
