/// 媒体上传管线（S2 Phase 5，入口 B）。
///
/// 系统相册选图 → EXIF 剥离（硬要求）→ 客户端转码（stub）→
/// BlobGateway 两阶段上传（public）→ 返回 [PlaygroundAttachment]。
///
/// 真云端 BlobGateway 交付前，注入 [FirebaseBlobGateway]（内存 fake）即可
/// 全链路跑通（契约套件 C6/C7 依赖本管线做 EXIF 断言）。
library;

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'client_transcoder.dart';
import 'exif_stripper.dart';

/// 上传管线默认分块大小（与 fake capabilities.maxChunkBytes 一致）。
const int kUploadChunkBytes = 256 * 1024;

/// 单图上传管线。
final class PlaygroundMediaUploadPipeline {
  PlaygroundMediaUploadPipeline({
    required BlobGateway blobGateway,
    ClientTranscoder transcoder = const ClientTranscoder(),
  })  : _blobGateway = blobGateway,
        _transcoder = transcoder;

  final BlobGateway _blobGateway;
  final ClientTranscoder _transcoder;

  /// 上传一张图片（公开可见），返回附件（含 mediaObjectId）。
  ///
  /// 管线顺序不可调换：**先剥离 EXIF，再转码**（契约套件 C7 变异自检
  /// 依赖剥离步骤必须存在）。
  Future<PlaygroundAttachment> uploadImage({
    required PlaygroundUserId userId,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    // 1. EXIF 剥离（硬要求，GPS 等隐私元数据不得上云）。
    final stripped = stripExif(bytes);

    // 2. 客户端转码（当前 stub 原样返回）。
    final transcoded = await _transcoder.transcode(
      stripped,
      mimeType: mimeType,
    );

    // 3. 构造公开 blob 句柄：public → cipherManifestId == plaintextSha256。
    final shaHex = sha256.convert(transcoded).toString();
    final chunkCount =
        (transcoded.length + kUploadChunkBytes - 1) ~/ kUploadChunkBytes;
    final handle = BlobHandle(
      plaintextSha256: shaHex,
      cipherManifestId: shaHex,
      cipherId: 'identity', // public 对象不加密
      keyVersion: 1,
      totalBytes: transcoded.length,
      chunkCount: chunkCount,
      mimeType: mimeType,
    );

    // 4. 两阶段上传：登记 → 分块 → 完成。
    final ticket = await _blobGateway.beginUpload(
      scopeUid: userId.value,
      handle: handle,
      visibility: BlobVisibility.public,
    );
    for (var i = 0; i < chunkCount; i++) {
      final start = i * kUploadChunkBytes;
      final end = (start + kUploadChunkBytes).clamp(0, transcoded.length);
      await _blobGateway.putChunk(
        ticket: ticket,
        index: i,
        cipherBytes: transcoded.sublist(start, end),
      );
    }
    await _blobGateway.completeUpload(ticket);

    // 5. 返回附件（含 mediaObjectId）。
    return PlaygroundAttachment.image(
      mediaObjectId: PlaygroundAttachmentId(handle.cipherManifestId),
      mimeType: mimeType,
    );
  }
}
