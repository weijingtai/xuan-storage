/// Conditional byte-storage boundary for blob chunks.
///
/// This file re-exports the correct platform backend based on
/// compile-time platform checks. Native platforms use `dart:io`,
/// Web throws a named unsupported error.
library;

export 'native.dart' if (dart.library.html) 'web.dart';