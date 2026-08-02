/// 远端二进制对象网关（RemoteDataSource 的 blob 面，设计稿 §3.4）。
///
/// 实现：firebase / supabase / 自建 REST / 自建 gRPC。
/// 与既有 PlaygroundMediaRepository.beginUpload 形状保持一致风格。
/// 本文件零实现，只有值类型与端口签名。
library;

import 'blob_types.dart';
import 'cancellation_token.dart';

/// 上传凭证：两阶段上传第一阶段的产物。
///
/// 字段约定：
/// - [objectName]：远端对象名。private → 随机 UUID（§7.4.3）；public →
///   等于 plaintextSha256。
/// - [expiresAtUtc]：凭证过期时间（UTC），过期后须重新 beginUpload。
final class BlobUploadTicket {
  /// 远端对象名。
  final String objectName;

  /// 凭证过期时间（UTC）。
  final DateTime expiresAtUtc;

  /// 构造一个 [BlobUploadTicket]。
  const BlobUploadTicket({
    required this.objectName,
    required this.expiresAtUtc,
  });
}

/// 下载凭证：短期签名 URL。
///
/// 约定（§7.5.2）：
/// - **每次调用都要新取，不缓存** —— 紧急下架依赖服务端在此处按 status
///   拒发，缓存会让下架失效。
/// - 视频返回短期签名 URL（1–2 分钟），过期后须重新取。
final class BlobDownloadTicket {
  /// 签名 URL。
  final String url;

  /// 签名过期时间（UTC）。
  final DateTime expiresAtUtc;

  /// 构造一个 [BlobDownloadTicket]。
  const BlobDownloadTicket({
    required this.url,
    required this.expiresAtUtc,
  });
}

/// 远端 blob 网关能力描述，用于动态 feature gating 与超时兜底。
///
/// 字段约定：
/// - [maxChunkBytes]：单 chunk 最大字节数（服务端上限）。
/// - [requestTimeout]：单请求超时（§3.6「超时」：每个 BlobGateway 方法
///   必须在 requestTimeout 内返回或抛超时）。
/// - [supportsResumable]：是否支持断点续传（remoteChunks 依赖它）。
final class BlobGatewayCapabilities {
  /// 单 chunk 最大字节数。
  final int maxChunkBytes;

  /// 单请求超时。
  final Duration requestTimeout;

  /// 是否支持断点续传。
  final bool supportsResumable;

  /// 构造一个 [BlobGatewayCapabilities]。
  const BlobGatewayCapabilities({
    required this.maxChunkBytes,
    required this.requestTimeout,
    required this.supportsResumable,
  });
}

/// 远端二进制对象网关端口。
abstract interface class BlobGateway {
  /// 两阶段上传的第一阶段：登记对象、拿到直传凭证。
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid（通常为用户 uid）。
  /// - [handle]: 目标 blob 句柄。
  /// - [visibility]: 可见性。private → 随机 UUID 对象名。
  ///
  /// 约定：
  /// - 凭证带过期时间，过期后须重新 beginUpload。
  Future<BlobUploadTicket> beginUpload({
    required String scopeUid,
    required BlobHandle handle,
    required BlobVisibility visibility,
  });

  /// 上传单个密文 chunk。支持乱序与重传，服务端按 index 归位。
  ///
  /// 参数说明：
  /// - [ticket]: 两阶段上传第一阶段的凭证。
  /// - [index]: chunk 序号。
  /// - [cipherBytes]: **密文** chunk 字节（密钥完全不参与传输路径）。
  /// - [cancel]: 取消令牌（可选）。
  ///
  /// 约定：
  /// - 必须在 capabilities.requestTimeout 内返回或抛超时（§3.6）。
  /// - 取消后已完成的 chunk 保留供续传，不回滚。
  Future<void> putChunk({
    required BlobUploadTicket ticket,
    required int index,
    required List<int> cipherBytes,
    CancellationToken? cancel,
  });

  /// 第二阶段：声明全部 chunk 已传完，服务端校验完整性后转 ready。
  ///
  /// 参数说明：
  /// - [ticket]: 两阶段上传第一阶段的凭证。
  Future<void> completeUpload(BlobUploadTicket ticket);

  /// 远端已持有的 chunk。断线重连后据此续传，不重传已成功的部分。
  ///
  /// 参数说明：
  /// - [ticket]: 两阶段上传第一阶段的凭证。
  ///
  /// 返回值：
  /// - 远端已持有的 chunk 序号集合。
  Future<Set<int>> remoteChunks(BlobUploadTicket ticket);

  /// 取下载凭证。**每次调用都要新取，不缓存** —— 紧急下架（§7.5）依赖
  /// 服务端在此处按 status 拒发。视频返回短期签名 URL（1–2 分钟）。
  ///
  /// 参数说明：
  /// - [handle]: 目标 blob 句柄。
  Future<BlobDownloadTicket> getDownloadTicket(BlobHandle handle);

  /// 删除远端对象。
  ///
  /// 参数说明：
  /// - [handle]: 目标 blob 句柄。
  Future<void> deleteObject(BlobHandle handle);

  /// 返回该网关的能力描述。
  ///
  /// 用途：
  /// - SyncRuntime 据此做动态 feature gating 与超时兜底。
  Future<BlobGatewayCapabilities> getCapabilities();
}
