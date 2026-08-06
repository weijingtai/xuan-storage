/// 设备配对流程实现（S6 / ACT 2，跑在 [PairingChannel] 上）。
///
/// 【流程】双方 open 同一 rendezvous → 等对端到场（presence）→ 交换
/// offer（deviceId + 公钥 PEM）→ deviceId 较小者发起挑战 → 双方各自
/// 验证对方签名 + channel binding 指纹比对 → 各自算出**对称**的带外
/// 配对指纹 `SHA-256(sort([localPubFp, peerPubFp]))`（不含证书指纹，
/// 两端相同）。
///
/// 【channel binding（ACT 3，Q3 v2 已批准）】签名对象 =
/// `nonce ‖ localCertificateFingerprint ‖ localPublicKeyFingerprint
///  ‖ peerPublicKeyFingerprint`（UTF-8，字段间 `|` 分隔）。每端签本端
/// 自己证书的指纹（Q3 v2 洞一方案 A），指纹来自传输层的
/// [ChannelBinding]（生产实现取 `PeerSession.channelBinding`）。绑定的
/// **强制**（对端声明指纹 == 本端这一腿观测到的对端证书指纹）发生在
/// [Transport.connect]/[Transport.advertise] 握手内部（Q3 v2 洞三）：
/// 握手不产出会话，配对层据此发现 MITM。
///
/// 【MITM 检测】信令被攻破、攻击者替换 DTLS/SDP 指纹时：
/// - 攻击者改签名对象 → 配对层验签失败 → [PairingSignatureError]；
/// - 攻击者用自己证书替换对端证书（B 观测到 M、A 声明 X）→
///   [Transport] 握手强制比对 X ≠ M → 会话不产出 →
///   [PairingBindingMismatchError]（配对层发现）。
///
/// 【订阅模型】本流程对 `session.incoming` 只建立**一次**持久订阅，
/// 事件进 inbox 队列 / 唤醒等待者 —— 不依赖流是否可多次监听（单订阅
/// 流取消后不可再监听是 Dart 语义，逐次 firstWhere 会踩这个坑）。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:persistence_core/persistence_core.dart';

import 'pairing_identity.dart';

/// 配对结果：两端各自算出的对称带外指纹 + 对端身份。
final class PairingResult {
  /// 对端身份（deviceId + 对端公钥指纹）。
  final PeerIdentity remote;

  /// **对称**带外配对指纹：`SHA-256(sort([localPubFp, peerPubFp]))`
  /// 的 hex（`:` 分组）。两端算出的值**必须相同**，供用户肉眼/扫码比对。
  final String outOfBandFingerprint;

  /// 本端公钥指纹。
  final String localPublicKeyFingerprint;

  /// 对端在其签名对象里**声明**的传输层证书指纹（验签通过后可信）。
  ///
  /// 这是 channel binding 的输入：`Transport.connect` 握手时拿它与
  /// 本端这一腿观测到的对端证书指纹比对（Q3 v2 洞三），不等即拒绝
  /// 产出会话（MITM 被发现）。
  final String peerDeclaredCertificateFingerprint;

  /// 构造一个配对结果。
  const PairingResult({
    required this.remote,
    required this.outOfBandFingerprint,
    required this.localPublicKeyFingerprint,
    required this.peerDeclaredCertificateFingerprint,
  });
}

/// 设备配对流程：把 [PairingIdentityProvider]（身份）与 [PairingChannel]
/// （会合）组装成一次可验证的配对。
///
/// 线程模型：全部异步。失败一律抛 [PairingError] 子类。
final class DevicePairingProtocol {
  /// 构造配对协议。
  ///
  /// 参数说明：
  /// - [channel]: 配对通道（本轮测试注入内存 fabric）。
  /// - [keys]: 本端设备身份（私钥不出实现，见 [PairingIdentityProvider]）。
  /// - [binding]: 真 channel binding（Q3 v2）：本端传输层证书指纹
  ///   （来自 [ChannelBinding]，生产实现取 `PeerSession.channelBinding`）。
  ///   它进入签名对象并被本端私钥签名。null 表示本端不参与 channel
  ///   binding（签名对象里证书指纹为空串，规格文档写明限制）。
  DevicePairingProtocol({
    required this._channel,
    required this._keys,
    this._binding,
  });

  final PairingChannel _channel;
  final PairingIdentityProvider _keys;
  final ChannelBinding? _binding;

  /// 单次配对流程的最长等待时间。
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// 在 [rendezvous] 下与对端完成一次配对。
  ///
  /// 流程（双方对称，deviceId 排序决定谁先挑战）：
  /// 1. open 同一会合标识；
  /// 2. 等对端到场（[PeerPresence.present]）；
  /// 3. 双方互发 [PairingOfferEnvelope]（deviceId + 公钥 PEM）；
  /// 4. deviceId 较小者生成 nonce，签
  ///    `nonce ‖ 本端证书指纹 ‖ 本端公钥指纹 ‖ 对端公钥指纹` 发挑战；
  /// 5. 应答方验挑战签名 + 指纹比对，签同一 nonce 发应答；
  /// 6. 挑战方验应答签名 + 指纹比对；
  /// 7. 双方各自算对称带外指纹并返回。
  Future<PairingResult> pair(
    RendezvousKey rendezvous, {
    Duration timeout = defaultTimeout,
  }) async {
    final session = await _channel.open(rendezvous);
    final inbox = <PairingEnvelope>[];
    final waiters = <Completer<PairingEnvelope>>[];
    // 整个流程只建立一次订阅：事件先进 inbox，等待者按序唤醒。
    final sub = session.incoming.listen((e) {
      if (waiters.isNotEmpty) {
        waiters.removeAt(0).complete(e);
      } else {
        inbox.add(e);
      }
    });
    try {
      // 信令语义：先到者等后到者 —— 对端到场前不发送任何配对消息。
      await session.peerPresence
          .firstWhere((p) => p == PeerPresence.present)
          .timeout(timeout, onTimeout: () {
        throw PairingError(
          message: '配对超时：对端未到场',
          reason: '对端未在 $timeout 内 open 同一会合标识',
          suggestion: '确认两端使用同一会合标识后重试',
        );
      });

      final identity = await _keys.localIdentity;
      final publicKeyPem = await _keys.localPublicKeyPem;
      final localPublicKeyFingerprint = identity.publicKeyFingerprint;

      // ── 第 3 步：双方互发 offer ──
      await session.send(PairingOfferEnvelope(
        deviceId: identity.deviceId,
        publicKeyPem: publicKeyPem,
      ));

      final offer = await _nextFromInbox<PairingOfferEnvelope>(
        inbox,
        waiters,
        timeout,
        onTimeoutMessage: '配对超时：未收到对端 offer',
        onTimeoutSuggestion: '确认两端使用同一会合标识后重试',
      );

      // 对端公钥指纹：从 PEM 本地派生（SHA-256(公钥原始 32B)），
      // 不信任 offer 里可能被篡改的字段。
      final peerPublicKeyFingerprint =
          await _fingerprintHexFromPem(offer.publicKeyPem);

      // ── 第 4 步：deviceId 排序决定挑战方（双方算出同一结论）──
      final iAmChallenger = identity.deviceId.compareTo(offer.deviceId) < 0;

      // 对端在其签名对象里声明的证书指纹（验签通过后可信）——
      // channel binding 的输入，供 Transport 握手比对观测值。
      late final String declaredPeerCertFp;

      final String nonce;
      if (iAmChallenger) {
        nonce = _newNonce();
        await session.send(PairingChallengeEnvelope(
          nonce: nonce,
          localCertificateFingerprint:
              _binding?.localCertificateFingerprint ?? '',
          localPublicKeyFingerprint: localPublicKeyFingerprint,
          peerPublicKeyFingerprint: peerPublicKeyFingerprint,
          signatureBase64: await _signBinding(
            nonce: nonce,
            localCertificateFingerprint:
                _binding?.localCertificateFingerprint ?? '',
            localPublicKeyFingerprint: localPublicKeyFingerprint,
            peerPublicKeyFingerprint: peerPublicKeyFingerprint,
          ),
        ));
        final answer = await _nextFromInbox<PairingAnswerEnvelope>(
          inbox,
          waiters,
          timeout,
          onTimeoutMessage: '配对超时：未收到对端应答',
          onTimeoutSuggestion: '检查对端配对流程是否正常后重试',
        );
        declaredPeerCertFp = await _verifyBindingEnvelope(
          nonce: answer.nonce,
          localCertificateFingerprint:
              answer.localCertificateFingerprint,
          localPublicKeyFingerprint: answer.localPublicKeyFingerprint,
          peerPublicKeyFingerprint: answer.peerPublicKeyFingerprint,
          signatureBase64: answer.signatureBase64,
          expectedNonce: nonce,
          expectedMyFingerprint: localPublicKeyFingerprint,
          peerPublicKeyPem: offer.publicKeyPem,
        );
      } else {
        final challenge = await _nextFromInbox<PairingChallengeEnvelope>(
          inbox,
          waiters,
          timeout,
          onTimeoutMessage: '配对超时：未收到对端挑战',
          onTimeoutSuggestion: '检查对端配对流程是否正常后重试',
        );
        declaredPeerCertFp = await _verifyBindingEnvelope(
          nonce: challenge.nonce,
          localCertificateFingerprint:
              challenge.localCertificateFingerprint,
          localPublicKeyFingerprint: challenge.localPublicKeyFingerprint,
          peerPublicKeyFingerprint: challenge.peerPublicKeyFingerprint,
          signatureBase64: challenge.signatureBase64,
          expectedNonce: challenge.nonce,
          expectedMyFingerprint: localPublicKeyFingerprint,
          peerPublicKeyPem: offer.publicKeyPem,
        );
        nonce = challenge.nonce;
        await session.send(PairingAnswerEnvelope(
          nonce: nonce,
          localCertificateFingerprint:
              _binding?.localCertificateFingerprint ?? '',
          localPublicKeyFingerprint: localPublicKeyFingerprint,
          peerPublicKeyFingerprint: peerPublicKeyFingerprint,
          signatureBase64: await _signBinding(
            nonce: nonce,
            localCertificateFingerprint:
                _binding?.localCertificateFingerprint ?? '',
            localPublicKeyFingerprint: localPublicKeyFingerprint,
            peerPublicKeyFingerprint: peerPublicKeyFingerprint,
          ),
        ));
      }

      // ── 第 7 步：对称带外指纹 SHA-256(sort([localFp, peerFp])) ──
      final outOfBand = await _outOfBandFingerprint(
        localPublicKeyFingerprint: localPublicKeyFingerprint,
        peerPublicKeyFingerprint: peerPublicKeyFingerprint,
      );

      return PairingResult(
        remote: PeerIdentity(
          deviceId: offer.deviceId,
          publicKeyFingerprint: peerPublicKeyFingerprint,
        ),
        outOfBandFingerprint: outOfBand,
        localPublicKeyFingerprint: localPublicKeyFingerprint,
        peerDeclaredCertificateFingerprint: declaredPeerCertFp,
      );
    } finally {
      await sub.cancel();
      await session.close();
    }
  }

  // ── 私有：inbox、签名、验证、派生 ──────────────────────────

  /// 从 inbox 取下一条指定类型的信封；没有则注册等待者。
  ///
  /// [inbox] 与 [waiters] 由 `pair()` 创建并传给本方法 —— 整个流程
  /// 共用同一份（配对消息的到达顺序与消费顺序一一对应）。
  Future<T> _nextFromInbox<T extends PairingEnvelope>(
    List<PairingEnvelope> inbox,
    List<Completer<PairingEnvelope>> waiters,
    Duration timeout, {
    required String onTimeoutMessage,
    required String onTimeoutSuggestion,
  }) async {
    for (var i = 0; i < inbox.length; i++) {
      final e = inbox[i];
      if (e is T) {
        inbox.removeAt(i);
        return e;
      }
    }
    final completer = Completer<PairingEnvelope>();
    waiters.add(completer);
    try {
      final envelope = await completer.future.timeout(timeout, onTimeout: () {
        throw PairingError(
          message: onTimeoutMessage,
          reason: '对端未在 $timeout 内送达所期待的信封',
          suggestion: onTimeoutSuggestion,
        );
      });
      return envelope as T;
    } finally {
      waiters.remove(completer);
    }
  }

  /// 签名对象（ACT 3 规格）：`nonce ‖ 本端证书指纹 ‖ 本端公钥指纹
  /// ‖ 对端公钥指纹`，UTF-8，字段间以 `|` 分隔。
  static List<int> _bindingPayload({
    required String nonce,
    required String localCertificateFingerprint,
    required String localPublicKeyFingerprint,
    required String peerPublicKeyFingerprint,
  }) =>
      utf8.encode([
        nonce,
        localCertificateFingerprint,
        localPublicKeyFingerprint,
        peerPublicKeyFingerprint,
      ].join('|'));

  /// 用本端私钥签签名对象，返回 base64。
  Future<String> _signBinding({
    required String nonce,
    required String localCertificateFingerprint,
    required String localPublicKeyFingerprint,
    required String peerPublicKeyFingerprint,
  }) async {
    final payload = _bindingPayload(
      nonce: nonce,
      localCertificateFingerprint: localCertificateFingerprint,
      localPublicKeyFingerprint: localPublicKeyFingerprint,
      peerPublicKeyFingerprint: peerPublicKeyFingerprint,
    );
    final sig = await _keys.sign(payload);
    return base64.encode(sig);
  }

  /// 验证对端的挑战/应答信封（挑战与应答字段形状相同）。
  ///
  /// 顺序：① nonce 一致性 → ② 验签（防篡改）→ ③ 对端声明的本端
  /// 指纹 == 本端真实指纹。返回对端在其签名对象里**声明**的证书指纹
  /// （验签通过后可信）—— channel binding 输入，供 `Transport.connect`
  /// 握手与观测值比对（Q3 v2 洞三，比对强制在握手内部，不在本层）。
  Future<String> _verifyBindingEnvelope({
    required String nonce,
    required String localCertificateFingerprint,
    required String localPublicKeyFingerprint,
    required String peerPublicKeyFingerprint,
    required String signatureBase64,
    required String expectedNonce,
    required String expectedMyFingerprint,
    required String peerPublicKeyPem,
  }) async {
    if (nonce != expectedNonce) {
      throw PairingSignatureError(
        message: '配对信封 nonce 不一致',
        reason: '对端回传的 nonce ≠ 期望的 nonce',
        suggestion: '对端可能重放或篡改了配对消息',
      );
    }
    final payload = _bindingPayload(
      nonce: nonce,
      localCertificateFingerprint: localCertificateFingerprint,
      localPublicKeyFingerprint: localPublicKeyFingerprint,
      peerPublicKeyFingerprint: peerPublicKeyFingerprint,
    );
    final ok = await _keys.verify(
      payload: payload,
      signature: base64.decode(signatureBase64),
      peerPublicKeyPem: peerPublicKeyPem,
    );
    if (!ok) {
      throw PairingSignatureError(
        message: '配对信封签名验证失败',
        reason: '用对端公钥验对端签名不通过 —— 信封可能在信令通道上被篡改',
        suggestion: '中止配对并检查信令通道是否被劫持',
      );
    }
    if (peerPublicKeyFingerprint != expectedMyFingerprint) {
      throw PairingSignatureError(
        message: '配对信封声明的本端指纹不符',
        reason: '对端签名对象里的 peerPublicKeyFingerprint ≠ 本端真实指纹',
        suggestion: '对端可能拿到了错误的公钥信息',
      );
    }
    // channel binding 的「声明 vs 观测」比对不在本层做（Q3 v2 洞三：
    // 绑定强制在 Transport.connect/advertise 握手内部），这里只把
    // 验签通过的声明指纹交出去供握手比对。
    return localCertificateFingerprint;
  }

  /// 对称带外指纹：`SHA-256(sort([localFp, peerFp]))`，hex `:` 分组。
  static Future<String> _outOfBandFingerprint({
    required String localPublicKeyFingerprint,
    required String peerPublicKeyFingerprint,
  }) async {
    final sorted = [localPublicKeyFingerprint, peerPublicKeyFingerprint]
      ..sort();
    final hash = await Sha256().hash(utf8.encode(sorted.join(':')));
    return hash.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }

  /// 生成挑战 nonce（16 字节，hex）。
  static String _newNonce() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// SPKI PEM → 公钥原始字节（32B）。校验 RFC 8410 前缀。
  static List<int> _parsePublicKeyPem(String pem) {
    const prefix = [
      0x30, 0x2a, 0x30, 0x05, 0x06, 0x03, 0x2b, 0x65, 0x70, 0x03, 0x21, 0x00,
    ];
    try {
      final lines = pem
          .split('\n')
          .where((l) => !l.startsWith('-----') && l.trim().isNotEmpty)
          .join('');
      final der = base64.decode(lines);
      if (der.length != prefix.length + 32) {
        throw FormatException('SPKI DER 长度异常: ${der.length}');
      }
      for (var i = 0; i < prefix.length; i++) {
        if (der[i] != prefix[i]) {
          throw FormatException('SPKI 前缀不匹配（非 Ed25519？）');
        }
      }
      return der.sublist(prefix.length);
    } on Object catch (e) {
      throw PairingError(
        message: '对端公钥 PEM 解析失败',
        reason: '$e',
        suggestion: '确认 PEM 为标准 Ed25519 SPKI 格式',
      );
    }
  }

  /// 公钥 PEM → SHA-256 指纹（hex `:` 分组），与
  /// [PersistentDeviceKeyStore] 的指纹算法同源。
  static Future<String> _fingerprintHexFromPem(String pem) async {
    final publicKeyBytes = _parsePublicKeyPem(pem);
    final hash = await Sha256().hash(publicKeyBytes);
    return hash.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }
}

/// 握手内部的 channel binding 强制（Q3 v2 洞三的「怎么验」落地）。
///
/// 配对流程（[DevicePairingProtocol.pair]）验签通过后产出对端**声明**的
/// 传输层证书指纹（[PairingResult.peerDeclaredCertificateFingerprint]）。
/// 传输层握手（`Transport.connect`/`advertise`，S3c-c 实现）完成时观测到
/// 对端证书的真实指纹。本函数把两者比对：
///
/// - **相等 → 通过**：声明与观测一致，绑定成立，会话可产出。
/// - **不等 → [PairingBindingMismatchError]**（MITM 发现路径）：攻击者
///   替换传输层证书时（如 M 给 B 的腿发自己的证书，B 观测到 fp(M_self)、
///   A 声明 fp(A_self)），比对必然失败。
///
/// 为什么不在配对流程内部做比对（Q3 v2 洞三）：观测值来自传输层握手，
/// 而配对跑在信令层、先于传输握手 —— 配对完成时观测值尚不存在。本函数
/// 在 S6 交付「怎么验」（只实现「签什么」而不实现「怎么验」等于没做），
/// 供 S3c-c 的 `connect`/`advertise` 握手实现调用。
void enforceChannelBindingMatches({
  required String peerDeclaredCertificateFingerprint,
  required String observedPeerCertificateFingerprint,
}) {
  if (peerDeclaredCertificateFingerprint !=
      observedPeerCertificateFingerprint) {
    throw PairingBindingMismatchError(
      message: 'channel binding 比对失败：对端声明的证书指纹 ≠ 本端观测',
      reason: '对端声明 $peerDeclaredCertificateFingerprint，本端观测到 '
          '$observedPeerCertificateFingerprint —— 传输层证书可能被中间人替换',
      suggestion: '中止连接，检查信令通道是否被劫持、传输层证书来源是否可信',
    );
  }
}
