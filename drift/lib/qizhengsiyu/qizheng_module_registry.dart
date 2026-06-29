import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import 'qizheng_record_codec.dart';
import 'record_backed_qizheng_repository.dart';

/// 七政四余模块注册 — 提供 Codec + Repository 实例供 DI 组装。
class QiZhengModuleRegistry {
  static RecordModuleCodec<QiZhengSiYuPanContract> codec() =>
      QiZhengRecordCodec();

  static QiZhengRecordRepository repository({
    required ScopedRecordStore store,
    Uuid? uuid,
  }) =>
      RecordBackedQiZhengRepository(store: store, codec: codec(), uuid: uuid);
}
