import 'dart:async';
import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'package:persistence_core/model/signaling.dart';

/// 本地局域网信令实现（bonsoir + socket 直连）。
class LocalSignaling implements SignalingChannel {
  final _advertisement = Advertisement();
  final _discovery = Discovery();
  final Map<RendezvousKey, _LanSession> _sessions = {};

  @override
  Future<SignalingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) async {
    // 1. 先广播自己（先到者登记）
    await _advertisement.start();

    // 2. 发现对端
    await _discovery.start();

    // 3. 创建会话
    final session = _LanSession(rendezvous);
    _sessions[rendezvous] = session;

    return session;
  }

  @override
  Future<void> dispose() async {
    await _advertisement.stop();
    await _discovery.stop();
    _sessions.clear();
  }
}

class _LanSession implements SignalingSession {
  final RendezvousKey rendezvous;
  // ... 后续实现 socket 直连 + SDP 交换
  _LanSession(this.rendezvous);
  // 省略实现，待完成
}
