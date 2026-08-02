/// 数据分类模型（设计稿 §2.1）。
///
/// 存储策略由四个正交维度决定：可见性、发布者、载体、来源，
/// 外加传输通道与加密形态两个派生维度。详见
/// docs/superpowers/specs/2026-07-31-storage-architecture-design.md §2。
library;

/// 可见性。命名为 DataVisibility 而非 Visibility —— persistence_core 依赖
/// flutter（core/pubspec.yaml），裸 Visibility 会与 Flutter 的
/// Visibility widget 冲突，迫使每个调用点写 import 前缀。
enum DataVisibility { private, shared, resource, control }

/// 发布者身份。与可见性正交，决定信任级别与是否需要审核。
enum Publisher { official, user }

/// 载体形态。row 与 blob 的同步机制无共用面。
enum Carrier { row, blob }

/// 资源来源。会随时间演进，Repository 必须对来源无感。
enum Source { bundled, officialRemote }

/// 传输通道。与 Transport 端口的关系见 §3.5：
/// Channel 是策略层的声明单位，Transport 是实现层的连接抽象，
/// 一个 Channel 值对应恰好一个 Transport 实现（cloud 除外，它走 SyncPeer 直连）。
enum Channel { cloud, lan, webrtc, manualExport }

/// 加密形态。三个取值对应 §2.2 派生表的三行。
enum Encryption {
  /// 客户端 E2EE 后再存入桶级 SSE 的桶。仅 private 使用。
  e2eeOverSse,

  /// 仅桶级 SSE，服务端可读。shared / resource 使用。
  sseOnly,

  /// 仅桶级 SSE + 强制传输层 TLS + 签名校验。control 使用。
  sseOverTls,
}
