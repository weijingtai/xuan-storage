/// Cross-app anonymous identity provider.
///
/// Used in mode 3 (multiple standalone apps on one device, same signature).
/// All apps with the same signature share one anon ID via OS-level IPC
/// (iOS App Group / Android signature-protected ContentProvider).
///
/// See: docs/superpowers/specs/2026-05-27-xuan-common-storage-migration-design.md §7.4
abstract interface class AnonIdentityProvider {
  /// Returns the shared anonId for this device's same-signature apps.
  /// Generates and persists if not yet present.
  Future<String> sharedAnonId();

  /// Stream of anonId changes (rare; eg. clear-and-regenerate scenario).
  Stream<String> watchAnonId();

  /// True if cross-app sharing is available on this platform with current
  /// signature. False fallback path: each app gets its own deviceLocal anon ID.
  Future<bool> isCrossAppShareAvailable();
}
