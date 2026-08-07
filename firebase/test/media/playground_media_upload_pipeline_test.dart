/// 上传管线 EXIF 门禁（S2 P0-2 返工）。
///
/// 与契约 C6（纯函数级）不同，本测试断言**上传路径上的真实字节流**：
/// 通过 [InMemoryFirebaseBlobGateway] 读回 pipeline 实际提交的 chunk 字节，
/// 验证 EXIF 剥离发生在字节真正进入网关之前（验收 A4/A5 的靶点）。
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_firebase/media/blob_gateway_firebase.dart';
import 'package:persistence_firebase/media/playground_media_upload_pipeline.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 构造含 GPS 标签的 JPEG（SOI + EXIF APP1 + JFIF APP0 + EOI）。
Uint8List _gpsJpeg() {
  final gpsTag = [0x47, 0x50, 0x53]; // "GPS"
  final exifPayload = <int>[
    0x45, 0x78, 0x69, 0x66, 0x00, 0x00, // "Exif\0\0"
    ...gpsTag,
  ];
  final app1Length = exifPayload.length + 2;
  return Uint8List.fromList([
    0xFF, 0xD8, // SOI
    0xFF, 0xE1, // APP1
    (app1Length >> 8) & 0xFF, app1Length & 0xFF,
    ...exifPayload,
    0xFF, 0xE0, // APP0（JFIF）
    0x00, 0x04, 0x4A, 0x46, 0x49, 0x46, // "JFIF"
    0xFF, 0xD9, // EOI
  ]);
}

bool _containsSequence(List<int> haystack, List<int> needle) {
  if (needle.isEmpty || haystack.length < needle.length) return false;
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    var match = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}

void main() {
  test('uploadImage 上传路径上的字节流查不到 GPS 标签（A4 门禁）', () async {
    final gateway = InMemoryFirebaseBlobGateway();
    final pipeline = PlaygroundMediaUploadPipeline(blobGateway: gateway);

    final attachment = await pipeline.uploadImage(
      userId: const PlaygroundUserId('u-gps'),
      bytes: _gpsJpeg(),
      mimeType: 'image/jpeg',
    );

    // 从网关读回 pipeline 实际提交的字节（public → objectName == sha256）。
    final uploaded = gateway.uploadedBytes(attachment.mediaObjectId!.value);
    expect(uploaded, isNotEmpty, reason: 'gateway 必须收到字节');

    // 核心断言：上传路径上的字节流不含 GPS 标签。
    expect(
      _containsSequence(uploaded, [0x47, 0x50, 0x53]),
      isFalse,
      reason: 'A4: 上传路径上的字节流不得含 GPS 标签（EXIF 剥离须发生在上传前）',
    );

    // 非 EXIF 段（JFIF）应保留。
    expect(
      _containsSequence(uploaded, [0x4A, 0x46, 0x49, 0x46]),
      isTrue,
      reason: 'A4: 非 EXIF 段必须保留',
    );
  });
}
