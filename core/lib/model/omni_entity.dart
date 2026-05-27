/// Base contract for entities managed by [OmniCoordinator].
///
/// All domain entities (Seeker, DivinationRequest, etc.) must implement
/// this interface to participate in the hybrid storage model.
abstract interface class OmniEntity {
  /// Unique identifier (UUID).
  String get id;

  /// Domain namespace (e.g. 'taiyi', 'daliuren', 'qimen').
  String get domain;

  /// Serialized payload (typically JSON string of full entity data).
  String get data;

  /// Searchable feature tags for the EAV index.
  ///
  /// Keys are tag names (e.g. 'year_gan'), values are tag values.
  /// Extracted from the full payload for fast cross-domain queries.
  Map<String, String> get searchableTags;

  /// Serializes the entity into an outbox-compatible payload.
  Map<String, dynamic> toOutboxPayload();
}
