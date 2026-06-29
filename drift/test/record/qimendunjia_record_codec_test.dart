import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/qimendunjia/qimen_record_codec.dart';
import 'package:flutter_test/flutter_test.dart';

QimenDivinationRecordContract _rec({String uuid = 'qm1', String juType = 't1', int juNumber = 1}) => QimenDivinationRecordContract(
      uuid: uuid,
      question: 'q',
      datetimeJson: '{}',
      juType: juType,
      juNumber: juNumber,
      paiPanJson: '{}',
      shiJiJson: '{}',
      yueJiangJson: '{}',
      paramsJson: '{}',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

void main() {
  final codec = QimenRecordCodec();

  test('encode then decode round-trips the contract', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    expect(encoded.meta.module, 'qimendunjia');
    expect(encoded.meta.scopeUid, 's1');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'qi_men');

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

  test('extractSearchTags emits juType and juNumber', () {
    final encoded = codec.encode(_rec(juType: 'yang', juNumber: 5), scopeUid: 's1');
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('ju_type', 'yang')));
    expect(tags, contains(const SearchTag('ju_number', '5')));
  });

  test('uuidOf and withUuid operations', () {
    final r = _rec();
    expect(codec.uuidOf(r), 'qm1');
    final r2 = codec.withUuid(r, 'qm2');
    expect(codec.uuidOf(r2), 'qm2');
    expect(r2.juType, 't1');
  });
}
