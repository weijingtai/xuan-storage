/// Conditional byte-storage boundary for blob chunks.
///
/// Re-exports the correct platform backend based on compile-time platform
/// checks plus the shared interface. Web compilations (dart2js / dart2wasm,
/// which define `dart.library.js_interop`) get the IndexedDB backend; every
/// other target keeps the dart:io file backend.
///
/// NOTE: `dart.library.html` is retired on current toolchains (Flutter
/// 3.44 / Dart 3.10+); the live web marker is `dart.library.js_interop`.
/// The DDC test compiler (`flutter test -d chrome`) defines neither marker,
/// so this entry resolves to the native backend there — web tests must import
/// `web.dart` explicitly (the WB0 storage test does), matching the tests that
/// exercise the IndexedDB backend directly.
library;

export 'blob_byte_backend_contract.dart';
export 'native.dart' if (dart.library.js_interop) 'web.dart';