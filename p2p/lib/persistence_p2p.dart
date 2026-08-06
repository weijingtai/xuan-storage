/// P2P 局域网信令包入口。
///
/// 导出产品 API：[LocalSignaling]（局域网信令）与 [PersistentDeviceKeyStore]
///（设备身份密钥，S6）。`LanDiscovery` 是包内窄端口，不属对外契约，消费方
/// 不应直接依赖（测试经 `@Tags(['integration'])` 的集成测试走深路径消费，
/// 见任务计划 P8）。
library;

export 'device_key_store.dart';
export 'device_pairing.dart';
export 'local_signaling.dart';
export 'pairing_identity.dart';
