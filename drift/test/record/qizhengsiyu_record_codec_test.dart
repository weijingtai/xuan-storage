import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/qizhengsiyu/qizheng_record_codec.dart';
import 'package:flutter_test/flutter_test.dart';

QiZhengSiYuPanContract _rec({String uuid = 'q1', String reqUuid = 'req-123'}) => QiZhengSiYuPanContract(
      uuid: uuid,
      createdAt: DateTime.utc(2026),
      lastUpdatedAt: DateTime.utc(2026),
      deletedAt: null,
      divinationRequestInfoUuid: reqUuid,
      divinationDatetimeJson: '{}',
      panelConfigJson: '{}',
      panelModelJson: '{}',
    );

void main() {
  final codec = QiZhengRecordCodec();

  test('encode then decode round-trips the contract', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    expect(encoded.meta.module, 'qizhengsiyu');
    expect(encoded.meta.scopeUid, 's1');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'qi_zheng');

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

  test('extractSearchTags emits divinationRequestInfoUuid', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('divination_request_info_uuid', 'req-123')));
  });

  test('uuidOf and withUuid operations', () {
    final r = _rec();
    expect(codec.uuidOf(r), 'q1');
    final r2 = codec.withUuid(r, 'q2');
    expect(codec.uuidOf(r2), 'q2');
    expect(r2.divinationRequestInfoUuid, 'req-123');
  });
}
