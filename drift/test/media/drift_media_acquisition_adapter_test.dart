import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/in_memory_blob_store.dart';
import 'package:persistence_drift/media/drift_keyframe_extraction_adapter.dart';
import 'package:persistence_drift/media/drift_media_acquisition_adapter.dart';
import 'package:persistence_drift/media/media_source.dart';
import 'package:repository_interface_media/repository_interface_media.dart';

/// TDD-T5 — 生产级 MediaAcquisitionPort（xuan-storage blob 后端）：
/// 采集结果只含稳定 MediaReference + 描述符，禁止二进制/绝对路径进入业务层；
/// 视频关键帧经 KeyframeExtractionPort 生产适配器产出 keyframe 引用。
void main() {
  const scope = 'scope-media-t5';

  InMemoryBlobStore newBlobStore() => InMemoryBlobStore(scopeUid: scope);

  MediaSourceData sourceData({
    List<int>? bytes,
    String mimeType = 'image/jpeg',
    int? width = 800,
    int? height = 600,
    int? durationMs,
  }) =>
      MediaSourceData(
        bytes: bytes ?? List<int>.generate(1024, (i) => i % 256),
        mimeType: mimeType,
        width: width,
        height: height,
        durationMs: durationMs,
        fileSizeBytes:
            (bytes ?? List<int>.generate(1024, (i) => i % 256)).length,
      );

  test('acquireImage 经 blob 持久化并返回稳定 MediaReference（无二进制/无绝对路径）',
      () async {
    final blobStore = newBlobStore();
    final capturedRoles = <MediaRole>[];
    final adapter = DriftMediaAcquisitionAdapter(
      blobStore: blobStore,
      picker: (role, {maxWidth, maxHeight, maxDurationMs}) async {
        capturedRoles.add(role);
        return sourceData(mimeType: 'image/png', width: 1200, height: 1600);
      },
    );

    final result = await adapter.acquireImage(role: MediaRole.evidenceImage);

    expect(capturedRoles, [MediaRole.evidenceImage]);
    expect(result.readiness, MediaReadiness.ready);
    expect(result.localPreviewPath, isNull);
    final ref = result.reference;
    expect(ref.refId, isNotEmpty);
    expect(ref.role, MediaRole.evidenceImage);
    expect(ref.mimeType, 'image/png');
    expect(ref.originalWidth, 1200);
    expect(ref.originalHeight, 1600);
    // 引用经 blob 持久化（cipherManifestId 可查）。
    final list = await blobStore.list(tier: BlobTier.sourceOfTruth).toList();
    expect(list.any((e) => e.handle.cipherManifestId == ref.refId), isTrue);
  });

  test('acquireAudio / acquireVideo 同样产出稳定引用', () async {
    final blobStore = newBlobStore();
    final adapter = DriftMediaAcquisitionAdapter(
      blobStore: blobStore,
      picker: (role, {maxWidth, maxHeight, maxDurationMs}) async {
        return switch (role) {
          MediaRole.evidenceAudio => sourceData(
              mimeType: 'audio/mp3',
              width: null,
              height: null,
              durationMs: 30000,
            ),
          _ => sourceData(
              mimeType: 'video/mp4',
              width: 1920,
              height: 1080,
              durationMs: 60000,
            ),
        };
      },
    );

    final audio = await adapter.acquireAudio(role: MediaRole.evidenceAudio);
    expect(audio.reference.mimeType, 'audio/mp3');
    expect(audio.reference.durationMs, 30000);
    expect(audio.reference.originalWidth, isNull);

    final video = await adapter.acquireVideo(role: MediaRole.evidenceVideo);
    expect(video.reference.mimeType, 'video/mp4');
    expect(video.reference.durationMs, 60000);
    expect(video.reference.originalWidth, 1920);
  });

  test('MediaReference 值对象不含二进制或文件路径字段', () {
    final ref = MediaReference(
      refId: 'ref-1',
      version: 1,
      role: MediaRole.evidenceImage,
      mimeType: 'image/jpeg',
      createdAtUtc: DateTime.utc(2026, 1, 1),
    );
    final json = ref.toJson();
    expect(json.keys.any((k) => k.contains('path')), isFalse);
    expect(json.keys.any((k) => k.contains('binary')), isFalse);
    expect(json.keys.any((k) => k.contains('data')), isFalse);
  });

  test('keyframe 经生产 KeyframeExtractionPort 产出 keyframe 引用', () async {
    final blobStore = newBlobStore();
    final adapter = DriftKeyframeExtractionAdapter(
      blobStore: blobStore,
      provider: (ref, positionMs, {maxWidth, maxHeight}) async => sourceData(
        mimeType: 'image/jpeg',
        width: 320,
        height: 240,
      ),
    );
    final source = MediaReference(
      refId: 'video-ref-1',
      version: 1,
      role: MediaRole.evidenceVideo,
      mimeType: 'video/mp4',
      durationMs: 60000,
      createdAtUtc: DateTime.utc(2026, 1, 1),
    );

    final kf = await adapter.extractKeyframe(
      sourceVideo: source,
      positionMs: 15000,
    );

    expect(kf.sourceVideo.refId, 'video-ref-1');
    expect(kf.sourcePositionMs, 15000);
    expect(kf.keyframeReference.role, MediaRole.keyframe);
    expect(kf.keyframeReference.originalWidth, 320);
    expect(kf.keyframeReference.mimeType, 'image/jpeg');
    final list = await blobStore.list(tier: BlobTier.sourceOfTruth).toList();
    expect(
      list.any((e) => e.handle.cipherManifestId == kf.keyframeReference.refId),
      isTrue,
    );
  });
}
