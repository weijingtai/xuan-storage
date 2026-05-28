import 'package:persistence_domain/domain.dart';

/// Central registry where each domain's [TagExtractor] gets registered.
///
/// Usage:
/// ```dart
/// final registry = TagExtractorRegistry();
/// registry.register(BaZiTagExtractor());
/// registry.register(LiuRenTagExtractor());
/// // ... at write time:
/// final tags = registry.extract('ba_zi', payload);
/// ```
class TagExtractorRegistry {
  final Map<String, TagExtractor> _extractors = {};

  void register(TagExtractor extractor) {
    _extractors[extractor.domain] = extractor;
  }

  List<Tag> extract(String domain, Map<String, dynamic> payload) {
    final extractor = _extractors[domain];
    if (extractor == null) return const [];
    return extractor.extract(payload);
  }

  Set<String> get registeredDomains => _extractors.keys.toSet();
}
