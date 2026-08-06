/// 设备配对端口（S6 / 设计稿 §6.3、任务纪要 ACT 2/3）。
///
/// 【本文件解决的问题】两台设备在数据通道建立之前，必须先互认身份并
/// 协商出**对称的带外配对指纹**供用户肉眼/扫码比对。这个交换过程跑在
/// 会合标识（rendezvous）语义上，与 [SignalingChannel] 同构 —— 但
/// 信令信封（[SignalingEnvelope]）是 SDP/ICE 专用的**封闭类型**，没有
/// 承载公钥/挑战-应答的变体；给封闭类型加变体属于契约变更，本轮不碰
/// signaling.dart。因此配对层定义自己的信封（[PairingEnvelope]）与
/// 会话（[PairingSession]），语义对齐信令端口。
///
/// 【channel binding（ACT 3）】签名对象钉死为
/// `nonce ‖ localCertificateFingerprint ‖ localPublicKeyFingerprint
///  ‖ peerPublicKeyFingerprint`（Q3 v2 洞二）：每端签**本端自己证书的
/// 指纹**（洞一方案 A），两端各自签、不对称。对端**不验签**该声明（验签
/// 只保证声明未被改、确是本端发的），而是拿声明里的证书指纹去比自己
/// **这一腿观测到的对端证书指纹**：无 MITM 则等，MITM 替换则不等 →
/// 带外比对发现。
///
/// 【channel binding（真形态，Q3 v2 已批准落地）】`Transport` 契约已新增
/// [ChannelBinding] 值类与 `PeerSession.channelBinding` getter（transport.dart，
/// 本轮改动，既有成员未动）。本端证书指纹进入签名对象并被本端私钥签名；
/// 验证侧的「声明 vs 观测」比对由 `p2p` 的 [enforceChannelBindingMatches]
/// 提供（Q3 v2 洞三：强制发生在 `Transport.connect`/`advertise` 握手内部，
/// 该函数供 S3c-c 握手实现调用）。规格见
/// `docs/storage-s6-keystore-pairing/CHANNEL-BINDING-SPEC.md`。
///
/// 【为什么信封字段都是字符串】公钥 PEM、指纹（SHA-256 hex `:` 分组）、
/// nonce（hex）、签名（base64）都可经 JSON 序列化 —— 生产实现（未来把
/// 配对消息经信令通道转发时）无需改造契约。
library;

import 'cancellation_token.dart';
import 'signaling.dart';
import 'storage_error.dart';

/// 配对信封：在配对通道上传输的消息（S6 自己的封闭类型，不碰
/// [SignalingEnvelope]）。
///
/// 变体穷尽，字段定死 —— 与信令信封同一手法：把「配对只传身份与
/// 挑战-应答、不传业务数据」变成类型系统的事实。
sealed class PairingEnvelope {
  /// 构造一个配对信封。本类不可被外部直接实例化。
  const PairingEnvelope();
}

/// 配对 offer：本端身份声明。
///
/// 携带 deviceId 与公钥 PEM。**不携带证书指纹** —— 证书指纹属于
/// 签名对象（channel binding），由挑战/应答阶段签名声明，不在本阶段
/// 明文传输（防替换：明文传输的指纹若被改，验签会发现不了）。
final class PairingOfferEnvelope extends PairingEnvelope {
  /// 本端设备唯一标识。
  final String deviceId;

  /// 本端公钥（Ed25519 SPKI PEM）。对端用它验本端的签名。
  final String publicKeyPem;

  /// 构造一条配对 offer。
  const PairingOfferEnvelope({
    required this.deviceId,
    required this.publicKeyPem,
  });
}

/// 配对挑战：deviceId 较小的一端（双方各自排序可得出同一结论）发出。
///
/// 签名对象（ACT 3 规格）：
/// `nonce ‖ localCertificateFingerprint ‖ localPublicKeyFingerprint
///  ‖ peerPublicKeyFingerprint`（UTF-8 字节，字段间以 `|` 分隔）。
/// 签名用**本端私钥**，验签用对端从 offer 拿到的公钥 PEM。
final class PairingChallengeEnvelope extends PairingEnvelope {
  /// 挑战 nonce（hex）。应答方必须原样使用，不得重新生成。
  final String nonce;

  /// 本端声明的传输层证书指纹（签名对象的一部分，防替换）。
  final String localCertificateFingerprint;

  /// 本端公钥指纹（签名对象的一部分）。
  final String localPublicKeyFingerprint;

  /// 对端公钥指纹（签名对象的一部分）。
  final String peerPublicKeyFingerprint;

  /// 本端对上述签名对象的 Ed25519 签名（base64）。
  final String signatureBase64;

  /// 构造一条配对挑战。
  const PairingChallengeEnvelope({
    required this.nonce,
    required this.localCertificateFingerprint,
    required this.localPublicKeyFingerprint,
    required this.peerPublicKeyFingerprint,
    required this.signatureBase64,
  });
}

/// 配对应答：对挑战的回应，字段形状与挑战一致（同一 nonce 下的
/// 本端签名对象）。
final class PairingAnswerEnvelope extends PairingEnvelope {
  /// 原样回传挑战的 nonce。
  final String nonce;

  /// 本端声明的传输层证书指纹。
  final String localCertificateFingerprint;

  /// 本端公钥指纹。
  final String localPublicKeyFingerprint;

  /// 对端公钥指纹。
  final String peerPublicKeyFingerprint;

  /// 本端对签名对象的 Ed25519 签名（base64）。
  final String signatureBase64;

  /// 构造一条配对应答。
  const PairingAnswerEnvelope({
    required this.nonce,
    required this.localCertificateFingerprint,
    required this.localPublicKeyFingerprint,
    required this.peerPublicKeyFingerprint,
    required this.signatureBase64,
  });
}

/// 配对失败（契约 §3.6：失败一律抛 StorageError 子类）。
final class PairingError extends StorageError {
  /// 构造一个配对错误。
  PairingError({
    required super.message,
    required super.reason,
    required super.suggestion,
  }) : super(code: 'storage.pairing');
}

/// 配对时签名验证失败：对端的挑战/应答签名用其声明的公钥验不过。
///
/// 出现即意味着信封在信令通道上被篡改（或身份声明与签名不匹配）。
final class PairingSignatureError extends PairingError {
  /// 构造一个签名验证失败错误。
  PairingSignatureError({
    required super.message,
    required super.reason,
    required super.suggestion,
  });
}

/// 配对时 channel binding 指纹比对失败：对端签名声明的证书指纹 ≠
/// 本端这一腿观测到的对端证书指纹。
///
/// 这正是 MITM 攻击（攻击者替换 DTLS/SDP 指纹）被发现的路径
/// （设计稿 §5.2b、任务纪要 ACT 6 / A5）。
final class PairingBindingMismatchError extends PairingError {
  /// 构造一个指纹比对失败错误。
  PairingBindingMismatchError({
    required super.message,
    required super.reason,
    required super.suggestion,
  });
}

/// 一条已打开的双向配对会话（语义对齐 [SignalingSession]）。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
abstract interface class PairingSession {
  /// 本会话所在的会合标识。
  RendezvousKey get rendezvous;

  /// 对端发来的配对信封。
  ///
  /// 约定：
  /// - 只投递**对端**发来的信封，不回显本端 [send] 的内容。
  Stream<PairingEnvelope> get incoming;

  /// 对端存活状态（语义同 [SignalingSession.peerPresence]）。
  Stream<PeerPresence> get peerPresence;

  /// 向对端发一个配对信封。
  ///
  /// 约定：
  /// - 对端处于 [PeerPresence.departed] 时发送应抛错，不得静默丢弃。
  Future<void> send(PairingEnvelope envelope);

  /// 关闭本配对会话。
  ///
  /// 约定：
  /// - 幂等：重复调用不得抛错。
  Future<void> close();
}

/// 配对通道端口：在指定会合标识下交换配对信封。
///
/// 一个实现对应一种承载（本轮测试用内存 fabric；未来可经信令通道
/// 转发或独立 socket —— 属实现细节，不属契约）。
abstract interface class PairingChannel {
  /// 在指定会合标识下打开一条双向配对会话。
  ///
  /// 参数说明：
  /// - [rendezvous]: 会合标识。双方必须用同一个值才能相遇。
  /// - [cancel]: 取消令牌（可选）。等待对端可能耗时很久，故必须可取消。
  Future<PairingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  });

  /// 释放本通道占用的资源（含其打开的全部会话）。
  Future<void> dispose();
}
