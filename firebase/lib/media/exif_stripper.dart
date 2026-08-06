/// EXIF 剥离器（S2 Phase 5，设计稿入口 B 硬要求）。
///
/// 纯 Dart 实现，不依赖原生插件，可在 VM 中单测（契约套件 C6/C7）。
/// 输入：JPEG / PNG 字节流；输出：剥离 EXIF/GPS 等元数据后的字节流。
///
/// 处理矩阵：
/// - JPEG：移除 APP1 标记段（EXIF 数据所在，payload 以 `Exif\0\0` 开头）。
/// - PNG：移除 tEXt / iTXt / zTXt 辅助块（元数据所在）。
/// - HEIC / 其他：**原样返回**（iOS 相册已自动转 JPEG，不属于本层职责）。
library;

import 'dart:typed_data';

/// JPEG SOI 标记。
const int _kJpegSoi0 = 0xFF;
const int _kJpegSoi1 = 0xD8;

/// PNG 签名（8 字节）。
const List<int> _kPngSignature = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
];

/// PNG 块类型。
const String _kPngText = 'tEXt';
const String _kPngIText = 'iTXt';
const String _kPngZText = 'zTXt';

/// 剥离 EXIF/GPS 元数据。
///
/// 对非 JPEG/PNG（或无法识别的）输入原样返回（拷贝）。
Uint8List stripExif(List<int> bytes) {
  if (_isJpeg(bytes)) return _stripJpegExif(bytes);
  if (_isPng(bytes)) return _stripPngMetadata(bytes);
  // HEIC / 其他格式：不剥离（上游已保证无 EXIF，或本层不支持）。
  return Uint8List.fromList(bytes);
}

bool _isJpeg(List<int> bytes) {
  return bytes.length >= 2 && bytes[0] == _kJpegSoi0 && bytes[1] == _kJpegSoi1;
}

bool _isPng(List<int> bytes) {
  if (bytes.length < _kPngSignature.length) return false;
  for (var i = 0; i < _kPngSignature.length; i++) {
    if (bytes[i] != _kPngSignature[i]) return false;
  }
  return true;
}

/// JPEG：逐标记段扫描，跳过 EXIF 所在 APP1 段。
///
/// 段结构：`FF marker LEN_HI LEN_LO payload...`，LEN 为 2 字节大端，
/// 长度**包含** LEN 自身的 2 字节。
Uint8List _stripJpegExif(List<int> bytes) {
  final out = BytesBuilder(copy: false);
  var i = 0;

  // SOI
  out.addByte(bytes[i++]);
  out.addByte(bytes[i++]);

  while (i < bytes.length) {
    // 跳过 marker 前的 0xFF 填充。
    if (bytes[i] != 0xFF) {
      // 数据段（如熵编码数据）直接拷贝到结尾。
      out.add(bytes.sublist(i));
      break;
    }
    while (i < bytes.length && bytes[i] == 0xFF) {
      i++;
    }
    if (i >= bytes.length) break;

    final marker = bytes[i++];
    if (marker == 0x00 || marker == 0xFF) {
      // 填充字节/异常：原样保留 0xFF 与当前字节，继续。
      out.addByte(0xFF);
      if (marker == 0x00) {
        out.addByte(0x00);
        continue;
      }
      // marker == 0xFF 时上面的 while 已消耗，这里继续扫描。
      i--; // 让外层 while 重新处理。
      continue;
    }

    // SOS (0xDA)：其后是熵编码数据，无段长度。
    if (marker == 0xDA) {
      out.addByte(0xFF);
      out.addByte(0xDA);
      out.add(bytes.sublist(i));
      break;
    }

    // 无长度段的单字节标记（RST 除外，RST 只有 0xFFD0-0xFFD7）。
    if ((marker >= 0xD0 && marker <= 0xD7) || marker == 0x01) {
      out.addByte(0xFF);
      out.addByte(marker);
      continue;
    }

    // 一般段：读长度。
    if (i + 2 > bytes.length) {
      out.addByte(0xFF);
      out.addByte(marker);
      break;
    }
    final len = (bytes[i] << 8) | bytes[i + 1];
    if (len < 2 || i + len > bytes.length) {
      // 长度异常：原样保留该段剩余。
      out.addByte(0xFF);
      out.addByte(marker);
      out.add(bytes.sublist(i));
      break;
    }
    final payloadStart = i + 2;
    final payloadEnd = payloadStart + (len - 2);

    final isExifApp1 =
        marker == 0xE1 && payloadEnd - payloadStart >= 6 &&
        bytes[payloadStart] == 0x45 && // 'E'
        bytes[payloadStart + 1] == 0x78 && // 'x'
        bytes[payloadStart + 2] == 0x69 && // 'i'
        bytes[payloadStart + 3] == 0x66 && // 'f'
        bytes[payloadStart + 4] == 0x00 &&
        bytes[payloadStart + 5] == 0x00;

    if (!isExifApp1) {
      out.addByte(0xFF);
      out.addByte(marker);
      out.add(bytes.sublist(i, payloadEnd));
    }
    // EXIF APP1：整段丢弃（含 GPS IFD）。

    i = payloadEnd;
  }

  return out.toBytes();
}

/// PNG：删除 tEXt / iTXt / zTXt 辅助块，其余块（IHDR/IDAT/IEND 等）原样保留。
Uint8List _stripPngMetadata(List<int> bytes) {
  final out = BytesBuilder(copy: false);
  out.add(bytes.sublist(0, _kPngSignature.length));

  var i = _kPngSignature.length;
  while (i + 12 <= bytes.length) {
    final dataLen = (bytes[i] << 24) |
        (bytes[i + 1] << 16) |
        (bytes[i + 2] << 8) |
        bytes[i + 3];
    final typeStart = i + 4;
    final type = String.fromCharCodes(bytes.sublist(typeStart, typeStart + 4));
    final blockEnd = typeStart + 4 + dataLen + 4; // +4 CRC
    if (blockEnd > bytes.length) {
      // 损坏：剩余原样保留。
      out.add(bytes.sublist(i));
      break;
    }
    if (type != _kPngText && type != _kPngIText && type != _kPngZText) {
      out.add(bytes.sublist(i, blockEnd));
    }
    i = blockEnd;
  }
  if (i < bytes.length) {
    out.add(bytes.sublist(i));
  }
  return out.toBytes();
}
