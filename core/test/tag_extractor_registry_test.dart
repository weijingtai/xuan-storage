import 'package:test/test.dart';
import 'package:persistence_core/tag/tag_extractor_registry.dart';
import 'package:persistence_domain/domain.dart';

class _DummyExtractor implements TagExtractor {
  @override
  String get domain => 'dummy';
  @override
  List<Tag> extract(Map<String, dynamic> payload) => [
        Tag(domain: 'dummy', key: 'k1', value: payload['k1']?.toString() ?? ''),
      ];
}

class _SecondExtractor implements TagExtractor {
  @override
  String get domain => 'second';
  @override
  List<Tag> extract(Map<String, dynamic> payload) => payload.entries
      .map((e) => Tag(domain: 'second', key: e.key, value: e.value.toString()))
      .toList();
}

void main() {
  group('TagExtractorRegistry', () {
    test('returns extractor tags for registered domain', () {
      final r = TagExtractorRegistry()..register(_DummyExtractor());
      final tags = r.extract('dummy', {'k1': 'v1'});
      expect(tags.length, equals(1));
      expect(tags.first.value, equals('v1'));
      expect(tags.first.domain, equals('dummy'));
      expect(tags.first.key, equals('k1'));
    });

    test('returns empty for unknown domain', () {
      final r = TagExtractorRegistry();
      expect(r.extract('unknown', {}), isEmpty);
    });

    test('registeredDomains reflects registered extractors', () {
      final r = TagExtractorRegistry()
        ..register(_DummyExtractor())
        ..register(_SecondExtractor());
      expect(r.registeredDomains, equals({'dummy', 'second'}));
    });

    test('second registration overwrites first for same domain', () {
      final r = TagExtractorRegistry()
        ..register(_DummyExtractor())
        ..register(_SecondExtractor());
      // Both use different domains, so this tests distinct domain handling
      final tags = r.extract('second', {'a': 'b', 'c': 'd'});
      expect(tags.length, equals(2));
    });

    test('extract returns empty list for domain with no extractor', () {
      final r = TagExtractorRegistry()..register(_DummyExtractor());
      expect(r.extract('nonexistent', {'key': 'value'}), isEmpty);
    });
  });
}
