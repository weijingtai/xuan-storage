/// P2P 信令端口（设计稿 §6.3 裁定 C3、§9.5 裁定 C2）。
///
/// 【本文件解决的问题】点对点连接建立前，双方必须先交换会话描述（SDP）与
/// 候选地址（ICE candidate）。这个交换过程本身需要一条通道 —— 那就是信令。
/// 信令通道与数据通道是两回事：信令只传「怎么连」，连上之后即失效。
///
/// 【为什么是接口而不是直接写某个后端】裁定 C3：信令后端可换，实现分层落包，
/// **传输层实现不得直接依赖任何具体后端 SDK**。与本仓「Repository +
/// 可切换 RemoteDataSource」的既有风格一致。
///
/// 【本文件刻意不点名任何后端】具体选型（首实现用哪个实时数据库、局域网发现
/// 用哪个包）写在设计稿与任务纪要里，不写在契约里 —— 契约里出现后端名，
/// 哪怕只在注释中，也会让后人以为绑定了它。契约只声明**后端必须具备什么能力**
/// （见 [SignalingSession.peerPresence]），选型据此挑选。
/// 本约定由契约测试的源码扫描守卫强制。
///
/// 【两种拓扑必须都能塞进来】裁定 C2 把 S3b（局域网直连）降级为本端口的一个
/// 实现，于是本端口要同时容纳两种形态迥异的拓扑：
///
/// - **局域网直连**：发现对端后**直接连过去**交换 SDP，全程零外网。
///   有直接地址，但没有共享房间。
/// - **云端中转**：双方各自连到**第三方会合点**中转。有共享房间，
///   但建连前没有对端地址。
///
/// 二者的最大公约数**既不是「地址」也不是「房间」**，而是
/// [RendezvousKey]：双方事先各自知道同一个标识符，此后在这个标识符下双向
/// 收发信封。「标识符如何变成一条真实链路」属实现，不属契约。
///
/// 本文件零实现。两个实现分别落在后续轮次（局域网实现、云端实现）。
library;

import 'cancellation_token.dart';

/// 会合标识：两端事先各自知道的同一个标识符。
///
/// 这是本端口对两种拓扑的统一抽象（见库级注释）。它的**来源**因实现而异：
/// - 局域网：来自 mDNS 广播里的 `AdvertisementHandle.transientServiceId`；
/// - 云端：来自设备配对时约定的会合 id。
///
/// 隐私约定：与 `AdvertisementHandle.transientServiceId` 同源同要求 ——
/// **不得**含 scopeUid、用户名或设备名，且应可轮换。
typedef RendezvousKey = String;

/// 会话描述的方向。
enum SdpKind {
  /// 主叫方发出的 offer。一次握手中**有且仅有一条**。
  offer,

  /// 被叫方回应的 answer。一次握手中**有且仅有一条**。
  answer,
}

/// 对端在本会合标识下的存活状态。
///
/// 【为什么 [awaiting] 与 [departed] 必须分开】二者都表示「此刻没有对端」，
/// 但调用方的正确反应相反：前者该继续等，后者该立刻放弃。若合并成一个
/// 「不在线」，调用方就只能靠超时去猜对端是没来还是已经走了 —— 而那恰好
/// **抹掉了「后端能主动告知对端已断开」这个能力的全部价值**
/// （见 [SignalingSession.peerPresence] 的后端能力要求）。
enum PeerPresence {
  /// 尚未见到对端。刚 [SignalingChannel.open] 而对端还没出现时即此状态。
  ///
  /// 调用方应继续等待。
  awaiting,

  /// 对端在线，可以发信封。
  present,

  /// 对端**已确认离开**（正常告别，或被后端判定为断开）。
  ///
  /// 调用方应停止等待，不要再往这条会合标识发信封。
  departed,
}

/// 信令信封：在信令通道上传输的消息。
///
/// 【为什么是封闭类型，而不是带一个自由载荷】
/// 「信令只传怎么连、不传任何用户数据」这条约定，如果只靠契约测试断言
/// 「当前载荷里没有 scopeUid」，那它抓的是**样本**不是**规则** —— 后人往
/// 一个自由键值载荷里塞任何东西都照样通过。
///
/// 封闭类型把这条约定变成**类型系统的事实**：变体穷尽，每个变体的字段都是
/// 定死的具名字段，没有任何自由载荷口子。想塞用户数据就必须新增变体，
/// 而新增变体会让所有 `switch` 的穷尽性检查变红，改动无法悄悄发生。
///
/// 这与 `Transport.advertise()` 返回 `AdvertisementHandle` 是同一手法：
/// 把隐私约定从一句注释变成一条可机械验证的结构。
sealed class SignalingEnvelope {
  /// 构造一个信封。本类不可被外部直接实例化，只能通过三个变体。
  const SignalingEnvelope();
}

/// 会话描述信封：承载一条 SDP。
///
/// 【为什么与候选地址分开】二者时序不同：SDP 是 offer/answer 各一条，
/// 候选地址则陆续到达、条数不定（trickle 式收集）。合并成一种「万能消息」
/// 会让实现无法表达「offer 有且仅有一条」这个事实。
final class SessionDescriptionEnvelope extends SignalingEnvelope {
  /// 本条描述是 offer 还是 answer。
  final SdpKind kind;

  /// SDP 文本本体（RFC 8866 格式）。
  ///
  /// 它描述的是媒体与传输参数（编解码、DTLS 指纹、ICE 凭据），
  /// **不含任何业务数据**。
  final String sdp;

  /// 构造一条会话描述信封。
  ///
  /// 参数说明：
  /// - [kind]: offer 还是 answer。
  /// - [sdp]: SDP 文本。
  const SessionDescriptionEnvelope({
    required this.kind,
    required this.sdp,
  });
}

/// 候选地址信封：承载一条 ICE candidate。
///
/// 一次握手会产生多条（trickle 式：边收集边发送，不等全部收集完）。
final class IceCandidateEnvelope extends SignalingEnvelope {
  /// candidate 文本（`candidate:...` 形式）。
  final String candidate;

  /// 该 candidate 所属的媒体流标识（SDP 的 `a=mid` 值）。
  final String sdpMid;

  /// 该 candidate 所属的媒体描述在 SDP 中的序号。
  final int sdpMLineIndex;

  /// 构造一条候选地址信封。
  ///
  /// 参数说明：
  /// - [candidate]: candidate 文本。
  /// - [sdpMid]: 媒体流标识。
  /// - [sdpMLineIndex]: 媒体描述序号。
  const IceCandidateEnvelope({
    required this.candidate,
    required this.sdpMid,
    required this.sdpMLineIndex,
  });
}

/// 告别信封：本端主动离开本会合标识。
///
/// 与 [PeerPresence.departed] 的关系：收到本信封的一方**必须**观测到
/// `departed`。区别在于本信封是**主动告别**，而 `departed` 也可能由后端
/// 在**非正常断开**时判定产生（见 [SignalingSession.peerPresence]）。
final class ByeEnvelope extends SignalingEnvelope {
  /// 构造一条告别信封。
  const ByeEnvelope();
}

/// 一条已打开的双向信令会话。
///
/// 生命周期：[SignalingChannel.open] 产出 → 双方交换信封 → 数据通道建立
/// → [close]。**信令会话在数据通道建成后即应关闭**，它不是长连接。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
abstract interface class SignalingSession {
  /// 本会话所在的会合标识。
  RendezvousKey get rendezvous;

  /// 对端发来的信封。
  ///
  /// 约定：
  /// - 只投递**对端**发来的信封，不回显本端 [send] 的内容。
  Stream<SignalingEnvelope> get incoming;

  /// 对端存活状态。
  ///
  /// 【后端能力要求 —— 换后端时不得漏掉这条】
  /// - 实现必须在对端**非正常断开**（进程被杀、断网、崩溃）时产出
  ///   [PeerPresence.departed]，**不得要求调用方靠超时自行推断**。
  /// - 对云端实现，这要求所选后端具备「**服务端可感知客户端断开并自动摘除
  ///   其信令节点**」的能力。这不是可选项：信令节点是短命的，设备断线就该
  ///   消失，否则对端会去连一个已不存在的候选并白白超时。
  ///   **选型时若后端无此原生能力，就必须自行实现心跳 + 超时清理来补上，
  ///   代价须计入选型评估。**（裁定 C3 的首实现正是据此挑选的。）
  /// - 对局域网实现，这要求在底层连接断开时产出 [PeerPresence.departed]。
  /// - 订阅后应立即得到一个当前状态，不必等到下次变化。
  Stream<PeerPresence> get peerPresence;

  /// 向对端发一个信封。
  ///
  /// 参数说明：
  /// - [envelope]: 要发送的信封。
  ///
  /// 约定：
  /// - 对端处于 [PeerPresence.departed] 时发送应抛错，不得静默丢弃。
  Future<void> send(SignalingEnvelope envelope);

  /// 关闭本信令会话。
  ///
  /// 约定：
  /// - 关闭前应尽力向对端发出 [ByeEnvelope]，使对端能立即观测到
  ///   [PeerPresence.departed] 而不必等后端超时判定。
  /// - 幂等：重复调用不得抛错。
  Future<void> close();
}

/// 信令通道端口：点对点建连所需的 SDP 与候选地址交换通道。
///
/// 一个实现对应一种拓扑（局域网直连 / 云端中转），二者共用本契约 ——
/// 详见库级注释「两种拓扑必须都能塞进来」。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
/// - 超过 1 秒的方法接受 `CancellationToken?`。
abstract interface class SignalingChannel {
  /// 在指定会合标识下打开一条双向信令会话。
  ///
  /// 参数说明：
  /// - [rendezvous]: 会合标识。双方必须用同一个值才能相遇。
  /// - [cancel]: 取消令牌（可选）。等待对端可能耗时很久，故必须可取消。
  ///
  /// 约定：
  /// - **不阻塞等待对端到场**：返回的会话此刻可能处于
  ///   [PeerPresence.awaiting]。调用方通过
  ///   [SignalingSession.peerPresence] 观测对端何时出现。
  ///   （若在此阻塞，局域网的「先到者等待」与云端的「双方异步入场」
  ///   就得各写一套等待语义。）
  /// - 同一 [rendezvous] 重复 open 的行为由实现定义，调用方不应依赖。
  Future<SignalingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  });

  /// 释放本通道占用的资源（含其打开的全部会话）。
  Future<void> dispose();
}
