/// `DeviceKeyStore` 的真实现（S6 / 设计稿 §3.5、`transport.dart:80`）。
///
/// 【本文件解决的问题】`DeviceKeyStore` 契约只暴露 `localIdentity` / `sign()`
/// / `verify()` 三个能力，**私钥永不出实现**。本类用 `cryptography` 包的
/// Ed25519 落地这套语义：32 字节 seed 存 `flutter_secure_storage`（Android
/// Keystore / iOS Keychain 硬件背书；桌面端亦同--见决定记录 Q2），签名时
/// 按 seed 重建密钥对、签完即弃。
///
/// 【为什么存 seed 而非完整 KeyPair】`Ed25519().newKeyPairFromSeed(seed)` 是
/// 确定性派生：seed（32B）-> 私钥 + 公钥。只存 seed 即可重建全部，且 seed 是
/// 定长 32B，适合 secure storage 的 String value。完整 KeyPair 的私钥字节
/// 与 seed 等价（Ed25519 私钥就是 seed），存哪个都一样，存 seed 更直接。
///
/// 【私钥无导出路径】本类没有任何 public 成员返回 seed / 私钥字节 / KeyPair
/// 对象。`_loadKeyPair()` 是私有方法，返回的 `SimpleKeyPair` 不出本文件。
/// 契约测试 A2 用源码扫描守卫这条。
///
/// 【PEM 形态】`verify({required String peerPublicKeyPem})` 要 PEM。Ed25519
/// 公钥（32B）的标准封装是 SubjectPublicKeyInfo（SPKI），前缀固定 12B：
/// `30 2a 30 05 06 03 2b 65 70 03 21 00`（RFC 8410），base64 后套
/// `-----BEGIN PUBLIC KEY-----`。这是可互操作的标准形态，跨语言可用
/// `ed25519-dalek` / Web Crypto 验。
///
/// 【指纹形态】`publicKeyFingerprint` = SHA-256(公钥原始 32B)，hex，`:` 分组
/// （`AA:BB:...`），供带外肉眼/扫码比对。这与 SDP 的 DTLS 指纹格式同形，
/// 带外比对时视觉一致。
///
/// 【失败语义】契约 §3.6「失败一律抛 StorageError 子类，不返回 null」。本类
/// 的失败模式：secure storage 读写失败、seed 损坏、PEM 解析失败--一律包成
/// [DeviceKeyStoreError]。
library;

import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:persistence_core/model/storage_error.dart';
import 'package:persistence_core/model/transport.dart';
import 'package:uuid/uuid.dart';

import 'pairing_identity.dart';

/// `DeviceKeyStore` 操作失败。
///
/// 契约 §3.6「失败一律抛 StorageError 子类」。
final class DeviceKeyStoreError extends StorageError {
  DeviceKeyStoreError({
    required super.message,
    required super.reason,
    required super.suggestion,
  }) : super(
          code: 'storage.device_key_store',
        );
}

/// Ed25519 公钥的 SPKI DER 固定前缀（RFC 8410）。
///
/// `30 2a 30 05 06 03 2b 65 70 03 21 00` -- 12 字节，后接 32 字节公钥即得
/// 完整 SPKI DER（44B），base64 后套 PEM 头尾。
const List<int> _kEd25519SpkiPrefix = [
  0x30, 0x2a, 0x30, 0x05, 0x06, 0x03, 0x2b, 0x65, 0x70, 0x03, 0x21, 0x00,
];

/// secure storage 里存 seed 的 key。
const String _kSeedKey = 'device_identity.ed25519_seed';

/// secure storage 里存 deviceId 的 key。
const String _kDeviceIdKey = 'device_identity.device_id';

/// 基于 `flutter_secure_storage` 的 `DeviceKeyStore` 实现。
///
/// 移动端（iOS/Android）与桌面端（macOS/Windows/Linux）共用本实现--身份
/// 私钥用硬件背书的 secure storage 是最佳归宿（决定记录 Q2）。Web 端本期
/// 不交付 S6 能力（D18）。
///
/// 【可测性】[storage] 与 [uuid] 经构造函数注入：测试用内存 fake 的
/// `FlutterSecureStorage` 与固定 UUID，验证确定性；生产用默认工厂
/// [PersistentDeviceKeyStore.newProduction]。
final class PersistentDeviceKeyStore
    implements DeviceKeyStore, PairingIdentityProvider {
  /// 构造一个可注入依赖的 `DeviceKeyStore`。
  ///
  /// 参数说明：
  /// - [storage]: `flutter_secure_storage` 实例（测试可注入 fake）。
  /// - [uuid]: UUID 生成器（测试可注入固定值）。
  /// - [ed25519]: Ed25519 算法实例（测试可注入）。
  PersistentDeviceKeyStore({
    FlutterSecureStorage? storage,
    Uuid? uuid,
    Ed25519? ed25519,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _uuid = uuid ?? const Uuid(),
        _ed25519 = ed25519 ?? Ed25519();

  final FlutterSecureStorage _storage;
  final Uuid _uuid;
  final Ed25519 _ed25519;

  /// 缓存的本地身份（首次访问后避免重复读 secure storage + 重建公钥）。
  PeerIdentity? _cachedIdentity;

  @override
  Future<PeerIdentity> get localIdentity async {
    final cached = _cachedIdentity;
    if (cached != null) {
      return cached;
    }
    final identity = await _loadOrCreateIdentity();
    _cachedIdentity = identity;
    return identity;
  }

  @override
  Future<List<int>> sign(List<int> payload) async {
    // 首次使用即生成身份（seed 落 secure storage），随后加载密钥对。
    await _loadOrCreateIdentity();
    final keyPair = await _loadKeyPair();
    final signature = await _ed25519.sign(payload, keyPair: keyPair);
    // 签完即弃：keyPair 是局部变量，函数返回后即可 GC。不缓存 KeyPair，
    // 避免私钥对象长驻内存。
    return signature.bytes;
  }

  /// 本端公钥的 PEM（SPKI 格式）。
  ///
  /// **这是公钥，不是私钥**--公钥本就可公开交换（设备配对时发给对端）。
  /// 供配对流程（ACT 2）把本端公钥经信令发给对端、供对端 `verify()` 用。
  /// 与 `localIdentity.publicKeyFingerprint` 同源（都从 seed 派生）。
  @override
  Future<String> get localPublicKeyPem async {
    await _loadOrCreateIdentity();
    final keyPair = await _loadKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    return encodePublicKeyPem(publicKey.bytes);
  }

  @override
  Future<bool> verify({
    required List<int> payload,
    required List<int> signature,
    required String peerPublicKeyPem,
  }) async {
    final publicKeyBytes = _parsePublicKeyPem(peerPublicKeyPem);
    final publicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);
    final sig = Signature(signature, publicKey: publicKey);
    return _ed25519.verify(payload, signature: sig);
  }

  // ── 私有：私钥不出本节 ─────────────────────────────────────────

  /// 加载或首次生成设备身份。
  ///
  /// 首次调用时生成新 seed + deviceId 并持久化；后续调用读回。
  Future<PeerIdentity> _loadOrCreateIdentity() async {
    try {
      final existingSeed = await _storage.read(key: _kSeedKey);
      final existingDeviceId = await _storage.read(key: _kDeviceIdKey);

      if (existingSeed != null && existingDeviceId != null) {
        final seed = _decodeSeed(existingSeed);
        final publicKey = await _publicKeyFromSeed(seed);
        return PeerIdentity(
          deviceId: existingDeviceId,
          publicKeyFingerprint: await _fingerprintOf(publicKey),
        );
      }

      // 首次：生成新 seed + deviceId，持久化。
      final newSeed = await _ed25519.newKeyPair();
      final seedBytes = await newSeed.extractPrivateKeyBytes();
      final deviceId = _uuid.v4();
      final publicKey = await newSeed.extractPublicKey();

      await _storage.write(
        key: _kSeedKey,
        value: base64.encode(seedBytes),
      );
      await _storage.write(key: _kDeviceIdKey, value: deviceId);

      return PeerIdentity(
        deviceId: deviceId,
        publicKeyFingerprint: await _fingerprintOf(publicKey.bytes),
      );
    } on Object catch (e) {
      throw DeviceKeyStoreError(
        message: '设备身份加载/生成失败',
        reason: 'secure storage 读写或密钥派生异常: $e',
        suggestion: '检查 secure storage 配置（iOS Keychain 权限 / Android '
            'Keystore 可用性）后重试',
      );
    }
  }

  /// 按 seed 重建密钥对（私钥不出本方法）。
  Future<SimpleKeyPair> _loadKeyPair() async {
    try {
      final seedB64 = await _storage.read(key: _kSeedKey);
      if (seedB64 == null) {
        throw DeviceKeyStoreError(
          message: '设备私钥不存在',
          reason: 'secure storage 中无 seed，可能未完成首次初始化',
          suggestion: '先访问 localIdentity 触发首次生成',
        );
      }
      final seed = _decodeSeed(seedB64);
      return _ed25519.newKeyPairFromSeed(seed);
    } on DeviceKeyStoreError {
      rethrow;
    } on Object catch (e) {
      throw DeviceKeyStoreError(
        message: '设备私钥加载失败',
        reason: '读取/解析 seed 异常: $e',
        suggestion: '检查 secure storage 状态后重试',
      );
    }
  }

  /// 从 seed 派生公钥原始字节（不持私钥）。
  Future<List<int>> _publicKeyFromSeed(List<int> seed) async {
    final keyPair = await _ed25519.newKeyPairFromSeed(seed);
    final publicKey = await keyPair.extractPublicKey();
    return publicKey.bytes;
  }

  // ── 静态：编码/解析（纯函数，无私钥语义）─────────────────────────

  /// 解码 base64 seed，校验长度（Ed25519 seed = 32B）。
  static List<int> _decodeSeed(String base64Str) {
    final bytes = base64.decode(base64Str);
    if (bytes.length != KeyPairType.ed25519.privateKeyLength) {
      throw DeviceKeyStoreError(
        message: 'seed 长度异常',
        reason: 'Ed25519 seed 应为 '
            '${KeyPairType.ed25519.privateKeyLength} 字节，实际 ${bytes.length}',
        suggestion: 'seed 可能损坏，清除后重新初始化设备身份',
      );
    }
    return bytes;
  }

  /// 公钥原始字节（32B）-> SHA-256 hex，`:` 分组。
  ///
  /// 用 `cryptography` 包的 [Sha256]，不为指纹计算引入 `crypto` 依赖。
  static Future<String> _fingerprintOf(List<int> publicKeyBytes) async {
    final hash = await Sha256().hash(publicKeyBytes);
    // hex，每字节两位，用 `:` 分组（如 `AA:BB:CC:...`），与 SDP DTLS 指纹同形。
    return hash.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }

  /// 公钥原始字节（32B）-> SPKI PEM。
  static String encodePublicKeyPem(List<int> publicKeyBytes) {
    final der = <int>[..._kEd25519SpkiPrefix, ...publicKeyBytes];
    final b64 = base64.encode(der);
    // 标准 PEM：64 字符一行。44B DER -> 60 base64 字符，一行够。
    return '-----BEGIN PUBLIC KEY-----\n$b64\n-----END PUBLIC KEY-----';
  }

  /// SPKI PEM -> 公钥原始字节（32B）。校验前缀。
  static List<int> _parsePublicKeyPem(String pem) {
    try {
      final lines = pem
          .split('\n')
          .where((l) =>
              !l.startsWith('-----') && l.trim().isNotEmpty)
          .join('');
      final der = base64.decode(lines);
      if (der.length != _kEd25519SpkiPrefix.length + 32) {
        throw FormatException('SPKI DER 长度异常: ${der.length}');
      }
      for (var i = 0; i < _kEd25519SpkiPrefix.length; i++) {
        if (der[i] != _kEd25519SpkiPrefix[i]) {
          throw FormatException('SPKI 前缀不匹配（非 Ed25519？）');
        }
      }
      return der.sublist(_kEd25519SpkiPrefix.length);
    } on DeviceKeyStoreError {
      rethrow;
    } on Object catch (e) {
      throw DeviceKeyStoreError(
        message: '对端公钥 PEM 解析失败',
        reason: '$e',
        suggestion: '确认 PEM 为标准 Ed25519 SPKI 格式',
      );
    }
  }
}
