/// Platform-agnostic byte-level blob storage boundary (single interface).
///
/// The interface lives in its own file so both the native (`dart:io` files)
/// and web (IndexedDB) implementations can import it without going through
/// the conditional entry `blob_byte_backend.dart` — which previously forced a
/// circular import on web builds.
library;

/// Platform-agnostic interface for byte-level blob storage.
abstract interface class BlobByteBackend {
  /// Write bytes at [index] to a manifest. A write overwrites the key
  /// atomically; web commits a single final key's read-write transaction.
  Future<void> writeChunk(String manifestDir, int index, List<int> bytes);

  /// Read bytes for chunk at [index]; a missing chunk maps to
  /// [BlobNotFoundError].
  Future<List<int>> readChunk(String manifestDir, int index);

  /// Delete chunk at [index]; a missing chunk is a no-op.
  Future<void> deleteChunk(String manifestDir, int index);

  /// List all chunk indices present in [manifestDir].
  Future<Set<int>> listChunks(String manifestDir);

  /// Delete every chunk key belonging to [manifestDir].
  Future<void> deleteManifest(String manifestDir);

  /// Enumerate orphaned keys under [rootDir]. Web never creates temp keys,
  /// so it always returns an empty set.
  Future<Set<String>> orphanChunkPaths(String rootDir);

  /// Total stored bytes used by [manifestDir].
  Future<int> manifestSize(String manifestDir);
}