/// Blob byte backend for web platforms.
///
/// Web blob storage is not supported in this iteration (S1d).
/// See design doc: 2026-08-03-s1d-blob-store-design.md
library;

import 'blob_byte_backend.dart';

/// Web backend — always throws because web blob storage is deferred.
final class WebBlobByteBackend implements BlobByteBackend {
  const WebBlobByteBackend();

  @override
  Future<void> writeChunk(String manifestDir, int index, List<int> bytes) =>
      _unsupported();

  @override
  Future<List<int>> readChunk(String manifestDir, int index) =>
      _unsupported();

  @override
  Future<void> deleteChunk(String manifestDir, int index) => _unsupported();

  @override
  Future<Set<int>> listChunks(String manifestDir) => _unsupported();

  @override
  Future<void> deleteManifest(String manifestDir) => _unsupported();

  @override
  Future<Set<String>> orphanChunkPaths(String rootDir) => _unsupported();

  @override
  Future<int> manifestSize(String manifestDir) => _unsupported();

  Never _unsupported() => throw UnsupportedError(
        'Blob byte storage is not supported on web platforms in S1d. '
        'See docs/superpowers/specs/2026-08-03-s1d-blob-store-design.md',
      );
}