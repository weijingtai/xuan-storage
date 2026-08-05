/// P2P 局域网信令包入口。
///
/// 只导出产品 API（[LocalSignaling]）。`LanDiscovery` 是包内窄端口，
/// 不属对外契约，消费方不应直接依赖（测试经 `@Tags(['integration'])`
/// 的集成测试走深路径消费，见任务计划 P8）。
library;

export 'local_signaling.dart';
