import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import 'ziwei_record_codec.dart';
import 'record_backed_ziwei_repository.dart';

class ZiweidoushuModuleRegistry {
  static RecordModuleCodec<ZiweiDivinationRecordContract> codec() =>
      ZiweiRecordCodec();

  static ZiweiRecordRepository repository({
    required ScopedRecordStore store,
    Uuid? uuid,
  }) =>
      RecordBackedZiweiRepository(store: store, codec: codec(), uuid: uuid);
}
