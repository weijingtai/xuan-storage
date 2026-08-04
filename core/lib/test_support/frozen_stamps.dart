import 'dart:math';

import 'package:crdt/crdt.dart' show Hlc;

/// 用 3 节点 HLC 仿真生成一组【确定性的】版本戳，供收敛性测试复用。
///
/// [seed] 固定时输出完全一致，便于失败复现。
///
/// 返回的每个条目：
/// - [entityId]: 实体标识（覆盖多个实体）。
/// - [hlcPacked]: int64 打包值 `(dateTime.millisecondsSinceEpoch << 16) | counter`
///   （ACT 08 TASK_DETAIL.hlc_wire_format_spec ② 的位布局）。
/// - [deviceId]: 产生该戳的设备标识（= crdt Hlc 的 nodeId）。
///
/// ⚠ 必须含若干【并发对】：同一物理毫秒（hlcPacked 的高 48 位相同）、
/// deviceId 不同的戳 —— 物理上无法判定先后，胜负完全由 nodeId 决出。
/// 这是 ACT 09 收敛性测试的命根子；没有并发对，收敛性测试就退化成
/// "给一列全序值排序"，什么都证明不了。
List<({String entityId, int hlcPacked, String deviceId})>
    generateFrozenStamps({required int seed, int count = 50}) {
  final random = Random(seed);
  final nodeIds = ['device-a', 'device-b', 'device-c'];
  final entityTypes = ['record', 'divination_case', 'seeker'];

  final baseMillis =
      DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;

  final out = <({String entityId, int hlcPacked, String deviceId})>[];

  // 生成 count 条；保证存在同毫秒不同 deviceId 的并发对。
  // 用分组生成：先造一批"同毫秒不同 deviceId"的并发对，再造普通戳。
  final concurrentPairCount = max(1, count ~/ 4);
  for (var i = 0; i < concurrentPairCount; i += 1) {
    final millis = baseMillis + random.nextInt(1 << 30);
    final entityId = '${entityTypes[i % entityTypes.length]}-$i';
    // 同一毫秒，两个不同 deviceId 的戳（counter 可相同，由 nodeId 决胜负）
    final a = Hlc(
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
      0,
      nodeIds[i % nodeIds.length],
    );
    final b = Hlc(
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
      0,
      nodeIds[(i + 1) % nodeIds.length],
    );
    out.add((
      entityId: '$entityId-a',
      hlcPacked: _pack(a),
      deviceId: a.nodeId,
    ));
    out.add((
      entityId: '$entityId-b',
      hlcPacked: _pack(b),
      deviceId: b.nodeId,
    ));
  }

  // 普通戳（不同毫秒），凑够 count
  while (out.length < count) {
    final i = out.length;
    final millis = baseMillis + random.nextInt(1 << 30);
    final h = Hlc(
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
      random.nextInt(1000),
      nodeIds[random.nextInt(nodeIds.length)],
    );
    final entityId = '${entityTypes[i % entityTypes.length]}-$i';
    out.add((
      entityId: entityId,
      hlcPacked: _pack(h),
      deviceId: h.nodeId,
    ));
  }

  return out;
}

/// 按 ACT 08 规格②打包：`(dateTime.millisecondsSinceEpoch << 16) | counter`。
int _pack(Hlc hlc) =>
    (hlc.dateTime.millisecondsSinceEpoch << 16) | (hlc.counter & 0xffff);
