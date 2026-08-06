/// ICE 服务器端口（S3c-c-preflight P3）。
///
/// 【本文件解决的问题】WebRTC 建连需要 ICE 服务器列表（STUN / TURN 服务器）。
/// 所有托管 TURN 服务都签发**短期凭证**（默认 24h 有效），因此本端口必须能
/// **随时**返回当前有效的服务器列表，而不是一份静态配置 —— 静态配置在凭证
/// 过期后会让所有中继连接失败。
///
/// 【为什么凭证是异步获取的】凭证有失效时间，必须在**每次使用前**向签发方
/// 索取。若把凭证做成同步常量字符串，就等于把它当永久密钥存储 —— 这正是
/// TURN 服务提供方都要求避免的做法。
///
/// 【本文件刻意不点名任何供应商】选型结论（谁家、什么价、什么暴露面）写在
/// 选型文档里，不写进契约 —— 契约里出现供应商名，哪怕只在注释中，也会让
/// 后人以为绑定了它。契约只声明「必须具备的能力」：能拿到当前有效的 ICE
/// 服务器列表。本约定由契约测试的源码扫描守卫强制。
library;

/// 一条 ICE 服务器配置。
///
/// 对应 WebRTC 的 RTCIceServer：建连时把列表交给引擎。凭证是**运行时**
/// 获取的短期值（见库级注释），不是常量字符串。
final class IceServer {
  /// 服务器地址。
  ///
  /// STUN 或 TURN URL（如 `stun:...`、`turn:...`）。TURN 可提供多个
  /// 备选地址，以空格分隔。
  final String urls;

  /// 用户名。
  ///
  /// TURN 短期凭证的用户名部分；STUN 服务器通常不需要，为 null。
  final String? username;

  /// 获取当前有效凭证的回调。
  ///
  /// 每次调用都应返回**当前仍有效**的凭证：凭证过期后再次调用必须
  /// 重新向签发方索取，不得返回缓存值。
  final Future<String> Function() credential;

  /// 凭证过期时刻（UTC）。
  ///
  /// 【为什么必须有这个字段】凭证时效性是本端口的核心语义，必须可被
  /// **运行期**机械验证：凭证是短期值，过期后必须重新索取。若只靠
  /// [credential] 的异步签名，把凭证做成常量字符串只会在编译期失败；
  /// 有了本字段，守卫测试就能断言「过期时刻存在且在合理窗口内」，
  /// 「永不过期 / 常量凭证」的实现会在此**运行期**变红。
  final DateTime expiresAt;

  /// 判断 [expiresAt] 是否为「短期凭证」的有效过期时刻。
  ///
  /// 有效期必须落在 [now] 之后的 [minLifetime] ~ [maxLifetime] 窗口内：
  /// - 过去 / 立即过期：无效（凭证已失效，调用方必须重新索取）。
  /// - 永不过期 / 超长有效期：无效（等价「常量凭证」，违背本端口语义）。
  ///
  /// 这是凭证时效性的**运行期**守卫 —— 只靠 [credential] 的异步签名，把
  /// 凭证做成常量只会在编译期失败；本方法让「永不过期」在运行期变红。
  ///
  /// 参数说明：
  /// - [expiresAt]: 凭证过期时刻（UTC）。
  /// - [now]: 当前时刻（默认取系统时钟；测试可注入固定时刻）。
  /// - [minLifetime]: 最短有效期（默认 5 分钟）。
  /// - [maxLifetime]: 最长有效期（默认 72 小时，托管 TURN 都发 24h 级凭证）。
  static bool isValidCredentialExpiry(
    DateTime expiresAt, {
    DateTime? now,
    Duration minLifetime = const Duration(minutes: 5),
    Duration maxLifetime = const Duration(hours: 72),
  }) {
    final base = now ?? DateTime.now().toUtc();
    final lifetime = expiresAt.difference(base);
    return lifetime >= minLifetime && lifetime <= maxLifetime;
  }

  /// 构造一条 ICE 服务器配置。
  ///
  /// 参数说明：
  /// - [urls]: 服务器地址。
  /// - [username]: 用户名（可选）。
  /// - [credential]: 当前有效凭证的获取回调。
  /// - [expiresAt]: 凭证过期时刻（UTC），必须是一个**有限的未来时刻**。
  const IceServer({
    required this.urls,
    this.username,
    required this.credential,
    required this.expiresAt,
  });
}

/// ICE 服务器提供方端口：建连前向引擎提供服务器列表。
///
/// 【为什么是接口】TURN 是标准协议，换供应商只需换凭证签发地址 ——
/// 本端口必须与具体供应商解耦，实现可随时替换。
///
/// 约定（§3.6）：
/// - 失败一律抛 StorageError 子类，不返回 null 表达失败。
abstract interface class IceServerProvider {
  /// 返回当前有效的 ICE 服务器列表。
  ///
  /// 约定：
  /// - 列表中的每条 [IceServer] 都必须携带**当前有效**的凭证；
  ///   凭证过期后调用方应重新索取，不得依赖缓存。
  /// - 无可用服务器时返回空列表（调用方应能区分「没有服务器」与「出错」）。
  Future<List<IceServer>> iceServers();
}
