/// Web factory: returns the IndexedDB backend.
library;

import 'blob_byte_backend_contract.dart';
import 'web.dart';

/// Creates the platform's blob byte backend.
///
/// [rootDir] is accepted for signature symmetry with the native factory; the
/// IndexedDB backend has no filesystem and ignores it (logical namespaces
/// already travel inside `manifestDir`).
BlobByteBackend createBlobByteBackend({required String rootDir}) =>
    WebBlobByteBackend();