import '../model/storage_error.dart';

/// Error thrown when the shared vault's database version is newer
/// than what the current app supports.
///
/// Scenario: App A (v2) and App B (v3) share the same vault.
/// If App B upgrades the DB schema to v3, App A (still at v2)
/// must detect this and guide the user to upgrade.
class VersionMismatchError extends StorageError implements Exception {
  VersionMismatchError({
    required int vaultVersion,
    required int supportedVersion,
  }) : super(
          code: 'storage.version_mismatch',
          message:
              'Database version $vaultVersion is newer than supported version $supportedVersion',
          reason:
              'The shared vault was upgraded by a newer version of the app',
          suggestion:
              '当前数据库已被新版应用升级，请立即从应用商店下载并升级您的 APP 以保持兼容性。',
        );
}

/// Guards against accessing a shared vault whose schema version
/// is incompatible with the current app.
///
/// Usage:
/// ```dart
/// final guard = VersionGuard(supportedVersion: currentSchemaVersion);
/// guard.verifyCompatibility(vaultVersion: await readVaultVersion());
/// ```
class VersionGuard {
  /// The maximum database schema version this app can handle.
  final int supportedVersion;

  const VersionGuard({required this.supportedVersion});

  /// Verifies that [vaultVersion] is not newer than [supportedVersion].
  ///
  /// Throws [VersionMismatchError] if the vault is ahead of what
  /// this app supports. Silently returns if versions are compatible
  /// (vault version <= supported version).
  void verifyCompatibility({required int vaultVersion}) {
    if (vaultVersion > supportedVersion) {
      throw VersionMismatchError(
        vaultVersion: vaultVersion,
        supportedVersion: supportedVersion,
      );
    }
  }
}
