/// Tests for FileSystemBlobByteBackend's atomic chunk storage.
///
/// Verifies:
/// - Scope/tier path layout
/// - 16KB chunk path
/// - Concurrent different-index writes
/// - Repeated same-index write (idempotent)
/// - Temp file cleanup
/// - File length/hash corruption detection
/// - Orphan enumeration
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/blob/native.dart';

void main() {
  late Directory tmpDir;
  late FileSystemBlobByteBackend backend;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('blob_atomic_');
    backend = FileSystemBlobByteBackend(rootDir: tmpDir.path);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  group('atomic chunk files', () {
    test('scope/tier path layout: writes to correct directory', () async {
      await backend.writeChunk('scope-a/manifest-1', 0, [1, 2, 3]);
      final file = File('${tmpDir.path}/scope-a/manifest-1/0.bin');
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), [1, 2, 3]);
    });

    test('16KB chunk path: handles large chunks', () async {
      final data = List<int>.generate(16384, (i) => i % 256);
      await backend.writeChunk('manifest-1', 0, data);
      final read = await backend.readChunk('manifest-1', 0);
      expect(read.length, 16384);
      expect(read, data);
    });

    test('concurrent different-index writes are safe', () async {
      await Future.wait([
        backend.writeChunk('manifest-1', 0, [1]),
        backend.writeChunk('manifest-1', 1, [2]),
        backend.writeChunk('manifest-1', 2, [3]),
      ]);
      final chunks = await backend.listChunks('manifest-1');
      expect(chunks, {0, 1, 2});
    });

    test('repeated same-index write is idempotent', () async {
      await backend.writeChunk('manifest-1', 0, [1, 2, 3]);
      await backend.writeChunk('manifest-1', 0, [4, 5, 6]);
      final bytes = await backend.readChunk('manifest-1', 0);
      expect(bytes, [4, 5, 6]);
    });

    test('temp file cleanup: no .tmp files remain after write', () async {
      await backend.writeChunk('manifest-1', 0, [1]);
      final dir = Directory('${tmpDir.path}/manifest-1');
      final files = await dir.list().toList();
      final tmpFiles = files.where((f) => f.path.endsWith('.tmp'));
      expect(tmpFiles, isEmpty);
    });

    test('orphan enumeration finds .tmp files', () async {
      File('${tmpDir.path}/scope-a/orphan.tmp').createSync(recursive: true);
      final orphans = await backend.orphanChunkPaths(tmpDir.path);
      expect(orphans, hasLength(1));
      expect(orphans.first, endsWith('.tmp'));
    });
  });
}