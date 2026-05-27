/// Represents a directional link between two divination records.
///
/// Used to model "decision chains" — sequences of divination sessions
/// connected by intent (e.g. "看完八字后起六壬化解").
///
/// Storage: maps to the `t_decision_links` relational table.
class DecisionLink {
  /// The source divination UUID (the "from" end of the link).
  final String sourceId;

  /// The target divination UUID (the "to" end of the link).
  final String targetId;

  /// The intent/reason for this link (e.g. '化解', '增强', '验证').
  final String intent;

  /// A snapshot of key context data at the time the link was created.
  ///
  /// Allows downstream consumers to understand *why* the link was made
  /// without having to re-read the full source divination payload.
  final Map<String, dynamic> contextSnapshot;

  const DecisionLink({
    required this.sourceId,
    required this.targetId,
    required this.intent,
    this.contextSnapshot = const {},
  });
}

/// Abstract repository for querying decision chain links.
///
/// Implementations should query the `t_decision_links` table and
/// return the full chain of links originating from [rootId].
abstract interface class IDecisionRepository {
  /// Retrieves all links in the chain starting from [rootId].
  ///
  /// Returns an ordered list: the first element links from [rootId],
  /// subsequent elements link from the previous target.
  Future<List<DecisionLink>> getDecisionChain(String rootId);
}
