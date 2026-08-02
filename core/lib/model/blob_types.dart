/// blob 层值类型（设计稿 §3.2 + §3.2.4）。
///
/// 本文件只有纯值类型与 sealed 结果类型，零实现。
/// 加密边界（§3.2「加密边界」）：`LocalBlobStore` 存的是密文，且它自己不是
/// 密码学组件；加密由独立的 `BlobCipher` 端口承担（见 blob_cipher.dart）。
library;

import 'dart:async';

/// blob 句柄：描述一个已落盘 blob 的全部元数据。
///
/// 字段约定：
/// - [plaintextSha256]：明文 sha256（hex）。本地索引与去重用，**永不作为
///   远端对象名**（§7.4.3）。
/// - [cipherManifestId]：密文清单 id。私有 blob 为随机 UUID；公开 blob
///   等于 [plaintextSha256]。
/// - [cipherId]：解密时定位实现的 cipher 标识（§3.2.4）。
/// - [keyVersion]：加密时的密钥版本，支持轮换后解旧数据（§3.2.4）。
///
/// 值语义：同值 == 为真，hashCode 一致（值对象）。
final class BlobHandle {
  /// 明文 sha256（hex）。本地索引与去重用，**永不作为远端对象名**。
  final String plaintextSha256;

  /// 密文清单 id。私有 blob 为随机 UUID；公开 blob 等于 [plaintextSha256]。
  final String cipherManifestId;

  /// 解密时定位实现的 cipher 标识。
  final String cipherId;

  /// 加密时的密钥版本，支持密钥轮换后解旧数据。
  final int keyVersion;

  /// 明文总字节数。
  final int totalBytes;

  /// chunk 总数。
  final int chunkCount;

  /// MIME 类型。
  final String mimeType;

  /// 构造一个 [BlobHandle]。
  const BlobHandle({
    required this.plaintextSha256,
    required this.cipherManifestId,
    required this.cipherId,
    required this.keyVersion,
    required this.totalBytes,
    required this.chunkCount,
    required this.mimeType,
  });

  /// 值相等：全部字段相等即相等。
  @override
  bool operator ==(Object other) {
    return other is BlobHandle &&
        other.plaintextSha256 == plaintextSha256 &&
        other.cipherManifestId == cipherManifestId &&
        other.cipherId == cipherId &&
        other.keyVersion == keyVersion &&
        other.totalBytes == totalBytes &&
        other.chunkCount == chunkCount &&
        other.mimeType == mimeType;
  }

  @override
  int get hashCode => Object.hash(
        plaintextSha256,
        cipherManifestId,
        cipherId,
        keyVersion,
        totalBytes,
        chunkCount,
        mimeType,
      );

  @override
  String toString() =>
      'BlobHandle($plaintextSha256, chunks=$chunkCount, $mimeType)';
}

/// blob 的本地就绪状态。取代原先的 bool isPresent —— 见 §3.2.1。
///
/// 「部分持有」必须可表达：§6.2 要求「局域网传了 60%，切云端接着传剩余
/// 40%」，bool 无法表达三级降级。
enum BlobStatus {
  /// 本地完全没有该 blob 的 chunk。
  absent,

  /// 持有部分 chunk，可断点续传。
  partial,

  /// chunk 齐全且完整性校验通过。
  complete,

  /// 数据损坏（hash 不匹配等）。
  corrupt,

  /// 密文存在但无法解密（密钥问题）。
  undecryptable,
}

/// 本地 blob 的两个区，语义完全不同 —— 见 §7.4.6。
enum BlobTier {
  /// 真相源：私有 blob。清了就没了，不可自动回收。
  sourceOfTruth,

  /// 缓存：公开 blob（本人及他人帖子配图）。可 LRU 清理，清了重新下载。
  cache,
}

/// blob 可见性。决定加密与否：private → 真加密；public → identity cipher。
enum BlobVisibility {
  /// 私有 blob：客户端 E2EE，仅本人可见。
  private,

  /// 公开 blob：identity cipher（不加密），可分享。
  public,
}

/// 本地 blob 目录条目，由 [LocalBlobStore.list] 产出。
///
/// 用途：
/// - 供 UI / 清理策略遍历：区分 [BlobTier.sourceOfTruth]（不可清）与
///   [BlobTier.cache]（可 LRU 清理）。
final class BlobEntry {
  /// blob 句柄。
  final BlobHandle handle;

  /// 所在区（真相源 / 缓存）。
  final BlobTier tier;

  /// 最近一次访问时间（UTC），LRU 清理的排序依据。
  final DateTime lastAccessAtUtc;

  /// 当前引用计数（已对账且引用数为 0 的 cache blob 可回收）。
  final int refCount;

  /// 构造一个 [BlobEntry]。
  const BlobEntry({
    required this.handle,
    required this.tier,
    required this.lastAccessAtUtc,
    required this.refCount,
  });
}

/// 读取结果。用 sealed 类区分五种后果，因为它们的补救动作完全不同。
sealed class BlobReadResult {
  /// 私有构造器：调用方只能走五个命名工厂。
  const BlobReadResult._();

  /// 读取成功，产出明文流。
  const factory BlobReadResult.ok(Stream<List<int>> plaintext) = BlobOk;

  /// blob 不存在。补救：重新上传 / 从远端下载。
  const factory BlobReadResult.absent() = BlobAbsent;

  /// 只持有部分 chunk，携带已持有集合。补救：断点续传补齐缺失 chunk。
  const factory BlobReadResult.partial(Set<int> presentChunks) = BlobPartial;

  /// 数据损坏，携带坏 chunk 集合。补救：删除并从远端重新下载。
  const factory BlobReadResult.corrupt(Set<int> badChunks) = BlobCorrupt;

  /// 密钥不可用。**重新下载没有用**，UI 必须提示密钥问题。
  const factory BlobReadResult.undecryptable() = BlobUndecryptable;
}

/// 读取成功：携带明文流。
final class BlobOk extends BlobReadResult {
  /// 明文流。
  final Stream<List<int>> plaintext;

  /// 构造 [BlobOk]。
  const BlobOk(this.plaintext) : super._();
}

/// 读取时 blob 不存在。
final class BlobAbsent extends BlobReadResult {
  /// 构造 [BlobAbsent]。
  const BlobAbsent() : super._();
}

/// 读取时只持有部分 chunk。
final class BlobPartial extends BlobReadResult {
  /// 已持有的 chunk 序号集合。
  final Set<int> presentChunks;

  /// 构造 [BlobPartial]。
  const BlobPartial(this.presentChunks) : super._();
}

/// 读取时发现数据损坏。
final class BlobCorrupt extends BlobReadResult {
  /// 损坏的 chunk 序号集合。
  final Set<int> badChunks;

  /// 构造 [BlobCorrupt]。
  const BlobCorrupt(this.badChunks) : super._();
}

/// 读取时密文无法解密（密钥问题）。
final class BlobUndecryptable extends BlobReadResult {
  /// 构造 [BlobUndecryptable]。
  const BlobUndecryptable() : super._();
}
