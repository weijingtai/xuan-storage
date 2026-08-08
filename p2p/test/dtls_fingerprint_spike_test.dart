@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// DTLS 指纹探路 spike（框架计划 §五，前置①）。
///
/// 目的：确认 flutter_webrtc 能否取到三个指纹 ——
///   ① 本端 DTLS 证书指纹（本端 SDP a=fingerprint）
///   ② 对端声明的证书指纹（对端 answer SDP a=fingerprint）
///   ③ DTLS 握手完成后**观测到**的对端证书指纹（getStats 的 certificate 报告）
///
/// 结论（源码 + 实测）：
/// - ①/② 从 local/remoteDescription.sdp 解析 a=fingerprint 行，必可得
/// - ③ 走标准 WebRTC stats：`getStats()` 返回 `List<StatsReport>`，其中
///   `transport` 类型 report 的 `remoteCertificateId` 指向 `certificate`
///   类型 report，其 `fingerprint` 即 DTLS 实际协商的对端证书指纹。
///   Android 原生（PeerConnectionObserver.handleStatsReport）与 Web
///   （dart_webrtc 直接用浏览器 RTCStatsReport）都完整透传 stats 成员。
///
/// 人工触发（本机有 Chrome 时）：
/// ```bash
/// cd p2p && flutter test --platform chrome --tags integration \
///   test/dtls_fingerprint_spike_test.dart
/// ```
/// （dart_test.yaml 默认排除 integration tag，故不带 --tags 不跑。）
void main() {
  test('spike: 两条 RTCPeerConnection 握手后取到 ①②③ 三个指纹', () async {
    // ── 1. 建两条对等连接 ──────────────────────────────
    final alice = await createPeerConnection(const <String, dynamic>{});
    final bob = await createPeerConnection(const <String, dynamic>{});

    // 非 trickle：等 gathering complete 后一次性交换完整 SDP（含候选）。
    final aliceCandidates = <RTCIceCandidate>[];
    final bobCandidates = <RTCIceCandidate>[];
    alice.onIceCandidate = (c) {
      if ((c.candidate ?? '').isNotEmpty) aliceCandidates.add(c);
    };
    bob.onIceCandidate = (c) {
      if ((c.candidate ?? '').isNotEmpty) bobCandidates.add(c);
    };

    // 建 DataChannel 触发 offer 带数据通道（无需媒体设备）。
    final dc = await alice.createDataChannel('probe', RTCDataChannelInit());
    expect(dc.label, 'probe');

    // ── 2. offer/answer 交换（非 trickle）──────────────
    final offer = await alice.createOffer();
    await alice.setLocalDescription(offer);
    // 等本端 ICE 收集完成（loopback 环境通常 <1s）。
    await _waitIceComplete(alice);

    await bob.setRemoteDescription(offer);
    final answer = await bob.createAnswer();
    await bob.setLocalDescription(answer);
    await _waitIceComplete(bob);

    await alice.setRemoteDescription(answer);
    for (final c in bobCandidates) {
      await alice.addCandidate(c);
    }
    for (final c in aliceCandidates) {
      await bob.addCandidate(c);
    }

    // ── 3. 等 DTLS 握手完成（connectionState == connected）──
    await _waitConnected(alice);
    await _waitConnected(bob);

    // ── 4. 取 ① 本端指纹：本端 SDP a=fingerprint ───────
    final aliceLocal = await alice.getLocalDescription();
    final aliceLocalSdp = aliceLocal?.sdp ?? '';
    // 探路记录：web 端 SDP 的 fingerprint 行实际格式。
    // ignore: avoid_print
    print('SPIKE 本端 SDP fingerprint 行: '
        '${aliceLocalSdp.split(RegExp(r'\r?\n')).where((l) => l.contains('fingerprint')).toList()}');
    final aliceLocalFp = _parseSdpFingerprint(aliceLocalSdp);
    expect(aliceLocalFp, isNotNull, reason: '① 本端 SDP 必须含 a=fingerprint');
    expect(aliceLocalFp, startsWith('sha-256 '),
        reason: '① 必须 SDP a=fingerprint 格式（算法名内联）');

    // ── 5. 取 ② 对端声明指纹：对端 answer SDP a=fingerprint ──
    final aliceRemote = await alice.getRemoteDescription();
    final aliceRemoteSdp = aliceRemote?.sdp ?? '';
    // ignore: avoid_print
    print('SPIKE 对端 SDP fingerprint 行: '
        '${aliceRemoteSdp.split(RegExp(r'\r?\n')).where((l) => l.contains('fingerprint')).toList()}');
    final aliceRemoteFp = _parseSdpFingerprint(aliceRemoteSdp);
    expect(aliceRemoteFp, isNotNull, reason: '② 对端 SDP 必须含 a=fingerprint');
    expect(aliceRemoteFp, startsWith('sha-256 '));

    // ── 6. 取 ③ 观测指纹：getStats → transport.remoteCertificateId
    //       → certificate.fingerprint ─────────────────────
    final stats = await alice.getStats();
    final observed = _extractObservedPeerFingerprint(stats);
    expect(observed, isNotNull,
        reason: '③ 观测指纹必须可得：getStats 的 transport.remoteCertificateId '
            '→ certificate.fingerprint（DTLS 实际协商的对端证书指纹）');
    expect(observed, startsWith('sha-256 '));

    // 正常路径下 ② 声明值 == ③ 观测值（无 MITM 时两者一致）。
    expect(observed, aliceRemoteFp,
        reason: '无 MITM 时观测指纹应等于对端 SDP 声明指纹');

    // 记录探路结论（人工查看 print 输出）。
    // ignore: avoid_print
    print('SPIKE ① 本端指纹: $aliceLocalFp');
    // ignore: avoid_print
    print('SPIKE ② 对端声明指纹: $aliceRemoteFp');
    // ignore: avoid_print
    print('SPIKE ③ 观测指纹: $observed');
    // ignore: avoid_print
    print('SPIKE stats types: ${stats.map((s) => s.type).toSet()}');

    await alice.close();
    await bob.close();
  });
}

/// 解析 SDP 的 `a=fingerprint` 行，返回 `'sha-256 AA:BB:...'` 形态（含算法名）。
///
/// 兼容两种来源格式：`a=fingerprint:sha-256 AA:BB...`（原生/macOS）与
/// `a=fingerprint:AA:BB...`（Web 端实测格式，算法名缺失则补 `sha-256 `）。
String? _parseSdpFingerprint(String sdp) {
  for (final line in sdp.split(RegExp(r'\r?\n'))) {
    if (line.startsWith('a=fingerprint:')) {
      final rest = line.substring('a=fingerprint:'.length).trim();
      if (rest.isEmpty) continue;
      return rest.startsWith('sha-256 ') ? rest : 'sha-256 $rest';
    }
  }
  return null;
}

/// 从 stats 报告中取「观测到的对端证书指纹」：
/// transport 类型 report 的 remoteCertificateId → certificate 报告.fingerprint。
///
/// 返回 SDP a=fingerprint 格式 `'sha-256 AA:BB:...'`（算法名内联）。实测：
/// Chrome stats 的 certificate.fingerprint 是纯 `AA:BB:...`（算法名在
/// `fingerprintAlgorithm` 字段），实现时需拼上算法名前缀以符合契约格式。
String? _extractObservedPeerFingerprint(List<StatsReport> stats) {
  // 1. 找 transport 报告，取其 remoteCertificateId。
  String? remoteCertId;
  for (final s in stats) {
    if (s.type == 'transport') {
      final v = s.values['remoteCertificateId'];
      if (v is String && v.isNotEmpty) remoteCertId = v;
      break;
    }
  }
  if (remoteCertId == null) return null;
  // 2. 找对应 certificate 报告，取其 fingerprint（+ 算法名）。
  for (final s in stats) {
    if (s.type == 'certificate' && s.id == remoteCertId) {
      final fp = s.values['fingerprint'];
      if (fp is String && fp.isNotEmpty) {
        final algo = s.values['fingerprintAlgorithm'];
        if (algo is String && algo.isNotEmpty) return '$algo $fp';
        return fp.startsWith('sha-256 ') ? fp : 'sha-256 $fp';
      }
    }
  }
  return null;
}

/// 等 ICE gathering 完成（非 trickle 全量交换的前提）。
Future<void> _waitIceComplete(RTCPeerConnection pc) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    final state = await pc.getIceGatheringState();
    if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  throw StateError('ICE gathering 未在 10s 内完成');
}

/// 等连接状态 connected（DTLS 握手完成）。
Future<void> _waitConnected(RTCPeerConnection pc) async {
  final deadline = DateTime.now().add(const Duration(seconds: 15));
  while (DateTime.now().isBefore(deadline)) {
    final state = await pc.getConnectionState();
    if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  throw StateError('连接未在 15s 内建立（DTLS 握手未完成）');
}
