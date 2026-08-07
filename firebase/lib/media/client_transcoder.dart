/// 客户端转码器（S2 Phase 5）。
///
/// 计划要求「先做 stub」：本实现当前原样返回输入字节流，不改变尺寸。
/// 真实转码（压缩/降采样）待后续接入系统级编码器后替换。
library;

import 'dart:typed_data';

/// 客户端转码端口：压缩/降采样图片字节。
final class ClientTranscoder {
  const ClientTranscoder();

  /// 转码输入字节流。
  ///
  /// ⚠ stub 行为：原样返回（`bytes` 的新拷贝），不做任何压缩。
  /// TODO(S2): 接入图片压缩（质量分级 + 尺寸上限），替换 stub 行为。
  Future<Uint8List> transcode(
    Uint8List bytes, {
    required String mimeType,
  }) async {
    return Uint8List.fromList(bytes);
  }
}
