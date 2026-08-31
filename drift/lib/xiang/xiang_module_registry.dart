import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';
import '../blob/blob_metadata_repository.dart';
import 'xiang_record_codec.dart';
import 'xiang_reading_repository_impl.dart';

/// 相法模块注册 — 提供 Codec + Repository 实例供 Shell DI 组装（TDD-T4）。
///
/// 与其它占测模块的 ModuleRegistry 同构；统一 History 检索经
/// [RecordModuleRegistry.allExtractors] 注册 [XiangRecordCodec]。
///
/// C3：生产装配注入共享 [RecordBlobUnitOfWork] 与 [BlobMetadataRepository]
/// （Shell composition root 已建的 scope-bound kanyuUow / xiangMediaMetadataRepo），
/// 使 Xiang `put` 走共享 UoW 原子落库。纯记录装配（测试）可不注入。
class XiangModuleRegistry {
  const XiangModuleRegistry._();

  static XiangRecordCodec codec() => XiangRecordCodec();

  static XiangReadingRepository repository({
    required ScopedRecordStore store,
    RecordBlobUnitOfWork? unitOfWork,
    BlobMetadataRepository? blobMetadataRepository,
  }) => XiangReadingRepositoryImpl(
    store: store,
    codec: codec(),
    unitOfWork: unitOfWork,
    blobMetadataRepository: blobMetadataRepository,
  );
}
