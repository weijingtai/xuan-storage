/// Blob byte backend for native (dart:io) platforms.
///
/// This file imports `dart:io` for file system operations.
/// It does NOT import external storage APIs like `getExternalStorageDirectory`,
/// `MediaStore`, or `PHPhotoLibrary`.
library;

import 'dart:io';

import 'package:persistence_core/persistence_core.dart';

/// Platform-agnostic interface for byte-level blob storage.
abstract interface class BlobByteBackend {
  /// Write bytes at [index] to a temp file, then atomically rename.
  Future<void> writeChunk(
    String manifestDir,
    int index,
    List<int> bytes,
  );

  /// Read bytes for chunk at [index].
  Future<List<int>> readChunk(String manifestDir, int index);

  /// Delete chunk at [index].
  Future<void> deleteChunk(String manifestDir, int index);

  /// List all chunk indices present in [manifestDir].
  Future<Set<int>> listChunks(String manifestDir);

  /// Delete entire manifest directory.
  Future<void> deleteManifest(String manifestDir);

  /// Enumerate all orphan chunk files across all manifest directories.
  Future<Set<String>> orphanChunkPaths(String rootDir);

  /// Total bytes used by a manifest directory.
  Future<int> manifestSize(String manifestDir);
}

/// File-system based [BlobByteBackend].
///
/// Layout:
/// ```
/// {rootDir}/{scopeUid}/{manifestDir}/{index}.bin
/// ```
///
/// Writes use temp file → flush → atomic rename for crash safety.
final class FileSystemBlobByteBackend implements BlobByteBackend {
  FileSystemBlobByteBackend({required this.rootDir});

  /// Root directory for all blob data.
  final String rootDir;

  @override
  Future<void> writeChunk(
    String manifestDir,
    int index,
    List<int> bytes,
  ) async {
    final dir = Directory('$rootDir/$manifestDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final targetPath = '${dir.path}/$index.bin';
    final tempPath = '$targetPath.tmp';

    // Write to temp file, flush, then atomic rename.
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes, flush: true);
    await tempFile.rename(targetPath);
  }

  @override
  Future<List<int>> readChunk(String manifestDir, int index) async {
    final file = File('$rootDir/$manifestDir/$index.bin');
    if (!await file.exists()) {
      throw BlobNotFoundError();
    }
    return file.readAsBytes();
  }

  @override
  Future<void> deleteChunk(String manifestDir, int index) async {
    final file = File('$rootDir/$manifestDir/$index.bin');
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<Set<int>> listChunks(String manifestDir) async {
    final dir = Directory('$rootDir/$manifestDir');
    if (!await dir.exists()) return {};
    final files = await dir.list().toList();
    final indices = <int>{};
    for (final entity in files) {
      final name = entity.path.split('/').last;
      if (name.endsWith('.bin')) {
        final index = int.tryParse(name.replaceAll('.bin', ''));
        if (index != null) indices.add(index);
      }
    }
    return indices;
  }

  @override
  Future<void> deleteManifest(String manifestDir) async {
    final dir = Directory('$rootDir/$manifestDir');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  @override
  Future<Set<String>> orphanChunkPaths(String rootDir) async {
    final root = Directory(rootDir);
    if (!await root.exists()) return {};
    final orphans = <String>{};
    await for (final entity in root.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.tmp')) {
        orphans.add(entity.path);
      }
    }
    return orphans;
  }

  @override
  Future<int> manifestSize(String manifestDir) async {
    final dir = Directory('$rootDir/$manifestDir');
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }
}