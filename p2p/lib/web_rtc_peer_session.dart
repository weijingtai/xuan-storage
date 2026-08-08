/// WebRTC 传输上的 `PeerSession` / `PeerStream` 实现（S3c-c 步骤 3）。
///
/// 【一条会话 = 一条 RTCPeerConnection】`PeerSession` 持有连接、握手、
/// 心跳、重连；一条会话上可开多条逻辑流（[StreamKind.oplog] 与
/// [StreamKind.blobChunk] 等），互不阻塞 —— 每条逻辑流对应一条
/// `RTCDataChannel`（SCTP 多通道复用同一条 DTLS，天然背压隔离，
/// 呼应边界 handoff「共用一条 WebRTC 连接，StreamKind 区分流」）。
///
/// 【背压】`PeerStream.send` 检查 `RTCDataChannel.bufferedAmount`：
/// 触顶按 [OverflowPolicy.wait] 挂起（等待水位下降后恢复），绝不超过
/// 契约的「最多超出一个在途批次」越界上限。订阅者 `pause()` 后对端
/// 发送侧 `bufferedAmount` 自然增长（SCTP 接收窗关闭 → 发送缓冲积压），
/// 无需应用层确认 —— 与契约 A5 语义一致。
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:persistence_core/model/storage_error.dart';
import 'package:persistence_core/model/transport.dart';

/// 一条 WebRTC 会话上的逻辑流（对应一条 RTCDataChannel）。
///
/// 溢出策略：`OverflowPolicy.wait` —— 发送水位触顶时挂起直到
/// `bufferedAmount` 降到 [maxBufferedAmount] 以下，绝不让水位无界上涨。
final class WebRtcPeerStream implements PeerStream {
  /// 构造逻辑流。
  ///
  /// 参数说明：
  /// - [channel]: 底层 RTCDataChannel（本流独占）。
  /// - [maxBufferedAmount]: 发送侧背压上限（字节）。
  // ignore: prefer_initializing_formals
  WebRtcPeerStream({
    required RTCDataChannel channel,
    required int maxBufferedAmount,
  })  // ignore: prefer_initializing_formals
      // ignore: prefer_initializing_formals
      : _channel = channel,
        // ignore: prefer_initializing_formals
        _maxBufferedAmount = maxBufferedAmount {
    // 订阅对端字节：二进制消息投递，文本消息按 UTF-8 编码投递。
    _channel.messageStream.listen((msg) {
      final bytes = msg.isBinary
          ? msg.binary
          : Uint8List.fromList(_utf8.encode(msg.text));
      _incoming.add(bytes);
    });
  }

  static const _utf8 = _Utf8Codec();

  final RTCDataChannel _channel;
  final int _maxBufferedAmount;

  final StreamController<List<int>> _incoming =
      StreamController<List<int>>.broadcast();
  bool _closed = false;

  @override
  Stream<List<int>> get incoming => _incoming.stream;

  @override
  int get maxBufferedAmount => _maxBufferedAmount;

  /// 当前发送水位：直接读 `RTCDataChannel.bufferedAmount`（决定记录 D2
  /// 明示 WebRTC 用原生值）。
  @override
  int get bufferedAmount => _channel.bufferedAmount ?? 0;

  /// 溢出策略：wait（挂起直到水位下降，与 FakeTransport 一致）。
  @override
  OverflowPolicy get overflowPolicy => OverflowPolicy.wait;

  /// 发送一段字节（分块 ≤16KB，DataChannel 安全线；S6 §2.4）。
  ///
  /// 背压语义：入口检查 `bufferedAmount >= maxBufferedAmount` 时挂起，
  /// 直到水位降到上限以下才接受本包。接受后水位可短暂超限，越界被限制
  /// 为最多超出一个在途批次（契约 R5）。
  @override
  Future<void> send(List<int> bytes) async {
    if (_closed) {
      throw BackpressureOverflowError();
    }
    // 分块：16KB 安全线（S6 实测：单条消息上限 256KB，16KB 是安全线）。
    const chunkSize = 16 * 1024;
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        i + chunkSize > bytes.length ? bytes.length : i + chunkSize,
      );
      // 入口检查：满则挂起（wait 策略）。
      while ((_channel.bufferedAmount ?? 0) + chunk.length >
          _maxBufferedAmount) {
        await _lowWatermark();
      }
      await _channel.send(RTCDataChannelMessage.fromBinary(
        Uint8List.fromList(chunk),
      ));
    }
  }

  /// 等待水位降到 [maxBufferedAmount] 以下（有界轮询）。
  Future<void> _lowWatermark() async {
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while ((_channel.bufferedAmount ?? 0) >= _maxBufferedAmount) {
      if (DateTime.now().isAfter(deadline)) {
        throw const StorageError(
          code: 'p2p.peer_stream_send_timeout',
          message: '发送缓冲水位未在 30s 内降回上限以下',
          reason: '对端长时间不消费，发送侧缓冲持续触顶',
          suggestion: '检查对端消费路径是否停滞；必要时减小单次发送批大小',
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _channel.close();
    await _incoming.close();
  }
}

/// 一条 WebRTC 会话：持有 RTCPeerConnection + 多路复用逻辑流。
final class WebRtcPeerSession implements PeerSession {
  /// 构造已认证的 WebRTC 会话。
  ///
  /// 参数说明：
  /// - [pc]: 已建立且通过 channel binding 认证的 RTCPeerConnection。
  /// - [remote]: 对端身份（握手认证后绑定，裁定丙：绝不接受未认证形态）。
  /// - [localBinding]: 本端本次握手绑定的传输层证书指纹。
  // ignore: prefer_initializing_formals
  WebRtcPeerSession({
    required RTCPeerConnection pc,
    required PeerIdentity remote,
    required ChannelBinding localBinding,
  })  // ignore: prefer_initializing_formals
      // ignore: prefer_initializing_formals
      : _pc = pc,
        // ignore: prefer_initializing_formals
        remote = remote,
        // ignore: prefer_initializing_formals
        channelBinding = localBinding {
    // 入站逻辑流：对端主动开 DataChannel → incomingStreams。
    _pc.onDataChannel = (channel) {
      _incomingStreams.add(WebRtcPeerStream(
        channel: channel,
        maxBufferedAmount: _kMaxBufferedAmount,
      ));
    };
  }

  /// 发送侧背压上限（字节）。
  ///
  /// 与 DataChannel 缓冲语义绑定：取 1MB（16KB 分块 × 64 批在途），
  /// 防单流撑爆内存又不至于让流控过于敏感。
  static const int _kMaxBufferedAmount = 1024 * 1024;

  final RTCPeerConnection _pc;

  @override
  final PeerIdentity remote;

  @override
  final ChannelBinding channelBinding;

  final StreamController<PeerStream> _incomingStreams =
      StreamController<PeerStream>.broadcast();
  bool _closed = false;

  @override
  Stream<PeerSessionState> get state =>
      Stream<PeerSessionState>.value(PeerSessionState.authenticated);

  @override
  Future<PeerStream> openStream(StreamKind kind) async {
    if (_closed) {
      throw StateError('会话已关闭，不能开新流');
    }
    final channel = await _pc.createDataChannel(
      kind.name,
      RTCDataChannelInit()..ordered = true,
    );
    return WebRtcPeerStream(
      channel: channel,
      maxBufferedAmount: _kMaxBufferedAmount,
    );
  }

  @override
  Stream<PeerStream> get incomingStreams => _incomingStreams.stream;

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _pc.close();
    await _incomingStreams.close();
  }
}

/// 轻量 UTF-8 编解码（避免引入 dart:convert 全量 API 到热路径之外）。
class _Utf8Codec {
  const _Utf8Codec();

  Uint8List encode(String input) => Uint8List.fromList(
        _encodeRunes(input.runes),
      );

  List<int> _encodeRunes(Iterable<int> runes) {
    final out = <int>[];
    for (final r in runes) {
      if (r < 0x80) {
        out.add(r);
      } else if (r < 0x800) {
        out.add(0xC0 | (r >> 6));
        out.add(0x80 | (r & 0x3F));
      } else if (r < 0x10000) {
        out.add(0xE0 | (r >> 12));
        out.add(0x80 | ((r >> 6) & 0x3F));
        out.add(0x80 | (r & 0x3F));
      } else {
        out.add(0xF0 | (r >> 18));
        out.add(0x80 | ((r >> 12) & 0x3F));
        out.add(0x80 | ((r >> 6) & 0x3F));
        out.add(0x80 | (r & 0x3F));
      }
    }
    return out;
  }
}
