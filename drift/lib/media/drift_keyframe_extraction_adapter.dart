import 'dart:async';

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_media/repository_interface_media.dart';

import 'media_source.dart';

/// 生产级 [KeyframeExtractionPort]（TDD-T5）。
///
/// 视频解码委托给注入的 [VideoKeyframeProvider]（平台解码器），关键帧字节
/// 经 [LocalBlobStore] 持久化为 keyframe 引用。适配器只负责存储边界，
/// 不自行解码视频。
class DriftKeyframeExtractionAdapter implements KeyframeExtractionPort {
  final LocalBlobStore blobStore;
  final VideoKeyframeProvider provider;
  final BlobTier _tier;

  DriftKeyframeExtractionAdapter({
    required this.blobStore,
    required this.provider,
    BlobTier tier = BlobTier.sourceOfTruth,
  }) : _tier = tier;

  @override
  Future<KeyframeResult> extractKeyframe({
    required MediaReference sourceVideo,
    required int positionMs,
    double? maxWidth,
    double? maxHeight,
  }) async {
    final source = await provider(
      sourceVideo,
      positionMs,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    final handle = await blobStore.put(
      Stream.fromIterable([source.bytes]),
      mimeType: source.mimeType,
      tier: _tier,
      expectedBytes: source.sizeBytes,
    );
    final reference = MediaReference(
      refId: handle.cipherManifestId,
      version: 1,
      role: MediaRole.keyframe,
      mimeType: handle.mimeType,
      originalWidth: source.width,
      originalHeight: source.height,
      createdAtUtc: DateTime.now().toUtc(),
    );
    return KeyframeResult(
      keyframeReference: reference,
      descriptor: MediaDescriptor(
        mimeType: handle.mimeType,
        width: source.width,
        height: source.height,
        fileSizeBytes: handle.totalBytes,
      ),
      sourceVideo: sourceVideo,
      sourcePositionMs: positionMs,
    );
  }
}
