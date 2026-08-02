/// 存储策略密封类族（设计稿 §2.3）。
///
/// 「防混用」机制：非法组合在【工厂构造器的参数表】上传不进去，
/// 而不是靠运行时检查拦截。基类声明全部事实 getter，契约测试统一遍历；
/// 某个事实能否由调用方传入，由各工厂的参数表决定。
///
/// 强制级别（§2.3.0）：结构性不变式（private 必含 cloud、shared 只有 cloud、
/// control 全部写死、子类不可绕过工厂）靠参数表与私有构造器保证；
/// 注册期不变式（resource 必须 official、sources 非空）由
/// [StoragePolicyRegistry.register] 抛 StateError 强制。
library;

import 'storage_classification.dart';

/// 存储策略。sealed：调用方只能使用本文件内的四个子类。
///
/// 事实 getter 全部在基类声明，契约测试可统一遍历 [StoragePolicy] 类型。
sealed class StoragePolicy {
  const StoragePolicy._();

  /// 可见性。决定允许的通道与加密形态。
  DataVisibility get visibility;

  /// 载体形态集合。row 与 blob 的同步机制无共用面。
  Set<Carrier> get carriers;

  /// 允许的传输通道集合。private 的 channels 恒含 [Channel.cloud]。
  Set<Channel> get channels;

  /// 资源来源集合。private / shared 恒为 `const {}`（不适用）。
  Set<Source> get sources;

  /// 发布者身份。与可见性正交，决定信任级别与是否需要审核。
  Publisher get publisher;

  /// 加密形态。三个取值对应 §2.2 派生表的三行。
  Encryption get encryption;

  /// 私有：E2EE + SSE。**cloud 不是参数** —— 结构上无法关闭（见 §2.3.0）。
  /// 可选的只是要不要开三条 P2P 通道（lan / webrtc / manualExport）。
  const factory StoragePolicy.private({
    required Set<Carrier> carriers,
    bool lan,
    bool webrtc,
    bool manualExport,
  }) = PrivatePolicy._;

  /// 可分享：不接受 channels，也不接受 publisher / sources。
  /// 分享数据【禁止】配置 P2P 通道 —— 参数表里没有 channels。
  const factory StoragePolicy.shared({
    required Set<Carrier> carriers,
  }) = SharedPolicy._;

  /// 资源：可跨 Source 演进；publisher 默认 official，开放 UGC 时才传 user。
  /// 当前阶段（§9.1）注册时校验 publisher 必须为 official。
  const factory StoragePolicy.resource({
    required Set<Carrier> carriers,
    required Set<Source> sources,
    Publisher publisher,
  }) = ResourcePolicy._;

  /// 控制下发：无参数可传，六个事实全部写死。
  /// 用户【无法】发布功能开关 / 服务器地址 —— 没有 publisher 参数。
  const factory StoragePolicy.control() = ControlPolicy._;
}

/// 私有策略：用户本地产出，客户端 E2EE + 桶级 SSE。
///
/// 构造器私有：调用方只能走命名工厂，不能绕过参数表约束。
final class PrivatePolicy extends StoragePolicy {
  /// 私有构造器。默认值写在目标构造器上（已实测 dart analyze 零 issue）。
  const PrivatePolicy._({
    required this.carriers,
    bool lan = true,
    bool webrtc = true,
    bool manualExport = true,
  })  : _lan = lan,
        _webrtc = webrtc,
        _manualExport = manualExport,
        super._();

  /// 载体形态集合。
  @override
  final Set<Carrier> carriers;

  final bool _lan;
  final bool _webrtc;
  final bool _manualExport;

  /// cloud 恒在集合里，无法被调用方移除（结构性不变式 #2）。
  @override
  Set<Channel> get channels => {
        Channel.cloud,
        if (_lan) Channel.lan,
        if (_webrtc) Channel.webrtc,
        if (_manualExport) Channel.manualExport,
      };

  /// 可见性恒为 private。
  @override
  DataVisibility get visibility => DataVisibility.private;

  /// 不适用：用户本地产出。
  @override
  Set<Source> get sources => const {};

  /// 发布者恒为 user。
  @override
  Publisher get publisher => Publisher.user;

  /// 加密恒为客户端 E2EE + SSE（结构性不变式 #2）。
  @override
  Encryption get encryption => Encryption.e2eeOverSse;
}

/// 可分享策略：他人可见，仅走云端。
///
/// 构造器私有：不接受 channels —— 分享数据【禁止】P2P 通道。
final class SharedPolicy extends StoragePolicy {
  /// 私有构造器。仅接受 carriers。
  const SharedPolicy._({required this.carriers}) : super._();

  /// 载体形态集合。
  @override
  final Set<Carrier> carriers;

  /// 可见性恒为 shared。
  @override
  DataVisibility get visibility => DataVisibility.shared;

  /// 通道恒为 `{cloud}`（结构性不变式 #1）。
  @override
  Set<Channel> get channels => const {Channel.cloud};

  /// 不适用。
  @override
  Set<Source> get sources => const {};

  /// 发布者恒为 user。
  @override
  Publisher get publisher => Publisher.user;

  /// 加密恒为仅桶级 SSE。
  @override
  Encryption get encryption => Encryption.sseOnly;
}

/// 资源策略：官方或用户发布的主题 / 数据资源，可跨来源演进。
///
/// 构造器私有：publisher 默认 official，开放 UGC 时才传 user。
final class ResourcePolicy extends StoragePolicy {
  /// 私有构造器。publisher 默认 official。
  const ResourcePolicy._({
    required this.carriers,
    required this.sources,
    this.publisher = Publisher.official,
  }) : super._();

  /// 载体形态集合。
  @override
  final Set<Carrier> carriers;

  /// 资源来源集合。可随时间演进（bundled → officialRemote）。
  @override
  final Set<Source> sources;

  /// 发布者身份。当前阶段注册时校验必须为 official。
  @override
  final Publisher publisher;

  /// 可见性恒为 resource。
  @override
  DataVisibility get visibility => DataVisibility.resource;

  /// 通道恒为 `{cloud}`。
  @override
  Set<Channel> get channels => const {Channel.cloud};

  /// 加密恒为仅桶级 SSE。
  @override
  Encryption get encryption => Encryption.sseOnly;
}

/// 控制下发策略：功能开关 / 服务器地址 / 默认主题 id。
///
/// 构造器私有且无参数：六个事实全部写死，用户无法发布控制下发。
final class ControlPolicy extends StoragePolicy {
  /// 私有构造器。无任何参数。
  const ControlPolicy._() : super._();

  /// 可见性恒为 control。
  @override
  DataVisibility get visibility => DataVisibility.control;

  /// 载体恒为 row（控制下发是结构化记录）。
  @override
  Set<Carrier> get carriers => const {Carrier.row};

  /// 通道恒为 `{cloud}`。
  @override
  Set<Channel> get channels => const {Channel.cloud};

  /// 来源恒为 `{officialRemote}`（结构性不变式 #3）。
  @override
  Set<Source> get sources => const {Source.officialRemote};

  /// 发布者恒为 official（结构性不变式 #3）。
  @override
  Publisher get publisher => Publisher.official;

  /// 加密恒为 SSE + 强制 TLS + 签名校验。
  @override
  Encryption get encryption => Encryption.sseOverTls;
}
