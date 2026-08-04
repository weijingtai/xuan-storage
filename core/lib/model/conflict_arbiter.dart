import 'dart:convert';

import 'package:crdt/crdt.dart' show Hlc;

/// 版本坐标：(hlc, deviceId)。
///
/// 【为什么需要 deviceId】：crdt 的 Hlc 内建 nodeId 且 compareTo 全序内建
/// （先比 dateTime、再比 counter、最后比 nodeId），但它的 nodeId 比较走的是
/// Dart 的 `String.compareTo`（UTF-16 code unit 序），与 A14「跨语言客户端
/// 可对表」要求的 UTF-8 字节序【在非 ASCII 上结论相反】（Codex R3 · P0-3）。
/// 因此本类【不直接依赖 Hlc.compareTo 的 nodeId 段】，而是自己按 UTF-8
/// 字节序比较 [deviceId]，把它补成全序 —— 保证任意两台设备对同一对版本
/// 得出【同一个】结论。
///
/// 比较规则：先比 hlc 的 dateTime（UTC 毫秒），再比 counter，最后比
/// deviceId 的 **UTF-8 字节序**（无符号逐字节字典序），大者胜。
///
/// ⚠⚠ 【deviceId 必须按 UTF-8 字节比，不许直接用 `String.compareTo`】
/// （Codex R3 · P0-3）。Dart 的 `String.compareTo` 走的是 **UTF-16 code unit**
/// 序，与 UTF-8 字节序【在非 ASCII 上结论相反】：
///   · U+10000（UTF-8 = F0 90 80 80；UTF-16 = D800 DC00 代理对）
///   · U+E000（UTF-8 = EE 80 80；UTF-16 = E000）
///   UTF-8 序：EE < F0 ⇒ U+E000 < U+10000
///   UTF-16 序：D800 < E000 ⇒ U+10000 < U+E000   ←【结论相反】
/// 两端若一端用 UTF-8 一端用 UTF-16，对同一对并发版本会选出【不同的赢家】，
/// 那正是 A14 要防的事，且不报错、只是静默分叉。
final class VersionStamp implements Comparable<VersionStamp> {
  /// HLC 戳。打包形式见 ACT 08 TASK_DETAIL.hlc_wire_format_spec。
  final Hlc hlc;

  /// 写入该版本的设备标识。取自 [DeviceIdentity.deviceId]。
  final String deviceId;

  /// 构造一个 [VersionStamp]。
  const VersionStamp({required this.hlc, required this.deviceId});

  /// 从线上打包值还原。[packed] 为 `(l << 16) | c`（ACT 08 规格②：
  /// l = UTC 毫秒，c = Hlc.counter）。
  ///
  /// 还原出的 Hlc 的 nodeId 取 [deviceId] —— 打包值不含 nodeId，
  /// 全序中的 deviceId 决胜位由本字段承担（A14 线上格式只打包 l 与 c）。
  factory VersionStamp.fromPacked(int packed, String deviceId) {
    final l = packed >> 16;
    final c = packed & 0xffff;
    return VersionStamp(
      hlc: Hlc(
        DateTime.fromMillisecondsSinceEpoch(l, isUtc: true),
        c,
        deviceId,
      ),
      deviceId: deviceId,
    );
  }

  /// 打包成线上格式 int64：`(dateTime.millisecondsSinceEpoch << 16) | counter`。
  int toPacked() =>
      (hlc.dateTime.millisecondsSinceEpoch << 16) | (hlc.counter & 0xffff);

  @override
  int compareTo(VersionStamp other) {
    // 先比 hlc 的 dateTime（UTC 毫秒）
    final lCmp = hlc.dateTime.millisecondsSinceEpoch
        .compareTo(other.hlc.dateTime.millisecondsSinceEpoch);
    if (lCmp != 0) return lCmp;
    // 再比 counter
    final cCmp = hlc.counter.compareTo(other.hlc.counter);
    if (cCmp != 0) return cCmp;
    // 最后比 deviceId 的 UTF-8 字节序（无符号逐字节，短的是前缀时短者小）
    return _compareUtf8Bytes(deviceId, other.deviceId);
  }

  /// 按 UTF-8 字节序比较两个字符串（无符号逐字节字典序）。
  ///
  /// 【不要】用 `String.compareTo` —— 那是 UTF-16 code unit 序，
  /// 非 ASCII 上与 UTF-8 序结论相反（Codex R3 · P0-3）。
  static int _compareUtf8Bytes(String a, String b) {
    final aBytes = utf8.encode(a);
    final bBytes = utf8.encode(b);
    final n = aBytes.length < bBytes.length ? aBytes.length : bBytes.length;
    for (var i = 0; i < n; i += 1) {
      final diff = aBytes[i].compareTo(bBytes[i]);
      if (diff != 0) return diff;
    }
    // 前缀相同：短者小
    return aBytes.length.compareTo(bBytes.length);
  }
}

/// 一次冲突的裁决。
enum ArbitrationDecision {
  /// 远端版本胜出，应覆盖本地。被覆盖的【本地】版本要留档。
  takeRemote,

  /// 本地版本胜出，远端变更应被丢弃。被丢弃的【远端】版本【同样】要留档。
  keepLocal,

  /// 两者坐标完全相同 —— 同一版本，无冲突，无需写入。
  identical,
}

/// 冲突仲裁器。决定"远端来的这条变更该不该覆盖本地"。
///
/// 【纯函数，无 IO、无状态】。持久化由调用方（ACT 10 的 applier）负责 ——
/// 混进来会让它没法被单元测试穷举，而定序正是最需要穷举的那类代码。
abstract interface class ConflictArbiter {
  /// 比较远端与本地版本，给出裁决。
  ///
  /// [remote] 可空：历史 oplog 条目没有戳。降级规则见 ACT 09 TASK_DETAIL。
  /// [local] 可空：t_entity_stamp 里还没有该实体的戳（首次收到）。
  ArbitrationDecision arbitrate({
    required VersionStamp? remote,
    required VersionStamp? local,
  });
}

/// 默认实现：严格按 (hlc, deviceId) 全序比较。
///
/// null 降级（fail-safe 方向）：
///   (null, null)   → identical
///   (null, 有)     → keepLocal（远端是无戳的历史条目，不覆盖有戳的本地）
///   (有, null)     → takeRemote（本地没有可比的版本坐标，直接采用）
///   (有, 有)       → 正常全序比较
final class HlcConflictArbiter implements ConflictArbiter {
  /// 构造一个 [HlcConflictArbiter]。
  const HlcConflictArbiter();

  @override
  ArbitrationDecision arbitrate({
    required VersionStamp? remote,
    required VersionStamp? local,
  }) {
    if (remote == null && local == null) {
      return ArbitrationDecision.identical;
    }
    if (remote == null) {
      // 远端是无戳的历史条目 → 不覆盖有戳的本地（fail-safe）
      return ArbitrationDecision.keepLocal;
    }
    if (local == null) {
      // 本地没有可比的版本坐标 → 直接采用远端
      return ArbitrationDecision.takeRemote;
    }

    final cmp = remote.compareTo(local);
    if (cmp > 0) return ArbitrationDecision.takeRemote;
    if (cmp < 0) return ArbitrationDecision.keepLocal;
    return ArbitrationDecision.identical;
  }
}
