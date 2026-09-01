/// Native factory: returns the file-system backend.
library;

import 'native.dart';

/// Creates the platform's blob byte backend.
///
/// [rootDir] is the logical filesystem root for native chunk storage; the web
/// implementation keeps the same signature and ignores it (IndexedDB has no
/// filesystem).
BlobByteBackend createBlobByteBackend({required String rootDir}) =>
    FileSystemBlobByteBackend(rootDir: rootDir);