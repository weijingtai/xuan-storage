import 'dart:async';

import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:repository_interface_media/repository_interface_media.dart';

/// Maps raw stream errors from blob consumption to the correct
/// [BlobCorruptError] / [BlobUndecryptableError] types, so callers never see
/// unmapped IO or decryption exceptions bubble out of [MediaReadComplete.byteStream].
Stream<List<int>> _mapStreamErrors(Stream<List<int>> source) {
  return source.transform(
    StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (data, sink) => sink.add(data),
      handleError: (error, stackTrace, sink) {
        if (error is BlobCorruptError || error is BlobUndecryptableError) {
          sink.addError(error, stackTrace);
        } else {
          // Unexpected errors during stream consumption are data-corruption
          // in disguise — map to BlobCorruptError so callers see a coherent
          // error domain instead of raw IO / cipher exceptions.
          sink.addError(BlobCorruptError(), stackTrace);
        }
      },
    ),
  );
}

/// Drift-backed implementation of [MediaReferenceReader].
///
/// Resolves media references to underlying blob storage by looking up
/// metadata in [BlobMetadataRepository] constrained to the current account scope,
/// and delegating read and status queries to [LocalBlobStore].
///
/// Does not maintain a separate media table or duplicate state storage;
/// single source of truth is the blob metadata repository and blob byte store.
final class DriftMediaReferenceReader implements MediaReferenceReader {
  DriftMediaReferenceReader({
    required this.blobStore,
    required this.metadataRepository,
  });

  final LocalBlobStore blobStore;
  final BlobMetadataRepository metadataRepository;

  @override
  Future<MediaReadStatus> statusOf(String refId) async {
    final meta = await metadataRepository.getMeta(refId);
    if (meta == null || meta.status == 0) {
      return MediaReadStatus.absent;
    }
    final handle = BlobHandle(
      plaintextSha256: meta.plaintextSha256,
      cipherManifestId: meta.cipherManifestId,
      cipherId: meta.cipherId,
      keyVersion: meta.keyVersion,
      totalBytes: meta.totalBytes,
      chunkCount: meta.chunkCount,
      mimeType: meta.mimeType,
    );
    final blobStatus = await blobStore.statusOf(handle);
    return switch (blobStatus) {
      BlobStatus.complete => MediaReadStatus.complete,
      BlobStatus.partial => MediaReadStatus.partial,
      BlobStatus.absent => MediaReadStatus.absent,
      BlobStatus.corrupt => MediaReadStatus.corrupt,
      BlobStatus.undecryptable => MediaReadStatus.undecryptable,
    };
  }

  @override
  Future<MediaReadResult> openRead(String refId) async {
    final meta = await metadataRepository.getMeta(refId);
    if (meta == null || meta.status == 0) {
      return const MediaReadResult.absent();
    }
    final handle = BlobHandle(
      plaintextSha256: meta.plaintextSha256,
      cipherManifestId: meta.cipherManifestId,
      cipherId: meta.cipherId,
      keyVersion: meta.keyVersion,
      totalBytes: meta.totalBytes,
      chunkCount: meta.chunkCount,
      mimeType: meta.mimeType,
    );

    try {
      final blobResult = await blobStore.openRead(handle);
      return switch (blobResult) {
        BlobOk(:final plaintext) => MediaReadResult.complete(
            byteStream: _mapStreamErrors(plaintext),
            mimeType: handle.mimeType,
            contentLength: handle.totalBytes,
          ),
        BlobAbsent() => const MediaReadResult.absent(),
        BlobPartial(:final presentChunks) =>
          MediaReadResult.partial(presentChunks: presentChunks),
        BlobCorrupt(:final badChunks) =>
          MediaReadResult.corrupt(badChunks: badChunks),
        BlobUndecryptable() => const MediaReadResult.undecryptable(),
      };
    } on BlobCorruptError {
      return const MediaReadResult.corrupt();
    } on BlobUndecryptableError {
      return const MediaReadResult.undecryptable();
    }
  }
}
