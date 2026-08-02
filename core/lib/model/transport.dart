/// 物理连接抽象（设计稿 §3.5）。
///
/// 层级：`Transport` 在下，`SyncPeer` 与 `BlobGateway` 是它之上的两个协议
/// 消费者，由一个 `PeerSession` 持有连接并做多路复用（oplog 流与 blob
/// chunk 流共用同一条物理连接）。
///
/// **文件导出不走本抽象，且不应存在对应的 Transport 实现。** 文件不是
/// 持续连接：没有 peer 发现后的交互式握手、没有心跳与重连、没有双向并发
/// 逻辑流、没有实时多路复用 —— 而这四样正是 [PeerSession] 的契约。
/// 导出导入走独立的 ExportBundle 端口（export_bundle.dart），不复用连接
/// 抽象。本文件零实现。
library;

import 'cancellation_token.dart';
import 'storage_classification.dart';

/// 逻辑流类型。oplog 与 blob chunk 各占一条，互不阻塞。
enum StreamKind {
  /// oplog 流：SyncPeer 消费。
  oplog,

  /// blob chunk 流：BlobGateway 消费。
  blobChunk,
}

/// 对端身份：认证握手后绑定到会话的身份信息。
///
/// 字段约定：
/// - [deviceId]：设备唯一标识。
/// - [publicKeyFingerprint]：对端公钥指纹，用于带外比对（channel binding）。
final class PeerIdentity {
  /// 设备唯一标识。
  final String deviceId;

  /// 公钥指纹。
  final String publicKeyFingerprint;

  /// 构造一个 [PeerIdentity]。
  const PeerIdentity({
    required this.deviceId,
    required this.publicKeyFingerprint,
  });
}

/// 被发现的可达对端。
///
/// 字段约定：
/// - [transientServiceId]：随机化的临时 service id。广播内容只含这个 id，
///   **不含 scopeUid 或设备名**（否则同一 WiFi 下任何人都能枚举设备归属）。
/// - [channel]：对端来自哪个通道。
final class DiscoveredPeer {
  /// 随机化的临时 service id。
  final String transientServiceId;

  /// 通道。
  final Channel channel;

  /// 构造一个 [DiscoveredPeer]。
  const DiscoveredPeer({
    required this.transientServiceId,
    required this.channel,
  });
}

/// 设备密钥对。仅占位形状，实现属 S6。
final class DeviceKeyPair {
  /// 公钥（PEM）。
  final String publicKeyPem;

  /// 构造一个 [DeviceKeyPair]。
  const DeviceKeyPair({required this.publicKeyPem});
}

/// 会话状态。
enum PeerSessionState {
  /// 连接建立中（含握手）。
  connecting,

  /// 已认证，可开流。
  authenticated,

  /// 已认证但链路降级（例如 QoS 恶化），仍可用但建议限速。
  degraded,

  /// 已关闭。
  closed,
}

/// 一条已认证连接上的逻辑流。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
/// - 超时约定：发送应在会话的传输超时内返回或抛超时。
abstract interface class PeerStream {
  /// 对端发来的字节流。
  Stream<List<int>> get incoming;

  /// 发送一段字节。
  ///
  /// 参数说明：
  /// - [bytes]: 要发送的字节。
  ///
  /// 约定：
  /// - 超时约定见 §3.6：应在传输超时内返回或抛超时。
  Future<void> send(List<int> bytes);

  /// 关闭本逻辑流。
  Future<void> close();
}

/// 一条已认证连接上的多路复用会话。
///
/// 持有连接、握手、心跳、重连。一条会话上可开多条逻辑流
/// （[StreamKind.oplog] 与 [StreamKind.blobChunk]），互不阻塞。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
abstract interface class PeerSession {
  /// 对端身份（握手认证后绑定）。
  PeerIdentity get remote;

  /// 会话状态流。
  Stream<PeerSessionState> get state;

  /// 开一条逻辑流。oplog 与 blob chunk 各占一条，互不阻塞。
  ///
  /// 参数说明：
  /// - [kind]: 逻辑流类型。
  ///
  /// 约定：
  /// - 同一条 session 上不同 kind 的流必须互不阻塞（多路复用）。
  Future<PeerStream> openStream(StreamKind kind);

  /// 关闭会话（含其全部逻辑流）。
  Future<void> close();
}

/// 物理连接抽象。一个 [Channel] 值对应恰好一个 Transport 实现
/// （[Channel.cloud] 除外 —— 云端走 SyncPeer 直连，不经 Transport）。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
abstract interface class Transport {
  /// 本 transport 对应的通道。
  Channel get channel;

  /// 发现可达对端。LAN 走 mDNS；WebRTC 走信令；导出文件走文件选择器。
  ///
  /// 参数说明：
  /// - [timeout]: 发现超时（可选）。
  ///
  /// 隐私约定：
  /// - 广播内容只含随机化的临时 service id，**不含 scopeUid 或设备名**
  ///   （否则同一咖啡厅 WiFi 下任何人都能枚举出设备归属，见 §6.3）。
  Stream<DiscoveredPeer> discover({Duration? timeout});

  /// 建立会话。握手必须完成认证密钥交换并绑定指纹到会话
  /// （channel binding），否则带外指纹比对对主动 MITM 无效。规格见 S6。
  ///
  /// 参数说明：
  /// - [peer]: 被发现的对端。
  /// - [localKeys]: 本端设备密钥对。
  /// - [cancel]: 取消令牌（可选）。
  Future<PeerSession> connect(
    DiscoveredPeer peer, {
    required DeviceKeyPair localKeys,
    CancellationToken? cancel,
  });

  /// 释放本 transport 占用的全部资源。
  Future<void> dispose();
}
