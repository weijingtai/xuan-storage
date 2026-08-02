/// 取消令牌。§3.6 规定所有可能超过 1 秒的方法接受 CancellationToken?。
library;

/// 协作式取消令牌，用于长耗时存储操作的取消。
///
/// 功能说明：
/// - 所有可能超过 1 秒的端口方法（LocalBlobStore / BlobGateway /
///   Transport / ExportBundleWriter 等）接受 [CancellationToken?] 参数。
/// - 取消是协作式的：被调方在安全点检查 [isCancelled]，不保证立即中止。
///
/// 约定（§3.6「取消」）：
/// - 取消后已完成的 chunk 保留供续传，不回滚。
/// - 由调用方持有令牌的所有权；实现不得自行取消令牌。
abstract interface class CancellationToken {
  /// 是否已请求取消。
  ///
  /// 返回值：
  /// - true 表示调用方已请求取消，被调方应尽快在安全点中止。
  bool get isCancelled;

  /// 取消完成时完成的 Future。
  ///
  /// 用途：
  /// - 被调方可以 await 此 Future 等待取消信号（例如与 IO 竞速）。
  /// - 未取消前该 Future 不完成；取消后立即完成。
  Future<void> get whenCancelled;

  /// 若已请求取消则立即抛 BlobCancelledError。
  ///
  /// 约定：
  /// - 在每次 chunk 边界 / 每批记录处理前调用，实现快速失败。
  void throwIfCancelled();
}
