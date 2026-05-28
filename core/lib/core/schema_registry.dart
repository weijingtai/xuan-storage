/// Meta-information about a domain's database schema.
class DomainSchema {
  final String domain;
  final List<String> tables;
  final int version;

  const DomainSchema({
    required this.domain,
    required this.tables,
    this.version = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DomainSchema &&
          runtimeType == other.runtimeType &&
          domain == other.domain;

  @override
  int get hashCode => domain.hashCode;
}

/// A global hub for registering domain-specific database tables.
/// 
/// Used by the Federated Repository to build the combined schema
/// across all active modules.
class SchemaRegistry {
  static final SchemaRegistry instance = SchemaRegistry._();
  SchemaRegistry._();

  final List<DomainSchema> _schemas = [];
  
  /// Returns an unmodifiable list of all registered schemas.
  List<DomainSchema> get schemas => List.unmodifiable(_schemas);

  /// Registers a new domain schema into the hub.
  /// Throws [ArgumentError] if the domain is already registered.
  void register(DomainSchema schema) {
    if (_schemas.any((s) => s.domain == schema.domain)) {
      throw ArgumentError('Domain "${schema.domain}" is already registered in SchemaRegistry.');
    }
    _schemas.add(schema);
  }

  /// Clears all registrations (primarily for testing).
  void reset() => _schemas.clear();
}
