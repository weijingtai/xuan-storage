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
import 'storage_error.dart';

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

/// 本机设备身份密钥的持有者。
///
/// **私钥【永远不】以字节形式出现在本契约里。** 只暴露「能签名」这个能力，
/// 不暴露「取出私钥」。这样实现方可以把私钥锁在 Keychain / Android Keystore，
/// 后续升级到 Secure Enclave / StrongBox（私钥永不导出、只能被调用）时
/// **只换实现、接口一个字不改**。
///
/// 决议（2026-08-04）：设备私钥走安全存储，与 D16「业务数据不做应用层落盘
/// 加密」不冲突 —— 私钥不是数据，是身份凭证；它泄露的后果是攻击者可冒充本
/// 设备加入用户的同步网络，属账户级危害。
///
/// 约定（§3.6）：
/// - 全部方法为异步：读安全存储是异步操作（D7 同因）。
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
abstract interface class DeviceKeyStore {
  /// 本机身份：deviceId + 公钥指纹。带外比对指纹时给用户看的就是它。
  Future<PeerIdentity> get localIdentity;

  /// 用本机私钥对 [payload] 签名。私钥不出实现。
  ///
  /// 参数说明：
  /// - [payload]: 待签名字节。
  Future<List<int>> sign(List<int> payload);

  /// 用对端公钥验签。
  ///
  /// 参数说明：
  /// - [payload]: 被签名的原始字节。
  /// - [signature]: 签名字节。
  /// - [peerPublicKeyPem]: 对端公钥（PEM）。
  Future<bool> verify({
    required List<int> payload,
    required List<int> signature,
    required String peerPublicKeyPem,
  });
}

/// 广播句柄：[Transport.advertise] 的返回值。
///
/// **返回它而不是 void，是为了让隐私约定可被机械验证。** 在此之前，
/// 「广播只含随机 service id」这条约定写在 [Transport.discover]（查询侧）的
/// 注释里，而真正执行广播的方法根本不存在 —— 约定无处可实现、无测试可验。
/// 现在契约测试可以直接断言 [transientServiceId] 不含 scopeUid 与设备名。
final class AdvertisementHandle {
  /// 随机化的临时 service id。
  ///
  /// **不得**含 scopeUid、用户名或设备名（否则同一咖啡厅 WiFi 下任何人
  /// 都能枚举出设备归属，见 §6.3）。
  final String transientServiceId;

  /// 广播开始时间（UTC）。
  final DateTime startedAtUtc;

  /// 轮换周期。到期后 [transientServiceId] 必须换新，防长期追踪。
  final Duration rotateAfter;

  /// 构造一个 [AdvertisementHandle]。
  const AdvertisementHandle({
    required this.transientServiceId,
    required this.startedAtUtc,
    required this.rotateAfter,
  });
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

/// 发送侧溢出策略：`bufferedAmount >= maxBufferedAmount` 时 [PeerStream.send]
/// 采取的行为。
///
/// 契约固定这两种明文策略（S3c-c-pre 决定记录 D2）—— 行为不是「由实现
/// 自由决定」，而是二选一：实现必须在运行时通过 [PeerStream.overflowPolicy]
/// 自报选的是哪一种，调用方据此决定「await 重试」还是「catch 背压错误」。
/// 对同一条流，所选策略**在生命周期内不得改变**（决定记录 R4）。
enum OverflowPolicy {
  /// 缓冲已满后 [PeerStream.send] 挂起，直到水位降到 `maxBufferedAmount`
  /// 以下才返回。适合内存充裕、宁可等也不抛错的场景。
  wait,

  /// 缓冲已满后 [PeerStream.send] 抛 [BackpressureOverflowError]。
  /// 适合内存预算硬约束、必须立刻止损的场景。
  fail,
}

/// 发送侧缓冲触顶抛出的背压溢出错误（[OverflowPolicy.fail] 专用）。
///
/// 调用方（如 BlobGateway）应对它做「等水位下降再重试」，与 sync 冲突、
/// vault 拒绝等不可重试错误区分开（§3.6 的 code/message/reason/suggestion
/// 四段齐备）。
final class BackpressureOverflowError extends StorageError {
  /// 构造一个背压溢出错误。
  BackpressureOverflowError()
      : super(
          code: 'storage.backpressure_overflow',
          message: 'Send buffer overflowed (backpressure)',
          reason:
              'Peer consumes slower than local send rate; bufferedAmount '
              'reached maxBufferedAmount',
          suggestion: '请等待发送缓冲水位下降后重试，或减小单次发送批大小',
        );
}

/// 一条已认证连接上的逻辑流。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
/// - 超时约定：发送应在会话的传输超时内返回或抛超时。
///
/// 多路复用隔离（S3c-c-pre 决定记录 D1，方案 C）：
/// 同一条会话上的多条逻辑流复用同一条物理连接。**一条流的背压不得饿死
/// 另一条流**：本流因 [overflowPolicy] 触顶挂起/抛错时，同一会话上其他流
/// 的 [send] 必须照常完成。契约测试 A6 验证。
abstract interface class PeerStream {
  /// 对端发来的字节流。
  ///
  /// 背压传导（S3c-c-pre 决定记录 D3）：实现必须实现订阅者 `pause()`
  /// 语义 —— 订阅者 `pause()` 后，压力必须传导到对端发送侧：对端连续
  /// [send] 时其 [bufferedAmount] 增长，并在达到 [maxBufferedAmount] 后
  /// 触发其 [overflowPolicy] 行为；本端不得无限缓冲。契约测试 A5 验证。
  Stream<List<int>> get incoming;

  /// 发送侧背压上限（字节）。
  ///
  /// 与实现的内存预算绑定（WebRTC 通道缓冲 / socket 缓冲区大小随环境
  /// 不同），因此是只读查询、不由调用方设置。调用方用它与 [bufferedAmount]
  /// 判断「现在写会不会撑爆」。
  int get maxBufferedAmount;

  /// 当前发送水位（字节）：已交给本地发送缓冲、尚未发出的字节数。
  ///
  /// 实现上的取值（决定记录 D2）：WebRTC 直接用原生
  /// `RTCDataChannel.bufferedAmount`；LAN socket 用「已 write - 已 flush」
  /// 自记账（`flush()` 完成 = 已交给内核）。
  ///
  /// 对端消费慢只经由传输层流控**间接**推高本值（对端停读 → TCP 窗口 /
  /// SCTP 接收窗关闭 → 本地发送缓冲积压）；本契约**不要求**应用层消费确认。
  ///
  /// 调用方可轮询它判断「现在写会不会撑爆」；而 [send] 的挂起/抛错才是
  /// 可 await 的事件语义（何时能继续写），见 [send] 的背压语义。
  int get bufferedAmount;

  /// 溢出策略：发送水位触顶（`bufferedAmount >= maxBufferedAmount`）时的行为。
  ///
  /// 契约固定两种明文策略（[OverflowPolicy]），实现运行时自报选哪一种。
  /// **同一条流的生命周期内不得改变**（决定记录 R4）：调用方读到该策略后，
  /// 后续每次 [send] 的行为都必须与之一致 —— 不得在调用方读到 `wait` 后
  /// 突然抛出 [BackpressureOverflowError]（TOCTOU）。契约测试 R4 验证。
  OverflowPolicy get overflowPolicy;

  /// 发送一段字节。
  ///
  /// 参数说明：
  /// - [bytes]: 要发送的字节。
  ///
  /// 背压语义（S3c-c-pre 决定记录 D2）：
  /// - 入口检查：调用时若 `bufferedAmount >= maxBufferedAmount`，按
  ///   [overflowPolicy] 行动 —— [OverflowPolicy.wait] 挂起直到水位降到
  ///   `maxBufferedAmount` 以下才返回；[OverflowPolicy.fail] 抛
  ///   [BackpressureOverflowError]。
  /// - 入口未满时接受本包；接受后水位可短暂超过上限，越界被限制为
  ///   **最多超出 [maxBufferedAmount] 一个在途批次**（一次 [send] 调用
  ///   接受的字节数，与 WebRTC 原生 bufferedAmount 行为一致）。因此调用方
  ///   用 `while (bufferedAmount < maxBufferedAmount)` 压满不会死锁。
  /// - 并发：[send] 允许并发调用（多条 in-flight，不逐条 await）。契约
  ///   写死越界上限即上面那条 —— 实现不得让并发下水位无界上涨；wait 策略
  ///   下并发调用各自挂起，对端消费后逐个恢复，不得丢字节。契约测试 R5 验证。
  /// - 多路复用隔离见本类说明：本流触顶不得饿死同一会话上的其他流。
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

  /// 开一条逻辑流（**出站**：本端主动发起）。
  ///
  /// 参数说明：
  /// - [kind]: 逻辑流类型。
  ///
  /// 约定：
  /// - 同一条 session 上不同 kind 的流必须互不阻塞（多路复用）。
  /// - 每次调用返回**不同实例**；契约测试必须 `await` 后再比实例，
  ///   直接比较两个 `Future` 恒不相等，那样的断言是恒绿的。
  Future<PeerStream> openStream(StreamKind kind);

  /// 对端主动开流时，这里出一条已就绪的逻辑流（**入站**）。
  ///
  /// 与 [openStream] 对称。没有它，双方都只能自己开流、无法接受对方开的流，
  /// 多路复用只在一个方向上成立。
  ///
  /// 约定：
  /// - 本流只投递**对端发起**的 [PeerStream]，不回显本端 [openStream] 的结果。
  Stream<PeerStream> get incomingStreams;

  /// 关闭会话（含其全部逻辑流）。
  Future<void> close();
}

/// 物理连接抽象。一个 [Channel] 值对应恰好一个 Transport 实现
/// （[Channel.cloud] 除外 —— 云端走 SyncPeer 直连，不经 Transport）。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
/// 主动侧（[discover] / [connect]）与被动侧（[advertise] / [incoming]）
/// **必须成对存在**：只有主动侧时两台装同一 app 的设备都只会拨号，
/// 没有一方会接听，物理上无法建连。
abstract interface class Transport {
  /// 本 transport 对应的通道。
  Channel get channel;

  // ── 主动侧 ──────────────────────────────────────────────

  /// 发现可达对端。LAN 走 mDNS（bonsoir 的 discovery 侧）；
  /// WebRTC 走信令后由 ICE 打洞。
  ///
  /// 参数说明：
  /// - [timeout]: 发现超时（可选）。
  Stream<DiscoveredPeer> discover({Duration? timeout});

  /// 建立会话（**主动拨号**）。握手必须完成认证密钥交换并把指纹绑定到会话
  /// （channel binding），否则带外指纹比对对主动 MITM 无效。规格见 S6。
  ///
  /// 参数说明：
  /// - [peer]: 被发现的对端。
  /// - [keys]: 本端设备身份密钥（私钥不出实现，见 [DeviceKeyStore]）。
  /// - [cancel]: 取消令牌（可选）。
  Future<PeerSession> connect(
    DiscoveredPeer peer, {
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  });

  // ── 被动侧 ──────────────────────────────────────────────

  /// 开始广播本机存在，使对端的 [discover] 能看见本机。
  /// LAN 走 mDNS 发布（bonsoir 的 broadcast 侧）；WebRTC 走信令注册。
  ///
  /// 参数说明：
  /// - [keys]: 本端设备身份密钥。
  /// - [cancel]: 取消令牌（可选）。
  ///
  /// 隐私约定（**本方法才是真正执行广播的地方，约定写在这里才可实现可验**）：
  /// - 广播内容只含 [AdvertisementHandle.transientServiceId]，
  ///   **不含 scopeUid、用户名或设备名**（见 §6.3）。
  /// - 该 id 必须在 [AdvertisementHandle.rotateAfter] 后轮换，防长期追踪。
  Future<AdvertisementHandle> advertise({
    required DeviceKeyStore keys,
    CancellationToken? cancel,
  });

  /// 停止广播。幂等：未在广播时调用不得抛错。
  Future<void> stopAdvertising();

  /// 对端主动连进来时，这里出一个**已完成认证**的会话（**接听**）。
  ///
  /// 与 [connect] 对称。约定：
  /// - 只投递握手与认证均已通过的会话；认证失败的连接**不得**出现在本流。
  /// - 未调用 [advertise] 时本流不产出元素（但订阅本身合法，不得抛错）。
  Stream<PeerSession> get incoming;

  /// 释放本 transport 占用的全部资源（含仍在进行的广播）。
  Future<void> dispose();
}
