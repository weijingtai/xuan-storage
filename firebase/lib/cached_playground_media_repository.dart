/// 组合 Repository：媒体（S2 Phase 4 + Phase 5）。
///
/// 实现业务层端口 [PlaygroundMediaRepository]。
///
/// 缓存裁定：媒体信息不缓存（status/URL 实时性要求高）。
/// 本类透传 [PlaygroundMediaRemoteDataSource]；上传管线（EXIF 剥离 →
/// 客户端转码 → BlobGateway）在 Phase 5 接入 `beginUpload`。
library;

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class CachedPlaygroundMediaRepository
    implements PlaygroundMediaRepository {
  CachedPlaygroundMediaRepository({
    required PlaygroundMediaRemoteDataSource remote,
  }) : _remote = remote;

  final PlaygroundMediaRemoteDataSource _remote;

  @override
  Future<PlaygroundMediaInfo> beginUpload({
    required PlaygroundUserId userId,
    required String mimeType,
    required int sizeBytes,
    int? width,
    int? height,
    int? durationSeconds,
  }) {
    return _remote.beginUpload(
      userId: userId,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      width: width,
      height: height,
      durationSeconds: durationSeconds,
    );
  }

  @override
  Future<PlaygroundMediaInfo> getMediaInfo(
      PlaygroundAttachmentId mediaObjectId) {
    return _remote.getMediaInfo(mediaObjectId);
  }

  @override
  Future<String> getDownloadUrl(PlaygroundAttachmentId mediaObjectId) {
    return _remote.getDownloadUrl(mediaObjectId);
  }

  @override
  Future<void> deleteMedia(PlaygroundAttachmentId mediaObjectId) {
    return _remote.deleteMedia(mediaObjectId);
  }
}
