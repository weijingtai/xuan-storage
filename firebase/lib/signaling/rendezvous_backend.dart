/// 会合点后端窄端口 —— `CloudSignaling` 与具体实时数据库之间的唯一接缝。
///
/// 【为什么存在】`onDisconnect`（服务端检测到客户端断连后自动执行预先登记的
/// 删除）是真实 RTDB 的**服务端行为**，本地 fake 通常不实现它。把 RTDB 访问
/// 收敛到窄端口后：
/// - 单元测试注入内存 backend —— 它**真的会在「断开」时执行已登记的删除**，
///   契约套件与变异自检都在它上面跑（验收 A3）；
/// - 真实 `RtdbRendezvousBackend` 是包内唯一依赖 `firebase_database` 的地方。
///
/// 【数据布局约定】路径与载荷一律不含 scopeUid / 用户名 / 设备名（验收 A7）：
/// 成员 id 是随机 transient id（每次 open 换新、可轮换），路径只由
/// `signaling` 前缀 + 会合标识 + 成员 id 组成。本端口不感知任何身份信息。
library;

import 'package:persistence_core/model/signaling.dart';

/// 会合点后端窄端口：只管成员登记、快照监听、断开清理与信封读写四件事。
abstract interface class RendezvousBackend {
  /// 登记本端成员节点（在场标识）。
  Future<void> register(RendezvousKey rendezvous, String memberId);

  /// 监听会合点下的成员集合与信封变化。
  ///
  /// 约定：订阅后应立即推一帧当前快照（契约要求「订阅后应立即得到当前状态」）。
  Stream<RendezvousSnapshot> watch(RendezvousKey rendezvous);

  /// 登记「本端断开时自动删除成员节点」的服务端钩子（RTDB `onDisconnect`）。
  ///
  /// 【为什么是本端名而非对端名】语义是「我掉线时删我自己的节点」：本端进程
  /// 被杀 / 断网 / 崩溃时，服务端检测到连接断开，执行这条预先登记的删除，
  /// 对端据此观测到 `departed`。这是**服务端事实**，不是客户端心跳 + 超时推断。
  Future<void> onDisconnectRemove(RendezvousKey rendezvous, String memberId);

  /// 立即删除本端成员节点（正常 `close` 时的清理）。
  Future<void> remove(RendezvousKey rendezvous, String memberId);

  /// 写一个信封到会合点（由会合点转发给对端）。
  Future<void> writeEnvelope(
    RendezvousKey rendezvous,
    String fromMemberId,
    Map<String, Object?> payload,
  );

  /// 指定成员节点在会合点下的真实路径（供 A7 隐私断言**读回**实现构造）。
  ///
  /// 【为什么是接口方法而非测试内硬编码】A7 的断言若只盯着内存 fake 自己
  /// 写死的字符串，就是在复述约定，不是读回真实实现 —— 真实路径构造被
  /// 塞进身份信息时没有任何断言能发现（验收 F1 / 返工 R1）。本方法让
  /// 每个后端暴露自己的路径构造：`RtdbRendezvousBackend` 返回真实
  /// `rootPath` 拼接结果，内存 fake 的 `debugSerializedRoom` 也必须调用它
  /// （且其格式源自同一 `rootPath` 常量），两条线绑定同一事实源。
  String pathOf(RendezvousKey rendezvous, String memberId);
}

/// 会合点快照：当前在场成员集合 + 该会合点下全部信封。
final class RendezvousSnapshot {
  /// 构造一帧快照。
  ///
  /// 参数说明：
  /// - [members]: 当前在场的成员 id 集合（**含本端**）。
  /// - [envelopes]: 该会合点下全部信封（**含本端自己写的**，由消费方过滤）。
  const RendezvousSnapshot({
    required this.members,
    required this.envelopes,
  });

  /// 当前在场的成员 id 集合（含本端）。
  final Set<String> members;

  /// 该会合点下全部信封（含本端自己写的，由消费方过滤）。
  final List<RendezvousEnvelope> envelopes;
}

/// 一条从会合点读回的信封。
final class RendezvousEnvelope {
  /// 构造一条读回的信封。
  ///
  /// 参数说明：
  /// - [id]: 信封唯一 id（RTDB 用 `push()` 生成的 key，供消费方去重）。
  /// - [from]: 发送方成员 id。
  /// - [payload]: 信封载荷（见 [signalingEnvelopeToPayload]）。
  const RendezvousEnvelope({
    required this.id,
    required this.from,
    required this.payload,
  });

  /// 信封唯一 id。
  final String id;

  /// 发送方成员 id。
  final String from;

  /// 信封载荷。
  final Map<String, Object?> payload;
}

/// 信封 → 可写载荷（穷尽 sealed 三变体）。
///
/// 与 `p2p` 的行分隔 JSON 编码等价，只是载荷直接是 Map（RTDB 原生可存）。
Map<String, Object?> signalingEnvelopeToPayload(SignalingEnvelope e) =>
    switch (e) {
      SessionDescriptionEnvelope(:final kind, :final sdp) =>
        {'t': 'sdp', 'kind': kind.name, 'sdp': sdp},
      IceCandidateEnvelope(
        :final candidate,
        :final sdpMid,
        :final sdpMLineIndex
      ) =>
        {
          't': 'ice',
          'candidate': candidate,
          'sdpMid': sdpMid,
          'sdpMLineIndex': sdpMLineIndex,
        },
      ByeEnvelope() => {'t': 'bye'},
    };

/// 载荷 → 信封（穷尽 sealed 三变体）。
SignalingEnvelope signalingEnvelopeFromPayload(Map<String, Object?> p) {
  return switch (p['t']) {
    'sdp' => SessionDescriptionEnvelope(
        kind: SdpKind.values.byName(p['kind'] as String),
        sdp: p['sdp'] as String,
      ),
    'ice' => IceCandidateEnvelope(
        candidate: p['candidate'] as String,
        sdpMid: p['sdpMid'] as String,
        sdpMLineIndex: (p['sdpMLineIndex'] as num).toInt(),
      ),
    'bye' => const ByeEnvelope(),
    _ => throw FormatException('未知信封类型: ${p['t']}'),
  };
}
