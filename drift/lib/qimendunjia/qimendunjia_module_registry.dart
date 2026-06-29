import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'qimen_record_codec.dart';
import 'record_backed_qimen_repository.dart';

class QimendunjiaModuleRegistry {
  static RecordModuleCodec<QimenDivinationRecordContract> codec() =>
      QimenRecordCodec();

  static QimenRecordRepository repository({
    required ScopedRecordStore store,
    String? uuid,
  }) =>
      RecordBackedQimenRepository(store: store, codec: codec(), uuid: uuid);
}
