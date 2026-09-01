/// WB0 RED — Chrome 真实 RED：Web 字节后端边界（Storage 侧）。
///
/// 构造 `WebBlobByteBackend`（浏览器实现，与条件入口 `blob_byte_backend.dart`
/// 的浏览器分支同一实现）并断言 writeChunk → readChunk 二进制往返。当前该
/// backend 是历史提交 `7447e74` 留下的永久 `UnsupportedError` 占位（S1d
/// 延期），此测试必须 RED；只有补齐 IndexedDB 实现（WB1）才会 GREEN。
///
/// Chrome-only：`flutter test -d chrome test/blob/web_blob_byte_backend_test.dart`。
///
/// 已探明：本工具链（Flutter 3.44，flutter test -d chrome 走 DDC）上
/// `dart.library.html` 与 `dart.library.js_interop` 均不为 true，既有条件入口
/// `blob_byte_backend.dart` 的 `if (dart.library.html)` 是死条件，恒解析到
/// native.dart。因此本测试直接 import 浏览器实现 `web.dart`（纯 Dart，双平台
/// 可编译），死条件修复列为 WB1 生产改动项。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/blob/web.dart';

void main() {
  test('web backend persists and reads raw chunk bytes (0x00/0xFF 无损)', () async {
    final backend = WebBlobByteBackend();

    // manifestDir 已含 logical namespace/scopeUid（既有 Blob 层语义）。
    const manifestDir = 'wb0-scope-range/77e862bf-a6b1-4ff5-a6b1-77e862bfa6b1';
    const raw = [0x00, 0xFF, 0x7F, 0x10, 0x00];

    await backend.writeChunk(manifestDir, 0, raw);

    final bytes = await backend.readChunk(manifestDir, 0);
    expect(bytes, raw, reason: 'chunk 字节必须 0x00/0xFF 无损往返');
    expect(await backend.listChunks(manifestDir), {0});
  });
}