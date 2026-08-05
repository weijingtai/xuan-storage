/// Blob byte backend for unsupported platforms.
///
/// This file is used when neither native (dart:io) nor web (dart:html)
/// is available. It throws a named unsupported error.
library;

import 'blob_byte_backend.dart';

/// Unsupported platform backend — always throws.
final class UnsupportedBlobByteBackend implements BlobByteBackend {
  const UnsupportedBlobByteBackend();

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
        'Blob byte storage is not supported on this platform.',
      );
}