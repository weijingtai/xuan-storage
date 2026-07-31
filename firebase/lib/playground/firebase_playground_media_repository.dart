import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';

final class FirebasePlaygroundMediaRepository
    implements PlaygroundMediaRepository {
  FirebasePlaygroundMediaRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<PlaygroundMediaInfo> beginUpload({
    required PlaygroundUserId userId,
    required String mimeType,
    required int sizeBytes,
    int? width,
    int? height,
    int? durationSeconds,
  }) async {
    try {
      final docRef =
          _firestore.collection(PlaygroundFirestoreSchema.media).doc();

      final data = <String, dynamic>{
        'user_app_user_id': userId.value,
        'mime_type': mimeType,
        'size_bytes': sizeBytes,
        'width': width,
        'height': height,
        'duration_seconds': durationSeconds,
        'status': PlaygroundMediaUploadStatus.pending.name,
        'created_at': FieldValue.serverTimestamp(),
        'expires_at': null,
      };

      await docRef.set(data);

      return PlaygroundMediaInfo(
        mediaObjectId: PlaygroundAttachmentId(docRef.id),
        status: PlaygroundMediaUploadStatus.pending,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
        width: width,
        height: height,
        durationSeconds: durationSeconds,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundMediaInfo> getMediaInfo(
      PlaygroundAttachmentId mediaObjectId) async {
    try {
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.media)
          .doc(mediaObjectId.value)
          .get();

      if (!snap.exists) {
        throw const PlaygroundError(
          code: PlaygroundErrorCode.notFound,
          message: '媒体资源不存在',
          machineCode: 'media/not-found',
        );
      }

      final d = snap.data()!;
      final expiresAt = d['expires_at'] as Timestamp?;
      return PlaygroundMediaInfo(
        mediaObjectId: mediaObjectId,
        status: PlaygroundMediaUploadStatus.values
            .byName(d['status'] as String? ?? 'pending'),
        mimeType: d['mime_type'] as String?,
        sizeBytes: d['size_bytes'] as int?,
        width: d['width'] as int?,
        height: d['height'] as int?,
        durationSeconds: d['duration_seconds'] as int?,
        uploadUrl: d['upload_url'] as String?,
        expiresAt: expiresAt?.toDate(),
      );
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<String> getDownloadUrl(
      PlaygroundAttachmentId mediaObjectId) async {
    try {
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.media)
          .doc(mediaObjectId.value)
          .get();

      if (snap.exists && snap.data()?['download_url'] != null) {
        return snap.data()!['download_url'] as String;
      }

      return '/media/${mediaObjectId.value}';
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteMedia(PlaygroundAttachmentId mediaObjectId) async {
    try {
      await _firestore
          .collection(PlaygroundFirestoreSchema.media)
          .doc(mediaObjectId.value)
          .delete();
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }
}
