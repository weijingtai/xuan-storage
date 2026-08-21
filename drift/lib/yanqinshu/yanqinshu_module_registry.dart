import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_yanqinshu/repository_interface_yanqinshu.dart';
import 'package:uuid/uuid.dart';
import 'record_backed_yanqinshu_repository.dart';
import 'yanqinshu_record_codec.dart';

class YanqinshuModuleRegistry {
  static RecordModuleCodec<YanqinshuDivinationRecordContract> codec() =>
      YanqinshuRecordCodec();

  static YanqinshuRecordRepository repository({
    required ScopedRecordStore store,
    Uuid? uuid,
  }) =>
      RecordBackedYanqinshuRepository(store: store, codec: codec(), uuid: uuid);
}
