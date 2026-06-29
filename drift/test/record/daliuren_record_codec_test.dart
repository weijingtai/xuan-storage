import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/daliuren/daliuren_record_codec.dart';
import 'package:flutter_test/flutter_test.dart';

DaliurenDivinationRecordContract _rec({String uuid = 'd1', String schoolId = 's1', String juName = 'ju1'}) => DaliurenDivinationRecordContract(
      uuid: uuid,
      question: 'q',
      lunarDateJson: '{}',
      ganzhiJson: '{}',
      juNumber: 1,
      juName: juName,
      schoolId: schoolId,
      yueJiangJson: '{}',
      riYueJson: '{}',
      sanChuanJson: '{}',
      siKeJson: '{}',
      twelveTianJinJson: '{}',
      paramsJson: '{}',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

void main() {
  final codec = DaliurenRecordCodec();

  test('encode then decode round-trips the contract', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    expect(encoded.meta.module, 'daliuren');
    expect(encoded.meta.scopeUid, 's1');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'da_liu_ren');

    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(_rec()));
  });

  test('decode with mismatched module throws', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    final badMeta = RecordMeta(
      uuid: encoded.meta.uuid,
      scopeUid: encoded.meta.scopeUid,
      module: 'mismatched',
      category: encoded.meta.category,
      divinationType: encoded.meta.divinationType,
      createdAt: encoded.meta.createdAt,
    );
    expect(() => codec.decode(badMeta, encoded.moduleData), throwsA(isA<RecordCodecMismatch>()));
  });

  test('extractSearchTags emits schoolId and juName', () {
    final encoded = codec.encode(_rec(schoolId: 'sch-1', juName: 'ju-2'), scopeUid: 's1');
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('school_id', 'sch-1')));
    expect(tags, contains(const SearchTag('ju_name', 'ju-2')));
  });

  test('uuidOf and withUuid operations', () {
    final r = _rec();
    expect(codec.uuidOf(r), 'd1');
    final r2 = codec.withUuid(r, 'd2');
    expect(codec.uuidOf(r2), 'd2');
    expect(r2.schoolId, 's1');
  });
}
