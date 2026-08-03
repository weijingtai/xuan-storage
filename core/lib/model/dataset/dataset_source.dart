/// XRAP 载荷取用端口（协议 §4）。
///
/// 【为什么不复用 ConfigSource】—— 协议 §4.4 / N2 明确禁止：
/// `loadRaw → String` 会把整个数据集读进内存字符串；配置的 7 天缓存
/// 与 L0 三次确认是配置语义；且违反《总纲》§8.1:1241「下发的是指针，
/// 不是内容本身」。数据平面自己搬字节。
library;

import '../cancellation_token.dart';
import '../storage_classification.dart';
import 'dataset_manifest.dart';

/// 数据集来源。
///
/// 两个实现：内置（读 asset）与官方远端（HTTPS GET）。
/// 来源链顺序见协议 §4.1：已安装世代 > 内置世代，**冷启动零网络**（P4）。
abstract interface class DatasetSource {
  /// 本源的种类。复用 S1a 的 [Source] 枚举，不新造。
  Source get sourceKind;

  /// 本源标识，用于诊断链「这一代来自哪个源」。
  String get sourceId;

  /// 取清单。
  ///
  /// [knownVersion] 非空时可做版本协商（如 HTTP If-None-Match）：
  /// 远端未变更时返回 null，省流量。
  ///
  /// 返回 null 的两种含义由实现区分并记入诊断：本源无此数据集 /
  /// 版本未变更。**网络故障必须抛异常，不得降级为 null** ——
  /// 否则「拿不到」与「不存在」不可区分，会误触发降级。
  Future<DatasetManifest?> fetchManifest(
    String datasetId, {
    String? knownVersion,
  });

  /// 取载荷字节流。
  ///
  /// [startByte] 是 row 世界的续传水位 —— 对应 blob 侧的
  /// `presentChunks`（《总纲》§3.2.1），但载荷是单个文件而非分块对象，
  /// 故用字节水位表达。协议 §5.3 规定【只在本阶段续传】，
  /// 落地阶段整代重做。
  ///
  /// 取消后已落盘的字节保留供续传，不回滚（《总纲》§3.6「取消」）。
  Stream<List<int>> openPayload(
    DatasetManifest manifest, {
    int startByte = 0,
    CancellationToken? cancel,
  });
}

/// 数据集 endpoint 提供者（协议 §4.3）。
///
/// 【存在理由】endpoint 归 `xuan_config` 下发（《总纲》§8.1:1237），
/// 但 `persistence_*` 不得 import `xuan_config`（既有架构禁令
/// `no_xuan_config_in_lib_test.dart`）。故定义窄端口，由 app 的 DI 层接线。
///
/// 这也兑现《总纲》§3.1:448：ConfigSource 属控制平面，
/// xuan-storage 只消费下发的指针。
abstract interface class DatasetEndpointProvider {
  /// 取某数据集的远端根地址。未配置返回 null（此时只用内置世代）。
  ///
  /// 实现须保证返回值已通过信任根校验（域名白名单 + https），
  /// 校验规则复用 xuan_config 的 `isTrustedEndpoint`（《总纲》§8.5.1）。
  Future<String?> endpointFor(String datasetId);
}
