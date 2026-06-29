import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/taiyishenshu/taiyi_record_codec.dart';
import 'package:flutter_test/flutter_test.dart';

TaiyiDivinationRecordContract _rec({String uuid = 'ty1', String schoolId = 'sch1'}) => TaiyiDivinationRecordContract(
      uuid: uuid,
      question: 'q',
      datetimeJson: '{}',
      schoolId: schoolId,
      juNumber: 1,
      taiYiPalaceJson: '{}',
      ninePalaceJson: '{}',
      deitiesJson: '{}',
      paramsJson: '{}',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

void main() {
  final codec = TaiyiRecordCodec();

  test('encode then decode round-trips the contract', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    expect(encoded.meta.module, 'taiyishenshu');
    expect(encoded.meta.scopeUid, 's1');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'tai_yi');

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

  test('extractSearchTags emits schoolId', () {
    final encoded = codec.encode(_rec(schoolId: 'taiyi-sch'), scopeUid: 's1');
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('school_id', 'taiyi-sch')));
  });

  test('uuidOf and withUuid operations', () {
    final r = _rec();
    expect(codec.uuidOf(r), 'ty1');
    final r2 = codec.withUuid(r, 'ty2');
    expect(codec.uuidOf(r2), 'ty2');
    expect(r2.schoolId, 'sch1');
  });
}
