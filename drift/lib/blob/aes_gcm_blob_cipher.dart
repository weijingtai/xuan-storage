/// AES-GCM blob cipher（S6 / ACT 4，填 S1a 已定死的 `BlobCipher` 端口）。
///
/// 【布局】每个 chunk 的密文 = `[nonce(12B)] ‖ [cipherText ‖ mac(16B)]`：
/// nonce **内联在头部**（解密时从头部读出，无需外部状态），AES-GCM 的
/// 认证 tag 紧随密文。
///
/// 【per-chunk nonce 由 chunkIndex 派生】nonce 的派生输入**包含
/// chunkIndex**：`nonce = SHA-256(randomSeed ‖ chunkIndex)[0:12]`。
/// - randomSeed（16B，每 chunk 随机）：保证跨文件、跨 chunk 不重用
///   nonce（AES-GCM nonce 重用的后果是灾难性的）；
/// - chunkIndex 参与派生：同一文件内各 chunk 的 nonce 与位置绑定，
///   满足「per-chunk nonce 由 chunkIndex 派生」的硬约束。
/// 解密不重新派生（nonce 在头部），因此派生函数只约束生成端。
///
/// 【密钥（DEK）】经构造函数注入（app 组装根注入：p2p 的
/// `DeviceKeyStore` 派生 DEK → 注册进 drift 的 `BlobCipherRegistry`，
/// 见决定记录 Q1-补充 —— drift 不依赖 p2p）。
///
/// 【失败语义】密钥不可用 / 版本不匹配 / 密文被篡改（认证失败）一律抛
/// [BlobUndecryptableError]（契约：**重新下载无用**）。
library;

import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:persistence_core/persistence_core.dart';

/// AES-256-GCM 逐 chunk 加密的 [BlobCipher] 实现。
final class AesGcmBlobCipher implements BlobCipher {
  /// 构造 AES-GCM cipher。
  ///
  /// 参数说明：
  /// - [dek]: 数据加密密钥（32 字节）。**每设备一把独立 DEK**（D17），
  ///   严禁跨设备共享。经 app 组装根注入，不在跨包签名里出现。
  AesGcmBlobCipher({required List<int> dek})
      : _dek = SecretKey(List<int>.from(dek));

  final SecretKey _dek;
  final AesGcm _aesGcm = AesGcm.with256bits(nonceLength: nonceLength);

  /// nonce 长度（12 字节，GCM 标准推荐）。
  static const int nonceLength = 12;

  /// GCM 认证 tag 长度（16 字节）。
  static const int macLength = 16;

  /// nonce 派生的随机种子长度（16 字节，每 chunk 新取）。
  static const int _seedLength = 16;

  @override
  String get id => 'aes-256-gcm';

  @override
  int get currentKeyVersion => 1;

  @override
  Future<List<int>> encryptChunk(
    List<int> plain, {
    required int chunkIndex,
  }) async {
    final nonce = await _deriveNonce(chunkIndex);
    final box = await _aesGcm.encrypt(plain, secretKey: _dek, nonce: nonce);
    return <int>[...nonce, ...box.cipherText, ...box.mac.bytes];
  }

  @override
  Future<List<int>> decryptChunk(
    List<int> cipherBytes, {
    required int chunkIndex,
    required int keyVersion,
  }) async {
    if (keyVersion != currentKeyVersion) {
      // 密钥轮换未实现：版本不匹配即不可解（契约：重新下载无用）。
      throw BlobUndecryptableError();
    }
    if (cipherBytes.length < nonceLength + macLength) {
      throw BlobUndecryptableError();
    }
    final nonce = cipherBytes.sublist(0, nonceLength);
    final body = cipherBytes.sublist(nonceLength);
    final cipherText = body.sublist(0, body.length - macLength);
    final mac = body.sublist(body.length - macLength);
    try {
      return await _aesGcm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: _dek,
      );
    } on SecretBoxAuthenticationError {
      // 密文被篡改 / 密钥不对 → 认证失败 → 不可解。
      throw BlobUndecryptableError();
    }
  }

  /// per-chunk nonce 派生：`SHA-256(randomSeed ‖ chunkIndex)[0:12]`。
  Future<List<int>> _deriveNonce(int chunkIndex) async {
    final seed = _randomBytes(_seedLength);
    final input = <int>[...seed, ...utf8.encode('$chunkIndex')];
    final hash = await Sha256().hash(input);
    return hash.bytes.sublist(0, nonceLength);
  }

  /// 密码学安全随机字节。
  static List<int> _randomBytes(int length) {
    final rng = Random.secure();
    return List<int>.generate(length, (_) => rng.nextInt(256));
  }
}
