import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/bazi/bazi_record_codec.dart';
import 'package:flutter_test/flutter_test.dart';

BaziRecordContract _rec({
  String uuid = 'bz1',
  String caseUuid = 'case1',
  String? chartSnapshotJson,
  String? legacyEightCharsJson,
  String? daYunJson,
  String? note,
}) =>
    BaziRecordContract(
      uuid: uuid,
      caseUuid: caseUuid,
      recordDate: DateTime.utc(2026, 7, 27),
      chartSnapshotJson: chartSnapshotJson,
      snapshotSchemaVersion: 1,
      legacyEightCharsJson: legacyEightCharsJson,
      daYunJson: daYunJson,
      note: note,
      createdAt: DateTime.utc(2026, 7, 27),
    );

void main() {
  final codec = BaziRecordCodec();

  test('module/category/divinationType values', () {
    expect(codec.module, 'bazi');
    expect(codec.category, 'divination');
    expect(codec.divinationType, 'ba_zi');
  });

  test('encode then decode round-trips the contract (basic)', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    expect(encoded.meta.module, 'bazi');
    expect(encoded.meta.scopeUid, 's1');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'ba_zi');
    expect(encoded.meta.caseUuid, 'case1');

    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(_rec()));
  });

  test('encode then decode round-trips with chartSnapshotJson', () {
    final r = _rec(chartSnapshotJson: '{"foo":"bar"}');
    final encoded = codec.encode(r, scopeUid: 's1');
    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(r));
  });

  test('encode then decode round-trips with daYunJson and note', () {
    final r = _rec(daYunJson: '{"dayun":[]}', note: '测试备注');
    final encoded = codec.encode(r, scopeUid: 's1');
    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(r));
  });

  test('encode then decode round-trips with all optional fields', () {
    final r = _rec(
      chartSnapshotJson: '{"chars":"abc"}',
      legacyEightCharsJson: '{"old":true}',
      daYunJson: '{"dayun":[1,2,3]}',
      note: '全部字段测试',
    );
    final encoded = codec.encode(r, scopeUid: 's1');
    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(r));
  });

  test('encode then decode round-trips with different caseUuid', () {
    final r = _rec(caseUuid: 'case-abc');
    final encoded = codec.encode(r, scopeUid: 's1');
    expect(encoded.meta.caseUuid, 'case-abc');
    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(r));
  });

  test('decode with mismatched module throws RecordCodecMismatch', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    final badMeta = RecordMeta(
      uuid: encoded.meta.uuid,
      scopeUid: encoded.meta.scopeUid,
      module: 'liuyao',
      category: encoded.meta.category,
      divinationType: encoded.meta.divinationType,
      createdAt: encoded.meta.createdAt,
    );
    expect(
      () => codec.decode(badMeta, encoded.moduleData),
      throwsA(isA<RecordCodecMismatch>()),
    );
  });

  test('uuidOf reads contract uuid', () {
    final r = _rec(uuid: 'real-uuid');
    expect(codec.uuidOf(r), 'real-uuid');
  });

  test('uuidOf returns empty for unsaved records', () {
    final r = _rec(uuid: '');
    expect(codec.uuidOf(r), '');
  });

  test('withUuid returns new instance with injected uuid and all fields preserved', () {
    final r = _rec(
      uuid: 'old',
      caseUuid: 'c1',
      chartSnapshotJson: '{"snap":1}',
      note: 'a note',
    );
    final r2 = codec.withUuid(r, 'new-uuid');
    expect(codec.uuidOf(r2), 'new-uuid');
    // Original unchanged
    expect(codec.uuidOf(r), 'old');
    // All other fields preserved
    expect(r2.caseUuid, 'c1');
    expect(r2.chartSnapshotJson, '{"snap":1}');
    expect(r2.note, 'a note');
    expect(r2.recordDate, r.recordDate);
    expect(r2.createdAt, r.createdAt);
  });

  test('extractSearchTags emits case_uuid tag', () {
    final encoded = codec.encode(_rec(caseUuid: 'target-case'), scopeUid: 's1');
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('case_uuid', 'target-case')));
  });

  test('decode from RecordMeta with null moduleDataJson returns valid contract', () {
    final r = _rec(uuid: 'bz99', caseUuid: 'c99');
    final encoded = codec.encode(r, scopeUid: 's1');
    final metaOnly = RecordMeta(
      uuid: encoded.meta.uuid,
      scopeUid: encoded.meta.scopeUid,
      module: encoded.meta.module,
      category: encoded.meta.category,
      divinationType: encoded.meta.divinationType,
      caseUuid: encoded.meta.caseUuid,
      moduleDataJson: encoded.meta.moduleDataJson,
      createdAt: encoded.meta.createdAt,
    );
    final decoded = codec.decode(metaOnly, null);
    expect(decoded.uuid, 'bz99');
    expect(decoded.caseUuid, 'c99');
    expect(decoded.recordDate, r.recordDate);
  });
}
