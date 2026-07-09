import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

void main() {
  test('RecordModuleRegistry contains all 9 unique modules (8 divination + 1 seeker)', () {
    final extractors = RecordModuleRegistry.allExtractors();
    expect(extractors, hasLength(9));

    final modules = extractors.map((e) => e.module).toList();
    expect(modules, containsAll([
      'meihua',
      'liuyao',
      'qizhengsiyu',
      'daliuren',
      'qimendunjia',
      'taiyishenshu',
      'tiebanshenshu',
      'ziweidoushu',
      'seeker',
    ]));

    // Check for duplicate modules
    final uniqueModules = modules.toSet();
    expect(uniqueModules.length, equals(modules.length), reason: 'Duplicate modules found in registry');
  });
}
