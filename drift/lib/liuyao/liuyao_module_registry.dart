import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import 'liuyao_record_codec.dart';
import 'record_backed_liuyao_repository.dart';

/// 六爻模块注册 — 提供 Codec + Repository 实例供 DI 组装。
class LiuYaoModuleRegistry {
  static RecordModuleCodec<SixYaoDivinationRecord> codec() =>
      LiuYaoRecordCodec();

  static SixYaoDivinationRecordRepository repository({
    required ScopedRecordStore store,
    Uuid? uuid,
  }) =>
      RecordBackedLiuYaoRepository(store: store, codec: codec(), uuid: uuid);
}
