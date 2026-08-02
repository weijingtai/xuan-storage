/// 本地二进制对象数据源（LocalDataSource 的 blob 面，设计稿 §3.2）。
///
/// 与 [ScopedRecordStore] 并列：前者管结构化记录，后者管字节。
/// 实现可以是 文件系统 / drift BLOB / 未来任意存储，业务侧只认此端口。
///
/// 通用约定（适用于本端口全部方法，见 §3.6）：
/// - 哈希与加解密**必须在独立 isolate 内完成**。500MB 视频在 UI isolate 上
///   分块哈希会冻结界面数秒。
/// - 所有长耗时方法接受 [CancellationToken]，取消后已写入的 chunk 保留
///   （供续传），不回滚。
/// - 失败一律抛 StorageError 子类（storage.blob_*），不返回 null 表达失败。
/// - 本端口【不接受任何密钥参数】：密钥由 [BlobCipherResolver] 内部持有，
///   调用方不传（§3.2.4）。
library;

import 'blob_cipher.dart';
import 'blob_types.dart';
import 'cancellation_token.dart';

/// 本地二进制对象数据源端口。
abstract interface class LocalBlobStore {
  /// 本 store 的作用域 uid（通常为用户 uid）。
  String get scopeUid;

  /// 从文件写入。
  ///
  /// **优先用这个而非 [put]（Stream）** —— 文件可重放、可 seek，中途失败
  /// 能续传；Stream 一旦消费就无法重试。
  ///
  /// 参数说明：
  /// - [path]: 源文件绝对路径。
  /// - [mimeType]: MIME 类型。
  /// - [tier]: 所在区。**必须携带**：清理缓存分区错误会删掉用户私人照片。
  /// - [cancel]: 取消令牌（可选）。
  /// - [onProgress]: 进度回调 (sent, total)。
  ///
  /// 约定：
  /// - 哈希计算必须在独立 isolate 内完成（§3.6「isolate」）。
  /// - 取消后已写入的 chunk 保留供续传，不回滚；handle 处于 staged 状态。
  Future<BlobHandle> putFile(
    String path, {
    required String mimeType,
    required BlobTier tier,
    CancellationToken? cancel,
    void Function(int sent, int total)? onProgress,
  });

  /// 流式写入。仅用于源头本就是流（如摄像头直录）的场景。
  ///
  /// 参数说明：
  /// - [bytes]: 明文字节流。
  /// - [mimeType]: MIME 类型。
  /// - [tier]: 所在区。
  /// - [expectedBytes]: 期望总字节数（用于进度与容量预检）。
  /// - [cancel]: 取消令牌（可选）。
  ///
  /// 约定：
  /// - 哈希计算必须在独立 isolate 内完成（§3.6「isolate」）。
  /// - 取消后已写入的 chunk 保留供续传，不回滚。
  Future<BlobHandle> put(
    Stream<List<int>> bytes, {
    required String mimeType,
    required BlobTier tier,
    required int expectedBytes,
    CancellationToken? cancel,
  });

  /// 写入单个密文 chunk。断点续传与三级降级（§6.2）依赖它。
  ///
  /// 参数说明：
  /// - [handle]: 目标 blob 句柄。
  /// - [index]: chunk 序号。
  /// - [cipherBytes]: **密文** chunk 字节（本端口不参与加密）。
  ///
  /// 约定：
  /// - 同一 [BlobHandle] 的并发 [putChunk] 必须安全（按 index 分片写）。
  /// - 写入的是密文：上传 / P2P 中继路径可经密文读取方法取出，
  ///   密钥完全不参与。
  Future<void> putChunk(BlobHandle handle, int index, List<int> cipherBytes);

  /// 读取指定 chunk 的**密文**，不解密。
  ///
  /// 用途：
  /// - 上传与 P2P 中继走这条路径，因此中继过程中密钥完全不参与，也不
  ///   需要在内存里出现明文（§3.2.5 —— 上传链原本是断的，本方法是补链）。
  ///
  /// 参数说明：
  /// - [handle]: 目标 blob 句柄。
  /// - [index]: chunk 序号。
  Future<List<int>> readCipherChunk(BlobHandle handle, int index);

  /// 读取。五种后果由 [BlobReadResult] 区分，调用方据此决定补救动作。
  ///
  /// 参数说明：
  /// - [handle]: 目标 blob 句柄。
  /// - [cancel]: 取消令牌（可选）。
  ///
  /// 约定：
  /// - 解密必须在独立 isolate 内完成（§3.6「isolate」）。
  /// - 取消后不产生副作用；已完成的读取结果可直接使用。
  Future<BlobReadResult> openRead(BlobHandle handle, {CancellationToken? cancel});

  /// 就绪状态。取代 bool —— UI 要区分「未下载」与「已损坏」。
  Future<BlobStatus> statusOf(BlobHandle handle);

  /// 已持有的 chunk 序号集合。切换通道续传时，新通道据此只取缺失部分。
  Future<Set<int>> presentChunks(BlobHandle handle);

  /// 明文总字节数。不存在返回 null。
  Future<int?> sizeOf(BlobHandle handle);

  /// 遍历指定区的全部 blob 条目。
  ///
  /// 参数说明：
  /// - [tier]: 只遍历该区的条目（sourceOfTruth / cache）。
  Stream<BlobEntry> list({required BlobTier tier});

  /// 引用集对账。取代裸 retain/release —— 见 §3.2.2。
  ///
  /// 把「这条记录当前引用哪些 blob」作为**幂等的全量声明**提交，由实现
  /// 内部算差集，并与记录写入**同事务**提交。
  ///
  /// 参数说明：
  /// - [ownerRecordUuid]: 拥有记录的 uuid。
  /// - [handles]: 该记录当前引用的全部 blob 句柄。
  ///
  /// 约定：
  /// - 同一 [ownerRecordUuid] 的并发 [reconcileRefs] 由实现串行化（§3.6）。
  /// - 是 handle 从 staged 转正的唯一途径。
  Future<void> reconcileRefs({
    required String ownerRecordUuid,
    required Set<BlobHandle> handles,
  });

  /// 按业务外部 id 逐出缓存。
  ///
  /// 用途：
  /// - 紧急下架（§7.5.1 第 3 层）依赖它，因为下发的黑名单是
  ///   PlaygroundAttachmentId，不是 [BlobHandle]。
  ///
  /// 参数说明：
  /// - [externalId]: 业务外部 id。
  Future<void> evictByExternalId(String externalId);

  /// 清理缓存区。**只清 [BlobTier.cache]，绝不触碰 [BlobTier.sourceOfTruth]。**
  ///
  /// 返回值：
  /// - `freed`：已释放字节数。
  /// - `unreclaimable`：因被 pin 而无法回收的字节数。
  ///
  /// 参数说明：
  /// - [targetFreeBytes]: 期望释放的目标字节数。
  Future<({int freed, int unreclaimable})> evictCache({
    required int targetFreeBytes,
  });
}
