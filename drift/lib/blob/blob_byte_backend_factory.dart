/// Platform factory for the single [BlobByteBackend].
///
/// Real web compilations (dart2js / dart2wasm, `dart.library.js_interop`)
/// resolve to the IndexedDB backend; every other target — including the DDC
/// test compiler (`flutter test -d chrome`) and native VMs — resolves to the
/// dart:io file backend. Production assembly (DriftLocalBlobStore and
/// DriftBlobGarbageCollector) consumes this factory instead of hard-coding
/// `FileSystemBlobByteBackend`; on DDC test targets the web implementation is
/// exercised by importing `web.dart` directly.
library;

export 'blob_byte_backend_contract.dart';
export 'blob_byte_backend_factory_native.dart'
    if (dart.library.js_interop) 'blob_byte_backend_factory_web.dart';