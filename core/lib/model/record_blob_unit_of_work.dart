/// 记录与其 blob 引用的原子提交单元（设计稿 §3.2.3）。
///
/// `ScopedRecordStore` 与 `LocalBlobStore` 都没有事务令牌、回调或工作单元，
/// 调用方**无法**把「保存 record + 对账 blob 引用」包进同一次事务。
/// 本端口补上这个机制：在单个事务内先写记录、再对账引用，任一步失败
/// 则整体回滚。drift 适配层用 db.transaction() 实现；内存 fake 用简单锁
/// 实现。业务 Repository 拿到的是这个端口，不再各自调 saveRecord +
/// reconcileRefs 两次。
library;

import 'blob_types.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

/// 记录与其 blob 引用的原子提交单元。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
/// - 长耗时操作（可选实现）接受 [CancellationToken]；取消后已写入的 chunk
///   保留供续传，不回滚。
abstract interface class RecordBlobUnitOfWork {
  /// 在单个事务内先写记录、再对账引用。任一步失败则整体回滚。
  ///
  /// 参数说明：
  /// - [record]: 要保存的记录（含其元数据）。
  /// - [referencedBlobs]: 该记录当前引用的全部 blob 句柄，作为幂等的
  ///   全量声明提交，由实现内部算差集（§3.2.2）。
  ///
  /// 约定：
  /// - 事务内先写记录、再对账引用；任一步失败则整体回滚。
  /// - 是 handle 从 staged 转正的唯一途径。
  Future<void> saveWithBlobs({
    required RecordMeta record,
    required Set<BlobHandle> referencedBlobs,
  });

  /// 软删记录并释放其全部引用，同事务。
  ///
  /// 参数说明：
  /// - [recordUuid]: 要删除记录的 uuid。
  ///
  /// 约定：
  /// - 删除记录与其 blob 引用计数释放必须在同一事务内完成。
  Future<void> deleteWithBlobs(String recordUuid);
}
