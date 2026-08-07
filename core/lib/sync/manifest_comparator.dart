/// 双遍历五类比对的默认实现（S1c §3.1② 定稿，纯函数）。
///
/// 无 IO、无状态 —— 定序逻辑用单元测试穷举（手法照 [ConflictArbiter]）。
///
/// 比较基准：[VersionStamp.compareTo] 全序（hlc.dateTime → counter →
/// deviceId UTF-8 字节序），`is_deleted` 不参与定序（S1c §3.2① 定稿）。
/// 本实现不依赖 [ConflictArbiter]，因为比对的是【清单坐标】而非
/// 【仲裁决策】——仲裁器在比对之后、由 applier 按需调用。
library;

import 'package:persistence_core/model/conflict_arbiter.dart';
import 'package:persistence_core/model/reconciliation.dart';
import 'package:persistence_core/model/reconciliation_ports.dart';

/// 默认双遍历比对器：纯全序比较，`is_deleted` 是数据位。
final class DefaultManifestComparator implements ManifestComparator {
  /// 构造一个 [DefaultManifestComparator]。
  const DefaultManifestComparator();

  @override
  ManifestComparatorDecision classifyLocalEntry({
    required ManifestEntry local,
    required ManifestEntry? remote,
  }) {
    if (remote == null) {
      // 本地有 / 对方无 → 发终态给对方
      return ManifestComparatorDecision.sendTerminal;
    }
    return _compareStamps(local, remote);
  }

  @override
  ManifestComparatorDecision classifyRemoteEntry({
    required ManifestEntry? local,
    required ManifestEntry remote,
  }) {
    if (local == null) {
      // 本地无 / 对方有 → 请对方发来（新设备入网核心路径）
      return ManifestComparatorDecision.requestTerminal;
    }
    return _compareStamps(local, remote);
  }

  /// 双方都有的全序比较：返回是否 send/request/skip。
  ///
  /// 两个方向对称：同一对 (local, remote)，本地遍历与远端遍历给出
  /// 互补结论（除戳相等外）。【注意】`classifyLocalEntry` 与
  /// `classifyRemoteEntry` 传入参数名不同但语义一致——本方法统一
  /// 以「本地 vs 远端」比较，调用方保证参数方向。
  ManifestComparatorDecision _compareStamps(
    ManifestEntry local,
    ManifestEntry remote,
  ) {
    final localStamp = VersionStamp.fromPacked(local.hlcPacked, local.deviceId);
    final remoteStamp =
        VersionStamp.fromPacked(remote.hlcPacked, remote.deviceId);
    final cmp = localStamp.compareTo(remoteStamp);
    if (cmp > 0) return ManifestComparatorDecision.sendTerminal;
    if (cmp < 0) return ManifestComparatorDecision.requestTerminal;
    return ManifestComparatorDecision.skip;
  }
}
