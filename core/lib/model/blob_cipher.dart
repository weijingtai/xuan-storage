/// blob 加解密端口（设计稿 §3.2.4）。
///
/// 加密由独立 [BlobCipher] 端口承担，`LocalBlobStore` 存密文且不是密码学
/// 组件。密钥【派生】属 S6，但密钥【上下文的端口形状】必须在 S1a 定死，
/// 否则 `LocalBlobStore` 的签名是假的。本文件零实现。
library;

import 'blob_types.dart';

/// cipher 标识。写入 BlobHandle，解密时据此定位实现。
typedef CipherId = String;

/// blob 加解密。实现由 S6 提供；S1a 只定契约。
///
/// 通用约定（§3.6）：
/// - 加解密**必须在独立 isolate 内完成**（500MB 视频在 UI isolate 上分块
///   加解密会冻结界面数秒）。
/// - 失败一律抛 [BlobError] 子类（storage.blob_*），不用 null 表达失败。
abstract interface class BlobCipher {
  /// 本 cipher 的标识。写入 [BlobHandle.cipherId]，解密时据此定位实现。
  CipherId get id;

  /// 当前密钥版本。写入 [BlobHandle.keyVersion]，支持密钥轮换后解旧数据。
  int get currentKeyVersion;

  /// 加密单个 chunk。
  ///
  /// 参数说明：
  /// - [plain]: 明文 chunk 字节。
  /// - [chunkIndex]: chunk 序号，用于派生每 chunk 独立的 nonce。
  ///
  /// 约定：
  /// - nonce 由实现生成并**内联在返回字节头部**（每 chunk 独立 nonce）。
  /// - 必须在独立 isolate 内执行（§3.6「isolate」）。
  Future<List<int>> encryptChunk(List<int> plain, {required int chunkIndex});

  /// 解密单个 chunk。
  ///
  /// 参数说明：
  /// - [cipherBytes]: 密文 chunk 字节（含内联 nonce 头部）。
  /// - [chunkIndex]: chunk 序号。
  /// - [keyVersion]: 来自 [BlobHandle.keyVersion]，支持轮换后解旧数据。
  ///
  /// 约定：
  /// - 密钥不可用时抛 `UndecryptableError`（**重新下载无用**，见
  ///   [BlobReadResult.undecryptable]）。
  /// - 必须在独立 isolate 内执行（§3.6「isolate」）。
  Future<List<int>> decryptChunk(
    List<int> cipherBytes, {
    required int chunkIndex,
    required int keyVersion,
  });
}

/// 按 scope 与可见性选择 cipher。
///
/// private → 真加密；public → identity（不加密）。
/// `LocalBlobStore` 的实现持有本 resolver，调用方【不传密钥】——
/// 密钥永不出现在跨包签名里（§3.2.4）。
abstract interface class BlobCipherResolver {
  /// 解析指定 scope 与可见性对应的 cipher。
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid（通常为用户 uid），密钥按 scope 隔离。
  /// - [v]: blob 可见性。private 返回真加密 cipher，public 返回 identity。
  BlobCipher resolve({required String scopeUid, required BlobVisibility v});
}
