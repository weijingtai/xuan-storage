/// blob 层专用错误类型。
///
/// 全部继承 [StorageError]，code 前缀统一为 `storage.blob_`。
/// 写法照 core/lib/model/storage_error.dart 里 SyncConflictError 的模式。
library;

import 'storage_error.dart';

/// blob 不存在。读取 / 打开 / 删除一个不存在的 blob 时抛出。
///
/// 功能说明：
/// - 与 [BlobReadResult.absent] 的区别：前者是查询结果，本错误是操作失败。
/// - 典型场景：handle 引用了一个已被 GC 或从未写入过的对象。
class BlobNotFoundError extends StorageError {
  /// 构造一个 blob 不存在错误。
  BlobNotFoundError()
      : super(
          code: 'storage.blob_not_found',
          message: 'Blob not found',
          reason: 'The referenced blob does not exist in local storage',
          suggestion: '请检查引用是否已过期，或重新上传该 blob',
        );
}

/// blob 数据损坏。完整性校验失败时抛出。
///
/// 功能说明：
/// - 哈希不匹配 / 分块长度异常 / 元数据缺失均属此类。
/// - 与 [BlobReadResult.corrupt] 的区别：后者是读取时的状态枚举，
///   本错误用于写后校验或非读取路径的损坏发现。
class BlobCorruptError extends StorageError {
  /// 构造一个 blob 损坏错误。
  BlobCorruptError()
      : super(
          code: 'storage.blob_corrupt',
          message: 'Blob data is corrupt',
          reason: 'Integrity check failed (hash mismatch or truncated chunk)',
          suggestion: '请删除该 blob 并从远端重新下载',
        );
}

/// blob 密文无法解密。密钥缺失 / 版本不匹配 / 密文被篡改时抛出。
///
/// 功能说明：
/// - 与 [BlobReadResult.undecryptable] 的区别：后者是读取时的状态枚举，
///   本错误用于解密路径上无法继续的场景。
/// - 可能原因：keyVersion 在本地密钥链中不存在、密文被外部修改。
class BlobUndecryptableError extends StorageError {
  /// 构造一个无法解密错误。
  BlobUndecryptableError()
      : super(
          code: 'storage.blob_undecryptable',
          message: 'Blob cannot be decrypted',
          reason: 'Missing key, key version mismatch, or tampered ciphertext',
          suggestion: '请确认密钥链完好，或从远端重新下载该 blob',
        );
}

/// 本地存储已满。写入因空间不足失败时抛出。
///
/// 功能说明：
/// - 触发方应优先调用 [LocalBlobStore.evictCache] 释放缓存空间后重试。
/// - tier == sourceOfTruth 的数据不可被 evictCache 删除，需提示用户清理。
class BlobStorageFullError extends StorageError {
  /// 构造一个存储已满错误。
  BlobStorageFullError()
      : super(
          code: 'storage.blob_storage_full',
          message: 'Local blob storage is full',
          reason: 'Not enough free space to persist the blob',
          suggestion: '请清理缓存或释放设备存储空间后重试',
        );
}

/// 操作被取消。调用方请求取消时抛出。
///
/// 功能说明：
/// - 由 [CancellationToken.throwIfCancelled] 抛出，表示协作式取消生效。
/// - 约定：已完成的 chunk 保留供续传，不回滚。
class BlobCancelledError extends StorageError {
  /// 构造一个取消错误。
  BlobCancelledError()
      : super(
          code: 'storage.blob_cancelled',
          message: 'Blob operation cancelled',
          reason: 'The caller requested cancellation via CancellationToken',
          suggestion: '如需继续，请重新发起操作；已完成 chunk 会用于续传',
        );
}
