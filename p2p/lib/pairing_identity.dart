/// 配对流程对设备身份的依赖面（S6 / ACT 2）。
///
/// 配对需要四件事：身份（deviceId + 指纹）、本端公钥 PEM（放进 offer
/// 供对端验签）、签名、验签。`DeviceKeyStore` 契约（transport.dart）
/// 只暴露前三件里的两件 + 验签，**没有公钥 PEM 出口** —— 而配对必须
/// 交换公钥。本接口补齐这一面，且不要求配对流程依赖具体存储实现：
/// [PersistentDeviceKeyStore] 天然满足本接口（成员名逐一对应）。
///
/// 【私钥语义】与 [DeviceKeyStore] 相同：私钥永不出现在本接口。
library;

import 'package:persistence_core/model/transport.dart';

/// 配对流程可用的设备身份提供者。
abstract interface class PairingIdentityProvider {
  /// 本机身份：deviceId + 公钥指纹。
  Future<PeerIdentity> get localIdentity;

  /// 本端公钥（Ed25519 SPKI PEM）。**这是公钥，不是私钥** —— 配对时
  /// 经信令发给对端，对端用它验本端签名。
  Future<String> get localPublicKeyPem;

  /// 用本机私钥对 [payload] 签名。私钥不出实现。
  Future<List<int>> sign(List<int> payload);

  /// 用对端公钥验签。
  Future<bool> verify({
    required List<int> payload,
    required List<int> signature,
    required String peerPublicKeyPem,
  });
}
