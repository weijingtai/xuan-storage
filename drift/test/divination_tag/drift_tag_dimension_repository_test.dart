import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/divination_tag/drift_tag_dimension_repository.dart';
import 'package:persistence_drift/divination_tag/drift_tag_tables.dart';
import 'package:repository_interface_divination_tag/repository_interface_divination_tag.dart';

void main() {
  final repository = DriftTagDimensionRepository();

  test('listDimensions returns seed data (五行, 吉凶)', () {
    final dims = repository.listDimensions();
    expect(dims.map((d) => d.dimensionId).toList(), ['wu-xing', 'ji-xiong']);
    expect(dims.any((d) => d.displayName == '五行'), isTrue);
    expect(dims.any((d) => d.displayName == '吉凶'), isTrue);
    expect(dims.every((d) => d.version >= 1), isTrue);
  });

  test('listTagsByDimension returns tags sorted by sortOrder', () {
    final wuxing = repository.listTagsByDimension('wu-xing');
    expect(wuxing.map((t) => t.text).toList(), ['金', '木', '水', '火', '土']);
    expect(wuxing.every((t) => t.dimensionId == 'wu-xing'), isTrue);

    final jixiong = repository.listTagsByDimension('ji-xiong');
    expect(jixiong.map((t) => t.text).toList(), ['吉', '凶', '平']);

    expect(repository.listTagsByDimension('unknown-dimension'), isEmpty);
  });

  test('validateTags returns correct boolean map', () {
    final result = repository.validateTags({
      'wu-xing': ['tag.wu-xing.jin', 'tag.wu-xing.mu', 'tag.wu-xing.nonexistent'],
      'ji-xiong': ['tag.ji-xiong.ji'],
    });
    expect(result['wu-xing:tag.wu-xing.jin'], isTrue);
    expect(result['wu-xing:tag.wu-xing.mu'], isTrue);
    expect(result['wu-xing:tag.wu-xing.nonexistent'], isFalse);
    expect(result['ji-xiong:tag.ji-xiong.ji'], isTrue);
  });

  test('seed constants define the 五行 and 吉凶 vocabulary', () {
    expect(seedTagDimensions, hasLength(2));
    expect(seedDimensionTags.map((t) => t.text), contains('金'));
    expect(seedDimensionTags.map((t) => t.text), contains('土'));
    expect(seedDimensionTags.map((t) => t.text), contains('平'));
    // 8 seed tags total: 5 五行 + 3 吉凶
    expect(seedDimensionTags, hasLength(8));
  });
}
