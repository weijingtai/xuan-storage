import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

void main() {
  test('RecordModuleRegistry contains all 8 unique modules', () {
    final extractors = RecordModuleRegistry.allExtractors();
    expect(extractors, hasLength(8));

    final modules = extractors.map((e) => e.module).toList();
    expect(modules, containsAll([
      'meihua',
      'liuyao',
      'qizhengsiyu',
      'daliuren',
      'qimendunjia',
      'taiyishenshu',
      'tiebanshenshu',
      'ziweidoushu'
    ]));

    // Check for duplicate modules
    final uniqueModules = modules.toSet();
    expect(uniqueModules.length, equals(modules.length), reason: 'Duplicate modules found in registry');
  });
}
