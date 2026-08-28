import 'dart:async';

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_media/repository_interface_media.dart';

import 'media_source.dart';

/// 生产级 [MediaAcquisitionPort]（TDD-T5）。
///
/// 采集动作委托给注入的 [MediaSourcePicker]（平台采集器），原始字节经
/// [LocalBlobStore] 持久化（sourceOfTruth 区），业务层只拿到稳定
/// [MediaReference]（refId = blob cipherManifestId）。不保存二进制、
/// 不保存绝对路径、不自行管理文件 —— 字节生命周期完全由 xuan-storage
/// blob 子系统负责。
class DriftMediaAcquisitionAdapter implements MediaAcquisitionPort {
  final LocalBlobStore blobStore;
  final MediaSourcePicker picker;
  final BlobTier _tier;

  DriftMediaAcquisitionAdapter({
    required this.blobStore,
    required this.picker,
    BlobTier tier = BlobTier.sourceOfTruth,
  }) : _tier = tier;

  @override
  Future<MediaAcquisitionResult> acquireImage({
    required MediaRole role,
    double? maxWidth,
    double? maxHeight,
  }) {
    return _acquire(role: role, maxWidth: maxWidth, maxHeight: maxHeight);
  }

  @override
  Future<MediaAcquisitionResult> acquireAudio({required MediaRole role}) {
    return _acquire(role: role);
  }

  @override
  Future<MediaAcquisitionResult> acquireVideo({
    required MediaRole role,
    int? maxDurationMs,
  }) {
    return _acquire(role: role, maxDurationMs: maxDurationMs);
  }

  Future<MediaAcquisitionResult> _acquire({
    required MediaRole role,
    double? maxWidth,
    double? maxHeight,
    int? maxDurationMs,
  }) async {
    final source = await picker(
      role,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      maxDurationMs: maxDurationMs,
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
      role: role,
      mimeType: handle.mimeType,
      originalWidth: source.width,
      originalHeight: source.height,
      durationMs: source.durationMs,
      createdAtUtc: DateTime.now().toUtc(),
    );
    return MediaAcquisitionResult(
      reference: reference,
      descriptor: MediaDescriptor(
        mimeType: handle.mimeType,
        width: source.width,
        height: source.height,
        durationMs: source.durationMs,
        fileSizeBytes: handle.totalBytes,
      ),
      readiness: MediaReadiness.ready,
      // 业务层禁止绝对路径：预览由 Shell 经 blob 读取能力解析，此处不传。
      localPreviewPath: null,
    );
  }
}
