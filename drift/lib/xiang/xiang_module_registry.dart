import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';
import 'xiang_record_codec.dart';
import 'xiang_reading_repository_impl.dart';

/// 相法模块注册 — 提供 Codec + Repository 实例供 Shell DI 组装（TDD-T4）。
///
/// 与其它占测模块的 ModuleRegistry 同构；统一 History 检索经
/// [RecordModuleRegistry.allExtractors] 注册 [XiangRecordCodec]。
class XiangModuleRegistry {
  const XiangModuleRegistry._();

  static XiangRecordCodec codec() => XiangRecordCodec();

  static XiangReadingRepository repository({required ScopedRecordStore store}) =>
      XiangReadingRepositoryImpl(store: store, codec: codec());
}
