import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/ziweidoushu/ziwei_record_codec.dart';
import 'package:flutter_test/flutter_test.dart';

ZiweiDivinationRecordContract _rec({String uuid = 'zw1', String birthDatetime = '2026-06-28 23:00:00'}) => ZiweiDivinationRecordContract(
      uuid: uuid,
      question: 'q',
      birthDatetimeJson: birthDatetime,
      isMale: true,
      chartRequestJson: '{}',
      chartResultJson: '{}',
      fourTransformationsJson: '{}',
      paramsJson: '{}',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

void main() {
  final codec = ZiweiRecordCodec();

  test('encode then decode round-trips the contract', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    expect(encoded.meta.module, 'ziweidoushu');
    expect(encoded.meta.scopeUid, 's1');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'zi_wei');

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

  test('extractSearchTags emits birthDatetimeJson', () {
    final encoded = codec.encode(_rec(birthDatetime: '1995-12-15 12:00:00'), scopeUid: 's1');
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('birth_datetime', '1995-12-15 12:00:00')));
  });

  test('uuidOf and withUuid operations', () {
    final r = _rec();
    expect(codec.uuidOf(r), 'zw1');
    final r2 = codec.withUuid(r, 'zw2');
    expect(codec.uuidOf(r2), 'zw2');
    expect(r2.birthDatetimeJson, '2026-06-28 23:00:00');
  });
}
