/// 加密导出包的读写（设计稿 §3.5）。
///
/// 导出导入【不走】Transport —— 文件不是持续连接：没有 peer 发现后的
/// 交互式握手、没有心跳与重连、没有双向并发逻辑流、没有实时多路复用，
/// 而这四样正是 [PeerSession] 的契约。导出文件在 oplog 合并语义上确实
/// 产出一批需要 LWW 仲裁的变更，但**不复用物理连接抽象**，走独立的
/// 编解码端口。本文件零实现。
library;

import 'cancellation_token.dart';
import 'types.dart';

/// 导出包清单：校验签名与完整性后得到的包元信息。
///
/// 字段约定：
/// - [scopeUid]：包所属作用域 uid。
/// - [operationCount]：包内 oplog 操作条数。
/// - [createdAtUtc]：打包时间（UTC）。
/// - [signature]：封口签名（校验通过后才可信）。
final class BundleManifest {
  /// 包所属作用域 uid。
  final String scopeUid;

  /// 包内 oplog 操作条数。
  final int operationCount;

  /// 打包时间（UTC）。
  final DateTime createdAtUtc;

  /// 封口签名。
  final String signature;

  /// 构造一个 [BundleManifest]。
  const BundleManifest({
    required this.scopeUid,
    required this.operationCount,
    required this.createdAtUtc,
    required this.signature,
  });
}

/// 导出包写入端口。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
/// - 压缩必须在独立 isolate 内完成（§3.6「isolate」）。
/// - 取消后已写入的部分保留供续传，不回滚。
abstract interface class ExportBundleWriter {
  /// 把指定 scope 的 oplog（可选含 blob 密文）打包并封口签名。
  ///
  /// 参数说明：
  /// - [scopeUid]: 要导出的作用域 uid。
  /// - [outputPath]: 输出文件路径。
  /// - [includeBlobs]: 是否把 blob 密文一并打包（导出到新设备时 true）。
  /// - [cancel]: 取消令牌（可选）。
  Future<void> write({
    required String scopeUid,
    required String outputPath,
    required bool includeBlobs,
    CancellationToken? cancel,
  });
}

/// 导出包读取端口。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
/// - 校验签名与完整性（inspect），失败即拒绝导入，不解密内容。
abstract interface class ExportBundleReader {
  /// 校验签名与完整性，不解密内容。失败即拒绝导入。
  ///
  /// 参数说明：
  /// - [path]: 导出包文件路径。
  ///
  /// 返回值：
  /// - 校验通过后的包清单 [BundleManifest]。
  Future<BundleManifest> inspect(String path);

  /// 产出与 SyncPeer.listChanges 同形状的变更页，从而复用同一套 LWW 仲裁。
  ///
  /// 参数说明：
  /// - [path]: 导出包文件路径。
  /// - [scopeUid]: 目标作用域 uid。
  ///
  /// 返回值：
  /// - [RemoteChangesPage] 流（复用 core/lib/model/types.dart 里【既有】的
  ///   RemoteChangesPage，复用数据形状而非连接抽象）。
  Stream<RemoteChangesPage> readChanges(String path, {required String scopeUid});
}
