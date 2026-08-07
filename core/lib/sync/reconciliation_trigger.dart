/// S1c 全量对齐触发判定（ACT-E）。
///
/// 决定一次拉取该走增量还是全量对齐。纯函数，无 IO —— 判定逻辑
/// 单元测试穷举。
///
/// 三种触发条件（设计稿 §2.5 / §2.4 定稿）：
/// 1. 对端否决增量（[IncrementalUnavailable]）：对端增量给不了 → 强制全量。
/// 2. 本地从未拉取过（[lastPulledAtUtc] 为 null）：新设备 / 新实体类型
///    首次入网 → 全量（没有增量起点）。
/// 3. 距上次成功拉取超过阈值（[fullReconcileInterval]，默认 90 天）：
///    对端保留水位之外的增量可能已 compact，增量续拉不完整 → 全量。
library;

import 'package:persistence_core/model/types.dart';

/// 一次拉取的触发决策。
enum ReconciliationDecision {
  /// 走增量拉取（正常路径）。
  incremental,

  /// 强制切全量对齐。
  fullReconcile,
}

/// 全量对齐触发判定器（纯函数，无状态）。
class ReconciliationTrigger {
  /// 构造一个 [ReconciliationTrigger]。
  ///
  /// [fullReconcileInterval]：距上次成功拉取的阈值，超过即强制全量。
  /// 默认 90 天（设计稿 §3.2① 墓碑保留期 ≥ 全量对齐阈值）。
  const ReconciliationTrigger({
    this.fullReconcileInterval = const Duration(days: 90),
  });

  /// 距上次成功拉取的阈值。
  final Duration fullReconcileInterval;

  /// 判定一次拉取走增量还是全量。
  ///
  /// 参数说明：
  /// - [lastPullResult]：上次增量拉取的结果（可为 null 表示尚未发起）。
  /// - [lastPulledAtUtc]：上次成功拉取时间；null 表示从未拉过。
  /// - [nowUtc]：当前时间（UTC）。
  ///
  /// 决策（优先级从高到低）：
  /// 1. [IncrementalUnavailable] → [ReconciliationDecision.fullReconcile]。
  /// 2. [lastPulledAtUtc] 为 null → [ReconciliationDecision.fullReconcile]。
  /// 3. 距上次拉取超过 [fullReconcileInterval] →
  ///    [ReconciliationDecision.fullReconcile]。
  /// 4. 否则 → [ReconciliationDecision.incremental]。
  ReconciliationDecision decide({
    required RemoteChangesResult? lastPullResult,
    required DateTime? lastPulledAtUtc,
    required DateTime nowUtc,
  }) {
    if (lastPullResult is IncrementalUnavailable) {
      return ReconciliationDecision.fullReconcile;
    }
    if (lastPulledAtUtc == null) {
      return ReconciliationDecision.fullReconcile;
    }
    final elapsed = nowUtc.difference(lastPulledAtUtc);
    if (elapsed > fullReconcileInterval) {
      return ReconciliationDecision.fullReconcile;
    }
    return ReconciliationDecision.incremental;
  }
}
