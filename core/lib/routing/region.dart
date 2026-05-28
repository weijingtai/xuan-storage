/// Backend region for dual-line hedge strategy.
/// See: docs/superpowers/specs/2026-05-27-xuan-common-storage-migration-design.md §4
enum Region {
  /// Firebase (海外用户 / overseas).
  firebase,

  /// Supabase or self-hosted (大陆用户 / mainland China).
  supabase,
}
