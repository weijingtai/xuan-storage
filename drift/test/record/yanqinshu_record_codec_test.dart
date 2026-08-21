import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/yanqinshu/yanqinshu_record_codec.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_yanqinshu/repository_interface_yanqinshu.dart';

YanqinshuDivinationRecordContract _rec({
  String uuid = 'y1',
  String technique = 'divine',
  String schoolId = 'yantongzuan',
}) =>
    YanqinshuDivinationRecordContract(
      uuid: uuid,
      question: '占失物',
      technique: technique,
      schoolId: schoolId,
      lunarDateJson: '{}',
      ganzhiJson: '{}',
      paramsJson: '{}',
      baseDataJson: '{"rel": "生我"}',
      viewDataJson: '{"left": "虚日鼠"}',
      conclusionJson: '{"main": "大吉"}',
      sourceMetadataJson: '{"book": "演禽通纂"}',
      createdAt: DateTime.utc(2026, 8, 20),
      updatedAt: DateTime.utc(2026, 8, 20),
      deletedAt: null,
    );

void main() {
  final codec = YanqinshuRecordCodec();

  test('encode then decode round-trips the contract', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    expect(encoded.meta.module, equals('yanqinshu'));
    expect(encoded.meta.scopeUid, equals('s1'));
    expect(encoded.meta.category, equals('divination'));
    expect(encoded.meta.divinationType, equals('yan_qin_shu'));

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
    expect(
      () => codec.decode(badMeta, encoded.moduleData),
      throwsA(isA<RecordCodecMismatch>()),
    );
  });

  test('extractSearchTags emits technique and school_id', () {
    final encoded = codec.encode(_rec(technique: 'war', schoolId: 'yantongzuan'), scopeUid: 's1');
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('technique', 'war')));
    expect(tags, contains(const SearchTag('school_id', 'yantongzuan')));
  });

  test('uuidOf and withUuid operations', () {
    final r = _rec();
    expect(codec.uuidOf(r), equals('y1'));
    final r2 = codec.withUuid(r, 'y2');
    expect(codec.uuidOf(r2), equals('y2'));
    expect(r2.schoolId, equals('yantongzuan'));
  });
}
