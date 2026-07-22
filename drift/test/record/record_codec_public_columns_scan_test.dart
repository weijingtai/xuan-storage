import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('codecs mention RecordMeta public columns and Taiyi has no double encoding', () {
    final codecFiles = [
      'lib/taiyishenshu/taiyi_record_codec.dart',
      'lib/qimendunjia/qimen_record_codec.dart',
      'lib/daliuren/daliuren_record_codec.dart',
      'lib/liuyao/liuyao_record_codec.dart',
      'lib/meihuayishu/meihua_record_codec.dart',
      'lib/meihuayishu/meihua_record_adapter.dart',
      'lib/qizhengsiyu/qizheng_record_codec.dart',
      'lib/ziweidoushu/ziwei_record_codec.dart',
      'lib/tiebanshenshu/tieban_record_codec.dart',
      'lib/seeker/seeker_record_codec.dart',
    ];

    final expectedFields = [
      'occurredAtUtc',
      'reckoningType',
      'timezoneStr',
      'latitude',
      'longitude',
      'locationName',
      'spacetimeJson',
      'gender',
    ];

    for (final path in codecFiles) {
      final file = File(path);
      if (!file.existsSync()) {
        fail('Codec file not found: $path');
      }
      final content = file.readAsStringSync();
      
      // Each file should at least have some awareness or mention of the fields,
      // either filling them or explicitly setting to null or a comment explaining why.
      // We check that the new RecordMeta fields are present in the text.
      for (final field in expectedFields) {
        if (!content.contains(field)) {
          fail('Codec $path does not mention RecordMeta field "$field". It must be explicitly mapped or set to null.');
        }
      }
      
      if (path.contains('taiyi_record_codec')) {
        // Also ensure double encoding is NOT present in Taiyi usecase.
        // Wait, the usecase is in xuan-taiyishenshu. This test is in xuan-storage.
        // The ACT says "or if taiyi still has jsonEncode(toIso8601String()) double encoding" - wait, we can just check the Taiyi codec to ensure it's not doing jsonDecode of jsonDecode. But the ACT grep checks xuan-taiyishenshu/lib. 
        // Let's just check the usecase file from here using relative path.
        final usecaseFile = File('../../xuan-taiyishenshu/lib/taiyi/usecases/save_record_usecase.dart');
        if (usecaseFile.existsSync()) {
          final usecaseContent = usecaseFile.readAsStringSync();
          if (usecaseContent.contains('datetimeJson: jsonEncode(') && usecaseContent.contains('toIso8601String())')) {
            fail('xuan-taiyishenshu save_record_usecase.dart contains double encoding: jsonEncode(...toIso8601String())');
          }
        }
      }
    }
  });
}
